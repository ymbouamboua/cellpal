# ============================================================
# Palette accessibility
# ============================================================

#' Simulate Colour-Vision Deficiencies
#'
#' Simulates how a palette appears under deuteranopia, protanopia, and
#' tritanopia.
#'
#' @param palette Palette name, `cellpal` object, or colour vector.
#' @param severity Numeric simulation severity between `0` and `1`.
#'
#' @return A named list of colour vectors.
#'
#' @examples
#' cellpal_simulate_cvd("nature")
#'
#' @export
cellpal_simulate_cvd <- function(
    palette,
    severity = 1
) {
  .require_colorspace()

  cols <- .resolve_cellpal_input(
    substitute(palette),
    parent.frame()
  )

  severity <- .validate_unit_amount(
    severity,
    argument = "severity",
    lower = 0,
    upper = 1
  )

  list(
    Normal = unclass(cols),
    Deuteranopia = colorspace::deutan(
      cols,
      severity = severity
    ),
    Protanopia = colorspace::protan(
      cols,
      severity = severity
    ),
    Tritanopia = colorspace::tritan(
      cols,
      severity = severity
    )
  )
}


#' Preview a Palette under Colour-Vision Deficiencies
#'
#' @param palette Palette name, `cellpal` object, or colour vector.
#' @param severity Simulation severity between `0` and `1`.
#' @param labels Logical. Display hexadecimal colour labels.
#' @param label_size Numeric text size.
#'
#' @return A `ggplot2` object.
#'
#' @examples
#' \donttest{
#' cellpal_cvd("nature")
#' }
#'
#' @export
cellpal_cvd <- function(
    palette,
    severity = 1,
    labels = TRUE,
    label_size = 2.7
) {
  cols <- .resolve_cellpal_input(
    substitute(palette),
    parent.frame()
  )

  simulations <- cellpal_simulate_cvd(
    cols,
    severity = severity
  )

  vision_types <- names(simulations)
  number_of_colours <- length(cols)

  data <- data.frame(
    vision = factor(
      rep(
        vision_types,
        each = number_of_colours
      ),
      levels = rev(vision_types)
    ),
    colour_index = rep(
      seq_len(number_of_colours),
      times = length(simulations)
    ),
    colour = unlist(
      simulations,
      use.names = FALSE
    ),
    stringsAsFactors = FALSE
  )

  data$text_colour <- .cellpal_text_colour(
    data$colour
  )

  palette_name <- attr(
    cols,
    "palette",
    exact = TRUE
  )

  if (is.null(palette_name)) {
    palette_name <- "Custom palette"
  }

  plot <- ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = colour_index,
      y = vision,
      fill = colour
    )
  ) +
    ggplot2::geom_tile(
      colour = "white",
      linewidth = 0.8
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::coord_cartesian(
      expand = FALSE
    ) +
    ggplot2::labs(
      title = palette_name,
      subtitle = paste0(
        "Colour-vision-deficiency simulation; severity = ",
        severity
      ),
      x = NULL,
      y = NULL
    ) +
    ggplot2::theme_minimal(
      base_size = 11
    ) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(
        face = "bold"
      ),
      plot.subtitle = ggplot2::element_text(
        colour = "#666666"
      ),
      axis.text.x = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_text(
        hjust = 1
      ),
      axis.ticks = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      plot.margin = ggplot2::margin(
        12,
        14,
        12,
        12
      )
    )

  if (isTRUE(labels)) {
    plot <- plot +
      ggplot2::geom_text(
        ggplot2::aes(
          label = toupper(colour),
          colour = text_colour
        ),
        size = label_size,
        show.legend = FALSE
      ) +
      ggplot2::scale_colour_identity()
  }

  plot
}


#' Calculate Palette Contrast Ratios
#'
#' Calculates WCAG-style contrast ratios between each palette colour and one
#' or more background colours.
#'
#' @param palette Palette name, `cellpal` object, or colour vector.
#' @param background Character vector of background colours.
#'
#' @return A data frame containing contrast ratios.
#'
#' @examples
#' cellpal_contrast("nature")
#' cellpal_contrast("nature", background = c("white", "black"))
#'
#' @export
cellpal_contrast <- function(
    palette,
    background = c("#FFFFFF", "#000000")
) {
  cols <- .resolve_cellpal_input(
    substitute(palette),
    parent.frame()
  )

  background <- .validate_colour_vector(background)

  combinations <- expand.grid(
    colour_index = seq_along(cols),
    background_index = seq_along(background),
    KEEP.OUT.ATTRS = FALSE,
    stringsAsFactors = FALSE
  )

  combinations$colour <- cols[
    combinations$colour_index
  ]

  combinations$background <- background[
    combinations$background_index
  ]

  combinations$contrast_ratio <- mapply(
    .contrast_ratio,
    combinations$colour,
    combinations$background
  )

  combinations$aa_large <- combinations$contrast_ratio >= 3
  combinations$aa_normal <- combinations$contrast_ratio >= 4.5
  combinations$aaa_normal <- combinations$contrast_ratio >= 7

  combinations[
    ,
    c(
      "colour_index",
      "colour",
      "background",
      "contrast_ratio",
      "aa_large",
      "aa_normal",
      "aaa_normal"
    )
  ]
}


