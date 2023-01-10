# an attempt at a reproducible data retrieval process
# a tough task because balancing programmability/reproducibility
# with security, and because ssh is a shell/C thing
# this may be overhauled in favor of something else later on
get_coder_table <- function(){
  user <- Sys.getenv("SSH_USERNAME")
  if(user == ""){
    stop("Must supply a username via the SSH_USERNAME environment variable.
         Check out README.md for more.")
  }

  session <- ssh_connect(paste0(user, "@sheriff.ssc.wisc.edu"))
  message("Logged into server!")

  exports_location <- "/var/www/campus_protest/exports/"
  get_last_file <- paste0("ls -tr ", exports_location, " | tail -1")
  last_file <- session |>
    ssh_exec_internal(get_last_file) |>
    pluck("stdout") |>
    rawToChar() |>
    str_trim()

  date <- str_extract(last_file, "([0-9]){4}-([0-9]){2}-([0-9]){2}")
  message("Now downloading MPEDS dataset current to ", date, "...")
  scp_download(session,
               paste0(exports_location, last_file),
               to = tempdir())
  ssh_disconnect(session)

  tempdir() |>
    paste0("/", last_file) |>
    read_csv()
}
