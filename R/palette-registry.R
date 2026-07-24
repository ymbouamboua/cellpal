# ============================================================
# Palette registry
# ============================================================


.cellpal_registry <- new.env(
  parent = emptyenv()
)


.is_palette_name <- function(
    name
) {
  is.character(name) &&
    length(name) == 1L &&
    !is.na(name) &&
    name %in% c(
      names(cellpal_palettes),
      cellpal_custom_names()
    )
}

.get_cellpal_palette <- function(
    name
) {
  if (name %in% names(cellpal_palettes)) {
    return(cellpal_palettes[[name]])
  }

  if (exists(
    name,
    envir = .cellpal_registry,
    inherits = FALSE
  )) {
    return(
      get(
        name,
        envir = .cellpal_registry,
        inherits = FALSE
      )$colours
    )
  }

  NULL
}


# Internal helper for palette type retrieval.
.get_cellpal_palette_type <- function(
    name
) {
  if (exists(
    name,
    envir = .cellpal_registry,
    inherits = FALSE
  )) {
    return(
      get(
        name,
        envir = .cellpal_registry,
        inherits = FALSE
      )$type
    )
  }

  if (exists("cellpal_info", inherits = TRUE) &&
      is.data.frame(cellpal_info) &&
      all(c("name", "type") %in% colnames(cellpal_info))) {
    index <- match(name, cellpal_info$name)

    if (!is.na(index)) {
      return(cellpal_info$type[[index]])
    }
  }

  NA_character_
}


.validate_palette_name <- function(
    palette
) {
  if (!is.character(palette) ||
      length(palette) != 1L ||
      is.na(palette) ||
      !nzchar(palette)) {
    stop(
      "`palette` must be a single non-empty character string.",
      call. = FALSE
    )
  }

  available <- c(
    names(cellpal_palettes),
    cellpal_custom_names()
  )

  if (!palette %in% available) {
    stop(
      "Unknown palette '",
      palette,
      "'. Available palettes: ",
      paste(available, collapse = ", "),
      call. = FALSE
    )
  }

  palette
}


.validate_colour_vector <- function(
    colours
) {
  if (!is.character(colours) || !length(colours)) {
    stop(
      "`colours` must be a non-empty character vector.",
      call. = FALSE
    )
  }

  if (anyNA(colours) || any(!nzchar(colours))) {
    stop(
      "`colours` cannot contain missing or empty values.",
      call. = FALSE
    )
  }

  valid <- vapply(
    colours,
    function(colour) {
      !inherits(
        try(
          grDevices::col2rgb(colour),
          silent = TRUE
        ),
        "try-error"
      )
    },
    logical(1)
  )

  if (!all(valid)) {
    stop(
      "Invalid colour value(s): ",
      paste(unique(colours[!valid]), collapse = ", "),
      call. = FALSE
    )
  }

  rgb_matrix <- grDevices::col2rgb(
    colours,
    alpha = TRUE
  )

  if (all(rgb_matrix["alpha", ] == 255)) {
    return(
      grDevices::rgb(
        red = rgb_matrix["red", ],
        green = rgb_matrix["green", ],
        blue = rgb_matrix["blue", ],
        maxColorValue = 255
      )
    )
  }

  grDevices::rgb(
    red = rgb_matrix["red", ],
    green = rgb_matrix["green", ],
    blue = rgb_matrix["blue", ],
    alpha = rgb_matrix["alpha", ],
    maxColorValue = 255
  )
}



#' @export
print.cellpal_palette_info <- function(
    x,
    ...
) {
  cat("<cellpal palette>\n")
  cat("Name:    ", x$name, "\n", sep = "")
  cat("Type:    ", x$type, "\n", sep = "")
  cat("Colours: ", x$n_colours, "\n", sep = "")
  cat(
    paste(x$colours, collapse = " "),
    "\n"
  )

  invisible(x)
}


#' List Available cellpal Palettes
#'
#' @param type Optional palette type: `"categorical"`, `"sequential"`,
#'   or `"diverging"`.
#'
#' @return A character vector of palette names.
#'
#' @examples
#' cellpal_names()
#' cellpal_names("categorical")
#'
#' @export
cellpal_names <- function(
    type = NULL
) {
  built_in <- names(cellpal_palettes)
  custom <- cellpal_custom_names()

  if (is.null(type)) {
    return(c(built_in, custom))
  }

  type <- match.arg(
    type,
    c(
      "categorical",
      "sequential",
      "diverging"
    )
  )

  built_in_names <- cellpal_info$name[
    cellpal_info$type == type &
      cellpal_info$name %in% built_in
  ]

  custom_names <- custom[
    vapply(
      custom,
      function(name) {
        identical(
          .get_cellpal_palette_type(name),
          type
        )
      },
      logical(1)
    )
  ]

  c(
    built_in_names,
    custom_names
  )
}

#' Create a Named Palette Mapping
#'
#' Creates a stable named colour vector for categorical variables such as
#' cell types, clusters, samples, or experimental groups.
#'
#' @param levels Character or factor vector containing category names.
#' @param palette Name of a registered cellpal palette.
#' @param sort Logical. Sort categories alphabetically before assigning
#'   colours.
#' @param reverse Logical. Reverse the palette.
#'
#' @return A named character vector with class `"cellpal"`.
#'
#' @examples
#' cellpal_named(
#'   c("T cell", "B cell", "Myeloid"),
#'   palette = "nature"
#' )
#'
#' @export
cellpal_named <- function(
    levels,
    palette = "base",
    sort = FALSE,
    reverse = FALSE
) {
  levels <- as.character(levels)
  levels <- unique(levels)

  levels <- levels[
    !is.na(levels) &
      nzchar(levels)
  ]

  if (!length(levels)) {
    stop(
      "`levels` must contain at least one non-missing category.",
      call. = FALSE
    )
  }

  if (isTRUE(sort)) {
    levels <- base::sort(levels)
  }

  colours <- cellpal(
    palette = palette,
    n = length(levels),
    type = "discrete",
    reverse = reverse
  )

  names(colours) <- levels

  colours
}



