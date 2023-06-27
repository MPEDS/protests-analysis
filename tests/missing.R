test_that("Event keys do not have missing values", {
  library(targets)
  tar_load(cleaned_events)
  tar_load(integrated)

  # expect_equal to report how many have missing values
  expect_equal(sum(is.na(cleaned_events$key)), 0)
  expect_equal(sum(is.na(integrated$key)), 0)
})

test_that("Publication names do not have missing values", {
  library(targets)
  tar_load(canonical_events)
  tar_load(cleaned_events)
  tar_load(integrated)

  expect_equal(sum(is.na(canonical_events$publication)), 0)
  expect_equal(sum(is.na(cleaned_events$publication)), 0)
  expect_equal(sum(is.na(integrated$publication)), 0)
})

test_that("`Location` field does not have any missing values", {
  library(targets)
  tar_load(events_wide)
  tar_load(cleaned_events)
  tar_load(integrated)

  expect_equal(sum(is.na(events_wide$location)), 0)
  expect_equal(sum(is.na(cleaned_events$location)), 0)
  expect_equal(sum(is.na(integrated$location)), 0)
})

test_that("`start_date` field does not have any missing values", {
  library(targets)
  tar_load(events_wide)
  tar_load(cleaned_events)
  tar_load(integrated)

  expect_equal(sum(is.na(events_wide$start_date)), 0)
  expect_equal(sum(is.na(cleaned_events$start_date)), 0)
  expect_equal(sum(is.na(integrated$start_date)), 0)
})
