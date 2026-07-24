# ============================================================
# Palette input resolution
# ============================================================

.resolve_cellpal_name <- function(
    expression,
    environment
) {
  if (is.character(expression) &&
      length(expression) == 1L) {
    return(expression)
  }
  
  if (is.name(expression)) {
    candidate <- as.character(expression)
    
    if (.is_palette_name(candidate)) {
      return(candidate)
    }
  }
  
  value <- tryCatch(
    eval(
      expression,
      envir = environment
    ),
    error = function(error) {
      NULL
    }
  )
  
  if (is.character(value) &&
      length(value) == 1L &&
      !is.na(value) &&
      nzchar(value)) {
    return(value)
  }
  
  stop(
    "`palette` must be a valid quoted or unquoted palette name.",
    call. = FALSE
  )
}


.resolve_cellpal_input <- function(
    expression,
    environment
) {
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
        .validate_colour_vector(expression)
      )
    )
  }
  
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
        .validate_colour_vector(value)
      )
    )
  }
  
  stop(
    "`palette` must be a registered palette name, a `cellpal` object, ",
    "or a character vector of valid R colours.",
    call. = FALSE
  )
}