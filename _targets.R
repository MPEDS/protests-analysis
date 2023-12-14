library(targets)
library(tarchetypes)
library(future)
library(crew)
tar_option_set(controller = crew_controller_local(workers = 4))
source("tasks/source_safely.R")
fn_filenames <- list.files(
  "tasks",
  full.names = TRUE,
  pattern = ".R",
  recursive = TRUE
)
invisible(lapply(fn_filenames, source_safely))

plan(multisession, workers = parallel::detectCores() - 2)
tar_option_set(
  packages = c(
    "tidyverse",
    "RMariaDB",
    "ssh",
    "haven",
    "testthat",
    "cluster",
    "googledrive",
    "nplyr",
    "httr",
    "curl",
    "sf",
    "tigris",
    "tidycensus"
  ),
)

# Prevent package from asking for sign-in options
googledrive::drive_deauth()
googledrive::drive_auth_configure(api_key = Sys.getenv("GMAPS_API_KEY"))

list(
  tar_target(canonical_events, get_canonical_events(),
             # set the DOWNLOAD_MPEDS variable in your .Renviron file
             # to force a download of the MPEDS database from the `sheriff` server
             # this lets us toggle the download on and off without changes to
             # source-control tracked files
             cue = tar_cue(
               mode = ifelse(
                 Sys.getenv("DOWNLOAD_MPEDS") %in% c('', 'false'),
                 'never',
                 'always'
               )
             )),
  tar_target(
    canonical_event_relationship,
    get_canonical_event_relationship(canonical_events)
  ),
  tar_target(uni_pub_xwalk_file, format =
               "file",
             command = "tasks/mpeds/hand/uni_pub_xwalk.csv"),
  tar_target(
    events_wide,
    process_canonical_events(canonical_events, uni_pub_xwalk_file)
  ),
  tar_target(cleaned_events, get_protest_coords(events_wide)),

  # CLUSTERING-SPECIFIC TARGETS
  tar_target(cluster_inputs, create_cluster_inputs(cleaned_events)),
  tar_target(distance_matrix, create_distance_matrix(cluster_inputs)),
  tar_target(indexes, seq(100, nrow(cluster_inputs) - 1, by = 50)),
  tar_target(
    clusters,
    assign_issue_clusters(distance_matrix, indexes),
    memory = "transient",
    storage = "worker",
    retrieval = "worker",
    garbage_collection = TRUE,
    # dynamically create branches according to `indexes`
    pattern = map(indexes)
  ),
  tar_target(
    cluster_metrics,
    create_cluster_metrics(
      clusters,
      cluster_inputs,
      cleaned_events,
      canonical_event_relationship
    )
  ),

  # 450 is approx. the number of campaigns (422)
  tar_target(
    cluster_campaigns,
    assign_issue_clusters(distance_matrix, 450)
  ),

  tar_target(articles, get_articles(), cue = tar_cue(mode = "always")),

  # Geographic information
  tar_target(
    us_regions_filename,
    format = "file",
    "tasks/geographic_covariates/us/us-regions.csv"
  ),
  tar_target(
    us_regions,
    read_csv(us_regions_filename, show_col_types = FALSE)
  ),
  tar_target(us_geo, get_us_geo(us_regions)),
  tar_target(canada_geo, get_canada_geo()),

  # needed for plotting
  tar_target(canada_province_shapes, get_canada_provinces()),
  tar_target(geo, bind_rows(us_geo, canada_geo)),

  # Using format = url here because it's updated regularly (weekly)
  tar_target(ccc_url, format = "url",
             command = "https://github.com/nonviolent-action-lab/crowd-counting-consortium/raw/master/ccc_compiled.csv"),
  tar_target(ccc, get_ccc(ccc_url)),

  # County+year-level covariates ---
  tar_target(canada_covariates, get_canada_covariates(canada_geo)),
  tar_target(us_covariates, get_us_covariates()),
  tar_target(covariates, bind_rows(us_covariates, canada_covariates)),

  tar_target(elephrame_blm, get_elephrame_blm()),

  # school-level covariates ---
  tar_target(ipeds_raw, get_school_directory()),
  tar_target(ipeds_directory, clean_school_directory(ipeds_raw)),
  tar_target(ipeds_tuition, get_ipeds_tuition()),
  tar_target(ipeds_race, get_ipeds_race()),
  tar_target(ipeds_pell, get_ipeds_pell()),
  tar_target(ipeds, list(ipeds_directory, ipeds_tuition, ipeds_race, ipeds_pell) |>
               reduce(full_join, by = c("uni_id", "year"))),
  tar_target(glued_raw, get_glued()),
  tar_target(glued, clean_glued(glued_raw)),
  tar_target(tuition, get_tuition()),

  # Integration steps ---
  # IPEDS and MPEDS
  # the `raw_coarse_filename` target is meant to be cleaned by hand (by me)
  tar_target(
    raw_coarse_filename,
    clean_mpeds_names(cleaned_events, ipeds, glued),
    format = "file"
  ),
  tar_target(
    coarse_uni_match_filename,
    update_coarse_matches(raw_coarse_filename),
    format = "file"
  ),
  tar_target(
    intermediate_pass_filename,
    "tasks/university_covariates/hand/intermediate_pass.csv",
    format = "file"
  ),
  # then passed off to coders in a readable format
  tar_target(
    postprocess_filename,
    postprocess_names(
      cleaned_events,
      coarse_uni_match_filename,
      intermediate_pass_filename,
      glued_raw,
      ipeds_raw,
      canonical_event_relationship,
      canada_geo
    ),
    format = "file"
  ),
  # And read in again after they've made their edits
  tar_target(
    cleaned_xwalk_dribble,
    googledrive::drive_download(
      "https://docs.google.com/spreadsheets/d/14ms9FF6Zg0oZf6AQRqOHASbrx1zLprRh/edit#gid=480957682",
      tempfile()
    ),
    cue = tar_cue(mode = ifelse(
      Sys.getenv("DOWNLOAD_UNI_XWALK") %in% c('', 'false'),
      'never',
      'always'
    ))
  ),
  tar_target(
    uni_xwalk,
    readxl::read_excel(cleaned_xwalk_dribble$local_path)
  ),
  tar_target(
    second_pass_filename,
    export_second_pass(uni_xwalk, cleaned_events, ipeds_raw,
                       glued_raw, canada_geo)
  ),

  # Export Canadian universities for additional manual data input
  tar_target(
    canadian_universities_filename,
    export_canada(coarse_uni_match_filename, glued),
    format = "file"
  ),

  tar_target(
    integrated,
    integrate_targets(cleaned_events,
                      ipeds,
                      glued,
                      uni_xwalk,
                      covariates,
                      geo)
  ),

  # Can't figure out how to get targets loading to work with testthat working
  # directory situation
  tar_target(tests,
             lapply(
               list.files("tests", full.names = TRUE), source
             ),
             cue = tar_cue(mode = "always")),

  # Plotting and other exploratory analysis ---
  tar_render(exploratory, "docs/exploratory_plots.Rmd")
)
