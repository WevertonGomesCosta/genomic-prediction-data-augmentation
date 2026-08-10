# Shared functions for the genomic prediction + data augmentation workflow.

assert_file <- function(path) {
  if (!file.exists(path)) {
    stop("Required file not found: ", path, call. = FALSE)
  }
  invisible(path)
}

build_global_G <- function(M) {
  p <- colMeans(M) / 2
  Z <- sweep(M, 2, 2 * p)
  denom <- 2 * sum(p * (1 - p))
  G <- tcrossprod(Z) / denom
  diag(G) <- diag(G) + 1e-6
  list(p = p, Z = Z, G = G, denom = denom)
}

prepare_data_objects <- function(
  data_file = "data/dados_gblup.csv",
  output_file = "output/01_data_objects.rds",
  audit_file = "results/01_data_audit.csv"
) {
  if (file.exists(output_file)) {
    cat("Core prerequisite 1/3: loading existing data objects.\n")
    return(readRDS(output_file))
  }

  cat("Core prerequisite 1/3: creating data objects.\n")
  assert_file(data_file)

  df_R <- read.csv(data_file, check.names = FALSE)
  stopifnot(nrow(df_R) > 1)
  stopifnot(sum(colnames(df_R) == "yield") == 1)
  stopifnot(sum(duplicated(colnames(df_R))) == 0)

  marker_names <- setdiff(colnames(df_R), "yield")
  pattern_snp <- "^Gm[0-9]{2}_[0-9]+_[ACGT]_[ACGT]$"
  stopifnot(all(grepl(pattern_snp, marker_names)))

  is_numeric <- vapply(
    df_R[, marker_names, drop = FALSE],
    function(x) is.numeric(x) || is.integer(x),
    logical(1)
  )
  stopifnot(all(is_numeric))

  valid_code <- vapply(
    df_R[, marker_names, drop = FALSE],
    function(x) all(is.na(x) | x %in% c(0, 1, 2)),
    logical(1)
  )
  stopifnot(all(valid_code))

  M <- as.matrix(df_R[, marker_names, drop = FALSE])
  storage.mode(M) <- "numeric"
  y <- as.numeric(df_R$yield)

  stopifnot(!anyNA(M))
  stopifnot(!anyNA(y))
  stopifnot(all(vapply(
    seq_len(ncol(M)),
    function(j) length(unique(M[, j])) > 1,
    logical(1)
  )))
  stopifnot(sum(duplicated(df_R)) == 0)
  stopifnot(sum(duplicated(as.data.frame(M))) == 0)

  data_objects <- list(
    df_R = df_R,
    y = y,
    M = M,
    n = nrow(M),
    m = ncol(M),
    marker_names = marker_names
  )

  stopifnot(data_objects$n == 1379)
  stopifnot(data_objects$m == 4325)

  dir.create(dirname(output_file), showWarnings = FALSE, recursive = TRUE)
  dir.create(dirname(audit_file), showWarnings = FALSE, recursive = TRUE)
  saveRDS(data_objects, output_file)

  audit <- data.frame(
    individuos = nrow(M),
    snps = ncol(M),
    yield_na = sum(is.na(y)),
    snp_na = sum(is.na(M)),
    duplicate_rows = sum(duplicated(df_R)),
    duplicate_genomic_profiles = sum(duplicated(as.data.frame(M)))
  )
  write.csv(audit, audit_file, row.names = FALSE)

  data_objects
}

