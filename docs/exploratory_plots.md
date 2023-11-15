Exploratory Plots
================

- [Basic counts](#basic-counts)
  - [Counts by (combined) issue](#counts-by-combined-issue)
  - [Counts by (split) issue and racial
    issue](#counts-by-split-issue-and-racial-issue)
- [Police involvement by issue](#police-involvement-by-issue)
- [Percentages of all protest with given
  preset](#percentages-of-all-protest-with-given-preset)
- [Counts over time](#counts-over-time)
  - [Police activities over time](#police-activities-over-time)
  - [Racial and “nonracial” issues over time
    (collapsed)](#racial-and-nonracial-issues-over-time-collapsed)
- [Basic summary plots by variable](#basic-summary-plots-by-variable)
- [Trying out joins with protest
  data](#trying-out-joins-with-protest-data)
- [Maps and related things](#maps-and-related-things)
- [Investigating specific movements](#investigating-specific-movements)
  - [2015 Mizzou protests](#2015-mizzou-protests)
    - [Mizzou issues](#mizzou-issues)
    - [2015 Antiracism protest profiles and
      comparison](#2015-antiracism-protest-profiles-and-comparison)
    - [Newspaper coverage for Mizzou
      umbrella](#newspaper-coverage-for-mizzou-umbrella)
  - [2012 Quebec protest wave](#2012-quebec-protest-wave)
    - [Quebec events frequency stratified by police
      fields](#quebec-events-frequency-stratified-by-police-fields)
  - [Trump-related protests](#trump-related-protests)
    - [Issue composition November 9th and 17th
      protests](#issue-composition-november-9th-and-17th-protests)
- [Investigating reporting measures](#investigating-reporting-measures)

# Basic counts

| Events with many issues                  | Number of issues |
|:-----------------------------------------|-----------------:|
| 20160305_Toronto_March_Feminism          |               14 |
| 20151112_Athens_Rally_Tuition            |               10 |
| 20160928_Hempstead_Rally_Trump(Against)  |               10 |
| 20161116_AnnArbor_Walkout_Trump(Against) |               10 |
| 20180121_Vancouver_March_Feminism        |               10 |

| Statistic                                             |   Value |
|:------------------------------------------------------|--------:|
| Total imported events                                 | 5995.00 |
| Total non-umbrella events                             | 5555.00 |
| Unique locations                                      |  537.00 |
| US counties                                           |  312.00 |
| Canadian CMAs                                         |   32.00 |
| Universities                                          |  437.00 |
| CEs with missing universities                         |    3.00 |
| Universities with missing locations                   |   43.00 |
| \# of events with police activity recorded            |  870.00 |
| \# of events with any police field recorded           |  925.00 |
| \# of events with university police only              |  452.00 |
| \# of events with government police only              |  282.00 |
| \# of events with both types of police                |  147.00 |
| \# of events with at least one issue or racial issue  | 5520.00 |
| \# of events with at least one issue and racial issue | 1073.00 |
| mode of issue counts                                  |    1.00 |
| mean of issue counts                                  |    2.12 |
| \# of events with just one issue                      | 2032.00 |

The initial import of the MPEDS db found 5995 unique canonical events,
and after all cleaning steps we still have 5994 canonical events.

However, there’s still an issue regarding duplicate matches in IPEDS we
can detect (there are likely also incorrect matches that we can’t detect
programmatically right now); there are lots of schools called “Columbia
College” (or another common name) inside IPEDS, so any schools with that
name in MPEDS will be assigned multiple schools. The MPEDS-IPEDS join is
crucial because we also use IPEDS to join county FIPS identifiers, and
thus no further joins will be accurate unless the MPEDS-IPEDS join is
accurate. As of Jan 30, 2023, we are in the middle of repairing this
join.

Of those events, there were 537 unique locations, 312 unique counties,
32 unique Canadian CMAs, and 437 unique universities. Surprisingly, all
of the locations that were not universities found geocoding matches, and
hand-checking the most common ones indicates that there isn’t a strong
pattern of missing value substitution, e.g. Google isn’t sending the
majority of results to the centroid of America or to `(-1, -1)` or
anything weird like that. Universities had a harder time, with 3
canonical events missing lon/lat coords for universities.

That comes out to ~5% of universities not having coordinates, and ~2.5%
of canonical events not having universities with coordinates.

The top universities by appearances:

| university_name                      |   n |
|:-------------------------------------|----:|
| University of California Berkeley    | 284 |
| McGill University                    | 258 |
| Concordia University                 | 216 |
| Harvard University                   | 151 |
| University of Toronto                | 135 |
| University of Michigan Ann Arbor     | 125 |
| University of California Los Angeles | 117 |
| Ryerson University                   |  97 |
| York University                      |  84 |
| Columbia University                  |  82 |
| Tufts University                     |  82 |
| University of Chicago                |  73 |
| University of Texas Austin           |  58 |
| University of Wisconsin Madison      |  58 |
| Georgetown University                |  55 |
| New York University                  |  55 |

And the top locations:

| location               |   n |
|:-----------------------|----:|
| Montreal, QC, Canada   | 376 |
| Toronto, ON, Canada    | 227 |
| Berkeley, CA, USA      | 224 |
| New York City, NY, USA | 169 |
| Los Angeles, CA, USA   | 136 |
| Cambridge, MA, USA     | 131 |
| Chicago, IL, USA       | 116 |
| Ann Arbor, MI, USA     | 112 |
| San Diego, CA, USA     |  92 |
| San Francisco, CA, USA |  85 |
| Washington, D.C., USA  |  73 |
| Boston, MA, USA        |  56 |
| Vancouver, BC, Canada  |  54 |
| Austin, TX, USA        |  53 |
| Madison, WI, USA       |  50 |
| Ottawa, ON, Canada     |  50 |

Top states:

| area_name            |   n |
|:---------------------|----:|
| California           | 905 |
| Quebec               | 425 |
| Massachusetts        | 364 |
| Ontario              | 339 |
| New York             | 334 |
| Illinois             | 263 |
| Pennsylvania         | 188 |
| Michigan             | 169 |
| Texas                | 161 |
| Ohio                 | 141 |
| District of Columbia | 127 |
| Virginia             | 119 |
| British Col          | 118 |
| Indiana              | 107 |
| North Carolina       | 107 |

And finally the top counties:

| locality_name        |   n |
|:---------------------|----:|
| Montréal             | 393 |
| Middlesex            | 304 |
| Alameda              | 248 |
| Toronto              | 247 |
| Los Angeles          | 207 |
| New York             | 177 |
| Cook                 | 140 |
| District of Columbia | 127 |
| Washtenaw            | 119 |
| San Diego            | 100 |
| San Francisco        |  86 |
| Vancouver            |  86 |
| Santa Clara          |  59 |
| Suffolk              |  57 |
| Travis               |  56 |

These glimpses seem mostly in line with what we should expect, with a
strong caveat that the Missouri protests are not making a leading
appearance in the counts by location, but there do seem to be a fair
number in Missouri when we take a look by state. It seems there are
non-MO locations being recognized as happening in Missouri. See our 1:1
notes Google Doc for details.

| police_presence_and_size |    n |
|:-------------------------|-----:|
| NA                       | 5189 |
| NA/Unclear               |  398 |
| Substantial              |  289 |
| Small/0 to 5 officers    |   87 |
| Heavily Policed          |   32 |
| Motorized Presence       |   17 |

| police_activities            |    n |
|:-----------------------------|-----:|
| NA                           | 5092 |
| Monitor/Present              |  410 |
| Instruct/Warn                |  175 |
| Arrest or Attempted          |  162 |
| Constrain                    |  161 |
| Formal Accusation            |  104 |
| Remove Individual Protesters |   63 |
| End Protest                  |   57 |
| Force: Vague/Body            |   57 |
| “Breaking the Rules”         |   52 |
| Detain                       |   48 |
| NA/Unclear                   |   32 |
| Force: Weapon                |   30 |
| Force: 2+ Weapon Types       |   27 |
| Arrest- Large Scale          |   26 |
| Present                      |   19 |
| Cooperate/Coordinate         |   14 |
| Participate                  |    6 |
| Disputed Actions             |    5 |
| “We’re Responsive”           |    1 |

| type_of_police        |    n |
|:----------------------|-----:|
| NA                    | 5084 |
| Univ police           |  455 |
| Govt police           |  299 |
| Univ police - assumed |  152 |
| Govt police - assumed |  134 |
| “Riot police”         |   68 |
| Private Security      |   27 |
| NA/Unclear            |    5 |
| Secret Service        |    2 |

| university_action_on_issue |    n |
|:---------------------------|-----:|
| NA                         | 4476 |
| NA/Unclear                 |  807 |
| Action in Process          |  393 |
| Reject Demand              |  189 |
| Fulfill Demand             |   99 |
| Structural Change          |   92 |
| No Cancellation            |   61 |
| Compromised Action         |   46 |
| Hold Forum                 |   32 |
| Contrary Action/Refuse     |   30 |
| Cancel Speaker/Event       |   26 |
| Resign/Fire                |   15 |
| Short Term Services        |   11 |
| Correct Racist History     |    6 |
| Sanction                   |    3 |

| university_discourse_on_issue   |    n |
|:--------------------------------|-----:|
| NA                              | 4453 |
| NA/Unclear                      |  535 |
| Explain Bureaucracy/Law         |  489 |
| Express Contrary Position       |  342 |
| Express Agreement               |  329 |
| Affirm Diversity                |   95 |
| Affirm Free Speech when Bigotry |   75 |
| Affirm Marginalized Students    |   61 |
| Emotional Appeal                |   48 |
| Oppose Racism                   |   28 |
| Apology/Responsibility          |   27 |
| Oppose Oppression               |   26 |
| Affirm BIPOC Students           |   18 |

| university_reactions_to_protest |    n |
|:--------------------------------|-----:|
| NA                              | 4461 |
| NA/Unclear                      |  720 |
| Monitor/Present                 |  280 |
| Meet                            |  182 |
| Direct Communications           |  178 |
| Get Confronted                  |  175 |
| Instruct/Warn                   |  120 |
| Participate/Aid                 |  116 |
| Penalize                        |   49 |
| Revisit Protest P&P             |   32 |
| No Intervention                 |   29 |
| Avoid Penalizing                |   26 |
| Refuse to Meet                  |   21 |
| End Protest                     |    9 |
| Protest Elsewhere               |    3 |

“NA” marks canonical events where issues were not assigned at all, or
where text-selects were used but not one of the preset issue categories.
“\_Not relevant” *should* be marked when a racial issue was selected
instead, per the codebook. “\_Other issue” marks issues not within the
preset options; the codebook gives the examples of:

- protestors who use hateful speech, e.g. anti-LGBTQ preachers
- (objection to?) corporate practices
- access to higher education (?)
- science (?)
- Armenian genocide (?)

Hm.

## Counts by (combined) issue

Issue counts here were combined for each canonical event, such that no
issue, racial issue, or some combination of the two is counted twice. If
an event has “University governance” for both issue and racial issue, it
is counted once.

The table below thus represents the proportion of all events a given
combined racial-nonracial issue was relevant to.

| issue                                                        | n      |
|:-------------------------------------------------------------|:-------|
| University governance, admin, policies, programs, curriculum | 38.58% |
| Labor and work                                               | 17.28% |
| Anti-racism                                                  | 15.36% |
| \_Other Issue                                                | 11.59% |
| Tuition, fees, financial aid                                 | 10.87% |
| Police violence                                              | 10.33% |
| Trump and/or his administration (Against)                    | 10.28% |
| Immigration (For)                                            | 8.66%  |
| Campus climate                                               | 7.74%  |
| Environmental                                                | 7.56%  |
| Sexual assault/violence                                      | 5.94%  |
| Economy/inequality                                           | 5.76%  |
| Feminism/women’s issues                                      | 5.4%   |
| Public funding for higher education                          | 4.66%  |
| Faith-based discrimination                                   | 4.59%  |
| LGB+/Sexual orientation (For)                                | 3.78%  |
| Hate speech                                                  | 3.46%  |
| Indigenous issues                                            | 3.08%  |
| White supremacy (Against)                                    | 2.72%  |
| Far Right/Alt Right (Against)                                | 2.16%  |
| Abortion access                                              | 1.87%  |
| Gun control                                                  | 1.78%  |
| Hate crimes/Anti-minority violence                           | 1.78%  |
| Police violence/anti-law enforcement/criminal justice        | 1.78%  |
| Abortion (Against)/Pro-life                                  | 1.69%  |
| Racist/racialized symbols                                    | 1.55%  |
| Free speech                                                  | 1.51%  |
| Transgender issues (For)                                     | 1.44%  |
| Pro-Palestine/BDS                                            | 1.3%   |
| Transgender issues                                           | 1.22%  |
| Anti-war/peace                                               | 1.12%  |
| Social services and welfare                                  | 1.06%  |
| Trump and/or his administration (For)                        | 0.94%  |
| LGB+/Sexual orientation (Against)                            | 0.9%   |
| Prison/mass incarceration                                    | 0.86%  |
| Human rights                                                 | 0.79%  |
| Far Right/Alt Right (For)                                    | 0.67%  |
| Memorials & anniversaries                                    | 0.67%  |
| Affirmative action (For)                                     | 0.61%  |
| Domestic foreign policy                                      | 0.59%  |
| Accessibility                                                | 0.49%  |
| Animal rights                                                | 0.41%  |
| Anti-colonial/political independence                         | 0.4%   |
| Immigration (Against)                                        | 0.36%  |
| White supremacy (For)                                        | 0.36%  |
| Cultural appropriation                                       | 0.32%  |
| Political corruption/malfeasance                             | 0.31%  |
| Pro-Israel/Zionism                                           | 0.31%  |
| Transgender issues (Against)                                 | 0.29%  |
| Gun owner rights                                             | 0.23%  |
| Racial/ethnic pride - white                                  | 0.13%  |
| All Lives Matter                                             | 0.11%  |
| Pro-law enforcement                                          | 0.11%  |
| Traditional marriage/family                                  | 0.11%  |
| Pro-police                                                   | 0.09%  |
| Reparations                                                  | 0.09%  |
| Affirmative action (Against)                                 | 0.07%  |
| Men’s rights                                                 | 0.04%  |
| K-12 education                                               | 0.02%  |
| Racial/ethnic pride - minority                               | 0.02%  |

## Counts by (split) issue and racial issue

| issue                                                        |    n |
|:-------------------------------------------------------------|-----:|
| University governance, admin, policies, programs, curriculum | 1715 |
| \_Not relevant                                               | 1002 |
| Labor and work                                               |  960 |
| Tuition, fees, financial aid                                 |  604 |
| Trump and/or his administration (Against)                    |  571 |
| \_Other Issue                                                |  526 |
| NA                                                           |  509 |
| Environmental                                                |  420 |
| Sexual assault/violence                                      |  330 |
| Economy/inequality                                           |  320 |
| Feminism/women’s issues                                      |  300 |
| Public funding for higher education                          |  259 |
| Faith-based discrimination                                   |  255 |
| LGB+/Sexual orientation (For)                                |  210 |
| Far Right/Alt Right (Against)                                |  120 |
| Hate speech                                                  |  112 |
| Abortion access                                              |  104 |
| Gun control                                                  |   99 |
| Police violence/anti-law enforcement/criminal justice        |   99 |
| Abortion (Against)/Pro-life                                  |   94 |
| Free speech                                                  |   84 |
| Transgender issues (For)                                     |   80 |
| Pro-Palestine/BDS                                            |   72 |
| Transgender issues                                           |   68 |
| Anti-war/peace                                               |   62 |
| Social services and welfare                                  |   59 |
| Trump and/or his administration (For)                        |   52 |
| LGB+/Sexual orientation (Against)                            |   50 |
| Human rights                                                 |   44 |
| Far Right/Alt Right (For)                                    |   37 |
| Domestic foreign policy                                      |   33 |
| Hate crimes/Anti-minority violence                           |   31 |
| Accessibility                                                |   27 |
| Animal rights                                                |   23 |
| Anti-colonial/political independence                         |   22 |
| Political corruption/malfeasance                             |   17 |
| Pro-Israel/Zionism                                           |   17 |
| Transgender issues (Against)                                 |   16 |
| Gun owner rights                                             |   13 |
| Pro-law enforcement                                          |    6 |
| Traditional marriage/family                                  |    6 |
| Men’s rights                                                 |    2 |
|                                                              |    1 |

| racial_issue                                                 |    n |
|:-------------------------------------------------------------|-----:|
| \_Not relevant                                               | 3335 |
| Anti-racism                                                  |  853 |
| Police violence                                              |  574 |
| University governance, admin, policies, programs, curriculum |  531 |
| Immigration (For)                                            |  481 |
| Campus climate                                               |  430 |
| Indigenous issues                                            |  171 |
| White supremacy (Against)                                    |  151 |
| \_Other Issue                                                |  135 |
| Hate speech                                                  |   97 |
| Racist/racialized symbols                                    |   86 |
| Hate crimes/Anti-minority violence                           |   74 |
| Prison/mass incarceration                                    |   48 |
| Memorials & anniversaries                                    |   37 |
| Affirmative action (For)                                     |   34 |
| Immigration (Against)                                        |   20 |
| White supremacy (For)                                        |   20 |
| Cultural appropriation                                       |   18 |
| Racial/ethnic pride - white                                  |    7 |
| All Lives Matter                                             |    6 |
| Pro-police                                                   |    5 |
| Reparations                                                  |    5 |
| Affirmative action (Against)                                 |    4 |
| K-12 education                                               |    1 |
| Racial/ethnic pride - minority                               |    1 |

# Police involvement by issue

We’re interested in describing police involvement by issue – what issues
attract the heaviest police presence and response?

I filtered our dataset to include only rows that had at least one
non-missing value for type of police, police actions, police activities,
and police presence and size, and tabulated the issues reported in the
remaining dataset. The table can thus be read as the most popular issues
among police-involved protests.

In the table below, counts may be inflated given each canonical event
could have multiple issues.

This table should be compared to the table of percentages of issues
across all events to be meaningful for the questions we’d like to
answer. For example, university governance makes a strong appearance
here, but that could be just because it is a popular issue at large, not
because protests around the issue attract police. On the other hand,
tuition and fees makes a solid jump here from having 10% prevalence
across all events but with 16% prevalence across police-involved events.
This makes sense given our knowledge that the Quebec tuition strike
protests were heavily policed.

| Issue                                                                 | Percent of events with given issue |
|:----------------------------------------------------------------------|-----------------------------------:|
| University governance, admin, policies, programs, curriculum          |                              28.32 |
| Tuition, fees, financial aid                                          |                              16.97 |
| Anti-racism (racial)                                                  |                              14.92 |
| Labor and work                                                        |                              12.43 |
| Police violence (racial)                                              |                              11.35 |
| \_Other Issue                                                         |                              11.03 |
| Trump and/or his administration (Against)                             |                               9.95 |
| Economy/inequality                                                    |                               8.11 |
| University governance, admin, policies, programs, curriculum (racial) |                               7.24 |
| Environmental                                                         |                               6.70 |
| Campus climate (racial)                                               |                               6.27 |
| Immigration (For) (racial)                                            |                               5.62 |
| Public funding for higher education                                   |                               5.62 |
| LGB+/Sexual orientation (For)                                         |                               5.51 |
| Far Right/Alt Right (Against)                                         |                               5.41 |
| Feminism/women’s issues                                               |                               5.19 |
| White supremacy (Against) (racial)                                    |                               5.19 |
| Faith-based discrimination                                            |                               4.43 |
| Sexual assault/violence                                               |                               4.32 |
| Police violence/anti-law enforcement/criminal justice                 |                               3.35 |
| Hate speech                                                           |                               3.14 |
| Abortion access                                                       |                               2.92 |
| Abortion (Against)/Pro-life                                           |                               2.59 |
| Free speech                                                           |                               2.38 |
| Transgender issues (For)                                              |                               2.38 |
| Far Right/Alt Right (For)                                             |                               2.27 |
| Hate speech (racial)                                                  |                               2.27 |
| Social services and welfare                                           |                               2.27 |
| Indigenous issues (racial)                                            |                               2.16 |
| \_Other Issue (racial)                                                |                               2.16 |
| Anti-war/peace                                                        |                               1.73 |
| LGB+/Sexual orientation (Against)                                     |                               1.73 |
| Racist/racialized symbols (racial)                                    |                               1.73 |
| Pro-Palestine/BDS                                                     |                               1.62 |
| White supremacy (For) (racial)                                        |                               1.62 |
| Transgender issues                                                    |                               1.51 |
| Trump and/or his administration (For)                                 |                               0.97 |
| Domestic foreign policy                                               |                               0.86 |
| Hate crimes/Anti-minority violence (racial)                           |                               0.86 |
| Prison/mass incarceration (racial)                                    |                               0.86 |
| Transgender issues (Against)                                          |                               0.86 |
| Gun control                                                           |                               0.76 |
| Accessibility                                                         |                               0.65 |
| Animal rights                                                         |                               0.54 |
| Affirmative action (For) (racial)                                     |                               0.43 |
| Anti-colonial/political independence                                  |                               0.43 |
| Human rights                                                          |                               0.43 |
| Political corruption/malfeasance                                      |                               0.43 |
| Pro-Israel/Zionism                                                    |                               0.43 |
| All Lives Matter (racial)                                             |                               0.32 |
| Hate crimes/Anti-minority violence                                    |                               0.32 |
| Immigration (Against) (racial)                                        |                               0.32 |
| Racial/ethnic pride - white (racial)                                  |                               0.32 |
| Gun owner rights                                                      |                               0.22 |
| Memorials & anniversaries (racial)                                    |                               0.22 |
| Traditional marriage/family                                           |                               0.22 |
| Men’s rights                                                          |                               0.11 |

![](exploratory_plots_files/figure-gfm/police_involvement_by_issue-1.png)<!-- -->![](exploratory_plots_files/figure-gfm/police_involvement_by_issue-2.png)<!-- -->![](exploratory_plots_files/figure-gfm/police_involvement_by_issue-3.png)<!-- -->

![](exploratory_plots_files/figure-gfm/police_issue_separate-1.png)<!-- -->![](exploratory_plots_files/figure-gfm/police_issue_separate-2.png)<!-- -->

![](exploratory_plots_files/figure-gfm/police_issue_baseline-1.png)<!-- -->

# Percentages of all protest with given preset

| issue                                                        |   pct |
|:-------------------------------------------------------------|------:|
| Percent of events with any value                             | 74.92 |
| University governance, admin, policies, programs, curriculum | 28.61 |
| \_Not relevant                                               | 16.72 |
| Labor and work                                               | 16.02 |
| Tuition, fees, financial aid                                 | 10.08 |
| Trump and/or his administration (Against)                    |  9.53 |
| \_Other Issue                                                |  8.78 |
| NA                                                           |  8.49 |
| Environmental                                                |  7.01 |
| Sexual assault/violence                                      |  5.51 |
| Economy/inequality                                           |  5.34 |
| Feminism/women’s issues                                      |  5.01 |
| Public funding for higher education                          |  4.32 |
| Faith-based discrimination                                   |  4.25 |
| LGB+/Sexual orientation (For)                                |  3.50 |
| Far Right/Alt Right (Against)                                |  2.00 |
| Hate speech                                                  |  1.87 |
| Abortion access                                              |  1.74 |
| Gun control                                                  |  1.65 |
| Police violence/anti-law enforcement/criminal justice        |  1.65 |
| Abortion (Against)/Pro-life                                  |  1.57 |
| Free speech                                                  |  1.40 |
| Transgender issues (For)                                     |  1.33 |
| Pro-Palestine/BDS                                            |  1.20 |
| Transgender issues                                           |  1.13 |
| Anti-war/peace                                               |  1.03 |
| Social services and welfare                                  |  0.98 |
| Trump and/or his administration (For)                        |  0.87 |
| LGB+/Sexual orientation (Against)                            |  0.83 |
| Human rights                                                 |  0.73 |
| Far Right/Alt Right (For)                                    |  0.62 |
| Domestic foreign policy                                      |  0.55 |
| Hate crimes/Anti-minority violence                           |  0.52 |
| Accessibility                                                |  0.45 |
| Animal rights                                                |  0.38 |
| Anti-colonial/political independence                         |  0.37 |
| Political corruption/malfeasance                             |  0.28 |
| Pro-Israel/Zionism                                           |  0.28 |
| Transgender issues (Against)                                 |  0.27 |
| Gun owner rights                                             |  0.22 |
| Pro-law enforcement                                          |  0.10 |
| Traditional marriage/family                                  |  0.10 |
| Men’s rights                                                 |  0.03 |
|                                                              |  0.02 |

| racial_issue                                                 |   pct |
|:-------------------------------------------------------------|------:|
| \_Not relevant                                               | 55.64 |
| Percent of events with any value                             | 44.51 |
| Anti-racism                                                  | 14.23 |
| Police violence                                              |  9.58 |
| University governance, admin, policies, programs, curriculum |  8.86 |
| Immigration (For)                                            |  8.02 |
| Campus climate                                               |  7.17 |
| Indigenous issues                                            |  2.85 |
| White supremacy (Against)                                    |  2.52 |
| \_Other Issue                                                |  2.25 |
| Hate speech                                                  |  1.62 |
| Racist/racialized symbols                                    |  1.43 |
| Hate crimes/Anti-minority violence                           |  1.23 |
| Prison/mass incarceration                                    |  0.80 |
| Memorials & anniversaries                                    |  0.62 |
| Affirmative action (For)                                     |  0.57 |
| Immigration (Against)                                        |  0.33 |
| White supremacy (For)                                        |  0.33 |
| Cultural appropriation                                       |  0.30 |
| Racial/ethnic pride - white                                  |  0.12 |
| All Lives Matter                                             |  0.10 |
| Pro-police                                                   |  0.08 |
| Reparations                                                  |  0.08 |
| Affirmative action (Against)                                 |  0.07 |
| K-12 education                                               |  0.02 |
| Racial/ethnic pride - minority                               |  0.02 |

# Counts over time

![](exploratory_plots_files/figure-gfm/basic_counts_over_time-1.png)<!-- -->

![](exploratory_plots_files/figure-gfm/basic_counts_time_redux-1.png)<!-- -->

![](exploratory_plots_files/figure-gfm/regions_over_time-1.png)<!-- -->

![](exploratory_plots_files/figure-gfm/regions_time_vert-1.png)<!-- -->

![](exploratory_plots_files/figure-gfm/over_time_country-1.png)<!-- -->

We can also begin to look at the top universities, counties, locations,
or states over time. This inevitably produces more complex summaries,
and it can be difficult to take an informative glimpse given so many
categories, so I’ve only shown the universities over time for now:

![](exploratory_plots_files/figure-gfm/unis_over_time-1.png)<!-- -->![](exploratory_plots_files/figure-gfm/unis_over_time-2.png)<!-- -->

    ## Scale for x is already present.
    ## Adding another scale for x, which will replace the existing scale.

![](exploratory_plots_files/figure-gfm/responses_over_time-1.png)<!-- -->

    ## Scale for x is already present.
    ## Adding another scale for x, which will replace the existing scale.

![](exploratory_plots_files/figure-gfm/responses_over_time-2.png)<!-- -->

    ## Scale for x is already present.
    ## Adding another scale for x, which will replace the existing scale.

![](exploratory_plots_files/figure-gfm/responses_over_time-3.png)<!-- -->

    ## Scale for x is already present.
    ## Adding another scale for x, which will replace the existing scale.

![](exploratory_plots_files/figure-gfm/responses_over_time-4.png)<!-- -->

    ## Scale for x is already present.
    ## Adding another scale for x, which will replace the existing scale.

![](exploratory_plots_files/figure-gfm/responses_over_time-5.png)<!-- -->

    ## Scale for x is already present.
    ## Adding another scale for x, which will replace the existing scale.

![](exploratory_plots_files/figure-gfm/responses_over_time-6.png)<!-- -->

### Police activities over time

Regrouped to be interpretable according to the following crosswalk:

| New umbrella category | Existing police activity     |
|:----------------------|:-----------------------------|
| Use of Force          | Force: Vague/Body            |
| Use of Force          | Force: Weapon                |
| Use of Force          | Force: 2+ Weapon Types       |
| Active Constraint     | Remove Individual Protesters |
| Active Constraint     | Arrest or Attempted          |
| Active Constraint     | Constrain                    |
| Active Constraint     | Arrest- Large Scale          |
| Active Constraint     | Detain                       |
| Active Constraint     | End Protest                  |
| Passive Control       | Cooperate/Coordinate         |
| Passive Control       | Monitor/Present              |
| Passive Control       | Participate                  |
| Passive Control       | Present                      |
| Verbal Communication  | Instruct/Warn                |
| Verbal Communication  | “Breaking the Rules”         |
| Verbal Communication  | Formal Accusation            |
| Verbal Communication  | Disputed Actions             |
| Verbal Communication  | “We’re Responsive”           |
| NA/Unclear            | NA/Unclear                   |

![](exploratory_plots_files/figure-gfm/police_activities_over_time-1.png)<!-- -->

| racial_issue                                                 |   n |
|:-------------------------------------------------------------|----:|
| Anti-racism                                                  | 853 |
| Police violence                                              | 574 |
| University governance, admin, policies, programs, curriculum | 531 |
| Immigration (For)                                            | 481 |
| Campus climate                                               | 430 |
| Indigenous issues                                            | 171 |
| White supremacy (Against)                                    | 151 |
| \_Other Issue                                                | 135 |
| Hate speech                                                  |  97 |
| Racist/racialized symbols                                    |  86 |
| Hate crimes/Anti-minority violence                           |  74 |
| Prison/mass incarceration                                    |  48 |
| Memorials & anniversaries                                    |  37 |
| Affirmative action (For)                                     |  34 |
| Immigration (Against)                                        |  20 |
| White supremacy (For)                                        |  20 |
| Cultural appropriation                                       |  18 |
| Racial/ethnic pride - white                                  |   7 |
| All Lives Matter                                             |   6 |
| Pro-police                                                   |   5 |
| Reparations                                                  |   5 |
| Affirmative action (Against)                                 |   4 |
| K-12 education                                               |   1 |
| Racial/ethnic pride - minority                               |   1 |

![](exploratory_plots_files/figure-gfm/issues_over_time-1.png)<!-- -->![](exploratory_plots_files/figure-gfm/issues_over_time-2.png)<!-- -->![](exploratory_plots_files/figure-gfm/issues_over_time-3.png)<!-- -->

## Racial and “nonracial” issues over time (collapsed)

![](exploratory_plots_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->![](exploratory_plots_files/figure-gfm/unnamed-chunk-5-2.png)<!-- -->![](exploratory_plots_files/figure-gfm/unnamed-chunk-5-3.png)<!-- -->

I’ve collapsed both types of issues here to show racial and nonracial
issues alongside each other. Racial issue counts here are taken at a
maximum of one per canonical event, so that events that relate to many
issues do not outweight others and we have a clearer understanding of
the weight of protest occurrence. The same goes for nonracial issues.

We’re also interested in understanding if the biggest upticks in protest
counts are driven by an uptick in racial issues. This is

    ## `geom_smooth()` using method = 'loess' and formula = 'y ~ x'

![](exploratory_plots_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->![](exploratory_plots_files/figure-gfm/unnamed-chunk-6-2.png)<!-- -->

# Basic summary plots by variable

| name                 | type    |      mean |        sd |
|:---------------------|:--------|----------:|----------:|
| campaign             | boolean |     0.248 |        NA |
| counterprotest       | boolean |     0.045 |        NA |
| inaccurate_date      | boolean |     0.009 |        NA |
| multiple_cities      | boolean |     0.025 |        NA |
| off_campus           | boolean |     0.074 |        NA |
| on_campus_no_student | boolean |     0.072 |        NA |
| quotes               | boolean |     0.641 |        NA |
| ritual               | boolean |     0.030 |        NA |
| slogans              | boolean |     0.401 |        NA |
| adjudicator_id       | numeric |    53.319 |     2.575 |
| mhi                  | numeric | 67556.527 | 16826.748 |
| rent_burden          | numeric |     0.517 |     0.082 |
| republican_vote_prop | numeric |     0.317 |     0.153 |
| unemp                | numeric |     5.133 |     1.664 |
| white_prop           | numeric |     0.694 |     0.166 |

For boolean variables, “mean” is the proportion that they are TRUE. Many
of the variables recorded in MPEDS allowed for the input of multiple
values, so those are handled as list-cols and not shown here.

![](exploratory_plots_files/figure-gfm/pairs-1.png)<!-- -->

The pairs plot is still very difficult to read after adjustments. This
should be treated as a glimpse or overview, and more detailed and
cleaner plots will be made later on.

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](exploratory_plots_files/figure-gfm/distributions-1.png)<!-- -->

# Trying out joins with protest data

To recap from our last conversation, it’s a bit difficult to join the
CCC data and our data since a lot of MPEDS data points could presumably
be in the CCC records. Then CCC data could be telling us that there was
a protest in the same county, when it could just be talking about the
same protest in MPEDS and essentially be turning data quality into
another covariate.

We discussed two solutions to this problem to avoid deduplication:

- Join so that CCC protests occurring one, three, five, or seven days
  before the MPEDS protest date are matched; the CCC variable then
  conceptually becomes “was there a recent protest in the same county.”
  Thus protests won’t find a match only because of duplicates
- Join only after filtering the CCC dataset so that rows with keywords
  related to universities are kicked out – things like teachers,
  faculty, students, colleges, universities. This is less ideal than the
  above strategy because it is so nonspecific, potentially missing many
  university matches and kicking out protests related to primary and
  secondary schools.

The following chunk gives a glimpse at total number of matches:

| source    | date_offset | recent_protests | match_percentage |
|:----------|------------:|----------------:|-----------------:|
| CCC       |           0 |               0 |                0 |
| CCC       |           1 |               0 |                0 |
| CCC       |           3 |               0 |                0 |
| CCC       |           5 |               0 |                0 |
| CCC       |           7 |               0 |                0 |
| Elephrame |           0 |               0 |                0 |
| Elephrame |           1 |               0 |                0 |
| Elephrame |           3 |               0 |                0 |
| Elephrame |           5 |               0 |                0 |
| Elephrame |           7 |               0 |                0 |

Here, the `match_percentage` column indicates how many canonical events
saw another protest occur in the same county within `diff` days,
according to the dataset in `source`. The fact that the match rate for 0
is much higher than 1 for both Elephrame and CCC indicates that there is
some double-counting of protests; rather than multiple protests
occurring concurrently, we may have recorded a protest in our dataset
that is also present in another dataset.

So it seems that there are a fair number of duplicates occurring if we
don’t have a date offset, but once we add one (of any days) that pretty
much solves the data quality issue.

That being said, the likely larger problem with the CCC data is that
it’s only available after 2017, so it may not be relevant even after we
become satisfied with the deduped match process. This can be refined a
little bit by adding in Elephrame data on BLM protests, but we’ve had
problems there already, and the topic differences mean we can’t pretend
we have complete data.

# Maps and related things

    ##   |                                                                              |                                                                      |   0%  |                                                                              |===                                                                   |   4%  |                                                                              |========================                                              |  35%  |                                                                              |==============================                                        |  43%  |                                                                              |==============================================                        |  65%  |                                                                              |=========================================================             |  82%  |                                                                              |======================================================================| 100%

![](exploratory_plots_files/figure-gfm/mpeds_map-1.png)<!-- -->

# Investigating specific movements

## 2015 Mizzou protests

| Statistics for Mizzou protests |   n |
|:-------------------------------|----:|
| Total number of links          | 115 |
| Unique events                  | 115 |
| Campaign events only           |  11 |
| Solidarity events only         | 104 |

The discrepancy between the total number of links from the original
Mizzou event to the total number of unique events comes from some events
being both campaign events and counterprotest events, or campaign events
and solidarity events.

![](exploratory_plots_files/figure-gfm/mizzou_map-1.png)<!-- -->![](exploratory_plots_files/figure-gfm/mizzou_map-2.png)<!-- -->

### Mizzou issues

| value                                                                 |   n |
|:----------------------------------------------------------------------|----:|
| Anti-racism (racial)                                                  | 106 |
| Campus climate (racial)                                               |  88 |
| University governance, admin, policies, programs, curriculum (racial) |  70 |
| University governance, admin, policies, programs, curriculum          |  17 |
| Police violence (racial)                                              |   9 |
| Hate speech (racial)                                                  |   8 |
| Racist/racialized symbols (racial)                                    |   8 |
| Hate crimes/Anti-minority violence (racial)                           |   6 |
| Labor and work                                                        |   6 |
| Tuition, fees, financial aid                                          |   6 |
| Economy/inequality                                                    |   5 |
| \_Other Issue                                                         |   4 |
| \_Other Issue (racial)                                                |   4 |
| Public funding for higher education                                   |   3 |
| Transgender issues                                                    |   3 |
| Affirmative action (For) (racial)                                     |   2 |
| Cultural appropriation (racial)                                       |   2 |
| Environmental                                                         |   2 |
| Indigenous issues (racial)                                            |   2 |
| LGB+/Sexual orientation (For)                                         |   2 |
| Pro-Palestine/BDS                                                     |   2 |
| Sexual assault/violence                                               |   2 |
| Free speech                                                           |   1 |
| Prison/mass incarceration (racial)                                    |   1 |

### 2015 Antiracism protest profiles and comparison

![](exploratory_plots_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

### Newspaper coverage for Mizzou umbrella

| canonical_key                                         | Article Mentions | Newspaper Mentions |
|:------------------------------------------------------|-----------------:|-------------------:|
| 20151102_Columbia_HungerStrike_UniversityGovernance   |              108 |                 79 |
| 20151010_Columbia_Blockade_UniversityGovernance       |               35 |                 27 |
| Umbrella_Mizzou_Anti-Racism_2015_Oct-Nov              |               19 |                 17 |
| 20151109_Columbia_Rally_CampusClimate                 |               14 |                 13 |
| 20151102_Columbia_Occupation_UniversityGovernance     |               12 |                  8 |
| 20151110_Columbia_FacultyWalkout_UniversityGovernance |                6 |                  6 |
| 20151001_Columbia_March_AntiRacism                    |                3 |                  2 |
| 20151021_Columbia_OtherForm_UniversityGovernance      |                3 |                  3 |
| 20151109_Columbia_OtherForm_FreeSpeech                |                3 |                  3 |
| 20151107_Columbia_Boycott_UniversityGovernance        |                2 |                  2 |
| 20151006_Columbia_Sit-in_AntiRacism                   |                1 |                  1 |
| 20151107_Columbia_Demonstration_CampusClimate         |                1 |                  1 |

## 2012 Quebec protest wave

| Statistics for Quebec protests |   n |
|:-------------------------------|----:|
| Total number of links          | 174 |
| Unique events                  | 175 |
| Campaign events only           | 166 |
| Solidarity events only         |   8 |

![](exploratory_plots_files/figure-gfm/quebec-1.png)<!-- -->

### Quebec events frequency stratified by police fields

For the solidarity paper, we’re interested in a frequency graph of
Quebec-related protests stratified by police presence, activities, and
type. It’s hard to do this on a single graph because there are many
categories involved, so instead I’ve made three separate graphs. I can
also make a single image composed of three sub-plots for presence,
activities, and type.

![](exploratory_plots_files/figure-gfm/quebec_police-1.png)<!-- -->![](exploratory_plots_files/figure-gfm/quebec_police-2.png)<!-- -->![](exploratory_plots_files/figure-gfm/quebec_police-3.png)<!-- -->

    ## `summarise()` has grouped output by 'date'. You can override using the
    ## `.groups` argument.
    ## `summarise()` has grouped output by 'date'. You can override using the
    ## `.groups` argument.

![](exploratory_plots_files/figure-gfm/quebec_extreme_police-1.png)<!-- -->

    ## `summarise()` has grouped output by 'type', 'name'. You can override using the
    ## `.groups` argument.

![](exploratory_plots_files/figure-gfm/quebec_extreme_police-2.png)<!-- -->

Brainstorming a breakdown for activity recategorization:

- Active Constraint: Arrest or Attempted, Arrest- Large Scale,
  Constrain, Detain,  
  Remove Individual Protestors
- Passive Control: Cooperate/Coordinate, Monitor/Present
- Verbal Communication: Instruct/Warn, “Breaking the Rules”
- Use of Force (all force mentions)
- NA/Unclear

## Trump-related protests

Unlike the above two protest wave profiles, I’m searching for these
protests based on issues, not by canonical event relationships.

![](exploratory_plots_files/figure-gfm/trump_events-1.png)<!-- -->

    ## [[1]]

![](exploratory_plots_files/figure-gfm/trump_map-1.png)<!-- -->

    ## 
    ## [[2]]

![](exploratory_plots_files/figure-gfm/trump_map-2.png)<!-- -->
![](exploratory_plots_files/figure-gfm/trump_map-3.png)<!-- -->

### Issue composition November 9th and 17th protests

In our notes document, Dr. Berrey noted that she was surprised to see
most of the November 17th protests were non-racial, and did not have to
do with sanctuary cities. I wanted to offer some more context on that,
as well as on her next comment on the heterogeneity of Trump-related
protests, so I made some tables on this point.

The day with the highest number of protests in our dataset was November
9th, 2016, holding 73 protests, followed by November 12th, 2015 November
16th, 2016. I’ve included tables for the 2016 dates showing the issue
breakdown on all of these dates and also for the November 17th protests
in case it offers any additional clarity.

It seems that “Immigration (For)”, which is the issue closest to the
topic of sanctuary cities that you thought would be at the heart of
these protests, does make a strong appearance for these days, but the
general category of Trump-related protests still far outnumber it.
Because the general Trump category is coded as a non-racial issue, the
chart above showing racial and nonracial issues over time shows more
nonracial issues than racial issues for November 2016.

| Top dates by protest occurrence | \# of events |
|:--------------------------------|-------------:|
| 2016-11-09                      |           73 |
| 2015-11-12                      |           51 |
| 2016-11-16                      |           48 |
| 2018-03-14                      |           47 |
| 2014-12-01                      |           42 |
| 2014-11-25                      |           40 |

| Top dates for immigration-related protests |   n |
|:-------------------------------------------|----:|
| 2016-11-16                                 |  22 |
| 2017-05-01                                 |  17 |
| 2017-02-01                                 |  14 |
| 2017-02-09                                 |  14 |
| 2017-01-31                                 |  13 |
| 2017-01-29                                 |  12 |

| Top ten issues for November 9th, 2016                                 |   n |
|:----------------------------------------------------------------------|----:|
| Trump and/or his administration (Against)                             |  61 |
| Immigration (For) (racial)                                            |  10 |
| Anti-racism (racial)                                                  |   8 |
| University governance, admin, policies, programs, curriculum (racial) |   7 |
| LGB+/Sexual orientation (For)                                         |   5 |
| Feminism/women’s issues                                               |   4 |
| Trump and/or his administration (For)                                 |   4 |
| Faith-based discrimination                                            |   3 |
| Hate speech                                                           |   3 |
| Sexual assault/violence                                               |   3 |

| Top ten issues for November 16th, 2016                                |   n |
|:----------------------------------------------------------------------|----:|
| Trump and/or his administration (Against)                             |  30 |
| Immigration (For) (racial)                                            |  22 |
| University governance, admin, policies, programs, curriculum (racial) |  18 |
| University governance, admin, policies, programs, curriculum          |  10 |
| Anti-racism (racial)                                                  |   9 |
| Campus climate (racial)                                               |   6 |
| Faith-based discrimination                                            |   5 |
| Hate crimes/Anti-minority violence (racial)                           |   5 |
| \_Other Issue (racial)                                                |   4 |
| Environmental                                                         |   3 |

| Top ten issues for November 17th, 2016                                |   n |
|:----------------------------------------------------------------------|----:|
| Trump and/or his administration (Against)                             |   4 |
| University governance, admin, policies, programs, curriculum          |   4 |
| Immigration (For) (racial)                                            |   3 |
| Anti-racism (racial)                                                  |   2 |
| Economy/inequality                                                    |   2 |
| Environmental                                                         |   2 |
| Indigenous issues (racial)                                            |   2 |
| Tuition, fees, financial aid                                          |   2 |
| University governance, admin, policies, programs, curriculum (racial) |   2 |
| Hate crimes/Anti-minority violence                                    |   1 |

# Investigating reporting measures

- Graph of articles per event vs size of protest
  - if reporting perfect, articles should increase linearly with size of
    protest
  - obv will not – what kinds of events attract lots of coverage despite
    being
