# ============================================================
# Palette adjustment functions
# ============================================================

#' Adjust Palette Lightness
#'
#' Lightens or darkens all colours or selected colours in a palette.
#'
#' @param palette Palette name, a `cellpal` object, or a character vector of
#'   valid R colours.
#' @param amount Numeric value between `-1` and `1`. Negative values darken
#'   colours and positive values lighten colours.
#' @param which Optional integer positions identifying colours to adjust.
#'
#' @return A character vector with class `"cellpal"`.
#'
#' @examples
#' cellpal_lightness("nature", amount = 0.2)
#' cellpal_lightness("nature", amount = -0.2, which = c(1, 3))
#'
#' @export
cellpal_lightness <- function(
    palette,
    amount = 0,
    which = NULL
) {
  .require_colorspace()

  cols <- .resolve_cellpal_input(
    substitute(palette),
    parent.frame()
  )

  amount <- .validate_unit_amount(
    amount,
    argument = "amount",
    lower = -1,
    upper = 1
  )

  positions <- .validate_colour_positions(
    which,
    length(cols)
  )

  out <- unclass(cols)

  if (amount < 0) {
    out[positions] <- colorspace::darken(
      out[positions],
      amount = abs(amount)
    )
  } else if (amount > 0) {
    out[positions] <- colorspace::lighten(
      out[positions],
      amount = amount
    )
  }

  .new_cellpal(
    out,
    palette = .modified_palette_name(
      cols,
      suffix = paste0(
        "_lightness_",
        format(amount, trim = TRUE)
      )
    ),
    type = attr(
      cols,
      "palette_type",
      exact = TRUE
    ),
    mode = attr(
      cols,
      "mode",
      exact = TRUE
    )
  )

}


#' Adjust Individual Palette Colours
#'
#' Applies a separate lightness adjustment to every colour.
#'
#' @param palette Palette name, `cellpal` object, or character colour vector.
#' @param adjustments Numeric vector of lightness adjustments between `-1`
#'   and `1`. Its length must equal the number of palette colours.
#'
#' @return A character vector with class `"cellpal"`.
#'
#' @examples
#' cellpal_adjust_each(
#'   "nature",
#'   adjustments = c(-0.2, 0, 0.1, 0.2, -0.1)
#' )
#'
#' @export
cellpal_adjust_each <- function(
    palette,
    adjustments
) {
  .require_colorspace()

  cols <- .resolve_cellpal_input(
    substitute(palette),
    parent.frame()
  )

  if (!is.numeric(adjustments) ||
      anyNA(adjustments)) {
    stop(
      "`adjustments` must be a numeric vector without missing values.",
      call. = FALSE
    )
  }

  if (length(adjustments) != length(cols)) {
    stop(
      "`adjustments` must have length ",
      length(cols),
      ", matching the palette length.",
      call. = FALSE
    )
  }

  if (any(adjustments < -1 | adjustments > 1)) {
    stop(
      "Every value in `adjustments` must be between -1 and 1.",
      call. = FALSE
    )
  }

  out <- unclass(cols)

  for (index in seq_along(out)) {
    amount <- adjustments[[index]]

    if (amount < 0) {
      out[[index]] <- colorspace::darken(
        out[[index]],
        amount = abs(amount)
      )
    } else if (amount > 0) {
      out[[index]] <- colorspace::lighten(
        out[[index]],
        amount = amount
      )
    }
  }

  .new_cellpal(
    out,
    palette = .modified_palette_name(
      cols,
      suffix = "_custom"
    )
  )
}


#' Adjust Palette Saturation
#'
#' Increases or decreases palette chroma in HCL colour space.
#'
#' @param palette Palette name, `cellpal` object, or character colour vector.
#' @param factor Numeric saturation multiplier. `1` preserves saturation,
#'   values below `1` reduce saturation, and values above `1` increase it.
#' @param which Optional integer positions identifying colours to modify.
#'
#' @return A character vector with class `"cellpal"`.
#'
#' @examples
#' cellpal_saturation("nature", factor = 0.5)
#' cellpal_saturation("nature", factor = 1.2)
#'
#' @export
cellpal_saturation <- function(
    palette,
    factor = 1,
    which = NULL
) {
  .require_colorspace()

  cols <- .resolve_cellpal_input(
    substitute(palette),
    parent.frame()
  )

  if (!is.numeric(factor) ||
      length(factor) != 1L ||
      is.na(factor) ||
      !is.finite(factor) ||
      factor < 0) {
    stop(
      "`factor` must be a single non-negative finite number.",
      call. = FALSE
    )
  }

  positions <- .validate_colour_positions(
    which,
    length(cols)
  )

  out <- unclass(cols)

  polar <- methods::as(
    colorspace::hex2RGB(out[positions]),
    "polarLUV"
  )

  coordinates <- colorspace::coords(polar)

  coordinates[, "C"] <- pmax(
    0,
    coordinates[, "C"] * factor
  )

  adjusted <- colorspace::polarLUV(
    L = coordinates[, "L"],
    C = coordinates[, "C"],
    H = coordinates[, "H"]
  )

  out[positions] <- colorspace::hex(
    adjusted,
    fixup = TRUE
  )

  .new_cellpal(
    out,
    palette = .modified_palette_name(
      cols,
      suffix = paste0(
        "_saturation_",
        format(factor, trim = TRUE)
      )
    )
  )
}


#' Desaturate Palette Colours
#'
#' @param palette Palette name, `cellpal` object, or character colour vector.
#' @param amount Numeric desaturation amount between `0` and `1`.
#' @param which Optional integer positions identifying colours to desaturate.
#'
#' @return A character vector with class `"cellpal"`.
#'
#' @examples
#' cellpal_desaturate("nature", amount = 0.5)
#'
#' @export
cellpal_desaturate <- function(
    palette,
    amount = 0.5,
    which = NULL
) {
  .require_colorspace()

  cols <- .resolve_cellpal_input(
    substitute(palette),
    parent.frame()
  )

  amount <- .validate_unit_amount(
    amount,
    argument = "amount",
    lower = 0,
    upper = 1
  )

  positions <- .validate_colour_positions(
    which,
    length(cols)
  )

  out <- unclass(cols)

  out[positions] <- colorspace::desaturate(
    out[positions],
    amount = amount
  )

  .new_cellpal(
    out,
    palette = .modified_palette_name(
      cols,
      suffix = paste0(
        "_desaturated_",
        format(amount, trim = TRUE)
      )
    )
  )
}


#' Set Palette Transparency
#'
#' @param palette Palette name, `cellpal` object, or character colour vector.
#' @param alpha Numeric transparency between `0` and `1`.
#' @param which Optional positions of colours to modify.
#'
#' @return A character vector with class `"cellpal"`.
#'
#' @examples
#' cellpal_alpha("nature", alpha = 0.5)
#'
#' @export
cellpal_alpha <- function(
    palette,
    alpha = 1,
    which = NULL
) {
  cols <- .resolve_cellpal_input(
    substitute(palette),
    parent.frame()
  )

  alpha <- .validate_unit_amount(
    alpha,
    argument = "alpha",
    lower = 0,
    upper = 1
  )

  positions <- .validate_colour_positions(
    which,
    length(cols)
  )

  out <- unclass(cols)

  out[positions] <- grDevices::adjustcolor(
    out[positions],
    alpha.f = alpha
  )

  .new_cellpal(
    out,
    palette = .modified_palette_name(
      cols,
      suffix = paste0(
        "_alpha_",
        format(alpha, trim = TRUE)
      )
    )
  )
}


