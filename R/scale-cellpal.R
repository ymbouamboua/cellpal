#' cellpal colour scale for ggplot2
#'
#' @param palette Name of a cellpal palette.
#' @param reverse Logical. Reverse the palette.
#' @param ... Arguments passed to the ggplot2 scale.
#'
#' @return A ggplot2 scale.
#' @export
scale_colour_cellpal <- function(
    palette = "nature",
    reverse = FALSE,
    ...
) {
  ggplot2::discrete_scale(
    aesthetics = "colour",
    name = palette,
    palette = function(n) {
      cellpal(
        palette = palette,
        n = n,
        type = "discrete",
        reverse = reverse
      )
    },
    ...
  )
}

#' @rdname scale_colour_cellpal
#' @export
scale_color_cellpal <- scale_colour_cellpal

#' @rdname scale_colour_cellpal
#' @export
scale_fill_cellpal <- function(
    palette = "nature",
    reverse = FALSE,
    ...
) {
  ggplot2::discrete_scale(
    aesthetics = "fill",
    name = palette,
    palette = function(n) {
      cellpal(
        palette = palette,
        n = n,
        type = "discrete",
        reverse = reverse
      )
    },
    ...
  )
}


.cellpal_discrete <- function(cols, n) {
  if (n <= length(cols)) {
    return(cols[seq_len(n)])
  }

  candidates_n <- max(256L, n * 20L)

  candidates <- grDevices::colorRampPalette(
    cols,
    space = "Lab"
  )(candidates_n)

  candidates <- unique(toupper(candidates))

  rgb <- grDevices::col2rgb(candidates) / 255

  keep <- apply(rgb, 2L, function(x) {
    max(x) - min(x) > 0.08
  })

  candidates <- candidates[keep]

  if (length(candidates) < n) {
    warning(
      "Could not generate enough distinct colours after filtering.",
      call. = FALSE
    )

    candidates <- grDevices::colorRampPalette(cols)(n)
    return(candidates)
  }

  idx <- unique(round(seq(
    from = 1,
    to = length(candidates),
    length.out = n
  )))

  candidates[idx][seq_len(n)]
}

