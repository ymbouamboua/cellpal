#' Discrete cellpal colour scales
#'
#' @param palette Name of a cellpal palette.
#' @param reverse Logical. Reverse the palette.
#' @param direction Either `1` or `-1`.
#' @param ... Additional arguments passed to ggplot2.
#'
#' @return A ggplot2 scale.
#'
#' @export
scale_colour_cellpal_d <- function(
    palette = "nature",
    reverse = FALSE,
    direction = 1,
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
        reverse = reverse,
        direction = direction
      )
    },
    ...
  )
}


#' @rdname scale_colour_cellpal_d
#' @export
scale_color_cellpal_d <- scale_colour_cellpal_d


#' @rdname scale_colour_cellpal_d
#' @export
scale_fill_cellpal_d <- function(
    palette = "nature",
    reverse = FALSE,
    direction = 1,
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
        reverse = reverse,
        direction = direction
      )
    },
    ...
  )
}


#' Continuous cellpal colour scales
#'
#' @inheritParams scale_colour_cellpal_d
#'
#' @return A ggplot2 scale.
#'
#' @export
scale_colour_cellpal_c <- function(
    palette = "viridis",
    reverse = FALSE,
    direction = 1,
    ...
) {
  colours <- cellpal(
    palette = palette,
    n = 256,
    type = "continuous",
    reverse = reverse,
    direction = direction
  )

  ggplot2::continuous_scale(
    aesthetics = "colour",
    scale_name = "cellpal",
    palette = scales::gradient_n_pal(colours),
    ...
  )
}


#' @rdname scale_colour_cellpal_c
#' @export
scale_color_cellpal_c <- scale_colour_cellpal_c


#' @rdname scale_colour_cellpal_c
#' @export
scale_fill_cellpal_c <- function(
    palette = "viridis",
    reverse = FALSE,
    direction = 1,
    ...
) {
  colours <- cellpal(
    palette = palette,
    n = 256,
    type = "continuous",
    reverse = reverse,
    direction = direction
  )

  ggplot2::continuous_scale(
    aesthetics = "fill",
    scale_name = "cellpal",
    palette = scales::gradient_n_pal(colours),
    ...
  )
}
