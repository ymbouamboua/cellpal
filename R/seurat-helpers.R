#' Generate colours from Seurat metadata
#'
#' @param object A Seurat object.
#' @param group.by Metadata column or `"ident"`.
#' @param palette Palette name.
#' @param sort Sort category names.
#'
#' @return A named colour vector.
#' @export
cellpal_seurat <- function(
    object,
    group.by = "ident",
    palette = "base",
    sort = FALSE
) {
  if (!inherits(object, "Seurat")) {
    stop("`object` must be a Seurat object.", call. = FALSE)
  }

  groups <- if (identical(group.by, "ident")) {
    as.character(SeuratObject::Idents(object))
  } else {
    if (!group.by %in% colnames(object[[]])) {
      stop(
        "Metadata column '",
        group.by,
        "' was not found.",
        call. = FALSE
      )
    }

    as.character(object[[group.by, drop = TRUE]])
  }

  cellpal_named(
    levels = groups,
    palette = palette,
    sort = sort
  )
}
