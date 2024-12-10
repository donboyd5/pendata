.onLoad <- function(libname, pkgname) {
  delayedAssign("frs",
                load_frs_data(),  # returns a list
                assign.env = parent.env(environment()))
}
