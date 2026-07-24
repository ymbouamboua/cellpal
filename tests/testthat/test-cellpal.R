test_that("multiplication works", {
  expect_equal(2 * 2, 4)
})


test_that("cellpal returns requested number of colours", {
  cols <- cellpal(
    "nature",
    n = 3
  )

  expect_length(cols, 3)
  expect_s3_class(cols, "cellpal")
})

test_that("continuous palettes can be expanded", {
  cols <- cellpal(
    "heatmap_nature",
    n = 100,
    type = "continuous"
  )

  expect_length(cols, 100)
})

test_that("unknown palettes produce an error", {
  expect_error(
    cellpal("does_not_exist"),
    "Unknown palette"
  )
})

test_that("alpha is validated", {
  expect_error(
    cellpal("nature", alpha = 2),
    "between 0 and 1"
  )
})
