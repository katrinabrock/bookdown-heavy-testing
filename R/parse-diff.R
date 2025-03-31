# Somewhat Guided by

parse_diff <- function(diff_lines) {
  diffs <- list()
  diff <- NULL
  for(line in diff_lines) {
    if(startsWith(line, 'diff -u')) next
    if(startsWith(line, '--- ')) {
      diffs <- c(diffs, list(diff))
      diff <- list(
        from = strsplit(line, '\t')[[1]][1]
      )
    } else if (startsWith(line, '+++ ')) {
      diff[['to']] = strsplit(line, '\t')[[1]][1]
    } else if (startsWith(line, '@@') & endsWith(line, '@@')){
      diff[['line_numbers']] <- line
    } else {
      diff[['lines']] <- c(diff[['lines']], line)
    }
  }
  diffs <- c(diffs[2:length(diffs)], list(diff))
  diffs
}

write_diffs <- function(diffs, filename){
  yaml::write_yaml(lapply(diffs, `[`, 1:3), filename)
}

run_diff_cmd <- function(from, to){
  system2('diff', c('-ur', from, to), stdout = TRUE)
}


dir_diff <- function(from, to, exceptions_file){
  diffs <- parse_diff(run_diff_cmd(from, to))
  diffs[!lapply(diffs, `[`, 1:3) %in% yaml::yaml.load_file(exceptions_file)]
}

diff_lines <- function(diffs, include.lines = FALSE) {
  if(!include.lines) diffs <- lapply(diffs, `[`, 1:3)
  do.call(
    paste,
    c(
      lapply(diffs, paste, collapse = '\n'), 
      list(sep = '\n')
    )
  )
}

