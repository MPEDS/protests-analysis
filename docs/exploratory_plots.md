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

| Statistic                                   |   Value |
|:--------------------------------------------|--------:|
| Total imported events                       | 6070.00 |
| Total non-umbrella events                   | 5586.00 |
| Unique locations                            |  539.00 |
| US counties                                 |  312.00 |
| Canadian CMAs                               |   32.00 |
| Universities                                |  689.00 |
| Missing universities                        |    9.00 |
| CEs with missing universities               |   61.00 |
| \# of events with police activity recorded  |  871.00 |
| \# of events with any police field recorded |  927.00 |
| \# of events with university police only    |  453.00 |
| \# of events with government police only    |  284.00 |
| \# of events with both types of police      |  146.00 |
| \# of events with at least one issue        | 1075.00 |
| mode of issue counts                        |    1.00 |
| mean of issue counts                        |    2.12 |
| \# of events with just one issue            | 2050.00 |

The initial import of the MPEDS db found 6070 unique canonical events,
and after all cleaning steps we still have 6070 canonical events.

However, there’s still an issue regarding duplicate matches in IPEDS we
can detect (there are likely also incorrect matches that we can’t detect
programmatically right now); there are lots of schools called “Columbia
College” (or another common name) inside IPEDS, so any schools with that
name in MPEDS will be assigned multiple schools. The MPEDS-IPEDS join is
crucial because we also use IPEDS to join county FIPS identifiers, and
thus no further joins will be accurate unless the MPEDS-IPEDS join is
accurate. As of Jan 30, 2023, we are in the middle of repairing this
join.

Of those events, there were 539 unique locations, 312 unique counties,
32 unique Canadian CMAs, and 689 unique universities. Surprisingly, all
of the locations that were not universities found geocoding matches, and
hand-checking the most common ones indicates that there isn’t a strong
pattern of missing value substitution, e.g. Google isn’t sending the
majority of results to the centroid of America or to `(-1, -1)` or
anything weird like that. Universities had a harder time, with 9
universities and 61 rows (canonical events) not returning lon/lat coords
for universities.

That comes out to ~5% of universities not having coordinates, and ~2.5%
of canonical events not having universities with coordinates.

The top universities by appearances:

| university                           |   n |
|:-------------------------------------|----:|
| University of California-Berkeley    | 227 |
| Concordia University                 | 163 |
| Harvard University                   | 139 |
| University of Michigan-Ann Arbor     | 119 |
| McGill University                    | 116 |
| University of Toronto                |  89 |
| Ryerson University                   |  80 |
| University of California Los Angeles |  77 |
| Mcgill University                    |  72 |
| Tufts University                     |  72 |
| York University                      |  67 |
| University of Chicago                |  66 |
| Columbia University                  |  62 |
| The University of Texas at Austin    |  54 |
| University of Wisconsin-Madison      |  51 |

And the top locations:

| location               |   n |
|:-----------------------|----:|
| Montreal, QC, Canada   | 377 |
| Toronto, ON, Canada    | 227 |
| Berkeley, CA, USA      | 225 |
| New York City, NY, USA | 171 |
| Los Angeles, CA, USA   | 136 |
| Cambridge, MA, USA     | 132 |
| Chicago, IL, USA       | 114 |
| Ann Arbor, MI, USA     | 112 |
| San Diego, CA, USA     |  91 |
| San Francisco, CA, USA |  85 |
| Boston, MA, USA        |  74 |
| Washington, D.C., USA  |  73 |
| Vancouver, BC, Canada  |  54 |
| Austin, TX, USA        |  53 |
| Ottawa, ON, Canada     |  51 |

Top states:

| area_name            |   n |
|:---------------------|----:|
| California           | 908 |
| Quebec               | 427 |
| Massachusetts        | 374 |
| Ontario              | 339 |
| New York             | 334 |
| Illinois             | 262 |
| Pennsylvania         | 187 |
| Michigan             | 171 |
| Texas                | 161 |
| Ohio                 | 141 |
| District of Columbia | 127 |
| Virginia             | 120 |
| British Col          | 118 |
| North Carolina       | 108 |
| Florida              | 107 |
| Indiana              | 107 |

And finally the top counties:

