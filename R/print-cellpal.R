#' Print a cellpal palette
#'
#' @param x A `cellpal` object.
#' @param ... Additional arguments.
#'
#' @return Invisibly returns `x`.
#'
#' @export
print.cellpal <- function(
    x,
    ...
) {
  palette_name <- attr(
    x,
    "palette",
    exact = TRUE
  ) %||% "custom"

  palette_type <- attr(
    x,
    "palette_type",
    exact = TRUE
  )

  mode <- attr(
    x,
    "mode",
    exact = TRUE
  )

  cat("<cellpal palette>\n")
  cat("Name:    ", palette_name, "\n", sep = "")
  cat("Type:    ", palette_type %||% "unknown", "\n", sep = "")
  cat("Mode:    ", mode %||% "unspecified", "\n", sep = "")
  cat("Colours: ", length(x), "\n", sep = "")

  formatted <- paste0(
    seq_along(x),
    ": ",
    unclass(x)
  )

  cat(
    paste(
      formatted,
      collapse = "\n"
    ),
    "\n"
  )

  invisible(x)
}