prepare_nested_splits <- function(
  data_objects,
  output_file = "output/02_splits_mestre_30rep.rds",
  summary_file = "results/02_splits_summary.csv",
  prop_validation = 0.20,
  proportions = c(0.25, 0.50, 0.75, 1.00),
  n_rep = 30
) {
  if (file.exists(output_file)) {
    cat("Core prerequisite 2/3: loading existing nested splits.\n")
    return(readRDS(output_file))
  }

  cat("Core prerequisite 2/3: creating nested splits.\n")
  n <- data_objects$n
  seeds_rep <- 101 * seq_len(n_rep)
  n_validation <- round(n * prop_validation)

  splits_mestre <- setNames(
    lapply(proportions, function(x) vector("list", n_rep)),
    as.character(proportions)
  )

  for (v in seq_len(n_rep)) {
    set.seed(seeds_rep[v])

    valid <- sort(sample(seq_len(n), n_validation, replace = FALSE))
    pool <- setdiff(seq_len(n), valid)
    perm <- sample(pool, length(pool), replace = FALSE)

    sizes <- c(
      floor(0.25 * length(pool)),
      floor(0.50 * length(pool)),
      floor(0.75 * length(pool)),
      length(pool)
    )

    for (i in seq_along(proportions)) {
      prop <- proportions[i]
      train <- sort(perm[seq_len(sizes[i])])
      splits_mestre[[as.character(prop)]][[v]] <- list(
        treino = train,
        valid = valid,
        pool = sort(pool),
        seed = seeds_rep[v]
      )
    }
  }

  for (v in seq_len(n_rep)) {
    t25 <- splits_mestre[["0.25"]][[v]]$treino
    t50 <- splits_mestre[["0.5"]][[v]]$treino
    t75 <- splits_mestre[["0.75"]][[v]]$treino
    t100 <- splits_mestre[["1"]][[v]]$treino
    valid <- splits_mestre[["1"]][[v]]$valid

    stopifnot(all(t25 %in% t50))
    stopifnot(all(t50 %in% t75))
    stopifnot(all(t75 %in% t100))
    stopifnot(length(intersect(t100, valid)) == 0)
    stopifnot(length(valid) == 276)
    stopifnot(length(t25) == 275)
    stopifnot(length(t50) == 551)
    stopifnot(length(t75) == 827)
    stopifnot(length(t100) == 1103)
  }

  dir.create(dirname(output_file), showWarnings = FALSE, recursive = TRUE)
  dir.create(dirname(summary_file), showWarnings = FALSE, recursive = TRUE)
  saveRDS(splits_mestre, output_file)

  summary_splits <- do.call(rbind, lapply(seq_len(n_rep), function(v) {
    do.call(rbind, lapply(proportions, function(p) {
      s <- splits_mestre[[as.character(p)]][[v]]
      data.frame(
        repeticao = v,
        proporcao_pool = p,
        n_treino = length(s$treino),
        n_validacao = length(s$valid),
        n_pool = length(s$pool),
        seed = s$seed
      )
    }))
  }))
  write.csv(summary_splits, summary_file, row.names = FALSE)

  splits_mestre
}

prepare_genomic_objects <- function(
  data_objects,
  output_file = "output/03_genomic_objects.rds"
) {
  if (file.exists(output_file)) {
    cat("Core prerequisite 3/3: loading existing genomic objects.\n")
    return(readRDS(output_file))
  }

  cat("Core prerequisite 3/3: creating the global genomic matrix.\n")
  gobj <- build_global_G(data_objects$M)

  stopifnot(max(abs(gobj$G - t(gobj$G))) < 1e-10)
  stopifnot(all(is.finite(gobj$G)))
  stopifnot(nrow(gobj$G) == 1379)
  stopifnot(ncol(gobj$G) == 1379)

  dir.create(dirname(output_file), showWarnings = FALSE, recursive = TRUE)
  saveRDS(gobj, output_file)
  gobj
}

ensure_core_objects <- function(
  data_file = "data/dados_gblup.csv"
) {
  dir.create("output", showWarnings = FALSE, recursive = TRUE)
  dir.create("results", showWarnings = FALSE, recursive = TRUE)

  obj <- prepare_data_objects(data_file = data_file)
  splits_mestre <- prepare_nested_splits(data_objects = obj)
  gobj <- prepare_genomic_objects(data_objects = obj)

  cat("Core prerequisites ready.\n")
  list(
    obj = obj,
    splits_mestre = splits_mestre,
    gobj = gobj
  )
}

prediction_metrics <- function(observed, predicted) {
  stopifnot(length(observed) == length(predicted))
  stopifnot(!anyNA(predicted), all(is.finite(predicted)))
  fit_cal <- lm(observed ~ predicted)
  data.frame(
    correlacao = cor(observed, predicted),
    RMSE = sqrt(mean((observed - predicted)^2)),
    MAE = mean(abs(observed - predicted)),
    slope_calibracao = unname(coef(fit_cal)[2])
  )
}

fit_gblup <- function(y, G, train_index, valid_index,
                      nIter = 10000, burnIn = 5000, seed = NULL) {
  if (!requireNamespace("BGLR", quietly = TRUE)) {
    stop("Install package 'BGLR' before fitting models.", call. = FALSE)
  }
  if (!is.null(seed)) set.seed(seed)

  y_na <- rep(NA_real_, length(y))
  y_na[train_index] <- y[train_index]

  stopifnot(all(is.na(y_na[setdiff(seq_along(y), train_index)])))
  stopifnot(length(intersect(train_index, valid_index)) == 0)

  fit <- BGLR::BGLR(
    y = y_na,
    ETA = list(list(K = G, model = "RKHS")),
    nIter = nIter,
    burnIn = burnIn,
    verbose = FALSE
  )

  pred <- fit$yHat[valid_index]
  prediction_metrics(y[valid_index], pred)
}