#' Retrieve Information about a cellpal Palette
#'
#' Returns metadata and colours associated with a registered palette.
#'
#' @param palette Character string naming a registered palette.
#'
#' @return A list containing the palette name, colours, number of colours,
#'   palette type, and available metadata.
#'
#' @examples
#' cellpal_palette_info("nature")
#'
#' @export
cellpal_palette_info <- function(
    palette
) {
  palette <- .validate_palette_name(palette)

  cols <- cellpal_palettes[[palette]]

  metadata <- NULL

  if (exists("cellpal_info", inherits = TRUE) &&
      is.data.frame(cellpal_info) &&
      "name" %in% colnames(cellpal_info)) {
    metadata <- cellpal_info[
      cellpal_info$name == palette,
      ,
      drop = FALSE
    ]

    if (!nrow(metadata)) {
      metadata <- NULL
    }
  }

  palette_type <- if (
    !is.null(metadata) &&
    "type" %in% colnames(metadata)
  ) {
    metadata$type[[1]]
  } else {
    NA_character_
  }

  structure(
    list(
      name = palette,
      colours = cols,
      n_colours = length(cols),
      type = palette_type,
      metadata = metadata
    ),
    class = "cellpal_palette_info"
  )
}


#' Check whether a Palette Exists
#'
#' @param palette Character string containing a palette name.
#'
#' @return A single logical value.
#'
#' @examples
#' cellpal_exists("nature")
#' cellpal_exists("unknown")
#'
#' @export
cellpal_exists <- function(
    palette
) {
  is.character(palette) &&
    length(palette) == 1L &&
    !is.na(palette) &&
    nzchar(palette) &&
    palette %in% names(cellpal_palettes)
}


#' Register a Custom Palette
#'
#' Registers a custom palette for the current R session.
#'
#' Because package objects are locked after loading, custom palettes are stored
#' in an internal session registry rather than modifying the built-in palette
#' object directly.
#'
#' @param name Character string naming the palette.
#' @param colours Character vector containing valid R colours.
#' @param type Palette type: `"categorical"`, `"sequential"`, or `"diverging"`.
#' @param overwrite Logical. Allow replacement of an existing custom palette.
#'
#' @return Invisibly returns the registered colour vector.
#'
#' @examples
#' cellpal_register(
#'   "my_palette",
#'   c("#264653", "#E9C46A", "#E76F51"),
#'   type = "categorical"
#' )
#'
#' @export
cellpal_register <- function(
    name,
    colours,
    type = c(
      "categorical",
      "sequential",
      "diverging"
    ),
    overwrite = FALSE
) {
  type <- match.arg(type)

  if (!is.character(name) ||
      length(name) != 1L ||
      is.na(name) ||
      !nzchar(name)) {
    stop(
      "`name` must be a single non-empty character string.",
      call. = FALSE
    )
  }

  if (!grepl("^[A-Za-z][A-Za-z0-9_.-]*$", name)) {
    stop(
      "`name` must begin with a letter and contain only letters, ",
      "numbers, underscores, periods, or hyphens.",
      call. = FALSE
    )
  }

  colours <- .validate_colour_vector(colours)

  already_builtin <- name %in% names(cellpal_palettes)
  already_custom <- exists(
    name,
    envir = .cellpal_registry,
    inherits = FALSE
  )

  if ((already_builtin || already_custom) && !isTRUE(overwrite)) {
    stop(
      "Palette '",
      name,
      "' already exists. Use `overwrite = TRUE` to replace it.",
      call. = FALSE
    )
  }

  entry <- list(
    colours = colours,
    type = type,
    source = "custom"
  )

  assign(
    name,
    entry,
    envir = .cellpal_registry
  )

  invisible(colours)
}


#' Remove a Custom Palette
#'
#' Removes a palette previously added with
#' [cellpal_register()][cellpal::cellpal_register].
#'
#' Built-in palettes cannot be removed.
#'
#' @param name Name of a custom palette.
#'
#' @return Invisibly returns `TRUE` when the palette is removed.
#'
#' @examples
#' cellpal_register("temporary", c("#000000", "#FFFFFF"))
#' cellpal_unregister("temporary")
#'
#' @export
cellpal_unregister <- function(
    name
) {
  if (!is.character(name) ||
      length(name) != 1L ||
      is.na(name) ||
      !nzchar(name)) {
    stop(
      "`name` must be a single non-empty character string.",
      call. = FALSE
    )
  }

  if (!exists(
    name,
    envir = .cellpal_registry,
    inherits = FALSE
  )) {
    stop(
      "Custom palette '",
      name,
      "' is not registered.",
      call. = FALSE
    )
  }

  rm(
    list = name,
    envir = .cellpal_registry
  )

  invisible(TRUE)
}


#' List Custom Palettes
#'
#' @return A character vector containing custom palette names.
#'
#' @export
cellpal_custom_names <- function() {
  ls(
    envir = .cellpal_registry,
    all.names = TRUE
  )
}

