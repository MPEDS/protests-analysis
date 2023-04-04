library(targets)
library(tarchetypes)

source("tasks/source_safely.R")
fn_filenames <- list.files("tasks", full.names = TRUE,
                           pattern = ".R",
                           recursive = TRUE)
invisible(lapply(fn_filenames, source_safely))

tar_option_set(packages = c("tidyverse", "RMariaDB", "ssh", "haven",
                            "httr", "curl", "sf", "tigris", "tidycensus"))

list(
  tar_target(canonical_events, get_canonical_events(),
            # set the DOWNLOAD_MPEDS variable in your .Renviron file
            # to force a download of the MPEDS database from the `sheriff` server
            # this lets us toggle the download on and off without changes to
            # source-control tracked files
            cue = tar_cue(mode = ifelse(
              Sys.getenv("DOWNLOAD_MPEDS") %in% c('', 'false'), 'never', 'always'
              )
            )
     ),
  tar_target(canonical_event_relationship, get_canonical_event_relationship(canonical_events)),
  tar_target(uni_pub_xwalk_file, format = "file",
             command = "tasks/mpeds/hand/uni_pub_xwalk.csv"),
  tar_target(events_wide, process_canonical_events(canonical_events, uni_pub_xwalk_file)),
  tar_target(geocoded, get_protest_coords(events_wide)),

  # Geographic information
  tar_target(us_regions_filename, format = "file",
             "tasks/geographic_covariates/us/us-regions.csv"),
  tar_target(us_regions, read_csv(us_regions_filename, show_col_types = FALSE)),
  tar_target(us_geo, get_us_geo(us_regions)),
  tar_target(canada_geo, get_canada_geo()),
    # needed for plotting
  tar_target(canada_province_shapes, get_canada_provinces()),
  tar_target(geo, bind_rows(us_geo, canada_geo)),

  # Using format = url here because it's updated regularly (weekly)
  tar_target(ccc_url, format = "url",
             command = "https://github.com/nonviolent-action-lab/crowd-counting-consortium/raw/master/ccc_compiled.csv"
             ),
  tar_target(ccc, get_ccc(ccc_url)),


  # County+year-level covariates ---
  tar_target(canada_covariates, get_canada_covariates(canada_geo)),
  tar_target(us_covariates, get_us_covariates()),
  tar_target(covariates, bind_rows(us_covariates, canada_covariates)),

  tar_target(elephrame_blm, get_elephrame_blm()),

  # school-level covariates ---
  tar_target(ipeds, get_school_directory()),
  tar_target(glued, get_glued()),
  tar_target(tuition, get_tuition()),

  # Integration steps ---
  # IPEDS and MPEDS
  # the `raw_coarse_filename` target is meant to be cleaned by hand (by me)
  tar_target(raw_coarse_filename, clean_mpeds_names(geocoded, ipeds, glued),
             format = "file"),
  tar_target(coarse_uni_match_filename,
             update_coarse_matches(raw_coarse_filename),
             format = "file"),
  # then passed off to coders in a readable format
  tar_target(postprocess_filename, postprocess_names(
    geocoded, coarse_uni_match_filename, glued, ipeds,
    canonical_event_relationship
  ), format = "file"),
  # And read in again after they've made their edits
  tar_target(uni_xwalk,  readxl::read_excel(postprocess_filename) |> distinct()),

  # Export Canadian universities for additional manual data input
  tar_target(canadian_universities_filename, export_canada(
    coarse_uni_match_filename, glued
  ), format = "file"),

  tar_target(integrated, integrate_targets(
    geocoded,
    ipeds,
    glued,
    uni_xwalk,
    covariates,
    geo
    )),

  # Plotting and other exploratory analysis ---
  tar_render(exploratory, "docs/exploratory_plots.Rmd" )
)

