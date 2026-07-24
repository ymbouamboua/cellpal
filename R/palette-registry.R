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
    nzchar(name) &&
    name %in% cellpal_names()
}


.get_cellpal_palette <- function(
    name
) {
  name <- .validate_palette_name(name)

  if (exists(
    name,
    envir = .cellpal_registry,
    inherits = FALSE
  )) {
    entry <- get(
      name,
      envir = .cellpal_registry,
      inherits = FALSE
    )

    return(entry$colours)
  }

  cellpal_palettes[[name]]
}


.get_cellpal_palette_type <- function(
    name
) {
  if (exists(
    name,
    envir = .cellpal_registry,
    inherits = FALSE
  )) {
    entry <- get(
      name,
      envir = .cellpal_registry,
      inherits = FALSE
    )

    return(entry$type)
  }

  index <- match(
    name,
    cellpal_info$name
  )

  if (!is.na(index)) {
    return(cellpal_info$type[[index]])
  }

  NA_character_
}


.get_cellpal_palette_source <- function(
    name
) {
  if (exists(
    name,
    envir = .cellpal_registry,
    inherits = FALSE
  )) {
    return("custom")
  }

  if (name %in% names(cellpal_palettes)) {
    return("built-in")
  }

  NA_character_
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

  available <- c(
    built_in,
    setdiff(custom, built_in)
  )

  if (is.null(type)) {
    return(available)
  }

  type <- match.arg(
    type,
    c(
      "categorical",
      "sequential",
      "diverging"
    )
  )

  available[
    vapply(
      available,
      function(name) {
        identical(
          .get_cellpal_palette_type(name),
          type
        )
      },
      logical(1)
    )
  ]
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
    palette %in% cellpal_names()
}


#' Register a Custom Palette
#'
#' Registers a custom palette for the current R session.
#'
#' @param name Character string naming the palette.
#' @param colours Character vector containing valid R colours.
#' @param type Palette type: `"categorical"`, `"sequential"`, or `"diverging"`.
#' @param overwrite Logical. Replace an existing custom palette.
#'
#' @return Invisibly returns the registered palette.
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
  name <- .validate_new_palette_name(name)
  type <- match.arg(type)
  overwrite <- .validate_flag(overwrite, "overwrite")
  colours <- .validate_colour_vector(colours)

  if (name %in% names(cellpal_palettes)) {
    stop(
      "Built-in palette '",
      name,
      "' cannot be overwritten.",
      call. = FALSE
    )
  }

  already_registered <- exists(
    name,
    envir = .cellpal_registry,
    inherits = FALSE
  )

  if (already_registered && !overwrite) {
    stop(
      "Custom palette '",
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

  invisible(
    .new_cellpal(
      colours,
      palette = name,
      type = type
    )
  )
}


#' Remove a Custom Palette
#'
#' @param name Name of a custom palette.
#'
#' @return Invisibly returns `TRUE`.
#'
#' @examples
#' cellpal_register("temporary", c("#000000", "#FFFFFF"))
#' cellpal_unregister("temporary")
#'
#' @export
cellpal_unregister <- function(
    name
) {
  name <- .validate_scalar_string(
    name,
    "name"
  )

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
  sort(
    ls(
      envir = .cellpal_registry,
      all.names = TRUE
    )
  )
}


#' Create a Named Palette Mapping
#'
#' @param levels Character or factor vector containing category names.
#' @param palette Name of a registered cellpal palette.
#' @param sort Logical. Sort categories alphabetically.
#' @param reverse Logical. Reverse the palette.
#' @param direction Either `1` or `-1`.
#'
#' @return A named `"cellpal"` vector.
#'
#' @export
cellpal_named <- function(
    levels,
    palette = "base",
    sort = FALSE,
    reverse = FALSE,
    direction = 1
) {
  categories <- if (is.factor(levels)) {
    base::levels(levels)
  } else {
    unique(
      as.character(levels)
    )
  }

  categories <- categories[
    !is.na(categories) &
      nzchar(categories)
  ]

  if (!length(categories)) {
    stop(
      "`levels` must contain at least one non-missing category.",
      call. = FALSE
    )
  }

  if (isTRUE(sort)) {
    categories <- base::sort(categories)
  }

  colours <- cellpal(
    palette = palette,
    n = length(categories),
    type = "discrete",
    reverse = reverse,
    direction = direction
  )

  names(colours) <- categories

  colours
}

