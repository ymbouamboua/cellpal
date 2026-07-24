#' Print a cellpal palette
#'
#' @param x A cellpal object.
#' @param ... Additional arguments.
#'
#' @return Invisibly returns `x`.
#' @export
print.cellpal <- function(x, ...) {
  palette_name <- attr(x, "palette")

  cat(
    "<cellpal: ",
    palette_name,
    ">\n",
    sep = ""
  )

  cat(
    paste(
      seq_along(x),
      unclass(x),
      sep = ": "
    ),
    sep = "\n"
  )

  cat("\n")

  invisible(x)
}
