file_installed <- system.file('data', 'frs.rda', package = 'pendata')
cat('installed frs.rda path:', file_installed, '\n')
if (file_installed != '') {
  load(file_installed)
  cat('Installed frs top-level:', paste(names(frs), collapse = ', '), '\n')
  cat(
    'Installed params_env class:',
    paste(class(frs$params_env), collapse = ','),
    '\n'
  )
  cat('Installed params_env length:', length(frs$params_env), '\n')
  cat(
    'Installed params_env head:',
    paste(head(names(frs$params_env), 20), collapse = ', '),
    '\n'
  )
} else {
  cat('frs.rda not found in installed package data folder\n')
}

# Local data
load('d:/cursor/pendata/data/frs.rda')
cat('Local frs top-level:', paste(names(frs), collapse = ', '), '\n')
cat(
  'Local params_env class:',
  paste(class(frs$params_env), collapse = ','),
  '\n'
)
cat('Local params_env length:', length(frs$params_env), '\n')
cat(
  'Local params_env head:',
  paste(head(names(frs$params_env), 20), collapse = ', '),
  '\n'
)

# Compare names
if (file_installed != '') {
  installed_names <- names(frs)
  load('d:/cursor/pendata/data/frs.rda')
  local_names <- names(frs)
  cat(
    '\nsetdiff(local top-level, installed top-level):',
    paste(setdiff(local_names, installed_names), collapse = ', '),
    '\n'
  )
}