| locality_name        |   n |
|:---------------------|----:|
| Montréal             | 395 |
| Middlesex            | 294 |
| Alameda              | 250 |
| Toronto              | 248 |
| Los Angeles          | 208 |
| New York             | 177 |
| Cook                 | 138 |
| District of Columbia | 127 |
| Washtenaw            | 118 |
| San Diego            |  99 |
| San Francisco        |  86 |
| Vancouver            |  86 |
| Suffolk              |  76 |
| Santa Clara          |  59 |
| Travis               |  56 |

These glimpses seem mostly in line with what we should expect, with a
strong caveat that the Missouri protests are not making a leading
appearance in the counts by location, but there do seem to be a fair
number in Missouri when we take a look by state. It seems there are
non-MO locations being recognized as happening in Missouri. See our 1:1
notes Google Doc for details.

| police_presence_and_size |    n |
|:-------------------------|-----:|
| NA                       | 5263 |
| NA/Unclear               |  398 |
| Substantial              |  291 |
| Small/0 to 5 officers    |   87 |
| Heavily Policed          |   32 |
| Motorized Presence       |   17 |

| police_activities            |    n |
|:-----------------------------|-----:|
| NA                           | 5166 |
| Monitor/Present              |  410 |
| Instruct/Warn                |  175 |
| Arrest or Attempted          |  162 |
| Constrain                    |  161 |
| Formal Accusation            |  104 |
| Remove Individual Protesters |   63 |
| End Protest                  |   57 |
| Force: Vague/Body            |   57 |
| “Breaking the Rules”         |   52 |
| Detain                       |   47 |
| NA/Unclear                   |   33 |
| Force: Weapon                |   30 |
| Arrest- Large Scale          |   27 |
| Force: 2+ Weapon Types       |   27 |
| Present                      |   19 |
| Cooperate/Coordinate         |   14 |
| Participate                  |    6 |
| Disputed Actions             |    5 |
| “We’re Responsive”           |    1 |

| type_of_police        |    n |
|:----------------------|-----:|
| NA                    | 5158 |
| Univ police           |  455 |
| Govt police           |  300 |
| Univ police - assumed |  152 |
| Govt police - assumed |  134 |
| “Riot police”         |   68 |
| Private Security      |   27 |
| NA/Unclear            |    5 |
| Secret Service        |    2 |

