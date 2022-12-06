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

missing_unis <- mpeds$university_locations %>%
  bind_rows() %>%
  filter(is.na(lat), !is.na(location))
n_missing_uni_rows <- nrow(missing_unis)
n_missing_unis <- missing_unis$location %>%
  unique() %>% 
  length()
```

The initial import of the MPEDS db found 5220 unique canonical events,
and after all cleaning steps we still have 5220 canonical events.

However, there’s still an issue regarding duplicate matches in IPEDS we
can detect; there are lots of schools called “Columbia College” inside
IPEDS, so any schools with that name in MPEDS will be assigned multiple
schools. The MPEDS-IPEDS join is crucial because we also use IPEDS to
join county FIPS identifiers, and thus no further joins will be accurate
unless the MPEDS-IPEDS join is accurate. We currently have 5260 rows in
the final dataset, indicating that this problem applies to some 40
canonical events.

Fixing it just requires a rewrite of how the join is done, so that we
join on IDs, not names, for at least all ambiguous cases. This doesn’t
require adjustments to the instructions given to student coders, but it
does require a little bit of time on my part, so it hasn’t been
completed yet.

Of those events, there were 517 unique locations, 291 unique counties,
and 422. Surprisingly, all of the locations that were not universities
found geocoding matches, and hand-checking the most common ones
indicates that there isn’t a strong pattern of missing value
substitution, e.g. Google isn’t sending the majority of results to the
centroid of America or to `(-1, -1)` or anything weird like that.
Universities had a harder time, with 23 universities and 133 rows
(canonical events) not returning lon/lat coords. That comes out to \~5%
of universities not having coordinates, and \~2.5% of canonical events
not having universities with coordinates.

The top universities by appearances:

``` r
university_counts <- mpeds %>% 
  group_by(university) %>% 
  count() %>% 
  ungroup() %>% 
  drop_na() %>% 
  slice_max(order_by = n, n = 15)

kable(university_counts)
```

| university                                  |   n |
|:--------------------------------------------|----:|
| University of California-Berkeley           | 179 |
| Harvard University                          | 139 |
| University of Michigan-Ann Arbor            | 120 |
| University of California-Los Angeles        |  82 |
| University of Chicago                       |  65 |
| University of California-Davis              |  50 |
| University of Wisconsin-Madison             |  49 |
| Tufts University                            |  48 |
| Columbia University in the City of New York |  47 |
| The University of Texas at Austin           |  46 |
| Cornell University                          |  44 |
| Georgetown University                       |  44 |
| New York University                         |  42 |
| University of Illinois at Urbana-Champaign  |  39 |
| Rutgers University-New Brunswick            |  38 |
| University of Colorado Boulder              |  38 |
| University of Miami                         |  38 |

And the top locations:

``` r
location_counts <- mpeds %>% 
  group_by(location) %>% 
  count() %>% 
  ungroup() %>% 
  drop_na() %>% 
  slice_max(order_by = n, n = 15)

kable(location_counts)
```

| location               |   n |
|:-----------------------|----:|
| Montreal, QC, Canada   | 301 |
| Berkeley, CA, USA      | 162 |
| New York City, NY, USA | 148 |
| Toronto, ON, Canada    | 142 |
| Cambridge, MA, USA     | 132 |
| Chicago, IL, USA       | 124 |
| Los Angeles, CA, USA   | 113 |
| Ann Arbor, MI, USA     | 111 |
| San Francisco, CA, USA |  69 |
| San Diego, CA, USA     |  68 |
| Boston, MA, USA        |  57 |
| Washington, D.C., USA  |  56 |
| Madison, WI, USA       |  48 |
| Davis, CA, USA         |  47 |
| Ithaca, NY, USA        |  46 |

And finally the top counties:

``` r
county_fips <- fips_codes %>% 
  mutate(fips = paste0(state_code, county_code),
         county_name = paste0(county, ", ", state_name)) %>% 
  select(fips, county_name)

county_counts <- mpeds %>% 
  group_by(fips) %>% 
  count() %>% 
  ungroup() %>% 
  drop_na() %>% 
  slice_max(order_by = n, n = 15) %>% 
  left_join(county_fips, by = "fips") %>% 
  select(-fips)
  
