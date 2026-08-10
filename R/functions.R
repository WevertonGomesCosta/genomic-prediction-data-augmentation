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
  cbind(metrics,
        media_lambda = mean(mix$lambda),
        sd_lambda = sd(mix$lambda))
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