| university_action_on_issue |    n |
|:---------------------------|-----:|
| NA                         | 4554 |
| NA/Unclear                 |  802 |
| Action in Process          |  393 |
| Reject Demand              |  190 |
| Fulfill Demand             |  100 |
| Structural Change          |   93 |
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
| NA                              | 4527 |
| NA/Unclear                      |  535 |
| Explain Bureaucracy/Law         |  488 |
| Express Contrary Position       |  341 |
| Express Agreement               |  331 |
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
| NA                              | 4538 |
| NA/Unclear                      |  719 |
| Monitor/Present                 |  281 |
| Meet                            |  180 |
| Direct Communications           |  178 |
| Get Confronted                  |  175 |
| Instruct/Warn                   |  120 |
| Participate/Aid                 |  118 |
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
| University governance, admin, policies, programs, curriculum | 38.51% |
| Labor and work                                               | 17.19% |
| Anti-racism                                                  | 15.36% |
| \_Other Issue                                                | 11.64% |
| Tuition, fees, financial aid                                 | 10.94% |
| Police violence                                              | 10.29% |
| Trump and/or his administration (Against)                    | 10.24% |
| Immigration (For)                                            | 8.61%  |
| Campus climate                                               | 7.79%  |
| Environmental                                                | 7.57%  |
| Sexual assault/violence                                      | 5.94%  |
| Economy/inequality                                           | 5.76%  |
| Feminism/women’s issues                                      | 5.37%  |
| Faith-based discrimination                                   | 4.56%  |
| Public funding for higher education                          | 4.56%  |
| LGB+/Sexual orientation (For)                                | 3.78%  |
| Hate speech                                                  | 3.37%  |
| Indigenous issues                                            | 3.08%  |
| White supremacy (Against)                                    | 2.74%  |
| Far Right/Alt Right (Against)                                | 2.15%  |
| Abortion access                                              | 2.02%  |
| Gun control                                                  | 1.77%  |
| Hate crimes/Anti-minority violence                           | 1.77%  |
| Police violence/anti-law enforcement/criminal justice        | 1.77%  |
| Abortion (Against)/Pro-life                                  | 1.54%  |
| Racist/racialized symbols                                    | 1.54%  |
| Free speech                                                  | 1.5%   |
| Transgender issues (For)                                     | 1.45%  |
| Pro-Palestine/BDS                                            | 1.29%  |
| Transgender issues                                           | 1.22%  |
| Anti-war/peace                                               | 1.13%  |
| Social services and welfare                                  | 1.06%  |
| Trump and/or his administration (For)                        | 0.93%  |
| LGB+/Sexual orientation (Against)                            | 0.9%   |
| Prison/mass incarceration                                    | 0.86%  |
| Human rights                                                 | 0.81%  |
| Far Right/Alt Right (For)                                    | 0.66%  |
| Memorials & anniversaries                                    | 0.66%  |
| Affirmative action (For)                                     | 0.61%  |
| Domestic foreign policy                                      | 0.61%  |
| Accessibility                                                | 0.48%  |
| Animal rights                                                | 0.41%  |
| Anti-colonial/political independence                         | 0.39%  |
| Immigration (Against)                                        | 0.36%  |
| White supremacy (For)                                        | 0.36%  |
| Political corruption/malfeasance                             | 0.34%  |
| Cultural appropriation                                       | 0.32%  |
| Pro-Israel/Zionism                                           | 0.3%   |
| Transgender issues (Against)                                 | 0.29%  |
| Gun owner rights                                             | 0.23%  |
| Pro-law enforcement                                          | 0.13%  |
| Racial/ethnic pride - white                                  | 0.13%  |
| All Lives Matter                                             | 0.11%  |
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
| University governance, admin, policies, programs, curriculum | 1718 |
| \_Not relevant                                               | 1008 |
| Labor and work                                               |  960 |
| Tuition, fees, financial aid                                 |  611 |
| Trump and/or his administration (Against)                    |  572 |
| NA                                                           |  556 |
| \_Other Issue                                                |  532 |
| Environmental                                                |  423 |
| Sexual assault/violence                                      |  332 |
| Economy/inequality                                           |  322 |
| Feminism/women’s issues                                      |  300 |
| Faith-based discrimination                                   |  255 |
| Public funding for higher education                          |  255 |
| LGB+/Sexual orientation (For)                                |  211 |
| Far Right/Alt Right (Against)                                |  120 |
| Abortion access                                              |  113 |
| Hate speech                                                  |  108 |
| Gun control                                                  |   99 |
| Police violence/anti-law enforcement/criminal justice        |   99 |
| Abortion (Against)/Pro-life                                  |   86 |
| Free speech                                                  |   84 |
| Transgender issues (For)                                     |   81 |
| Pro-Palestine/BDS                                            |   72 |
| Transgender issues                                           |   68 |
| Anti-war/peace                                               |   63 |
| Social services and welfare                                  |   59 |
| Trump and/or his administration (For)                        |   52 |
| LGB+/Sexual orientation (Against)                            |   50 |
| Human rights                                                 |   45 |
| Far Right/Alt Right (For)                                    |   37 |
| Domestic foreign policy                                      |   34 |
| Hate crimes/Anti-minority violence                           |   31 |
| Accessibility                                                |   27 |
| Animal rights                                                |   23 |
| Anti-colonial/political independence                         |   22 |
| Political corruption/malfeasance                             |   19 |
| Pro-Israel/Zionism                                           |   17 |
| Transgender issues (Against)                                 |   16 |
| Gun owner rights                                             |   13 |
| Pro-law enforcement                                          |    7 |
| Traditional marriage/family                                  |    6 |
| Men’s rights                                                 |    2 |
|                                                              |    1 |

