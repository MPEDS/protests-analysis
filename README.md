# Analyses for the Student and Campus Protest Events Project

This repository contains data cleaning and analysis code for
the Student and Campus Protest Events Project. Any questions
about the code here can be directed towards Nathan Kim
[@18kimn](https://github.com/18kimn) at nathanckim18
[at] gmail.com.

### Quickstart

In a terminal:

```sh
git clone https://github.com/18kimn/campus-protests
cd campus-protests
```

Then I recommend opening the `campus-protests.Rproj` file through whatever IDE
you use for R, which is probably RStudio but could anything
that works with R projects. Upon opening, `renv` should begin
the package loading process to create the environment needed
for the process.[^1]

Then, to run the data pipeline, run `targets::tar_make()` in an R
console.

### Data sources

This repository integrates the Student and Campus Protest
Events dataset with several data sources:

- the Integrated Postsecondary Education Data System (IPEDS)
- Statistics Canada, Universities Canada, and Canadian
  Association of University Business Officers
- Elephrame and the Crowd Counting Consortium
- Tweets collected by

[^1]:
    `renv` is great, read more
    [here](https://rstudio.github.io/renv)
