library(targets)
library(tarchetypes)

fn_filenames <- list.files("tasks", full.names = TRUE,
                           pattern = ".R",
                           recursive = TRUE)
invisible(lapply(fn_filenames, source))

tar_option_set(packages = c("tidyverse", "RMariaDB", "ssh",
                            "httr", "curl", "tidycensus"))

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
  tar_target(uni_pub_xwalk_file, format = "file",
             command = "tasks/mpeds/hand/uni_pub_xwalk.csv"),
  tar_target(events_wide, process_canonical_events(canonical_events, uni_pub_xwalk_file)),

  #tar_read(geocoded_cache_file, "tasks/mpeds/clean/geocoding_cache.RDS",
  #         format = "file"),
  #tar_read(geocoded_cache, readRDS(geocoded_cache_file)),
  tar_target(geocoded, get_protest_coords(events_wide)),

  tar_target(ccc_url, format = "url",
             command = "https://github.com/nonviolent-action-lab/crowd-counting-consortium/raw/master/ccc_compiled.csv"
             ),
  tar_target(ccc, get_ccc(ccc_url)),

  # County+year-level covariates ---
  tar_target(mhi_url, format = "url",
             command = get_mhi_urls()[1]
             ),
  tar_target(mhi, get_mhi(mhi_url)),

  tar_target(bls, get_bls()),
  tar_target(elephrame_blm, get_elephrame_blm()),

  tar_target(eviction_url, format = "url",
             command = "https://eviction-lab-data-downloads.s3.amazonaws.com/estimating-eviction-prevalance-across-us/county_proprietary_2000_2018.csv"
             ),
  tar_target(evictions, get_evictions(eviction_url)),
  tar_target(mit_elections, get_mit_elections()),

  # This queries the ACS, and doesn't depend on a URL,
  # so it will only be run once by the targets pipeline
  # IMO the ACS is stable enough not to update 2012-2018 data
  # But as with the first target we can force a run with `cue = ...`
  tar_target(acs, get_acs_indicators()),

  # school-level covariates ---
  tar_target(directory_url, format = "url", get_directory_url(2018)),
  tar_target(uni_directory, get_school_directory(directory_url)),

  tar_target(tuition_url, format = "url", get_tuition_url(2018)),
  tar_target(tuition, get_tuition(tuition_url)),

  # Integration steps ---
  # IPEDS and MPEDS
  # the `raw_names` target is meant to be cleaned by hand
  tar_target(raw_names, clean_mpeds_names(geocoded, uni_directory),
             format = "file"),
  # then passed off to coders in a readable format
  tar_target(postprocess_filename, postprocess_names(geocoded, "tasks/ipeds/hand/cleaned_ipeds_match.csv")),
  # and the cleaned version of `raw_names` will be read in from the below filename
  tar_target(ipeds_xwalk_filename,
             "tasks/ipeds/hand/cleaned_ipeds_match.csv",
             format = "file"),
  tar_target(ipeds_xwalk, match_ipeds(uni_directory, geocoded, ipeds_xwalk_filename
                                      )),

  tar_target(county_covariates, list(mhi, bls, evictions, mit_elections)),

  tar_target(integrated, integrate_targets(
    geocoded, uni_directory, ipeds_xwalk, county_covariates, ccc
    )),

  # Plotting and other exploratory analysis ---
  tar_render(exploratory, "docs/exploratory_plots.Rmd" )
)

