#' Generate a cellpal colour palette
#'
#' Generate categorical or continuous palettes for single-cell,
#' transcriptomic, and general ggplot2 visualizations.
#'
#' @param palette Character or unquoted palette name.
#' @param n Number of colours to return. By default, returns the original
#'   palette length.
#' @param type Palette mode: `"discrete"` or `"continuous"`.
#' @param reverse Logical. Reverse the palette.
#' @param alpha Numeric transparency between 0 and 1.
#' @param direction Integer, either `1` or `-1`. A value of `-1` reverses the
#'   palette. This is an alternative to `reverse`.
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
    alpha = 1,
    direction = 1
) {
  type <- match.arg(type)
  
  palette_name <- .resolve_cellpal_name(
    substitute(palette),
    parent.frame()
  )
  
  palette_name <- .validate_palette_name(palette_name)
  direction <- .validate_direction(direction)
  reverse <- .validate_flag(reverse, "reverse")
  alpha <- .validate_unit_amount(
    alpha,
    argument = "alpha",
    lower = 0,
    upper = 1
  )
  
  colours <- .get_cellpal_palette(palette_name)
  
  if (is.null(n)) {
    n <- length(colours)
  }
  
  n <- .validate_positive_integer(n, "n")
  
  should_reverse <- xor(
    reverse,
    direction == -1L
  )
  
  if (should_reverse) {
    colours <- rev(colours)
  }
  
  colours <- if (identical(type, "continuous")) {
    .interpolate_palette(colours, n)
  } else {
    .generate_discrete_palette(colours, n)
  }
  
  if (alpha < 1) {
    colours <- grDevices::adjustcolor(
      colours,
      alpha.f = alpha
    )
  }
  
  .new_cellpal(
    colours,
    palette = palette_name,
    type = .get_cellpal_palette_type(palette_name),
    mode = type
  )
}


.interpolate_palette <- function(
    colours,
    n
) {
  if (n == 1L) {
    return(colours[[1L]])
  }
  
  grDevices::colorRampPalette(
    colours,
    space = "Lab"
  )(n)
}


.generate_discrete_palette <- function(
    colours,
    n
) {
  if (n <= length(colours)) {
    return(colours[seq_len(n)])
  }
  
  candidates_n <- max(
    256L,
    n * 20L
  )
  
  candidates <- grDevices::colorRampPalette(
    colours,
    space = "Lab"
  )(candidates_n)
  
  candidates <- unique(
    toupper(candidates)
  )
  
  rgb <- grDevices::col2rgb(candidates) / 255
  
  keep <- apply(
    rgb,
    2L,
    function(channel) {
      max(channel) - min(channel) > 0.08
    }
  )
  
  candidates <- candidates[keep]
  
  if (length(candidates) < n) {
    warning(
      "Could not generate enough visually distinct colours; ",
      "using standard interpolation.",
      call. = FALSE
    )
    
    return(
      grDevices::colorRampPalette(
        colours,
        space = "Lab"
      )(n)
    )
  }
  
  indexes <- round(
    seq(
      from = 1,
      to = length(candidates),
      length.out = n
    )
  )
  
  indexes <- unique(indexes)
  
  if (length(indexes) < n) {
    indexes <- seq_len(n)
  }
  
  candidates[indexes[seq_len(n)]]
}