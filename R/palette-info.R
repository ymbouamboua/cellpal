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