| racial_issue                                                 |    n |
|:-------------------------------------------------------------|-----:|
| \_Not relevant                                               | 3354 |
| Anti-racism                                                  |  858 |
| Police violence                                              |  575 |
| University governance, admin, policies, programs, curriculum |  536 |
| Immigration (For)                                            |  481 |
| Campus climate                                               |  435 |
| Indigenous issues                                            |  172 |
| White supremacy (Against)                                    |  153 |
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
| University governance, admin, policies, programs, curriculum          |                              28.37 |
| Tuition, fees, financial aid                                          |                              17.04 |
| Anti-racism (racial)                                                  |                              14.89 |
| Labor and work                                                        |                              12.41 |
| Police violence (racial)                                              |                              11.33 |
| \_Other Issue                                                         |                              11.00 |
| Trump and/or his administration (Against)                             |                               9.92 |
| Economy/inequality                                                    |                               8.20 |
| University governance, admin, policies, programs, curriculum (racial) |                               7.34 |
| Environmental                                                         |                               6.80 |
| Campus climate (racial)                                               |                               6.04 |
| Immigration (For) (racial)                                            |                               5.61 |
| LGB+/Sexual orientation (For)                                         |                               5.50 |
| Public funding for higher education                                   |                               5.50 |
| Far Right/Alt Right (Against)                                         |                               5.29 |
| Feminism/women’s issues                                               |                               5.18 |
| White supremacy (Against) (racial)                                    |                               5.18 |
| Faith-based discrimination                                            |                               4.42 |
| Sexual assault/violence                                               |                               4.31 |
| Police violence/anti-law enforcement/criminal justice                 |                               3.34 |
| Hate speech                                                           |                               3.13 |
| Abortion access                                                       |                               3.02 |
| Abortion (Against)/Pro-life                                           |                               2.48 |
| Free speech                                                           |                               2.37 |
| Transgender issues (For)                                              |                               2.37 |
| Hate speech (racial)                                                  |                               2.27 |
| Social services and welfare                                           |                               2.27 |
| Far Right/Alt Right (For)                                             |                               2.16 |
| Indigenous issues (racial)                                            |                               2.16 |
| \_Other Issue (racial)                                                |                               2.16 |
| Anti-war/peace                                                        |                               1.83 |
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
| Percent of events with any value                             | 74.37 |
| University governance, admin, policies, programs, curriculum | 28.30 |
| \_Not relevant                                               | 16.61 |
| Labor and work                                               | 15.82 |
| Tuition, fees, financial aid                                 | 10.07 |
| Trump and/or his administration (Against)                    |  9.42 |
| NA                                                           |  9.16 |
| \_Other Issue                                                |  8.76 |
| Environmental                                                |  6.97 |
| Sexual assault/violence                                      |  5.47 |
| Economy/inequality                                           |  5.30 |
| Feminism/women’s issues                                      |  4.94 |
| Faith-based discrimination                                   |  4.20 |
| Public funding for higher education                          |  4.20 |
| LGB+/Sexual orientation (For)                                |  3.48 |
| Far Right/Alt Right (Against)                                |  1.98 |
| Abortion access                                              |  1.86 |
| Hate speech                                                  |  1.78 |
| Gun control                                                  |  1.63 |
| Police violence/anti-law enforcement/criminal justice        |  1.63 |
| Abortion (Against)/Pro-life                                  |  1.42 |
| Free speech                                                  |  1.38 |
| Transgender issues (For)                                     |  1.33 |
| Pro-Palestine/BDS                                            |  1.19 |
| Transgender issues                                           |  1.12 |
| Anti-war/peace                                               |  1.04 |
| Social services and welfare                                  |  0.97 |
| Trump and/or his administration (For)                        |  0.86 |
| LGB+/Sexual orientation (Against)                            |  0.82 |
| Human rights                                                 |  0.74 |
| Far Right/Alt Right (For)                                    |  0.61 |
| Domestic foreign policy                                      |  0.56 |
| Hate crimes/Anti-minority violence                           |  0.51 |
| Accessibility                                                |  0.44 |
| Animal rights                                                |  0.38 |
| Anti-colonial/political independence                         |  0.36 |
| Political corruption/malfeasance                             |  0.31 |
| Pro-Israel/Zionism                                           |  0.28 |
| Transgender issues (Against)                                 |  0.26 |
| Gun owner rights                                             |  0.21 |
| Pro-law enforcement                                          |  0.12 |
| Traditional marriage/family                                  |  0.10 |
| Men’s rights                                                 |  0.03 |
|                                                              |  0.02 |

