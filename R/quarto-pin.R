# R/quarto-pin.R  (repo root)
suppressWarnings(suppressMessages({
  have_here <- requireNamespace("here", quietly = TRUE)
  have_rprojroot <- requireNamespace("rprojroot", quietly = TRUE)
  have_rsapi <- requireNamespace("rstudioapi", quietly = TRUE)
  have_knitr <- requireNamespace("knitr", quietly = TRUE)
}))

quarto_root <- function(start = NULL, pin_here = TRUE, verbose = FALSE) {
  stopifnot(have_rprojroot)
  path <- start

  if (
    is.null(path) &&
      have_rsapi &&
      isTRUE(rstudioapi::hasFun("getActiveDocumentContext"))
  ) {
    ctx <- tryCatch(
      rstudioapi::getActiveDocumentContext(),
      error = function(e) NULL
    )
    if (!is.null(ctx) && nzchar(ctx$path)) path <- ctx$path
  }
  if (is.null(path) && have_knitr) {
    ki <- tryCatch(knitr::current_input(), error = function(e) NULL)
    if (!is.null(ki) && nzchar(ki)) path <- ki
  }
  if (is.null(path)) {
    qp <- Sys.getenv("QUARTO_PROJECT_ROOT", "")
    if (nzchar(qp)) path <- qp
  }
  if (is.null(path)) {
    path <- getwd()
  }

  start_dir <- if (dir.exists(path)) path else dirname(path)
  root <- tryCatch(
    rprojroot::find_root(
      rprojroot::has_file("_quarto.yml") | rprojroot::has_file("_quarto.yaml"),
      path = start_dir
    ),
    error = function(e) NULL
  )
  if (is.null(root)) {
    return(NULL)
  }

  root <- normalizePath(root, winslash = "/", mustWork = TRUE)

  if (isTRUE(pin_here) && have_here) {
    owd <- getwd()
    on.exit(setwd(owd), add = TRUE)
    setwd(root) # i_am() wants a relative path
    here::i_am(
      if (file.exists("_quarto.yml")) "_quarto.yml" else "_quarto.yaml"
    )
  }

  if (isTRUE(verbose)) {
    message(
      "Quarto root: ",
      root,
      if (pin_here && have_here) " (here pinned)" else ""
    )
  }
  root
}

# Optional interactive-only convenience:
pin_quarto_here <- function(verbose = TRUE) {
  quarto_root(pin_here = TRUE, verbose = verbose)
}
