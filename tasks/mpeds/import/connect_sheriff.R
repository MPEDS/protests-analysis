#' Connects, in a very hacky way, to the MySQL database on the server.
#' Please make sure you have port 3306 open, i.e. are not serving a local
#' MySQL or MariaDB instance.
#' @returns A database connection that can be used in calls to `tbl()` to
#' pull specific tables, and which can be readily manipulated using
#' conventional dplyr syntax.
connect_sheriff <- function(){
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
  session <- ssh::ssh_connect(paste0(user, "@sheriff.ssc.wisc.edu"))

  # grab database auth info
  invisible(ssh::scp_download(session,
               paste0("/home/", user, "/.my.cnf"),
               to = tempdir(),
               verbose = FALSE))
  ssh::ssh_disconnect(session)

  con <- RMariaDB::dbConnect(RMariaDB::MariaDB(),
                   dbname = "campus_protest_staging",
                   default.file = paste0(tempdir(), "/.my.cnf"),
                   host = "127.0.0.1",
                   port = 3306)

  invisible(file.remove(paste0(tempdir(), "/.my.cnf")))

  return(con)
}

