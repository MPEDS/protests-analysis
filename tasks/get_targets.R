get_targets <- function(){
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
