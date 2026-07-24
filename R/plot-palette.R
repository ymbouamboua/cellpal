# ============================================================
# Palette visualization
# ============================================================

#' Plot a cellpal Palette
#'
#' Displays a palette as labelled colour swatches.
#'
#' @param x A `cellpal` object.
#' @param ... Additional arguments passed to
#'   [cellpal_view()][cellpal::cellpal_view].
#'
#' @return A `ggplot2` object.
#'
#' @examples
#' \donttest{
#' plot(cellpal("nature"))
#' }
#'
#' @export
plot.cellpal <- function(
    x,
    ...
) {
  cellpal_view(
    x,
    ...
  )
}


#' Preview a cellpal Palette
#'
#' @param palette Palette name, a `cellpal` object, or a character vector of
#'   colours.
#' @param labels Logical. Display hexadecimal colour labels.
#' @param label_position Position of labels: `"inside"` or `"below"`.
#' @param label_size Numeric label size.
#' @param title Optional plot title.
#' @param subtitle Optional plot subtitle.
#'
#' @return A `ggplot2` object.
#'
#' @examples
#' \donttest{
#' cellpal_view("nature")
#' cellpal_view(cellpal("heatmap_nature", n = 20, type = "continuous"))
#' }
#'
#' @export
cellpal_view <- function(
    palette,
    labels = TRUE,
    label_position = c(
      "inside",
      "below"
    ),
    label_size = 3,
    title = NULL,
    subtitle = NULL
) {
  label_position <- match.arg(label_position)

  cols <- .resolve_cellpal_input(
    substitute(palette),
    parent.frame()
  )

  palette_name <- attr(
    cols,
    "palette",
    exact = TRUE
  )

  if (is.null(palette_name) ||
      !nzchar(palette_name)) {
    palette_name <- "Custom palette"
  }

  if (is.null(title)) {
    title <- palette_name
  }

  if (is.null(subtitle)) {
    subtitle <- paste(
      length(cols),
      if (length(cols) == 1L) "colour" else "colours"
    )
  }

  data <- data.frame(
    colour_index = seq_along(cols),
    colour = unclass(cols),
    stringsAsFactors = FALSE
  )

  data$text_colour <- .cellpal_text_colour(
    data$colour
  )

  if (label_position == "inside") {
    plot <- ggplot2::ggplot(
      data,
      ggplot2::aes(
        x = colour_index,
        y = 1,
        fill = colour
      )
    ) +
      ggplot2::geom_tile(
        colour = "white",
        linewidth = 1
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

    return(
      plot +
        ggplot2::scale_fill_identity() +
        ggplot2::coord_cartesian(
          expand = FALSE
        ) +
        ggplot2::labs(
          title = title,
          subtitle = subtitle,
          x = NULL,
          y = NULL
        ) +
        ggplot2::theme_void(
          base_size = 11
        ) +
        ggplot2::theme(
          plot.title = ggplot2::element_text(
            face = "bold",
            hjust = 0.5
          ),
          plot.subtitle = ggplot2::element_text(
            colour = "#666666",
            hjust = 0.5
          ),
          plot.margin = ggplot2::margin(
            12,
            12,
            12,
            12
          )
        )
    )
  }

  plot <- ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = colour_index,
      y = 1,
      fill = colour
    )
  ) +
    ggplot2::geom_tile(
      colour = "white",
      linewidth = 1
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::scale_x_continuous(
      breaks = data$colour_index,
      labels = if (labels) {
        toupper(data$colour)
      } else {
        NULL
      },
      expand = c(0, 0)
    ) +
    ggplot2::coord_cartesian(
      expand = FALSE,
      clip = "off"
    ) +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      x = NULL,
      y = NULL
    ) +
    ggplot2::theme_minimal(
      base_size = 11
    ) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(
        face = "bold",
        hjust = 0.5
      ),
      plot.subtitle = ggplot2::element_text(
        colour = "#666666",
        hjust = 0.5
      ),
      axis.text.x = ggplot2::element_text(
        angle = 45,
        hjust = 1,
        size = label_size * 2.5
      ),
      axis.text.y = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank(),
      plot.margin = ggplot2::margin(
        12,
        12,
        35,
        12
      )
    )

  plot
}


#' Plot Multiple cellpal Palettes
#'
#' Creates a gallery displaying several registered palettes.
#'
#' @param palettes Character vector of palette names. By default, all built-in
#'   palettes are shown.
#' @param type Optional palette type used to filter palettes.
#' @param n Optional number of colours to draw from every palette.
#' @param labels Logical. Display hexadecimal labels.
#'
#' @return A `ggplot2` object.
#'
#' @examples
#' \donttest{
#' cellpal_gallery(c("nature", "jama", "nejm"))
#' cellpal_gallery(type = "diverging", labels = FALSE)
#' }
#'
#' @export
cellpal_gallery <- function(
    palettes = NULL,
    type = NULL,
    n = NULL,
    labels = FALSE
) {
  if (is.null(palettes)) {
    palettes <- cellpal_names(type = type)
  }

  if (!is.character(palettes) ||
      !length(palettes) ||
      anyNA(palettes)) {
    stop(
      "`palettes` must be a non-empty character vector.",
      call. = FALSE
    )
  }

  unknown <- setdiff(
    palettes,
    c(
      names(cellpal_palettes),
      cellpal_custom_names()
    )
  )

  if (length(unknown)) {
    stop(
      "Unknown palette(s): ",
      paste(unknown, collapse = ", "),
      call. = FALSE
    )
  }

  gallery_data <- lapply(
    seq_along(palettes),
    function(palette_index) {
      palette_name <- palettes[[palette_index]]
      cols <- .get_cellpal_palette(palette_name)

      requested_n <- if (is.null(n)) {
        length(cols)
      } else {
        as.integer(n)
      }

      palette_type <- .get_cellpal_palette_type(
        palette_name
      )

      interpolation_type <- if (
        identical(
          palette_type,
          "categorical"
        )
      ) {
        "discrete"
      } else {
        "continuous"
      }

      displayed <- cellpal(
        palette = palette_name,
        n = requested_n,
        type = interpolation_type
      )

      data.frame(
        palette = palette_name,
        palette_order = palette_index,
        colour_index = seq_along(displayed),
        colour = unclass(displayed),
        stringsAsFactors = FALSE
      )
    }
  )

  data <- do.call(
    rbind,
    gallery_data
  )

  data$palette <- factor(
    data$palette,
    levels = rev(palettes)
  )

  data$text_colour <- .cellpal_text_colour(
    data$colour
  )

  plot <- ggplot2::ggplot(
    data,
    ggplot2::aes(
      x = colour_index,
      y = palette,
      fill = colour
    )
  ) +
    ggplot2::geom_tile(
      colour = "white",
      linewidth = 0.6
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::scale_x_continuous(
      expand = c(0, 0)
    ) +
    ggplot2::labs(
      title = "cellpal palettes",
      subtitle = paste(
        length(palettes),
        if (length(palettes) == 1L) "palette" else "palettes"
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
        face = "bold",
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
        size = 2.2,
        show.legend = FALSE
      ) +
      ggplot2::scale_colour_identity()
  }

  plot
}
