#' Generate a cellpal colour palette
#'
#' Generate categorical or continuous palettes for single-cell,
#' transcriptomic, and general ggplot2 visualizations.
#'
#' @param palette Character or unquoted palette name.
#' @param n Number of colours to return. By default, returns the original
#'   palette length.
#' @param type Palette type: `"discrete"` or `"continuous"`.
#' @param reverse Logical. Reverse the palette.
#' @param alpha Numeric transparency between 0 and 1.
#' @param direction Integer, either 1 or -1. An alternative to `reverse`.
#'
#' @return A character vector of hexadecimal colours with class `"cellpal"`.
#'
#' @examples
#' cellpal(nature)
#' cellpal("jama", n = 3)
#' cellpal(base, n = 20)
#' cellpal(heatmap_nature, n = 100, type = "continuous")
#'
#' @export
cellpal <- function(
    palette = "base",
    n = NULL,
    type = c("discrete", "continuous"),
    reverse = FALSE,
    alpha = 1
) {
  type <- match.arg(type)

  if (!is.character(palette) ||
      length(palette) != 1L ||
      is.na(palette) ||
      !nzchar(palette)) {
    stop(
      "`palette` must be a single non-empty character string.",
      call. = FALSE
    )
  }

  available_palettes <- cellpal_names()

  if (!palette %in% available_palettes) {
    stop(
      "Unknown palette '",
      palette,
      "'. Available palettes: ",
      paste(available_palettes, collapse = ", "),
      call. = FALSE
    )
  }

  colours <- .get_cellpal_palette(palette)

  if (is.null(n)) {
    n <- length(colours)
  }

  if (!is.numeric(n) ||
      length(n) != 1L ||
      is.na(n) ||
      n < 1 ||
      n != as.integer(n)) {
    stop(
      "`n` must be a single positive integer.",
      call. = FALSE
    )
  }

  n <- as.integer(n)

  if (isTRUE(reverse)) {
    colours <- rev(colours)
  }

  if (type == "continuous") {
    colours <- grDevices::colorRampPalette(colours)(n)
  } else if (n <= length(colours)) {
    colours <- colours[seq_len(n)]
  } else {
    colours <- grDevices::colorRampPalette(colours)(n)
  }

  if (!is.numeric(alpha) ||
      length(alpha) != 1L ||
      is.na(alpha) ||
      alpha < 0 ||
      alpha > 1) {
    stop(
      "`alpha` must be a number between 0 and 1.",
      call. = FALSE
    )
  }

  colours <- grDevices::adjustcolor(
    colours,
    alpha.f = alpha
  )

  structure(
    colours,
    class = c("cellpal", "character"),
    palette = palette,
    palette_type = .get_cellpal_palette_type(palette),
    mode = type
  )
}
