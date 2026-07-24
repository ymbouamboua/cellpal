# ============================================================
# Internal palette input resolver
# ============================================================

#' Resolve cellpal Input
#'
#' Internal helper that converts a palette name, a `cellpal` object, or a
#' character vector of colours into a validated `cellpal` object.
#'
#' @param expression Unevaluated palette expression.
#' @param environment Environment in which the expression should be evaluated.
#'
#' @return A `cellpal` object.
#'
#' @keywords internal
#' @noRd
.resolve_cellpal_input <- function(
    expression,
    environment
) {
  # Quoted palette name or direct colour vector
  if (is.character(expression)) {

    if (length(expression) == 1L &&
        .is_palette_name(expression)) {
      return(
        .new_cellpal(
          .get_cellpal_palette(expression),
          palette = expression,
          type = .get_cellpal_palette_type(expression)
        )
      )
    }

    return(
      .new_cellpal(
        .validate_colour_vector(expression),
        palette = "custom",
        type = NULL
      )
    )
  }

  # Unquoted palette name, for example:
  # cellpal_view(nature)
  if (is.name(expression)) {
    candidate <- as.character(expression)

    if (.is_palette_name(candidate)) {
      return(
        .new_cellpal(
          .get_cellpal_palette(candidate),
          palette = candidate,
          type = .get_cellpal_palette_type(candidate)
        )
      )
    }
  }

  # Evaluate variables:
  #
  # pal <- "nature"
  # cellpal_view(pal)
  #
  # cols <- c("#000000", "#FFFFFF")
  # cellpal_view(cols)
  value <- tryCatch(
    eval(
      expression,
      envir = environment
    ),
    error = function(error) {
      NULL
    }
  )

  if (inherits(value, "cellpal")) {
    return(value)
  }

  if (is.character(value) &&
      length(value) == 1L &&
      .is_palette_name(value)) {
    return(
      .new_cellpal(
        .get_cellpal_palette(value),
        palette = value,
        type = .get_cellpal_palette_type(value)
      )
    )
  }

  if (is.character(value) && length(value)) {
    return(
      .new_cellpal(
        .validate_colour_vector(value),
        palette = "custom",
        type = NULL
      )
    )
  }

  stop(
    "`palette` must be a registered palette name, a `cellpal` object, ",
    "or a character vector of valid R colours.",
    call. = FALSE
  )
}