| racial_issue                                                 |   pct |
|:-------------------------------------------------------------|------:|
| \_Not relevant                                               | 55.26 |
| Percent of events with any value                             | 44.89 |
| Anti-racism                                                  | 14.14 |
| Police violence                                              |  9.47 |
| University governance, admin, policies, programs, curriculum |  8.83 |
| Immigration (For)                                            |  7.92 |
| Campus climate                                               |  7.17 |
| Indigenous issues                                            |  2.83 |
| White supremacy (Against)                                    |  2.52 |
| \_Other Issue                                                |  2.22 |
| Hate speech                                                  |  1.60 |
| Racist/racialized symbols                                    |  1.42 |
| Hate crimes/Anti-minority violence                           |  1.22 |
| Prison/mass incarceration                                    |  0.79 |
| Memorials & anniversaries                                    |  0.61 |
| Affirmative action (For)                                     |  0.56 |
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
| Anti-racism                                                  | 858 |
| Police violence                                              | 575 |
| University governance, admin, policies, programs, curriculum | 536 |
| Immigration (For)                                            | 481 |
| Campus climate                                               | 435 |
| Indigenous issues                                            | 172 |
| White supremacy (Against)                                    | 153 |
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
| bachelors_granting   | boolean |     1.000 |        NA |
| campaign             | boolean |     0.245 |        NA |
| counterprotest       | boolean |     0.044 |        NA |
| hbcu                 | boolean |     0.011 |        NA |
| inaccurate_date      | boolean |     0.009 |        NA |
| masters_granting     | boolean |     1.000 |        NA |
| multiple_cities      | boolean |     0.024 |        NA |
| off_campus           | boolean |     0.073 |        NA |
| on_campus_no_student | boolean |     0.071 |        NA |
| phd_granting         | boolean |     1.000 |        NA |
| private              | boolean |     0.058 |        NA |
| quotes               | boolean |     0.635 |        NA |
| ritual               | boolean |     0.029 |        NA |
| slogans              | boolean |     0.396 |        NA |
| tribal               | boolean |     0.000 |        NA |
| adjudicator_id       | numeric |    53.323 |     2.577 |
| enrollment_count     | numeric | 42812.697 | 10169.299 |
| mhi                  | numeric | 67520.876 | 16814.225 |
| rent_burden          | numeric |     0.517 |     0.082 |
| republican_vote_prop | numeric |     0.317 |     0.153 |
| unemp                | numeric |     5.135 |     1.664 |
| white_prop           | numeric |     0.693 |     0.167 |

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

    ##   |                                                                              |                                                                      |   0%  |                                                                              |==========================================                            |  60%  |                                                                              |============================================================          |  85%  |                                                                              |======================================================================| 100%

![](exploratory_plots_files/figure-gfm/mpeds_map-1.png)<!-- -->

# Investigating specific movements

## 2015 Mizzou protests

| Statistics for Mizzou protests |   n |
|:-------------------------------|----:|
| Total number of links          | 170 |
| Unique events                  | 120 |
| Campaign events only           |  17 |
| Coinciding events only         |  18 |
| Counterprotest events only     |   1 |
| Solidarity events only         | 134 |

The discrepancy between the total number of links from the original
Mizzou event to the total number of unique events comes from some events
being both campaign events and counterprotest events, or campaign events
and solidarity events.

![](exploratory_plots_files/figure-gfm/mizzou_map-1.png)<!-- -->![](exploratory_plots_files/figure-gfm/mizzou_map-2.png)<!-- -->

### Mizzou issues

| value                                                                 |   n |
|:----------------------------------------------------------------------|----:|
| Anti-racism (racial)                                                  | 110 |
| Campus climate (racial)                                               |  89 |
| University governance, admin, policies, programs, curriculum (racial) |  74 |
| University governance, admin, policies, programs, curriculum          |  18 |
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
| 20151102_Columbia_HungerStrike_UniversityGovernance   |              107 |                 79 |
| 20151010_Columbia_Blockade_UniversityGovernance       |               35 |                 27 |
| Umbrella_Mizzou_Anti-Racism_2015_Oct-Nov              |               19 |                 17 |
| 20151109_Columbia_Rally_CampusClimate                 |               14 |                 13 |
| 20151102_Columbia_Occupation_UniversityGovernance     |               11 |                  7 |
| 20151110_Columbia_FacultyWalkout_UniversityGovernance |                4 |                  4 |
| 20151001_Columbia_March_AntiRacism                    |                3 |                  2 |
| 20151021_Columbia_OtherForm_UniversityGovernance      |                3 |                  3 |
| 20151109_Columbia_OtherForm_FreeSpeech                |                2 |                  2 |
| 20151006_Columbia_Sit-in_AntiRacism                   |                1 |                  1 |
| 20151107_Columbia_Boycott_UniversityGovernance        |                1 |                  1 |
| 20151107_Columbia_Demonstration_CampusClimate         |                1 |                  1 |

## 2012 Quebec protest wave

| Statistics for Quebec protests |   n |
|:-------------------------------|----:|
| Total number of links          | 175 |
| Unique events                  | 176 |
| Campaign events only           | 167 |
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
| 2014-12-01                      |           41 |
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
