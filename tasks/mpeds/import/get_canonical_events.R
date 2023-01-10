get_canonical_events <- function(){
  user <- Sys.getenv("SSH_USERNAME")
  if(user == ""){
    stop("Must supply a username via the SSH_USERNAME environment variable.
         Check out README.md for more.")
  }

  # async ssh session needed for tunneling (for database access)
  # can't use ssh::ssh_tunnel because it closes after passing a
  # single request (which is so silly??)
  make_tunnel <- paste0("ssh -L 3306:localhost:3306 ",
                        user, "@sheriff.ssc.wisc.edu -fN")
  system(make_tunnel, intern = TRUE)

  # wait 1 second at a time while connection is being established
  is_connected <- FALSE
  while(!is_connected){
    tryCatch({
      con <- suppressWarnings(socketConnection(port = 3306))
      is_connected <- TRUE
      close(con)
      # if fails, means nothing is sending on port 3306
      # so we just try again until it does (:
    }, error = function(e){ Sys.sleep(1) })
  }

  # R-interfacing ssh session useful for downloading specific files
  session <- ssh_connect(paste0(user, "@sheriff.ssc.wisc.edu"))

  # grab database auth info
  invisible(scp_download(session,
               paste0("/home/", user, "/.my.cnf"),
               to = tempdir(),
               verbose = FALSE))
  ssh_disconnect(session)

  con <- dbConnect(MariaDB(),
                   dbname = "campus_protest_staging",
                   default.file = paste0(tempdir(), "/.my.cnf"),
                   host = "127.0.0.1",
                   port = 3306)
  invisible(file.remove(paste0(tempdir(), "/.my.cnf")))

  # Merging:
  # `article_metadata`: Provides publication name so we can
  #   create some auxiliary or backup location variables
  # `coder_event_creator`: dataset of candidate events, or events
  # gleaned from articles pre-creation of canonical events
  # `canonical_event_link`: A crosswalk of which properties in the
  #   above dataset correspond to canonical events
  # `canonical_event`: Data containing canonical events, which
  # are made from the combined properties of candidate events

  # Must attach canonical event ID in advance, for now
  # attaching it to the location because
  # articles aren't attached by coders
  article_metadata <- tbl(con, "article_metadata") |>
    select(article_id = id, publication) |>
    mutate(variable = "location") |>
    left_join(tbl(con, "coder_event_creator"),
               by = c("article_id", "variable")) |>
    filter(variable == "location") |>
    select(publication, cec_id = id) |>
    filter(!is.na(cec_id)) |>
    inner_join(tbl(con, "canonical_event_link"), by = "cec_id") |>
    select(-timestamp, -cec_id, -id, -coder_id) |>
    distinct()

  canonical_events <- tbl(con, "coder_event_creator") |>
    select(-coder_id, -timestamp, -article_id) |>
    rename(cec_id = id) |>
    right_join(tbl(con, "canonical_event_link"), by = "cec_id") |>
    select(-coder_id, -id) |>
    right_join(tbl(con, "canonical_event"),
               by = c("canonical_id" = "id")) |>
    select(-last_updated, -coder_id, -timestamp) |>
    left_join(article_metadata, by = "canonical_id") |>
    collect()

  return(canonical_events)
}
