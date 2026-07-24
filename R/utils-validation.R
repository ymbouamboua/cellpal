# ============================================================ #
# Internal validation and constructors
# ============================================================ #


`%||%` <- function(
    x,
    y
) {
  if (is.null(x)) {
    y
  } else {
    x
  }
}


.new_cellpal <- function(
    colours,
    palette = "custom",
    type = NULL,
    mode = NULL
) {
  structure(
    as.character(colours),
    class = c(
      "cellpal",
      "character"
    ),
    palette = palette,
    palette_type = type,
    mode = mode
  )
}


.new_modified_cellpal <- function(
    colours,
    original,
    suffix
) {
  .new_cellpal(
    colours = colours,
    palette = .modified_palette_name(
      original,
      suffix
    ),
    type = attr(
      original,
      "palette_type",
      exact = TRUE
    ),
    mode = attr(
      original,
      "mode",
      exact = TRUE
    )
  )
}


.modified_palette_name <- function(
    palette,
    suffix
) {
  original_name <- attr(
    palette,
    "palette",
    exact = TRUE
  )

  if (is.null(original_name) ||
      length(original_name) != 1L ||
      is.na(original_name) ||
      !nzchar(original_name)) {
    original_name <- "custom"
  }

  paste0(
    original_name,
    suffix
  )
}


.validate_scalar_string <- function(
    value,
    argument
) {
  if (!is.character(value) ||
      length(value) != 1L ||
      is.na(value) ||
      !nzchar(value)) {
    stop(
      "`",
      argument,
      "` must be a single non-empty character string.",
      call. = FALSE
    )
  }

  value
}


.validate_palette_name <- function(
    palette
) {
  palette <- .validate_scalar_string(
    palette,
    "palette"
  )

  available <- cellpal_names()

  if (!palette %in% available) {
    stop(
      "Unknown palette '",
      palette,
      "'. Available palettes: ",
      paste(
        available,
        collapse = ", "
      ),
      call. = FALSE
    )
  }

  palette
}


.validate_new_palette_name <- function(
    name
) {
  name <- .validate_scalar_string(
    name,
    "name"
  )

  if (!grepl(
    "^[A-Za-z][A-Za-z0-9_.-]*$",
    name
  )) {
    stop(
      "`name` must begin with a letter and contain only letters, ",
      "numbers, underscores, periods, or hyphens.",
      call. = FALSE
    )
  }

  name
}


.validate_positive_integer <- function(
    value,
    argument
) {
  if (!is.numeric(value) ||
      length(value) != 1L ||
      is.na(value) ||
      !is.finite(value) ||
      value < 1 ||
      value != floor(value)) {
    stop(
      "`",
      argument,
      "` must be a single positive integer.",
      call. = FALSE
    )
  }

  as.integer(value)
}


.validate_flag <- function(
    value,
    argument
) {
  if (!is.logical(value) ||
      length(value) != 1L ||
      is.na(value)) {
    stop(
      "`",
      argument,
      "` must be `TRUE` or `FALSE`.",
      call. = FALSE
    )
  }

  value
}


.validate_direction <- function(
    direction
) {
  if (!is.numeric(direction) ||
      length(direction) != 1L ||
      is.na(direction) ||
      !is.finite(direction) ||
      !direction %in% c(-1, 1)) {
    stop(
      "`direction` must be either 1 or -1.",
      call. = FALSE
    )
  }

  as.integer(direction)
}


.validate_unit_amount <- function(
    value,
    argument,
    lower,
    upper
) {
  if (!is.numeric(value) ||
      length(value) != 1L ||
      is.na(value) ||
      !is.finite(value) ||
      value < lower ||
      value > upper) {
    stop(
      "`",
      argument,
      "` must be a single numeric value between ",
      lower,
      " and ",
      upper,
      ".",
      call. = FALSE
    )
  }

  value
}


.validate_colour_positions <- function(
    which,
    number_of_colours
) {
  number_of_colours <- .validate_positive_integer(
    number_of_colours,
    argument = "number_of_colours"
  )

  if (is.null(which)) {
    return(
      seq_len(number_of_colours)
    )
  }

  if (!is.numeric(which) ||
      !length(which) ||
      anyNA(which) ||
      any(!is.finite(which)) ||
      any(which != floor(which)) ||
      any(which < 1L) ||
      any(which > number_of_colours)) {
    stop(
      "`which` must contain integer positions between 1 and ",
      number_of_colours,
      ".",
      call. = FALSE
    )
  }

  unique(
    as.integer(which)
  )
}


.validate_colour_vector <- function(
    colours
) {
  if (!is.character(colours) ||
      !length(colours)) {
    stop(
      "`colours` must be a non-empty character vector.",
      call. = FALSE
    )
  }

  if (anyNA(colours) ||
      any(!nzchar(colours))) {
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
      paste(
        unique(colours[!valid]),
        collapse = ", "
      ),
      call. = FALSE
    )
  }

  rgb_matrix <- grDevices::col2rgb(
    colours,
    alpha = TRUE
  )

  has_alpha <- any(
    rgb_matrix["alpha", ] < 255
  )

  if (has_alpha) {
    return(
      grDevices::rgb(
        red = rgb_matrix["red", ],
        green = rgb_matrix["green", ],
        blue = rgb_matrix["blue", ],
        alpha = rgb_matrix["alpha", ],
        maxColorValue = 255
      )
    )
  }

  grDevices::rgb(
    red = rgb_matrix["red", ],
    green = rgb_matrix["green", ],
    blue = rgb_matrix["blue", ],
    maxColorValue = 255
  )
}


.require_colorspace <- function() {
  if (!requireNamespace(
    "colorspace",
    quietly = TRUE
  )) {
    stop(
      "Package `colorspace` is required. Install it with ",
      "`install.packages(\"colorspace\")`.",
      call. = FALSE
    )
  }

  invisible(TRUE)
}
