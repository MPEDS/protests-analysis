library(targets)

fn_filenames <- list.files("tasks", full.names = TRUE,
                           pattern = ".R",
                           recursive = TRUE)
invisible(lapply(fn_filenames, source))

tar_option_set(packages = c("tidyverse", "RMariaDB", "ssh",
                            "httr", "curl", "tidycensus"))

list(
  tar_target(canonical_events, get_canonical_events(),
            # uncomment cue = ... to force an update when we want
            # to refresh data, since `targets` has no knowledge
            # of changes on the server and won't update the data
            # on its own
            # cue = tar_cue(mode = "always")
     ),
  tar_target(uni_pub_xwalk_file, format = "file",
             command = "tasks/mpeds/hand/uni_pub_xwalk.csv"),
  tar_target(events_wide, process_canonical_events(canonical_events, uni_pub_xwalk_file)),
  tar_target(geocoded, get_protest_coords(events_wide)),

  tar_target(ccc_url, format = "url",
             command = "https://github.com/nonviolent-action-lab/crowd-counting-consortium/raw/master/ccc_compiled.csv"
             ),
  tar_target(ccc, get_ccc(ccc_url)),

  tar_target(mhi_url, format = "url",
             command = get_mhi_urls()[1]
             ),
  tar_target(mhi, get_mhi(mhi_url)),

  tar_target(eviction_url, format = "url",
             command = "https://eviction-lab-data-downloads.s3.amazonaws.com/estimating-eviction-prevalance-across-us/county_proprietary_2000_2018.csv"
             ),
  tar_target(evictions, get_evictions(eviction_url)),

  # This queries the ACS, and doesn't depend on a URL,
  # so it will only be run once by the targets pipeline
  # IMO the ACS is stable enough not to update 2012-2018 data
  # But as with the first target we can force a run with `cue = ...`
  tar_target(acs, get_acs_indicators()),

  tar_target(directory_url, get_directory_url(2018)),
  tar_target(uni_directory, get_school_directory(directory_url)),

  tar_target(tuition_url, get_tuition_url(2018)),
  tar_target(tuition, get_tuition(tuition_url))

  # tar_target(mit_elections_url, get_mit_elections_url()),
  #tar_target(mit_elections, get_mit_elections(mit_elections_url))
)