generate_mixup <- function(M_train, y_train, n_synthetic,
                           type = c("fixed", "beta"), alpha = NA_real_) {
  type <- match.arg(type)
  n_train <- nrow(M_train)
  stopifnot(n_train >= 2, length(y_train) == n_train, n_synthetic >= 1)

  idx1 <- sample(seq_len(n_train), n_synthetic, replace = TRUE)
  idx2_base <- sample(seq_len(n_train - 1), n_synthetic, replace = TRUE)
  idx2 <- ifelse(idx2_base >= idx1, idx2_base + 1L, idx2_base)
  stopifnot(all(idx1 != idx2))

  if (type == "fixed") {
    lambda <- rep(0.5, n_synthetic)
  } else {
    stopifnot(is.finite(alpha), alpha > 0)
    lambda <- rbeta(n_synthetic, shape1 = alpha, shape2 = alpha)
  }

  M_mix <- lambda * M_train[idx1, , drop = FALSE] +
    (1 - lambda) * M_train[idx2, , drop = FALSE]
  y_mix <- lambda * y_train[idx1] + (1 - lambda) * y_train[idx2]

  list(M_mix = M_mix, y_mix = y_mix, idx1 = idx1, idx2 = idx2, lambda = lambda)
}

fit_gblup_da <- function(y, M, G, Z, p, denom,
                         train_index, valid_index,
                         n_synthetic, type, alpha = NA_real_,
                         nIter = 10000, burnIn = 5000,
                         seed_da = NULL, seed_bglr = NULL) {
  if (!requireNamespace("BGLR", quietly = TRUE)) {
    stop("Install package 'BGLR' before fitting models.", call. = FALSE)
  }

  M_train <- M[train_index, , drop = FALSE]
  y_train <- y[train_index]

  if (!is.null(seed_da)) set.seed(seed_da)
  mix <- generate_mixup(M_train, y_train, n_synthetic, type, alpha)

  n <- nrow(M)
  n_total <- n + n_synthetic
  idx_syn <- (n + 1):(n + n_synthetic)

  G_expanded <- matrix(0, n_total, n_total)
  G_expanded[seq_len(n), seq_len(n)] <- G

  Z_mix <- sweep(mix$M_mix, 2, 2 * p)
  G_mix_real <- tcrossprod(Z_mix, Z) / denom
  G_mix_mix <- tcrossprod(Z_mix) / denom

  G_expanded[idx_syn, seq_len(n)] <- G_mix_real
  G_expanded[seq_len(n), idx_syn] <- t(G_mix_real)
  G_expanded[idx_syn, idx_syn] <- G_mix_mix
  G_expanded[cbind(idx_syn, idx_syn)] <-
    G_expanded[cbind(idx_syn, idx_syn)] + 1e-6

  stopifnot(max(abs(G_expanded - t(G_expanded))) < 1e-8)
  stopifnot(max(abs(G_expanded[seq_len(n), seq_len(n)] - G)) < 1e-12)

  y_da <- rep(NA_real_, n_total)
  y_da[train_index] <- y_train
  y_da[idx_syn] <- mix$y_mix

  real_outside_train <- setdiff(seq_len(n), train_index)
  stopifnot(all(is.na(y_da[valid_index])))
  stopifnot(all(is.na(y_da[real_outside_train])))
  stopifnot(sum(!is.na(y_da)) == length(train_index) + n_synthetic)

  if (!is.null(seed_bglr)) set.seed(seed_bglr)
  fit <- BGLR::BGLR(
    y = y_da,
    ETA = list(list(K = G_expanded, model = "RKHS")),
    nIter = nIter,
    burnIn = burnIn,
    verbose = FALSE
  )

  pred <- fit$yHat[valid_index]
  metrics <- prediction_metrics(y[valid_index], pred)
  cbind(
    metrics,
    media_lambda = mean(mix$lambda),
    sd_lambda = sd(mix$lambda)
  )
}

tost_nb <- function(d, delta = 0.05, alpha = 0.05,
                    n_resamples = 30, n_train = 1103, n_test = 276) {
  d <- as.numeric(d)
  media <- mean(d)
  sd_d <- sd(d)
  factor_nb <- 1 / n_resamples + n_test / n_train
  se <- sqrt(factor_nb * sd_d^2)
  gl <- length(d) - 1

  p_inf <- 1 - pt((media + delta) / se, df = gl)
  p_sup <- pt((media - delta) / se, df = gl)
  tc <- qt(1 - alpha, df = gl)
  ic_inf <- media - tc * se
  ic_sup <- media + tc * se

  data.frame(
    media_delta_cor = media,
    sd_delta_cor = sd_d,
    se_NB = se,
    ic90_inf = ic_inf,
    ic90_sup = ic_sup,
    p_inferior = p_inf,
    p_superior = p_sup,
    p_TOST = max(p_inf, p_sup),
    equivalente = (
      p_inf < alpha && p_sup < alpha &&
      ic_inf > -delta && ic_sup < delta
    )
  )
}
