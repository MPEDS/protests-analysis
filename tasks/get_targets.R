upload_targets <- function(){
  paste0(
    "You are about to upload your local _targets directory to `sheriff`, ",
    "which will overwrite the contents of the directory on that server. "
  ) |>
    str_wrap() |>
    message()

  confirmation <- readline("Enter 'y' to proceed; input anything else to quit: ")

  if(confirmation != "y"){
    stop(paste0("Needed 'y' to proceed, received: ", confirmation))
  }

  user <- Sys.getenv("SSH_USERNAME")
  if(user == ""){
    stop("Must supply a username via the SSH_USERNAME environment variable.
         Check out README.md for more.")
  }

  session <- ssh_connect(paste0(user, "@sheriff.ssc.wisc.edu"))
  scp_upload(session, "_targets", "/var/www/protests_analysis")
}

download_targets <- function(){
  if(dir.exists("_targets")){
    stop("It looks like you already have a targets directory!
         If you really want to download targets from `sheriff`,
         please delete the `_targets` directory first.")
  }
  user <- Sys.getenv("SSH_USERNAME")
  if(user == ""){
    stop("Must supply a username via the SSH_USERNAME environment variable.
         Check out README.md for more.")
  }

  session <- ssh_connect(paste0(user, "@sheriff.ssc.wisc.edu"))
  scp_download(session, "/var/www/protests_analysis/_targets")
}
