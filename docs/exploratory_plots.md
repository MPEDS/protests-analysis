Exploratory Plots
================

``` r
mpeds_raw <- tar_read(canonical_events)
mpeds <- tar_read(integrated)
```

# Basic counts

``` r
mpeds_raw_ids <- length(unique(mpeds_raw$canonical_id))
mpeds_ids <- length(unique(mpeds$canonical_id))
n_locations <- length(unique(mpeds$location))
n_fips <- length(unique(mpeds$fips))
n_universities <- length(unique(mpeds$university))

missing_unis <- mpeds$university_locations |>
  bind_rows() |>
  filter(is.na(lat), !is.na(location))
n_missing_uni_rows <- nrow(missing_unis)
n_missing_unis <- missing_unis$location |>
  unique() |> 
  length()
```

The initial import of the MPEDS db found 5220 unique canonical events,
and after all cleaning steps we still have 5220 canonical events.

However, there’s still an issue regarding duplicate matches in IPEDS we
can detect (there are likely also incorrect matches that we can’t detect
programmatically right now); there are lots of schools called “Columbia
College” (or another common name) inside IPEDS, so any schools with that
name in MPEDS will be assigned multiple schools. The MPEDS-IPEDS join is
crucial because we also use IPEDS to join county FIPS identifiers, and
thus no further joins will be accurate unless the MPEDS-IPEDS join is
accurate. We currently have 5578 rows in the final dataset, indicating
that this problem applies to some 358 canonical events.

Fixing it just requires a rewrite of how the join is done, so that we
join on IPEDS IDs, not names, for at least all ambiguous cases. This
doesn’t require adjustments to the instructions given to student coders,
but it does require a little bit of time on my part, so it hasn’t been
completed yet.

Of those events, there were 517 unique locations, 251 unique counties,
and 557 unique universities. Surprisingly, all of the locations that
were not universities found geocoding matches, and hand-checking the
most common ones indicates that there isn’t a strong pattern of missing
value substitution, e.g. Google isn’t sending the majority of results to
the centroid of America or to `(-1, -1)` or anything weird like that.
Universities had a harder time, with 20 universities and 190 rows
(canonical events) not returning lon/lat coords for universities.

That comes out to \~5% of universities not having coordinates, and
\~2.5% of canonical events not having universities with coordinates.

The top universities by appearances:

``` r
university_counts <- mpeds |> 
  group_by(university) |> 
  count() |> 
  ungroup() |> 
  drop_na() |>
  slice_max(order_by = n, n = 15)

kable(university_counts)
```

