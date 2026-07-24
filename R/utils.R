`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}


.validate_positions <- function(which, n) {
  if (!is.numeric(which) ||
      anyNA(which) ||
      any(which < 1) ||
      any(which > n)) {
    stop(
      "`which` must contain positions between 1 and ",
      n,
      ".",
      call. = FALSE
    )
  }

  unique(as.integer(which))
}


.resolve_cellpal_name <- function(name_expr, env = parent.frame()) {

  # Quoted name: cellpal("nature")
  if (is.character(name_expr) && length(name_expr) == 1L) {
    return(name_expr)
  }

  # Bare palette name: cellpal(nature)
  if (is.name(name_expr)) {
    candidate <- as.character(name_expr)

    if (candidate %in% names(cellpal_palettes)) {
      return(candidate)
    }
  }

  # Variable containing a palette name:
  # pal <- "nature"
  # cellpal(pal)
  value <- tryCatch(
    eval(name_expr, envir = env),
    error = function(e) NULL
  )

  if (is.character(value) && length(value) == 1L) {
    return(value)
  }

  stop(
    "`palette` must be a valid quoted or unquoted palette name.",
    call. = FALSE
  )
}



.new_cellpal <- function(
    colours,
    palette = "custom",
    type = NULL
) {
  structure(
    as.character(colours),
    class = c("cellpal", "character"),
    palette = palette,
    palette_type = type
  )
}


.get_cellpal_palette <- function(
    name
) {
  if (exists(
    name,
    envir = .cellpal_registry,
    inherits = FALSE
  )) {
    registered <- get(
      name,
      envir = .cellpal_registry,
      inherits = FALSE
    )

    return(registered$colours)
  }

  if (name %in% names(cellpal_palettes)) {
    return(cellpal_palettes[[name]])
  }

  stop(
    "Unknown palette '",
    name,
    "'. Available palettes: ",
    paste(cellpal_names(), collapse = ", "),
    call. = FALSE
  )
}



.get_cellpal_palette_type <- function(
    name
) {
  if (exists(
    name,
    envir = .cellpal_registry,
    inherits = FALSE
  )) {
    registered <- get(
      name,
      envir = .cellpal_registry,
      inherits = FALSE
    )

    return(registered$type)
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



