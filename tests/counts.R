test_that("Counts of protest events do not change throughout cleaning process", {
  library(targets)
  tar_load(canonical_events)
  tar_load(events_wide)
  tar_load(cleaned_events)
  tar_load(integrated)

  expect_equal(length(unique(canonical_events$canonical_id)), length(unique(events_wide$canonical_id)))
  expect_equal(length(unique(canonical_events$canonical_id)), length(unique(cleaned_events$canonical_id)))
  expect_equal(length(unique(canonical_events$canonical_id)), length(unique(integrated$canonical_id)))
})

test_that("Wide canonical event datasets have one row per canonical event", {
  library(targets)
  tar_load(canonical_events)
  tar_load(cleaned_events)
  tar_load(integrated)

  expect_equal(length(unique(cleaned_events$canonical_id)), length(cleaned_events$canonical_id))
  expect_equal(length(unique(integrated$canonical_id)), length(integrated$canonical_id))
})

test_that("Event keys and event IDs have a 1:1 correspondence", {
  library(targets)
  tar_load(canonical_events)
  tar_load(cleaned_events)
  tar_load(integrated)

  expect_equal(length(unique(cleaned_events$canonical_id)), length(unique(cleaned_events$key)))
  expect_equal(length(unique(integrated$canonical_id)), length(unique(integrated$key)))
})

test_that("Location field has one value per canonical event", {
  library(targets)
  tar_load(cleaned_events)
  tar_load(integrated)

  expect_setequal(map_int(cleaned_events$location, length), 1)
  expect_setequal(map_int(integrated$location, length), 1)
})

test_that("Start date has one value per canonical event", {
  library(targets)
  tar_load(canonical_events)
  tar_load(events_wide)
  tar_load(cleaned_events)
  tar_load(integrated)

  canonical_events <- canonical_events |>
    filter(variable == "start-date") |>
    pivot_wider(names_from = variable, values_from = value) |>
    janitor::clean_names()

  count_dates <- function(dta){
    dta |>
      filter(!str_detect(key, "^Umbrella")) |>
      pull(start_date) |>
      map_int(length)
  }

  expect_setequal(count_dates(canonical_events), 1)
  expect_setequal(count_dates(events_wide), 1)
  expect_setequal(count_dates(cleaned_events), 1)
  expect_setequal(count_dates(integrated), 1)
})
