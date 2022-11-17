# Analyses for the Student and Campus Protest Events Project

This repository contains data cleaning and analysis code for the Student
and Campus Protest Events Project. Any questions about the code here can
be directed towards Nathan Kim [@18kimn](https://github.com/18kimn) at
nathanckim18 [at] gmail.com.

### Prerequisites

Prior to working with this project, you must configure and/or install
the following dependencies.

- **ssh**. An SSH client establishes connections between different
  computers; in our case, it's the machine we run the pipeline on and
  the server that holds the database. Your personal computer likely
  already has an SSH client installed,[^1] but it needs to be configured
  with valid credentials to access the database server. Contact Dr.
  Hanna at alex[dot]hanna[at]gmail.com to have these provided.

  Once you obtain credentials, you should strongly consider creating and
  uploading SSH public key to the remote server to use passwordless
  login. This is convenient and also much more secure than password
  entry. One way to do so is by entering the following in a terminal:

  ```bash
  # only if you do not already have an SSH key pair on your computer
  ssh-keygen -t ed25519
  ssh-copy-id <YOUR_USERNAME>@sheriff.ssc.wisc.edu
  # you can also copy it to "cliff", but only sheriff is needed
  # for this project
  ssh-copy-id <YOUR_USERNAME>@cliff.ssc.wisc.edu
  ```

  Finally, enter your SSH username into a file called `.Renviron` at the
  root of the project:

  ```
  # .Renviron
  SSH_USERNAME=<YOUR_USERNAME>
  ```

- **MySQL clients and connectors.** The database itself runs on the
  remote server, but we need ways to talk to it and get that data.
  Follow the instructions [here](https://rmariadb.r-dbi.org) to install
  the relevant client and connector for your platform. On Windows you
  may skip this step entirely.

  Pro tip: On Arch, you should install
  [`mariadb-clients`](https://archlinux.org/packages/extra/x86_64/mariadb-clients/)
  and
  [`mariadb-connector-c`](https://aur.archlinux.org/packages/mariadb-connector-c).

- **A free port 3306.** This may sound strange, but **before** you run
  the pipeline, please check to make sure port 3306 on your local
  machine is open, or that entering `nc localhost 3306` in a terminal
  does not return anything. The most likely scenario is if you have
  another instance of MySQL or MariaDB open and they run on this port.

- **Google Maps API key**. This project geocodes protest data using the
  Google Maps Geocoding API. The Google Maps APIs require credentials;
  you should go ahead and create one by following the instructions
  [here](https://developers.google.com/maps/documentation/javascript/get-api-key#console).
  You may ignore the last step, it is handled by the code here.

  Once you create an API key, you should add it to the `.Renviron` file:

  ```
  # .Renviron
  SSH_USERNAME=<YOUR_USERNAME>
  GMAPS_API_KEY=<YOUR_API_KEY>
  ```

- **Census API Key**. The Census API also requires credentialed access;
  luckily it's quite easy to get. Visit
  [this link](http://api.census.gov/data/key_signup.html) to sign up for
  one, then place it in the `.Renviron` at the root of this project.

  If you already have a key and it is placed in your home directory's
  `.Renviron` file (if you use `tidycensus` elsewhere, you likely have
  already done this via `census_api_key()`), you may skip this step.

- Optionally set the `DOWNLOAD_MPEDS` variable in your `.Renviron` file to 
  any value other than "false" in order to force targets to download the MPEDS
  database each time the pipeline is run:
  
  ```
  # .Renviron
  SSH_USERNAME=<YOUR_USERNAME>
  GMAPS_API_KEY=<YOUR_API_KEY>
  DOWNLOAD_MPEDS="yes"
  ```
  
  - If the variable is not set, or set to `"false"`, the pipeline will download
  MPEDS data from our `sheriff` server once and will not continually check it for 
  updates again. Setting the variable ensures maximum reproducibility, but also 
  can be time-consuming to run the entire pipeline again and even result in 
  extra costs related to geocoding.
  - The switch is controlled through an environment variable so that the
  switch can be toggled without changes to source control-tracked files.

### Quickstart

In a terminal, first run:

```sh
git clone https://github.com/18kimn/campus-protests
cd campus-protests
```

Then I recommend opening the `campus-protests.Rproj` file through
whatever IDE you use for R, which is probably RStudio but could be
anything that respects the semantics of
[R projects](https://support.rstudio.com/hc/en-us/articles/200526207-Using-RStudio-Projects).
If the project is opened correctly, `renv` should begin the package
loading process to create the environment needed for this data
pipeline.[^2]

Then, to run the data pipeline, run `targets::tar_make()` in an R
console.

### Data sources

This repository integrates the Student and Campus Protest Events dataset
with several data sources:

- the Integrated Postsecondary Education Data System (IPEDS)
- Statistics Canada, Universities Canada, and Canadian Association of
  University Business Officers
- Elephrame and the Crowd Counting Consortium
- Tweets collected by

[^1]:
    unless you run Arch or another Linux variant that does not provide
    an SSH client by default, but if this applies to you, you already
    know enough about computers to not need my advice on installing it.

[^2]: `renv` is great, read more [here](https://rstudio.github.io/renv)
