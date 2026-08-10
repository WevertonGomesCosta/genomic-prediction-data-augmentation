required_packages <- c("workflowr", "BGLR")
missing <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing) > 0) {
  install.packages(missing)
}
