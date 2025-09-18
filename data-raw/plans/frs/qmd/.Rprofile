# qmd/.Rprofile (project-local; runs during render)
src <- file.path("..", "..", "..", "..", "R", "quarto-pin.R") # adjust if your depth differs
if (file.exists(src)) {
  source(src)
}
if (exists("quarto_root", mode = "function")) {
  quarto_root(pin_here = TRUE, verbose = FALSE)
}
