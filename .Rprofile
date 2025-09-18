# .Rprofile at repo root (optional convenience)
try(source("R/quarto-pin.R"), silent = TRUE)

# (Optional) Auto-pin when you focus a file in the IDE
if (exists("pin_quarto_here", mode = "function")) {
  .qr_last <- NULL
  .qr_callback <- function(expr, value, ok, visible) {
    path <- NULL
    if (
      requireNamespace("rstudioapi", quietly = TRUE) &&
        isTRUE(rstudioapi::hasFun("getActiveDocumentContext"))
    ) {
      ctx <- tryCatch(
        rstudioapi::getActiveDocumentContext(),
        error = function(e) NULL
      )
      if (!is.null(ctx) && nzchar(ctx$path)) path <- ctx$path
    }
    if (!is.null(path) && !identical(path, .qr_last)) {
      .qr_last <<- path
      try(pin_quarto_here(FALSE), silent = TRUE)
    }
    TRUE
  }
  try(addTaskCallback(.qr_callback, name = "quarto-pin-here"), silent = TRUE)
  try(pin_quarto_here(FALSE), silent = TRUE) # one-shot at startup
}