kable(county_counts)
```

|   n | county_name                                |
|----:|:-------------------------------------------|
| 238 | Middlesex County, Massachusetts            |
| 185 | Los Angeles County, California             |
| 184 | Alameda County, California                 |
| 127 | Cook County, Illinois                      |
| 122 | Washtenaw County, Michigan                 |
| 120 | New York County, New York                  |
| 107 | District of Columbia, District of Columbia |
|  79 | San Diego County, California               |
|  63 | San Francisco County, California           |
|  50 | Yolo County, California                    |
|  49 | Dane County, Wisconsin                     |
|  46 | Tompkins County, New York                  |
|  46 | Travis County, Texas                       |
|  44 | Santa Clara County, California             |
|  43 | Boone County, Missouri                     |

These glimpses seem mostly in line with what we should expect, with a
strong caveat that the Missouri protests are not making an appearance
here. That’s a bit alarming, so I’ll look into that.

# Basic summary plots

``` r
mpeds %>% select(where(function(x){is.numeric(x) || is.logical(x)}),
                 -canonical_id, -starts_with("location"),
                 -year, -uni_id, -size_category, -link) %>% 
  pivot_longer(cols = everything()) %>% 
  filter(name != "NA") %>% 
  group_by(name) %>% 
  summarize(
    type = ifelse(is.numeric(pull(mpeds[name[1]], 1)), "numeric", "boolean"),
    mean = mean(value, na.rm = TRUE),
    sd = sd(value, na.rm = TRUE)
  ) %>% 
  mutate(across(where(is.numeric), ~round(., 3))) %>% 
  arrange(type) %>% 
  kable()
```

| name                    | type    |      mean |        sd |
|:------------------------|:--------|----------:|----------:|
| campaign                | boolean |     0.235 |     0.424 |
| counterprotest          | boolean |     0.044 |     0.205 |
| hbcu                    | boolean |     0.008 |     0.087 |
| inaccurate_date         | boolean |     0.009 |     0.093 |
| multiple_cities         | boolean |     0.025 |     0.155 |
| off_campus              | boolean |     0.069 |     0.253 |
| on_campus_no_student    | boolean |     0.071 |     0.258 |
| quotes                  | boolean |     0.650 |     0.477 |
| ritual                  | boolean |     0.033 |     0.178 |
| tribal                  | boolean |     0.000 |     0.016 |
| eviction_filing_rate    | numeric |     3.936 |     5.536 |
| eviction_judgement_rate | numeric |     1.497 |     1.527 |
| mhi                     | numeric | 64936.340 | 16919.497 |
| republican_vote_prop    | numeric |     0.321 |     0.152 |
| unemp                   | numeric |     4.693 |     1.515 |

``` r
mpeds %>% select(where(is.numeric), -canonical_id, -starts_with("location"),
                 -year, -uni_id, -size_category) %>% 
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
ccc <- tar_read(ccc) %>% 
  distinct()
# a version where dates are a list-col, to assist in the testing below
ccc_dates <- ccc %>% 
  group_by(fips) %>% 
  summarize(dates_lst = list(ccc_protest_date))

# return a TRUE value if any protests occurred between 
# a given date and `diff` days from that date
compute_protests <- function(vec, date, diff){
  if(is.na(date)) return(NA)
  any(vec %in% (date + 1):(diff + date))
}

match_date_diff <- function(diff){
  ccc_diff <- ccc %>% 
    left_join(ccc_dates, by = "fips") %>% 
    mutate(
      ccc_dummy = unlist(map2(
        dates_lst, ccc_protest_date,
        function(x,y){compute_protests(x, y, diff)}
      ))
    )
  
  joined <- mpeds %>% 
    left_join(
      ccc_diff, by = c("start_date" = "ccc_protest_date", "fips")
      ) 
  
  joins <- sum(joined$ccc_dummy, na.rm = TRUE)
  
  tribble(~date_offset, ~recent_protests, ~match_percentage,
          diff, joins, 100 * joins/nrow(joined)
          )
}

map_dfr(c(0, 1,3,5,7), match_date_diff) %>% 
  kable()
```

| date_offset | recent_protests | match_percentage |
|------------:|----------------:|-----------------:|
|           0 |             554 |        10.532319 |
|           1 |             150 |         2.851711 |
|           3 |             251 |         4.771863 |
|           5 |             324 |         6.159696 |
|           7 |             372 |         7.072243 |

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
county_sf <- counties(keep_zipped_shapefile = TRUE, progress_bar = FALSE) %>% 
  select(fips = GEOID)
us_sf <- states(progress_bar = FALSE) %>% 
  filter(!(NAME %in% c("Hawaii", "Puerto Rico", "American Samoa", 
                       "United States Virgin Islands", 
                       "Commonwealth of the Northern Mariana Islands",
                       "Alaska", "Guam"))) %>% 
  st_union()
mpeds_sf <- mpeds %>% left_join(county_sf, by = "fips") 
```

``` r
mpeds %>% 
  drop_na(location_lat, location_lng) %>% 
  st_as_sf(coords = c("location_lng", "location_lat"), crs = st_crs(county_sf)) %>% 
  ggplot() + 
  geom_sf(data = us_sf, fill = "white", color = "gray") + 
  geom_sf(size = 0.1, alpha = 0.2) + 
  lims(
    x = c(-130, -60),
    y = c(20, 55)
  ) +
  labs(
    title = "Spread of protests and geocoded locations",
    caption = "Alaska, Hawaii, a few other locations with only a\nfew protests excluded in this map only."
    
  ) + 
  theme_void() + 
  theme(text = element_text(family = "Lato"),
        plot.title = element_text(size = 20))
```

![](exploratory_plots_files/figure-gfm/mpeds_map-1.png)<!-- -->
