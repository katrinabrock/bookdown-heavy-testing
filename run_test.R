options(install.packages.compile.from.source = "always")
Sys.setenv(OPENSSL_CONF = '/dev/null') # https://stackoverflow.com/a/72679175/
books_to_test <- unlist(yaml::yaml.load_file('books-to-test.yml'))
invisible(lapply(c('main', 'test'), function(scenario) {
  env_dir <- paste0('env-', scenario)
  if(dir.exists(env_dir)) unlink(env_dir, recursive = TRUE)
  R.utils::copyDirectory('env-base', env_dir, recursive = TRUE)
  renv::load(env_dir)
  devtools::install(paste0('in-bookdown-', scenario))
  sapply(names(books_to_test), function(book) {
    output_dir <- file.path(getwd(), paste0('out-', scenario), book)
    dir.create(output_dir, recursive = TRUE)
    bookdown::render_book(
      input = file.path(paste0('in-', book), books_to_test[[book]]),
      output_dir = output_dir
    )
  })
}))

q(status =system2('diff',  c('-r', 'main-out/', 'test-out/')))