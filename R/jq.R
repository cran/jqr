#' Execute a query with jq
#'
#' \code{jq} is meant to work with the high level interface in this package.
#' \code{jq} also provides access to the low level interface in which you can
#' use jq query strings just as you would on the command line. Output gets
#' class of json, and pretty prints to the console for easier viewing.
#' \code{jqr} doesn't do pretty printing.
#'
#' @export
#' @param x \code{json} object or character string with json data. this can
#' be one or more valid json objects
#' @param ... character specification of jq query. Each element in \code{...}
#'   will be combined with " | ", which is convenient for long queries.
#' @param flags See \code{\link{jq_flags}}
#' @seealso \code{\link{peek}}
#' @examples
#' '{"a": 7}' %>%  do(.a + 1)
#' '[8,3,null,6]' %>% sortj
#'
#' x <- '[{"message": "hello", "name": "jenn"},
#'   {"message": "world", "name": "beth"}]'
#' jq(index(x))
#'
#' jq('{"a": 7, "b": 4}', 'keys')
#' jq('[8,3,null,6]', 'sort')
#'
#' # many json inputs
#' jq(c("[123, 456]", "[77, 88, 99]", "[41]"), ".[]")
jq <- function(x, ...) {
  UseMethod("jq", x)
}

#' @rdname jq
#' @export
jq.jqr <- function(x, ...) {
  pipe_autoexec(toggle = FALSE)
  flags <- `if`(is.null(attr(x, "jq_flags")), jq_flags(), attr(x, "jq_flags"))
  res <- jqr(x$data, make_query(x), flags = flags)
  class(res) <- c("jqson", "character")
  query <- query_from_dots(...)
  if (query != "")
    jq(res, query)
  else
    res
}

#' @rdname jq
#' @export
jq.character <- function(x, ..., flags = jq_flags()) {
  query <- query_from_dots(...)
  structure(jqr(x, query, flags),
            class = c("jqson", "character"))
}

#' @rdname jq
#' @export
jq.json <- function(x, ..., flags = jq_flags()) {
  jq(unclass(x), ..., flags = flags)
}

#' @export
jq.default <- function(x, ...) {
  stop(sprintf("jq method not implemented for %s.", class(x)[1]))
}

#' @export
print.jqson <- function(x, ...) {
  cat(jsonlite::prettify(combine(x)))
}

#' Helper function for createing a jq query string from ellipses.
#' @noRd
query_from_dots <- function(...)
{
  dots <- list(...)
  if (!all(vapply(dots, is.character, logical(1))))
    stop("jq query specification must be character.")

  paste(unlist(dots), collapse = " | ")
}

#' @rdname jq
#' @param out a filename, callback function, connection object to stream output.
#' Set to `NULL` to buffer all output and return a character vector.
#' @export
#' @examples # Stream from connection
#' tmp <- tempfile()
#' writeLines(c("[123, 456]", "[77, 88, 99]", "[41]"), tmp)
#' jq(file(tmp), ".[]")
#'
#' \dontrun{
#' # from a url
#' x <- 'http://jeroen.github.io/data/diamonds.json'
#' jq(url(x), ".[]")
#'
#' # from a file
#' file <- file.path(tempdir(), "diamonds_nd.json")
#' download.file(x, destfile = file)
#' jq(file(file), ".carat")
#' jq(file(file), "select(.carat > 1.5)")
#' jq(file(file), 'select(.carat > 4 and .cut == "Fair")')
#' }
jq.connection <- function(x, ..., flags = jq_flags(), out = NULL) {
  query <- query_from_dots(...)
  res <- jqr.connection(x, query = query, flags = flags, out = out)
  if(!is.null(res))
    structure(res, class = c("jqson", "character"))
}
