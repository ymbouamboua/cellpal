#' Metadata for Built-in cellpal Palettes
#'
#' Metadata describing the built-in palettes provided by \pkg{cellpal}.
#'
#' @format A data frame with the following columns:
#' \describe{
#'   \item{name}{Palette name.}
#'   \item{type}{Palette type: categorical, sequential, or diverging.}
#'   \item{recommended_max}{Recommended maximum number of discrete colours.}
#'   \item{description}{Short description of the palette.}
#' }
#'
#' @export
cellpal_info <- data.frame(
  name = c(
    "base",
    "nature",
    "nejm",
    "lancet",
    "jama",
    "tableau",
    "tol",
    "okabe_ito",
    "heatmap_blue_red",
    "heatmap_nature",
    "viridis"
  ),
  type = c(
    "categorical",
    "categorical",
    "categorical",
    "categorical",
    "categorical",
    "categorical",
    "categorical",
    "categorical",
    "diverging",
    "diverging",
    "sequential"
  ),
  recommended_max = c(
    36L,
    5L,
    5L,
    5L,
    5L,
    18L,
    11L,
    8L,
    NA_integer_,
    NA_integer_,
    NA_integer_
  ),
  description = c(
    "Extended categorical palette for large cell-type collections.",
    "Journal-inspired categorical palette.",
    "NEJM-inspired categorical palette.",
    "Lancet-inspired categorical palette.",
    "JAMA-inspired categorical palette.",
    "Tableau-style categorical palette.",
    "Paul Tol-inspired categorical palette.",
    "Colour-vision-friendly categorical palette.",
    "Blue-white-red diverging palette.",
    "Nature-style blue-white-red diverging palette.",
    "Viridis-style sequential palette."
  ),
  stringsAsFactors = FALSE
)


#' Retrieve Information about a cellpal Palette
#'
#' @param palette Character string naming a registered palette.
#'
#' @return An object of class `"cellpal_palette_info"`.
#'
#' @examples
#' cellpal_palette_info("nature")
#'
#' @export
cellpal_palette_info <- function(
    palette
) {
  palette <- .validate_palette_name(palette)

  colours <- .get_cellpal_palette(palette)
  palette_type <- .get_cellpal_palette_type(palette)
  source <- .get_cellpal_palette_source(palette)

  metadata <- cellpal_info[
    cellpal_info$name == palette,
    ,
    drop = FALSE
  ]

  if (!nrow(metadata)) {
    metadata <- NULL
  }

  structure(
    list(
      name = palette,
      colours = colours,
      n_colours = length(colours),
      type = palette_type,
      source = source,
      metadata = metadata
    ),
    class = "cellpal_palette_info"
  )
}