| university                                  |   n | geometry                     |
|:--------------------------------------------|----:|:-----------------------------|
| University of California-Berkeley           | 184 | MULTIPOINT ((-121.7405 38.5… |
| McGill University                           | 154 | MULTIPOINT ((-66.06331 45.2… |
| Concordia University                        | 146 | MULTIPOINT ((-71.89367 45.4… |
| Harvard University                          | 145 | MULTIPOINT ((-91.53462 41.6… |
| University of Michigan-Ann Arbor            | 122 | MULTIPOINT ((-84.48387 42.7… |
| University of California-Los Angeles        |  86 | MULTIPOINT ((-122.273 37.87… |
| University of Toronto                       |  69 | MULTIPOINT ((-60.19422 46.1… |
| University of Chicago                       |  66 | POINT (-87.6298 41.87811)    |
| Ryerson University                          |  56 | MULTIPOINT ((-75.69719 45.4… |
| Columbia University in the City of New York |  49 | MULTIPOINT ((-72.28955 43.7… |
| Tufts University                            |  49 | MULTIPOINT ((-71.05888 42.3… |
| University of Wisconsin-Madison             |  49 | MULTIPOINT ((-96.49815 41.4… |
| Georgetown University                       |  48 | POINT (-77.03687 38.90719)   |
| The University of Texas at Austin           |  47 | MULTIPOINT ((-97.74306 30.2… |
| Cornell University                          |  46 | MULTIPOINT ((-76.50188 42.4… |

And the top locations:

``` r
location_counts <- mpeds |> 
  group_by(location) |> 
  count() |> 
  ungroup() |> 
  drop_na() |> 
  slice_max(order_by = n, n = 15)

kable(location_counts)
```

| location               |   n | geometry                   |
|:-----------------------|----:|:---------------------------|
| Montreal, QC, Canada   | 352 | POINT (-73.56739 45.50189) |
| New York City, NY, USA | 172 | POINT (-74.00597 40.71278) |
| Berkeley, CA, USA      | 170 | POINT (-122.273 37.87152)  |
| Toronto, ON, Canada    | 157 | POINT (-79.38318 43.65323) |
| Cambridge, MA, USA     | 139 | POINT (-71.10973 42.37362) |
| Chicago, IL, USA       | 133 | POINT (-87.6298 41.87811)  |
| Los Angeles, CA, USA   | 121 | POINT (-118.2437 34.05223) |
| Ann Arbor, MI, USA     | 113 | POINT (-83.74304 42.28083) |
| San Diego, CA, USA     |  77 | POINT (-117.1611 32.71574) |
| San Francisco, CA, USA |  76 | POINT (-122.4194 37.77493) |
| Boston, MA, USA        |  61 | POINT (-71.05888 42.36008) |
| Washington, D.C., USA  |  58 | POINT (-77.03687 38.90719) |
| Madison, WI, USA       |  48 | POINT (-89.40075 43.07217) |
| Davis, CA, USA         |  47 | POINT (-121.7405 38.54491) |
| Ithaca, NY, USA        |  47 | POINT (-76.50188 42.44396) |

Top states:

``` r
state_fips <- fips_codes |> 
  select(state_code, state_name) |> 
  distinct()

state_counts <- mpeds |> 
  mutate(state_code = str_sub(fips, 1, 2)) |> 
  group_by(state_code) |> 
  count() |> 
  ungroup() |> 
  drop_na() |> 
  slice_max(order_by = n, n = 15) |> 
  left_join(state_fips, by = "state_code") |> 
  select(-state_code)
  
kable(state_counts)
```

|   n | geometry                     | state_name           |
|----:|:-----------------------------|:---------------------|
| 562 | MULTIPOINT ((-121.8375 39.7… | California           |
| 341 | MULTIPOINT ((-105.2705 40.0… | Massachusetts        |
| 228 | MULTIPOINT ((-155.5828 19.8… | Illinois             |
| 172 | MULTIPOINT ((-84.34759 46.4… | Michigan             |
| 163 | MULTIPOINT ((-73.45291 44.6… | New York             |
| 142 | MULTIPOINT ((-96.79699 32.7… | Pennsylvania         |
| 113 | MULTIPOINT ((-79.94143 37.2… | District of Columbia |
| 111 | MULTIPOINT ((-119.8143 39.5… | Virginia             |
| 108 | MULTIPOINT ((-119.6982 34.4… | Florida              |
| 103 | MULTIPOINT ((-95.3698 29.76… | Texas                |
|  96 | MULTIPOINT ((-77.03687 38.9… | Connecticut          |
|  79 | MULTIPOINT ((-122.3321 47.6… | Wisconsin            |
|  77 | MULTIPOINT ((-85.38636 40.1… | Ohio                 |
|  72 | MULTIPOINT ((-81.67455 36.2… | North Carolina       |
|  59 | MULTIPOINT ((-122.4443 47.2… | Washington           |

And finally the top counties:

``` r
county_fips <- fips_codes |> 
  mutate(fips = paste0(state_code, county_code),
         county_name = paste0(county, ", ", state_name)) |> 
  select(fips, county_name)

county_counts <- mpeds |> 
  group_by(fips) |> 
  count() |> 
  ungroup() |> 
  drop_na() |> 
  slice_max(order_by = n, n = 15) |> 
  left_join(county_fips, by = "fips") |> 
  select(-fips)
  
kable(county_counts)
```

|   n | geometry                     | county_name                                |
|----:|:-----------------------------|:-------------------------------------------|
| 238 | MULTIPOINT ((-105.2705 40.0… | Middlesex County, Massachusetts            |
| 188 | MULTIPOINT ((-121.7405 38.5… | Alameda County, California                 |
| 128 | MULTIPOINT ((-87.6298 41.87… | Cook County, Illinois                      |
| 126 | MULTIPOINT ((-84.48387 42.7… | Washtenaw County, Michigan                 |
| 113 | MULTIPOINT ((-79.94143 37.2… | District of Columbia, District of Columbia |
|  80 | MULTIPOINT ((-118.2551 34.1… | Los Angeles County, California             |
|  63 | POINT (-74.00597 40.71278)   | New York County, New York                  |
|  59 | MULTIPOINT ((-121.7405 38.5… | San Diego County, California               |
|  56 | MULTIPOINT ((-122.4194 37.7… | San Francisco County, California           |
|  49 | MULTIPOINT ((-96.49815 41.4… | Dane County, Wisconsin                     |
|  48 | MULTIPOINT ((-92.17352 38.5… | Boone County, Missouri                     |
|  48 | MULTIPOINT ((-76.50188 42.4… | Tompkins County, New York                  |
|  47 | MULTIPOINT ((-122.0322 37.3… | Santa Clara County, California             |
|  47 | MULTIPOINT ((-97.74306 30.2… | Travis County, Texas                       |
|  42 | MULTIPOINT ((-71.80229 42.2… | Hampshire County, Massachusetts            |

These glimpses seem mostly in line with what we should expect, with a
strong caveat that the Missouri protests are not making a leading
appearance here. That’s a bit alarming; some playing around with the
dataset reveals there are a fair number of protests both in Missouri and
at University of Missouri-Columbia. There could still be errors here, so
I’m continuing to revise the code.

# Basic summary plots

``` r
mpeds |> st_drop_geometry() |> 
  select(where(function(x){is.numeric(x) || is.logical(x)}),
                 -canonical_id, -starts_with("location"),
                 -year, -uni_id, -size_category, -link) |> 
  pivot_longer(cols = everything()) |> 
  filter(name != "NA") |> 
  group_by(name) |> 
  summarize(
    type = ifelse(is.numeric(pull(mpeds[name[1]], 1)), "numeric", "boolean"),
    mean = mean(value, na.rm = TRUE),
    sd = sd(value, na.rm = TRUE)
  ) |> 
  mutate(across(where(is.numeric), ~round(., 3))) |> 
  arrange(type) |> 
  kable()
```

| name                    | type    |      mean |        sd |
|:------------------------|:--------|----------:|----------:|
| bachelors_granting      | boolean |     1.000 |     0.000 |
| campaign                | boolean |     0.248 |     0.432 |
| counterprotest          | boolean |     0.042 |     0.201 |
| hbcu                    | boolean |     0.010 |     0.099 |
| inaccurate_date         | boolean |     0.008 |     0.090 |
| masters_granting        | boolean |     1.000 |     0.000 |
| multiple_cities         | boolean |     0.027 |     0.163 |
| notes.y                 | boolean |       NaN |        NA |
| off_campus              | boolean |     0.067 |     0.250 |
| on_campus_no_student    | boolean |     0.071 |     0.257 |
| phd_granting            | boolean |     1.000 |     0.000 |
| private                 | boolean |     0.125 |     0.336 |
| quotes                  | boolean |     0.645 |     0.478 |
| ritual                  | boolean |     0.032 |     0.177 |
| tribal                  | boolean |     0.001 |     0.025 |
| enrollment_count        | numeric | 36583.172 |  9991.500 |
| eviction_filing_rate    | numeric |     4.029 |     5.174 |
| eviction_judgement_rate | numeric |     1.579 |     1.585 |
| mhi                     | numeric | 65260.556 | 17706.571 |
| republican_vote_prop    | numeric |     0.311 |     0.150 |
| unemp                   | numeric |     4.680 |     1.466 |

``` r
mpeds |> 
  st_drop_geometry() |> 
  select(where(is.numeric), -canonical_id, -starts_with("location"),
                 -year, -uni_id, -size_category) |> 
  pairs()
```

![](exploratory_plots_files/figure-gfm/pairs-1.png)<!-- -->

For boolean variables, “mean” is the proportion that they are TRUE. Many
of the variables recorded in MPEDS allowed for the input of multiple
values, so those are handled as list-cols and not shown here.

# Trying out CCC joins

To recap from our last conversation, it’s a bit difficult to join the
CCC data and our data since a lot of MPEDS data points could presumably
be in the CCC records. Then CCC data could be telling us that there was
a protest in the same county, when it could just be talking about the
same protest in MPEDS and essentially be turning data quality into
another covariate.

We discussed two solutions to this problem to avoid deduplication:

-   Join so that CCC protests occurring one, three, five, or seven days
    before the MPEDS protest date are matched; the CCC variable then
    conceptually becomes “was there a recent protest in the same
    county.” Thus protests won’t find a match only because of duplicates
-   Join only after filtering the CCC dataset so that rows with keywords
    related to universities are kicked out – things like teachers,
    faculty, students, colleges, universities. This is less ideal than
    the above strategy because it is so nonspecific, potentially missing
    many university matches and kicking out protests related to primary
    and secondary schools.

The following chunk gives a glimpse at total number of matches:

``` r
ccc <- tar_read(ccc) |> 
  distinct() |> 
  rename(protest_date = ccc_protest_date)

blm <- tar_read(elephrame_blm) |> 
  distinct() |> 
  rename(protest_date = blm_protest_date)

test_date_diffs <- function(protests){
  # a version where dates are a list-col, to assist in the testing below
  dates <- protests |> 
    group_by(fips) |> 
    summarize(dates_lst = list(protest_date))
  
  # return a TRUE value if any protests in `vec` occurred between 
  # a given date and `diff` days after that date
  compute_protests <- function(vec, date, diff){
    if(is.na(date)) return(NA)
    any(vec %in% (date + 1):(diff + date))
  }
  
  match_date_diff <- function(diff){
    diffed_protests <- protests |> 
      left_join(dates, by = "fips") |> 
      mutate(
        dummy = unlist(map2(
          dates_lst, protest_date,
          function(x,y){compute_protests(x, y, diff)}
        ))
      )
    
    joined <- mpeds |> 
      left_join(
        diffed_protests, by = c("start_date" = "protest_date", "fips")
        ) 
    
    n_matches <- sum(joined$dummy, na.rm = TRUE)
    
    tribble(~date_offset, ~recent_protests, ~match_percentage,
            diff, n_matches, 100 * n_matches/nrow(joined)
            )
  }
  return(map_dfr(c(0, 1,3,5,7), match_date_diff))
}

match_results <- map_dfr(list("CCC" = ccc, "Elephrame" = blm),
                         test_date_diffs, .id = "source")

kable(match_results)
```

| source    | date_offset | recent_protests | match_percentage |
|:----------|------------:|----------------:|-----------------:|
| CCC       |           0 |             478 |         8.569380 |
| CCC       |           1 |             121 |         2.169236 |
| CCC       |           3 |             210 |         3.764790 |
| CCC       |           5 |             265 |         4.750807 |
| CCC       |           7 |             301 |         5.396199 |
| Elephrame |           0 |             254 |         4.505144 |
| Elephrame |           1 |              74 |         1.312522 |
| Elephrame |           3 |             107 |         1.897836 |
| Elephrame |           5 |             120 |         2.128414 |
| Elephrame |           7 |             125 |         2.217098 |

So it seems that there are a fair number of duplicates occurring if we
don’t have a date offset, but once we add one (of any days) that pretty
much solves the data quality issue.

That being said, the likely larger problem with the CCC data is that
it’s only available after 2017, so it may not be relevant even after we
become satisfied with the deduped match process. This can be refined a
little bit by adding in Elephrame data on BLM protests, but we’ve had
problems there already, the topic differences mean we can’t pretend we
have complete data, Elephrame only begins in 2014, and I haven’t
actually joined it in yet.

# Maps and related things

``` r
county_sf <- counties(keep_zipped_shapefile = TRUE, progress_bar = FALSE) |> 
  select(fips = GEOID)
us_sf <- states(progress_bar = FALSE) |> 
  filter(!(NAME %in% c("Hawaii", "Puerto Rico", "American Samoa", 
                       "United States Virgin Islands", 
                       "Commonwealth of the Northern Mariana Islands",
                       "Alaska", "Guam"))) |> 
  st_union()
```

``` r
mpeds |> 
  st_transform(st_crs(county_sf)) |>
  mutate(geometry = st_jitter(geometry, factor = 0.005)) |> 
  ggplot() + 
  geom_sf(data = us_sf, fill = "white", color = "gray") + 
  geom_sf(size = 0.1, alpha = 0.2) + 
  lims(
    x = c(-130, -60),
    y = c(20, 55)
  ) +
  labs(
    title = "Spread of canonical events and geocoded locations",
    subtitle = "Locations jittered slightly, by 0.005*bounding box diagonal.",
    caption = "Alaska, Hawaii, a few other locations with only a\nfew protests excluded in this map only."
  ) + 
  theme_void() + 
  theme(text = element_text(family = "Lato"),
        plot.title = element_text(size = 20))
```

![](exploratory_plots_files/figure-gfm/mpeds_map-1.png)<!-- -->
