library(targets)
library(tarchetypes)
library(future)
library(crew)

# Load logic from various files to be executed here
source("tasks/utils/source_safely.R")
fn_filenames <- list.files(
  "tasks",
  full.names = TRUE,
  pattern = ".R",
  recursive = TRUE
)
invisible(lapply(fn_filenames, source_safely))

# Configure pipeline
plan(multisession, workers = parallel::detectCores() - 2)
tar_option_set(
  packages = c(
    "cluster",
    "curl",
    "zoo",
    "haven",
    "googledrive",
    "googleCloudStorageR",
    "httr",
    "janitor",
    "leaps",
    "nplyr",
    "readxl",
    "RMariaDB",
    "sf",
    "ssh",
    "testthat",
    "tidyverse",
    "tigris",
    "tidycensus"
  ),
  controller = crew_controller_local(workers = 4),
  repository = "gcp",
  resources = tar_resources(
    gcp = tar_resources_gcp(
      bucket = "mpeds_targets",
      prefix = "protests_analysis",
      verbose = TRUE,
      predefined_acl = "bucketLevel"),
  )
)

# Authenticate with GCP and Google Drive
# Prevent package from asking for sign-in options during a pipeline run
googledrive::drive_deauth()
googledrive::drive_auth_configure(api_key = Sys.getenv("GCP_API_KEY"))
dir.create(file.path(rappdirs::user_cache_dir(), "protests"), FALSE)

list(
  tar_target(canonical_events, get_canonical_events(),
             # set the DOWNLOAD_MPEDS variable in your .Renviron file
             # to force a download of the MPEDS database from the `sheriff` server
             # this lets us toggle the download on and off without changes to
             # source-control tracked files
             cue = tar_cue_if("DOWNLOAD_MPEDS")
             ),
  tar_target(
    canonical_event_relationship,
    get_canonical_event_relationship(canonical_events)
  ),

  # Hand-coding certain publications that don't match a university easily
  tar_target(uni_pub_hand_xwalk, format =
               "file",
             command = "tasks/mpeds/hand/uni_pub_xwalk.csv"),
  # An actual pre-made reference for university-publication-IPEDS that I was made aware of -
  tar_target(uni_pub_xwalk_reference,
             get_uni_pub_xwalk_reference("1LwWIMylixuo8cAFK1xQSS12jybQhLZQF06J40ggp-4A")
             ),

  tar_target(
    events_wide,
    process_canonical_events(canonical_events, uni_pub_hand_xwalk, uni_pub_xwalk_reference)
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
  tar_target(geo, bind_rows(us_geo, st_transform(canada_geo, st_crs(us_geo)))),

  tar_target(ccc, get_ccc()),

  # County+year-level covariates ---
  # Canada covariates unbearably slow because of rent burden
  # tar_target(canada_rentburden_raw, download_canada_rentburden()),
  # tar_target(canada_rentburden, get_canada_rentburden(canada_rentburden_raw, canada_geo)),
  #tar_target(canada_mhi, get_canada_mhi(canada_geo)),
  #tar_target(canada_covariates, get_canada_covariates(canada_rentburden, canada_mhi, canada_geo)),

  tar_target(us_covariates, list(
    get_us_nonwhite(),
    get_us_income(),
    # get_us_unemp(),
    get_us_rentburden(),
    get_us_elections()
  ) |>
    reduce(left_join, by = c("geoid", "year")) |>
    mutate(geoid = paste0("us_", geoid))),


  tar_target(covariates, us_covariates),

  tar_target(elephrame_blm, get_elephrame_blm()),

  # school-level covariates ---
  tar_target(ipeds_raw, get_ipeds_directory()),
  tar_target(ipeds_directory, clean_ipeds_directory(ipeds_raw)),
  tar_target(ipeds_tuition, get_ipeds_tuition()),
  tar_target(ipeds_instructional_gender, get_ipeds_instructional_gender()),
  tar_target(ipeds_instructional_race, get_ipeds_instructional_race()),
  tar_target(ipeds_race, get_ipeds_race()),
  tar_target(ipeds_finance, bind_rows(get_ipeds_finance_fasb(), get_ipeds_finance_gasb())),
  tar_target(ipeds_tenure, get_ipeds_tenure()),
  tar_target(ipeds_stem, get_ipeds_stem()),
  tar_target(ipeds_pell, get_ipeds_pell()),
  tar_target(ipeds, list(
    ipeds_directory,
    ipeds_tuition,
    ipeds_race,
    ipeds_pell,
    ipeds_finance,
    ipeds_stem,
    ipeds_tenure,
    ipeds_instructional_gender,
    ipeds_instructional_race
    ) |>
      combine_ipeds()),
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
  tar_target(initial_xwalk, read_googlesheet("14ms9FF6Zg0oZf6AQRqOHASbrx1zLprRh")$MPEDS,
    cue = tar_cue_if("DOWNLOAD_UNI_XWALK")
  ),
  # Second pass was necessary to clean up corner cases and such
  tar_target(
    second_pass_filename,
    export_second_pass(initial_xwalk, cleaned_events, ipeds_raw,
                       glued_raw, canada_geo)
  ),
  tar_target(second_xwalk, read_googlesheet("16yFZwTXfafr32l1oUttsTzojAruOgoqS"),
    cue = tar_cue_if("DOWNLOAD_UNI_XWALK"),
  ),
  tar_target(uni_xwalk, create_uni_xwalk(initial_xwalk, second_xwalk)),

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
  tar_target(
    audited_names,
    audit_university_names(integrated)
  ),

  # Modeling (in progress, a bit messy/in flux in terms of data structures)
  tar_target(
    timeseries,
    create_timeseries(
      integrated,
      canonical_event_relationship,
      ipeds,
      us_covariates,
      uni_pub_xwalk_reference,
      us_geo
    )
  ),

  tar_target(
    logit_results,
    run_logit(
      integrated,
      canonical_event_relationship,
      ipeds,
      us_covariates,
      uni_pub_xwalk_reference
    )
  ),

  # Can't figure out how to get targets loading to work with testthat working
  # # directory situation
  # tar_target(tests,
  #            lapply(
  #              list.files("tests", full.names = TRUE), source
  #            ),
  #            cue = tar_cue(mode = "always")),

  # Plotting and other exploratory analysis ---
  tar_render(exploratory, "docs/exploratory-plots/exploratory_plots.Rmd")
)

