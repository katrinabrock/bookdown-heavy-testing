options(install.packages.compile.from.source = "always")
Sys.setenv(OPENSSL_CONF = '/dev/null') # https://stackoverflow.com/a/72679175/
source('R/parse-diff.R')

base_env_dir <- '/root/env-base'
renv::load(base_env_dir)
renv::restore(base_env_dir)
renv::deactivate()

books_to_test <- unlist(yaml::yaml.load_file('books-to-test.yml'))
invisible(lapply(c('main', 'test'), function(scenario) {
  env_dir <- paste0('env-', scenario)
  if(dir.exists(env_dir)) unlink(env_dir, recursive = TRUE)
  R.utils::copyDirectory(base_env_dir, env_dir, recursive = TRUE)
  renv::load(env_dir)
  renv::restore(env_dir)
  # Load all the packages at the start so sessionInfo() is consistent accross runs
  lapply(names(renv::lockfile_read()$Packages), library, character.only=TRUE, quiet=TRUE)
  devtools::install(paste0('in-bookdown-', scenario))
  sapply(names(books_to_test), function(book) {
    input_dir <- file.path(paste0('in-', book), books_to_test[[book]])
    output_dir <- file.path(getwd(), paste0('out-', scenario), book)
    if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)
    bookdown::render_book(
      input = input_dir,
      output_dir = output_dir
    )
    unlink(bookdown:::files_cache_dirs(input_dir), recursive = TRUE)
  })
  renv::deactivate()
}))

diffs <- dir_diff('out-main/', 'out-test/', 'exceptions.yml')
diff_txt <- diff_lines(diffs)

cat(diff_txt)
cat(diff_txt, file = 'results.txt')
cat(diff_lines(diffs, TRUE), file = 'full_results.txt')

if (!interactive()) q(status = length(diff_txt))