#' Calculate Pairwise Palette Distances
#'
#' Calculates pairwise Euclidean distances in CIELAB space.
#'
#' Larger values generally indicate more distinguishable colours.
#'
#' @param palette Palette name, `cellpal` object, or colour vector.
#'
#' @return A data frame containing pairwise distances.
#'
#' @examples
#' cellpal_distances("nature")
#'
#' @export
cellpal_distances <- function(
    palette
) {
  .require_colorspace()

  cols <- .resolve_cellpal_input(
    substitute(palette),
    parent.frame()
  )

  lab <- methods::as(
    colorspace::hex2RGB(cols),
    "LAB"
  )

  coordinates <- colorspace::coords(lab)

  distance_matrix <- as.matrix(
    stats::dist(coordinates)
  )

  indexes <- which(
    upper.tri(distance_matrix),
    arr.ind = TRUE
  )

  data.frame(
    colour_1_index = indexes[, 1],
    colour_2_index = indexes[, 2],
    colour_1 = cols[indexes[, 1]],
    colour_2 = cols[indexes[, 2]],
    distance = distance_matrix[indexes],
    stringsAsFactors = FALSE
  )
}


#' Generate a Palette Accessibility Report
#'
#' Summarises pairwise colour distance, contrast, and colour-vision-deficiency
#' distinguishability.
#'
#' @param palette Palette name, `cellpal` object, or colour vector.
#' @param severity Colour-vision-deficiency simulation severity.
#' @param minimum_distance Recommended minimum pairwise CIELAB distance.
#'
#' @return A list with class `"cellpal_accessibility"`.
#'
#' @examples
#' cellpal_accessibility("nature")
#'
#' @export
cellpal_accessibility <- function(
    palette,
    severity = 1,
    minimum_distance = 15
) {
  cols <- .resolve_cellpal_input(
    substitute(palette),
    parent.frame()
  )

  if (!is.numeric(minimum_distance) ||
      length(minimum_distance) != 1L ||
      is.na(minimum_distance) ||
      minimum_distance < 0) {
    stop(
      "`minimum_distance` must be a single non-negative number.",
      call. = FALSE
    )
  }

  simulations <- cellpal_simulate_cvd(
    cols,
    severity = severity
  )

  distance_summaries <- lapply(
    names(simulations),
    function(vision_type) {
      distances <- cellpal_distances(
        simulations[[vision_type]]
      )

      minimum_observed <- if (nrow(distances)) {
        min(
          distances$distance,
          na.rm = TRUE
        )
      } else {
        NA_real_
      }

      data.frame(
        vision = vision_type,
        minimum_distance = minimum_observed,
        passes = is.na(minimum_observed) ||
          minimum_observed >= minimum_distance,
        stringsAsFactors = FALSE
      )
    }
  )

  distance_summary <- do.call(
    rbind,
    distance_summaries
  )

  contrasts <- cellpal_contrast(
    cols,
    background = c(
      "#FFFFFF",
      "#000000"
    )
  )

  white_contrast <- contrasts[
    contrasts$background == "#FFFFFF",
    ,
    drop = FALSE
  ]

  black_contrast <- contrasts[
    contrasts$background == "#000000",
    ,
    drop = FALSE
  ]

  output <- list(
    palette = attr(
      cols,
      "palette",
      exact = TRUE
    ),
    colours = unclass(cols),
    n_colours = length(cols),
    distance_summary = distance_summary,
    contrast = contrasts,
    all_cvd_pass = all(distance_summary$passes),
    readable_on_white = white_contrast$aa_normal,
    readable_on_black = black_contrast$aa_normal,
    minimum_distance_threshold = minimum_distance
  )

  class(output) <- "cellpal_accessibility"

  output
}


#' @export
print.cellpal_accessibility <- function(
    x,
    ...
) {
  palette_name <- x$palette

  if (is.null(palette_name)) {
    palette_name <- "Custom palette"
  }

  cat("<cellpal accessibility report>\n")
  cat("Palette: ", palette_name, "\n", sep = "")
  cat("Colours: ", x$n_colours, "\n", sep = "")
  cat(
    "Minimum distance threshold: ",
    x$minimum_distance_threshold,
    "\n",
    sep = ""
  )
  cat(
    "All CVD simulations pass: ",
    if (x$all_cvd_pass) "yes" else "no",
    "\n",
    sep = ""
  )

  print(
    x$distance_summary,
    row.names = FALSE
  )

  invisible(x)
}


.cellpal_text_colour <- function(
    colours
) {
  luminance <- vapply(
    colours,
    .relative_luminance,
    numeric(1)
  )

  ifelse(
    luminance > 0.45,
    "#1A1A1A",
    "#FFFFFF"
  )
}


.relative_luminance <- function(
    colour
) {
  rgb <- grDevices::col2rgb(colour) / 255

  linear <- ifelse(
    rgb <= 0.03928,
    rgb / 12.92,
    ((rgb + 0.055) / 1.055)^2.4
  )

  as.numeric(
    0.2126 * linear["red", ] +
      0.7152 * linear["green", ] +
      0.0722 * linear["blue", ]
  )
}


.contrast_ratio <- function(
    colour_1,
    colour_2
) {
  luminance_1 <- .relative_luminance(colour_1)
  luminance_2 <- .relative_luminance(colour_2)

  lighter <- max(
    luminance_1,
    luminance_2
  )

  darker <- min(
    luminance_1,
    luminance_2
  )

  (lighter + 0.05) / (darker + 0.05)
}
