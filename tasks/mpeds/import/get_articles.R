get_articles <- function(){
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

  articles <- tbl(con, "article_metadata")
  coder_event_creator <- tbl(con, "coder_event_creator") %>%
    select(article_id, event_id) %>%
    distinct()

  articles <- articles %>%
    left_join(coder_event_creator, by = c("id" = "article_id")) %>%
    collect()
  return(articles)
}
