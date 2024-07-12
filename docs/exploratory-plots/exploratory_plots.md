Exploratory Plots
================

- [Basic counts](#basic-counts)
  - [For US events, public/private division of police
    analyses](#for-us-events-publicprivate-division-of-police-analyses)
- [Counts of university responses](#counts-of-university-responses)
  - [For US, university responses disaggregated by public/private
    status](#for-us-university-responses-disaggregated-by-publicprivate-status)
  - [Counts by (combined) issue](#counts-by-combined-issue)
  - [Counts by combined issue, separated by
    country](#counts-by-combined-issue-separated-by-country)
  - [Counts by (split) issue and racial
    issue](#counts-by-split-issue-and-racial-issue)
  - [Counts of forms](#counts-of-forms)
  - [Counts of targets](#counts-of-targets)
- [Police involvement by issue](#police-involvement-by-issue)
- [Police involvement by issue separated by
  country](#police-involvement-by-issue-separated-by-country)
- [Police involvement for US disaggregated by public vs private
  universities](#police-involvement-for-us-disaggregated-by-public-vs-private-universities)
- [Percentages of all protest with given
  preset](#percentages-of-all-protest-with-given-preset)
- [Counts over time](#counts-over-time)
  - [Police activities over time](#police-activities-over-time)
  - [Racial and “nonracial” issues over time
    (collapsed)](#racial-and-nonracial-issues-over-time-collapsed)
- [Issue co-occurrence](#issue-co-occurrence)
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

| Events with many issues                 | Number of issues |
|:----------------------------------------|-----------------:|
| 20160305_Toronto_March_Feminism         |               14 |
| 20151112_Athens_Rally_Tuition           |               10 |
| 20160928_Hempstead_Rally_Trump(Against) |               10 |
| 20180201_Toronto_March_Anti-War         |               10 |
| 20140208_Raleigh_March_PublicFunding    |                9 |

| Statistic                                             |  Value |
|:------------------------------------------------------|-------:|
| Total imported events                                 | 5972.0 |
| Total non-umbrella events                             | 5518.0 |
| Unique locations                                      |  530.0 |
| US counties                                           |  314.0 |
| Canadian CMAs                                         |   31.0 |
| Universities                                          |  584.0 |
| CEs with missing universities                         |    2.0 |
| Universities with missing locations                   |   39.0 |
| \# of events with police activity recorded            |  868.0 |
| \# of events with any police field recorded           |  920.0 |
| \# of events with university police only              |  450.0 |
| \# of events with government police only              |  280.0 |
| \# of events with both types of police                |  149.0 |
| \# of events with at least one issue or racial issue  | 5485.0 |
| \# of events with at least one issue and racial issue | 1053.0 |
| mode of issue counts                                  |    1.0 |
| mean of issue counts                                  |    2.1 |
| \# of events with just one issue                      | 2022.0 |

The initial import of the MPEDS db found 5972 unique canonical events,
and after all cleaning steps we still have 5971 canonical events.

However, there’s still an issue regarding duplicate matches in IPEDS we
can detect (there are likely also incorrect matches that we can’t detect
programmatically right now); there are lots of schools called “Columbia
College” (or another common name) inside IPEDS, so any schools with that
name in MPEDS will be assigned multiple schools. The MPEDS-IPEDS join is
crucial because we also use IPEDS to join county FIPS identifiers, and
thus no further joins will be accurate unless the MPEDS-IPEDS join is
accurate. As of Jan 30, 2023, we are in the middle of repairing this
join.

Of those events, there were 530 unique locations, 314 unique counties,
31 unique Canadian CMAs, and 584 unique universities. Surprisingly, all
of the locations that were not universities found geocoding matches, and
hand-checking the most common ones indicates that there isn’t a strong
pattern of missing value substitution, e.g. Google isn’t sending the
majority of results to the centroid of America or to `(-1, -1)` or
anything weird like that. Universities had a harder time, with 2
canonical events missing lon/lat coords for universities.

That comes out to ~5% of universities not having coordinates, and ~2.5%
of canonical events not having universities with coordinates.

The top universities by appearances:

| university_name                      |   n |
|:-------------------------------------|----:|
| University of California Berkeley    | 281 |
| McGill University                    | 257 |
| Concordia University                 | 213 |
| Harvard University                   | 148 |
| University of Toronto                | 124 |
| University of Michigan Ann Arbor     | 122 |
| University of California Los Angeles | 116 |
| Ryerson University                   |  90 |
| York University                      |  83 |
| Columbia University                  |  81 |
| University of Missouri Columbia      |  74 |
| University of Chicago                |  73 |
| Tufts University                     |  71 |
| University of Texas Austin           |  59 |
| University of Wisconsin Madison      |  58 |

And the top locations:

| location               |   n |
|:-----------------------|----:|
| Montreal, QC, Canada   | 376 |
| Berkeley, CA, USA      | 221 |
| Toronto, ON, Canada    | 219 |
| New York City, NY, USA | 164 |
| Los Angeles, CA, USA   | 135 |
| Cambridge, MA, USA     | 129 |
| Chicago, IL, USA       | 116 |
| Ann Arbor, MI, USA     | 109 |
| San Diego, CA, USA     |  92 |
| San Francisco, CA, USA |  84 |
| Washington, D.C., USA  |  73 |
| Columbia, MO, USA      |  66 |
| Boston, MA, USA        |  56 |
| Austin, TX, USA        |  54 |
| Vancouver, BC, Canada  |  53 |

Top states:

| area_name            |   n |
|:---------------------|----:|
| California           | 894 |
| Quebec               | 422 |
| Massachusetts        | 347 |
| New York             | 325 |
| Ontario              | 323 |
| Illinois             | 259 |
| Pennsylvania         | 188 |
| Michigan             | 167 |
| Texas                | 162 |
| Ohio                 | 139 |
| Missouri             | 130 |
| District of Columbia | 126 |
| Virginia             | 119 |
| Connecticut          | 116 |
| British Col          | 115 |

And finally the top counties:

| locality_name        |   n |
|:---------------------|----:|
| Montréal             | 390 |
| Middlesex            | 283 |
| Alameda              | 244 |
| Toronto              | 235 |
| Los Angeles          | 204 |
| New York             | 172 |
| Cook                 | 140 |
| District of Columbia | 126 |
| Washtenaw            | 116 |
| San Diego            | 100 |
| San Francisco        |  85 |
| Vancouver            |  85 |
| Boone                |  66 |
| Santa Clara          |  59 |
| Suffolk              |  57 |
| Travis               |  57 |

These glimpses seem mostly in line with what we should expect, with a
strong caveat that the Missouri protests are not making a leading
appearance in the counts by location, but there do seem to be a fair
number in Missouri when we take a look by state. It seems there are
non-MO locations being recognized as happening in Missouri. See our 1:1
notes Google Doc for details.

| police_presence_and_size | Canada |   US | Total |
|:-------------------------|-------:|-----:|------:|
| NA                       |    739 | 3870 |  4609 |
| NA/Unclear               |     57 |  338 |   395 |
| Substantial              |    125 |  163 |   288 |
| Small/0 to 5 officers    |     17 |   72 |    89 |
| Heavily Policed          |     15 |   17 |    32 |
| Motorized Presence       |     14 |    3 |    17 |

| police_activities            | Canada |   US | Total |
|:-----------------------------|-------:|-----:|------:|
| NA                           |    724 | 3785 |  4509 |
| Monitor/Present              |     89 |  322 |   411 |
| Instruct/Warn                |     57 |  123 |   180 |
| Constrain                    |     63 |   99 |   162 |
| Arrest or Attempted          |     45 |  115 |   160 |
| Formal Accusation            |     30 |   73 |   103 |
| Remove Individual Protesters |     13 |   52 |    65 |
| End Protest                  |     24 |   33 |    57 |
| Force: Vague/Body            |     32 |   24 |    56 |
| “Breaking the Rules”         |     22 |   30 |    52 |
| Detain                       |     18 |   30 |    48 |
| NA/Unclear                   |      6 |   28 |    34 |
| Force: Weapon                |     22 |    7 |    29 |
| Force: 2+ Weapon Types       |     21 |    6 |    27 |
| Present                      |      1 |   24 |    25 |
| Arrest- Large Scale          |     17 |    7 |    24 |
| Cooperate/Coordinate         |      1 |   13 |    14 |
| Participate                  |      1 |    5 |     6 |
| Disputed Actions             |      2 |    3 |     5 |
| “We’re Responsive”           |     NA |    2 |    NA |

| type_of_police        | Canada |   US | Total |
|:----------------------|-------:|-----:|------:|
| NA                    |    725 | 3776 |  4501 |
| Univ police           |     70 |  391 |   461 |
| Govt police           |    102 |  199 |   301 |
| Univ police - assumed |     22 |  124 |   146 |
| Govt police - assumed |     59 |   73 |   132 |
| “Riot police”         |     52 |   16 |    68 |
| Private Security      |     11 |   17 |    28 |
| NA/Unclear            |     NA |    6 |    NA |
| Secret Service        |     NA |    3 |    NA |

## For US events, public/private division of police analyses

| police_presence_and_size | Private | Public |  NA |
|:-------------------------|--------:|-------:|----:|
| NA                       |    1295 |   2161 | 414 |
| NA/Unclear               |      84 |    220 |  34 |
| Substantial              |      44 |    104 |  15 |
| Small/0 to 5 officers    |      16 |     47 |   9 |
| Heavily Policed          |       6 |      9 |   2 |
| Motorized Presence       |       1 |      2 |  NA |

| police_activities            | Private | Public |  NA |
|:-----------------------------|--------:|-------:|----:|
| NA                           |    1267 |   2115 | 403 |
| Monitor/Present              |      95 |    199 |  28 |
| Instruct/Warn                |      28 |     78 |  17 |
| Arrest or Attempted          |      27 |     72 |  16 |
| Constrain                    |      23 |     61 |  15 |
| Formal Accusation            |      13 |     46 |  14 |
| Remove Individual Protesters |      18 |     29 |   5 |
| Detain                       |       4 |     21 |   5 |
| End Protest                  |       6 |     21 |   6 |
| “Breaking the Rules”         |       7 |     18 |   5 |
| NA/Unclear                   |      10 |     15 |   3 |
| Present                      |       3 |     15 |   6 |
| Force: Vague/Body            |       7 |     14 |   3 |
| Cooperate/Coordinate         |       2 |     10 |   1 |
| Force: 2+ Weapon Types       |       1 |      5 |  NA |
| Force: Weapon                |       1 |      5 |   1 |
| Arrest- Large Scale          |       1 |      4 |   2 |
| Participate                  |       1 |      4 |  NA |
| Disputed Actions             |       2 |      1 |  NA |
| “We’re Responsive”           |      NA |      1 |   1 |

| type_of_police        | Private | Public |  NA |
|:----------------------|--------:|-------:|----:|
| NA                    |    1262 |   2111 | 403 |
| Univ police           |     106 |    241 |  44 |
| Govt police           |      67 |    116 |  16 |
| Univ police - assumed |      22 |     93 |   9 |
| Govt police - assumed |      22 |     42 |   9 |
| “Riot police”         |      NA |     14 |   2 |
| Private Security      |       5 |     11 |   1 |
| NA/Unclear            |      NA |      2 |   4 |
| Secret Service        |      NA |      2 |   1 |

# Counts of university responses

| university_action_on_issue | Canada |   US | Total |
|:---------------------------|-------:|-----:|------:|
| NA                         |    711 | 3208 |  3919 |
| NA/Unclear                 |    140 |  665 |   805 |
| Action in Process          |     59 |  328 |   387 |
| Reject Demand              |     29 |  155 |   184 |
| Structural Change          |      4 |   88 |    92 |
| Fulfill Demand             |     10 |   79 |    89 |
| No Cancellation            |      5 |   50 |    55 |
| Compromised Action         |      8 |   35 |    43 |
| Hold Forum                 |      4 |   30 |    34 |
| Contrary Action/Refuse     |      7 |   19 |    26 |
| Cancel Speaker/Event       |      2 |   21 |    23 |
| Resign/Fire                |      1 |    8 |     9 |
| Correct Racist History     |     NA |    7 |    NA |
| Sanction                   |     NA |    4 |    NA |
| Short Term Services        |     NA |   12 |    NA |

| university_discourse_on_issue   | Canada |   US | Total |
|:--------------------------------|-------:|-----:|------:|
| NA                              |    700 | 3195 |  3895 |
| NA/Unclear                      |     96 |  436 |   532 |
| Explain Bureaucracy/Law         |    106 |  379 |   485 |
| Express Contrary Position       |     54 |  279 |   333 |
| Express Agreement               |     25 |  296 |   321 |
| Affirm Diversity                |      9 |   87 |    96 |
| Affirm Free Speech when Bigotry |      5 |   70 |    75 |
| Affirm Marginalized Students    |      5 |   53 |    58 |
| Emotional Appeal                |      3 |   43 |    46 |
| Oppose Racism                   |      1 |   29 |    30 |
| Apology/Responsibility          |      3 |   24 |    27 |
| Oppose Oppression               |      1 |   26 |    27 |
| Affirm BIPOC Students           |      3 |   17 |    20 |

| university_reactions_to_protest | Canada |   US | Total |
|:--------------------------------|-------:|-----:|------:|
| NA                              |    707 | 3198 |  3905 |
| NA/Unclear                      |    116 |  573 |   689 |
| Monitor/Present                 |     31 |  254 |   285 |
| Meet                            |     27 |  159 |   186 |
| Get Confronted                  |     27 |  156 |   183 |
| Direct Communications           |     31 |  150 |   181 |
| Instruct/Warn                   |     26 |   90 |   116 |
| Participate/Aid                 |     10 |  105 |   115 |
| Penalize                        |     16 |   33 |    49 |
| Revisit Protest P&P             |      9 |   24 |    33 |
| No Intervention                 |     24 |    6 |    30 |
| Avoid Penalizing                |      4 |   20 |    24 |
| Refuse to Meet                  |      2 |   20 |    22 |
| End Protest                     |      4 |    5 |     9 |
| Protest Elsewhere               |     NA |    3 |    NA |

## For US, university responses disaggregated by public/private status

| police_presence_and_size | Private | Public |  NA |
|:-------------------------|--------:|-------:|----:|
| NA                       |    1295 |   2161 | 414 |
| NA/Unclear               |      84 |    220 |  34 |
| Substantial              |      44 |    104 |  15 |
| Small/0 to 5 officers    |      16 |     47 |   9 |
| Heavily Policed          |       6 |      9 |   2 |
| Motorized Presence       |       1 |      2 |  NA |

| police_activities            | Private | Public |  NA |
|:-----------------------------|--------:|-------:|----:|
| NA                           |    1267 |   2115 | 403 |
| Monitor/Present              |      95 |    199 |  28 |
| Instruct/Warn                |      28 |     78 |  17 |
| Arrest or Attempted          |      27 |     72 |  16 |
| Constrain                    |      23 |     61 |  15 |
| Formal Accusation            |      13 |     46 |  14 |
| Remove Individual Protesters |      18 |     29 |   5 |
| Detain                       |       4 |     21 |   5 |
| End Protest                  |       6 |     21 |   6 |
| “Breaking the Rules”         |       7 |     18 |   5 |
| NA/Unclear                   |      10 |     15 |   3 |
| Present                      |       3 |     15 |   6 |
| Force: Vague/Body            |       7 |     14 |   3 |
| Cooperate/Coordinate         |       2 |     10 |   1 |
| Force: 2+ Weapon Types       |       1 |      5 |  NA |
| Force: Weapon                |       1 |      5 |   1 |
| Arrest- Large Scale          |       1 |      4 |   2 |
| Participate                  |       1 |      4 |  NA |
| Disputed Actions             |       2 |      1 |  NA |
| “We’re Responsive”           |      NA |      1 |   1 |

| type_of_police        | Private | Public |  NA |
|:----------------------|--------:|-------:|----:|
| NA                    |    1262 |   2111 | 403 |
| Univ police           |     106 |    241 |  44 |
| Govt police           |      67 |    116 |  16 |
| Univ police - assumed |      22 |     93 |   9 |
| Govt police - assumed |      22 |     42 |   9 |
| “Riot police”         |      NA |     14 |   2 |
| Private Security      |       5 |     11 |   1 |
| NA/Unclear            |      NA |      2 |   4 |
| Secret Service        |      NA |      2 |   1 |

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

| issue                                                                     | Canada | US     | Total  |
|:--------------------------------------------------------------------------|:-------|:-------|:-------|
| University governance, admin, policies, programs, curriculum              | 5.73%  | 24.13% | 29.86% |
| Labor and work                                                            | 3.41%  | 13.28% | 16.69% |
| Anti-racism (racialized)                                                  | 0.97%  | 14.41% | 15.37% |
| Tuition, fees, financial aid                                              | 5.42%  | 5.38%  | 10.8%  |
| Police violence (racialized)                                              | 0.26%  | 10.12% | 10.38% |
| Trump and/or his administration (Against)                                 | 0.15%  | 10.05% | 10.2%  |
| University governance, admin, policies, programs, curriculum (racialized) | 0.33%  | 9.54%  | 9.87%  |
| \_Other Issue                                                             | 2.48%  | 6.46%  | 8.94%  |
| Immigration (For) (racialized)                                            | 0.16%  | 8.15%  | 8.32%  |
| Campus climate (racialized)                                               | 0.24%  | 7.66%  | 7.9%   |
| Environmental                                                             | 1.2%   | 6.18%  | 7.39%  |
| Economy/inequality                                                        | 1.64%  | 4.1%   | 5.75%  |
| Sexual assault/violence                                                   | 0.89%  | 4.8%   | 5.69%  |
| Feminism/women’s issues                                                   | 1%     | 3.98%  | 4.98%  |
| Public funding for higher education                                       | 1.59%  | 2.97%  | 4.56%  |
| Faith-based discrimination                                                | 0.71%  | 3.63%  | 4.34%  |
| LGB+/Sexual orientation (For)                                             | 0.36%  | 3.03%  | 3.39%  |
| Indigenous issues (racialized)                                            | 0.93%  | 2.04%  | 2.97%  |
| White supremacy (Against) (racialized)                                    | 0.24%  | 2.32%  | 2.55%  |
| Transgender issues (For)                                                  | 0.33%  | 2.01%  | 2.33%  |
| \_Other Issue (racialized)                                                | 0.24%  | 1.99%  | 2.23%  |
| Far Right/Alt Right (Against)                                             | 0.22%  | 1.9%   | 2.12%  |
| Abortion access                                                           | 0.47%  | 1.35%  | 1.82%  |
| Gun control                                                               | 0.04%  | 1.79%  | 1.82%  |
| Police violence/anti-law enforcement/criminal justice                     | 0.4%   | 1.42%  | 1.82%  |
| Hate speech                                                               | 0.27%  | 1.46%  | 1.73%  |
| Abortion (Against)/Pro-life                                               | 0.36%  | 1.33%  | 1.7%   |
| Racist/racialized symbols (racialized)                                    | 0.07%  | 1.59%  | 1.66%  |
| Hate speech (racialized)                                                  | 0.04%  | 1.55%  | 1.59%  |
| Free speech                                                               | 0.36%  | 1.17%  | 1.53%  |
| Pro-Palestine/BDS                                                         | 0.53%  | 0.82%  | 1.35%  |
| Hate crimes/Anti-minority violence (racialized)                           | 0.18%  | 1.11%  | 1.29%  |
| Anti-war/peace                                                            | 0.33%  | 0.73%  | 1.06%  |
| Social services and welfare                                               | 0.73%  | 0.29%  | 1.02%  |
| LGB+/Sexual orientation (Against)                                         | 0.04%  | 0.86%  | 0.89%  |
| Prison/mass incarceration (racialized)                                    | 0.02%  | 0.84%  | 0.86%  |
| Human rights                                                              | 0.27%  | 0.46%  | 0.73%  |
| Memorials & anniversaries (racialized)                                    | 0.07%  | 0.62%  | 0.69%  |
| Far Right/Alt Right (For)                                                 | 0.07%  | 0.58%  | 0.66%  |
| Domestic foreign policy                                                   | 0.07%  | 0.47%  | 0.55%  |
| Accessibility                                                             | 0.11%  | 0.29%  | 0.4%   |
| Animal rights                                                             | 0.07%  | 0.33%  | 0.4%   |
| Hate crimes/Anti-minority violence                                        | 0.13%  | 0.27%  | 0.4%   |
| White supremacy (For) (racialized)                                        | 0.04%  | 0.36%  | 0.4%   |
| Anti-colonial/political independence                                      | 0.24%  | 0.15%  | 0.38%  |
| Transgender issues (Against)                                              | 0.04%  | 0.33%  | 0.36%  |
| Political corruption/malfeasance                                          | 0.05%  | 0.24%  | 0.29%  |
| Pro-Israel/Zionism                                                        | 0.16%  | 0.11%  | 0.27%  |
| Pro-law enforcement                                                       | 0.02%  | 0.07%  | 0.09%  |
| Racial/ethnic pride - white (racialized)                                  | 0.02%  | 0.07%  | 0.09%  |
| Reparations (racialized)                                                  | 0.04%  | 0.05%  | 0.09%  |
| Men’s rights                                                              | 0.02%  | NA%    | NA%    |
| Affirmative action (Against) (racialized)                                 | NA%    | 0.07%  | NA%    |
| Affirmative action (For) (racialized)                                     | NA%    | 0.62%  | NA%    |
| All Lives Matter (racialized)                                             | NA%    | 0.11%  | NA%    |
| Cultural appropriation (racialized)                                       | NA%    | 0.36%  | NA%    |
| Gun owner rights                                                          | NA%    | 0.24%  | NA%    |
| Immigration (Against) (racialized)                                        | NA%    | 0.35%  | NA%    |
| K-12 education (racialized)                                               | NA%    | 0.02%  | NA%    |
| Pro-police (racialized)                                                   | NA%    | 0.09%  | NA%    |
| Racial/ethnic pride - minority (racialized)                               | NA%    | 0.02%  | NA%    |
| Traditional marriage/family                                               | NA%    | 0.11%  | NA%    |
| Transgender issues                                                        | NA%    | 0.02%  | NA%    |
| Trump and/or his administration (For)                                     | NA%    | 0.93%  | NA%    |

## Counts by combined issue, separated by country

| issue                                                                     | Canada |   US | Total |
|:--------------------------------------------------------------------------|-------:|-----:|------:|
| University governance, admin, policies, programs, curriculum              |    314 | 1323 |  1637 |
| Labor and work                                                            |    187 |  728 |   915 |
| Anti-racism (racialized)                                                  |     53 |  790 |   843 |
| Tuition, fees, financial aid                                              |    297 |  295 |   592 |
| Police violence (racialized)                                              |     14 |  555 |   569 |
| Trump and/or his administration (Against)                                 |      8 |  551 |   559 |
| University governance, admin, policies, programs, curriculum (racialized) |     18 |  523 |   541 |
| \_Other Issue                                                             |    136 |  354 |   490 |
| Immigration (For) (racialized)                                            |      9 |  447 |   456 |
| Campus climate (racialized)                                               |     13 |  420 |   433 |
| Environmental                                                             |     66 |  339 |   405 |
| Economy/inequality                                                        |     90 |  225 |   315 |
| Sexual assault/violence                                                   |     49 |  263 |   312 |
| Feminism/women’s issues                                                   |     55 |  218 |   273 |
| Public funding for higher education                                       |     87 |  163 |   250 |
| Faith-based discrimination                                                |     39 |  199 |   238 |
| LGB+/Sexual orientation (For)                                             |     20 |  166 |   186 |
| Indigenous issues (racialized)                                            |     51 |  112 |   163 |
| White supremacy (Against) (racialized)                                    |     13 |  127 |   140 |
| Transgender issues (For)                                                  |     18 |  110 |   128 |
| \_Other Issue (racialized)                                                |     13 |  109 |   122 |
| Far Right/Alt Right (Against)                                             |     12 |  104 |   116 |
| Abortion access                                                           |     26 |   74 |   100 |
| Gun control                                                               |      2 |   98 |   100 |
| Police violence/anti-law enforcement/criminal justice                     |     22 |   78 |   100 |
| Hate speech                                                               |     15 |   80 |    95 |
| Abortion (Against)/Pro-life                                               |     20 |   73 |    93 |
| Racist/racialized symbols (racialized)                                    |      4 |   87 |    91 |
| Hate speech (racialized)                                                  |      2 |   85 |    87 |
| Free speech                                                               |     20 |   64 |    84 |
| Pro-Palestine/BDS                                                         |     29 |   45 |    74 |
| Hate crimes/Anti-minority violence (racialized)                           |     10 |   61 |    71 |
| Anti-war/peace                                                            |     18 |   40 |    58 |
| Social services and welfare                                               |     40 |   16 |    56 |
| LGB+/Sexual orientation (Against)                                         |      2 |   47 |    49 |
| Prison/mass incarceration (racialized)                                    |      1 |   46 |    47 |
| Human rights                                                              |     15 |   25 |    40 |
| Memorials & anniversaries (racialized)                                    |      4 |   34 |    38 |
| Far Right/Alt Right (For)                                                 |      4 |   32 |    36 |
| Domestic foreign policy                                                   |      4 |   26 |    30 |
| Accessibility                                                             |      6 |   16 |    22 |
| Animal rights                                                             |      4 |   18 |    22 |
| Hate crimes/Anti-minority violence                                        |      7 |   15 |    22 |
| White supremacy (For) (racialized)                                        |      2 |   20 |    22 |
| Anti-colonial/political independence                                      |     13 |    8 |    21 |
| Transgender issues (Against)                                              |      2 |   18 |    20 |
| Political corruption/malfeasance                                          |      3 |   13 |    16 |
| Pro-Israel/Zionism                                                        |      9 |    6 |    15 |
| Pro-law enforcement                                                       |      1 |    4 |     5 |
| Racial/ethnic pride - white (racialized)                                  |      1 |    4 |     5 |
| Reparations (racialized)                                                  |      2 |    3 |     5 |
| Men’s rights                                                              |      1 |   NA |    NA |
| Affirmative action (Against) (racialized)                                 |     NA |    4 |    NA |
| Affirmative action (For) (racialized)                                     |     NA |   34 |    NA |
| All Lives Matter (racialized)                                             |     NA |    6 |    NA |
| Cultural appropriation (racialized)                                       |     NA |   20 |    NA |
| Gun owner rights                                                          |     NA |   13 |    NA |
| Immigration (Against) (racialized)                                        |     NA |   19 |    NA |
| K-12 education (racialized)                                               |     NA |    1 |    NA |
| Pro-police (racialized)                                                   |     NA |    5 |    NA |
| Racial/ethnic pride - minority (racialized)                               |     NA |    1 |    NA |
| Traditional marriage/family                                               |     NA |    6 |    NA |
| Transgender issues                                                        |     NA |    1 |    NA |
| Trump and/or his administration (For)                                     |     NA |   51 |    NA |

## Counts by (split) issue and racial issue

| issue                                                        | Canada |   US | Total |
|:-------------------------------------------------------------|-------:|-----:|------:|
| University governance, admin, policies, programs, curriculum |    314 | 1323 |  1637 |
| \_Not relevant                                               |     30 |  989 |  1019 |
| Labor and work                                               |    187 |  728 |   915 |
| Tuition, fees, financial aid                                 |    297 |  295 |   592 |
| Trump and/or his administration (Against)                    |      8 |  551 |   559 |
| \_Other Issue                                                |    136 |  354 |   490 |
| Environmental                                                |     66 |  339 |   405 |
| Economy/inequality                                           |     90 |  225 |   315 |
| Sexual assault/violence                                      |     49 |  263 |   312 |
| Feminism/women’s issues                                      |     55 |  218 |   273 |
| Public funding for higher education                          |     87 |  163 |   250 |
| Faith-based discrimination                                   |     39 |  199 |   238 |
| LGB+/Sexual orientation (For)                                |     20 |  166 |   186 |
| Transgender issues (For)                                     |     18 |  110 |   128 |
| Far Right/Alt Right (Against)                                |     12 |  104 |   116 |
| Abortion access                                              |     26 |   74 |   100 |
| Gun control                                                  |      2 |   98 |   100 |
| Police violence/anti-law enforcement/criminal justice        |     22 |   78 |   100 |
| Hate speech                                                  |     15 |   80 |    95 |
| Abortion (Against)/Pro-life                                  |     20 |   73 |    93 |
| Free speech                                                  |     20 |   64 |    84 |
| Pro-Palestine/BDS                                            |     29 |   45 |    74 |
| NA                                                           |      4 |   64 |    68 |
| Anti-war/peace                                               |     18 |   40 |    58 |
| Social services and welfare                                  |     40 |   16 |    56 |
| LGB+/Sexual orientation (Against)                            |      2 |   47 |    49 |
| Human rights                                                 |     15 |   25 |    40 |
| Far Right/Alt Right (For)                                    |      4 |   32 |    36 |
| Domestic foreign policy                                      |      4 |   26 |    30 |
| Accessibility                                                |      6 |   16 |    22 |
| Animal rights                                                |      4 |   18 |    22 |
| Hate crimes/Anti-minority violence                           |      7 |   15 |    22 |
| Anti-colonial/political independence                         |     13 |    8 |    21 |
| Transgender issues (Against)                                 |      2 |   18 |    20 |
| Political corruption/malfeasance                             |      3 |   13 |    16 |
| Pro-Israel/Zionism                                           |      9 |    6 |    15 |
| Pro-law enforcement                                          |      1 |    4 |     5 |
| Men’s rights                                                 |      1 |   NA |    NA |
|                                                              |     NA |    1 |    NA |
| Gun owner rights                                             |     NA |   13 |    NA |
| Traditional marriage/family                                  |     NA |    6 |    NA |
| Transgender issues                                           |     NA |    1 |    NA |
| Trump and/or his administration (For)                        |     NA |   51 |    NA |

| racial_issue                                                 | Canada |   US | Total |
|:-------------------------------------------------------------|-------:|-----:|------:|
| \_Not relevant                                               |    803 | 2398 |  3201 |
| Anti-racism                                                  |     53 |  790 |   843 |
| Police violence                                              |     14 |  555 |   569 |
| University governance, admin, policies, programs, curriculum |     18 |  523 |   541 |
| Immigration (For)                                            |      9 |  447 |   456 |
| Campus climate                                               |     13 |  420 |   433 |
| Indigenous issues                                            |     51 |  112 |   163 |
| White supremacy (Against)                                    |     13 |  127 |   140 |
| \_Other Issue                                                |     13 |  109 |   122 |
| Racist/racialized symbols                                    |      4 |   87 |    91 |
| Hate speech                                                  |      2 |   85 |    87 |
| Hate crimes/Anti-minority violence                           |     10 |   61 |    71 |
| Prison/mass incarceration                                    |      1 |   46 |    47 |
| Memorials & anniversaries                                    |      4 |   34 |    38 |
| White supremacy (For)                                        |      2 |   20 |    22 |
| Racial/ethnic pride - white                                  |      1 |    4 |     5 |
| Reparations                                                  |      2 |    3 |     5 |
| Affirmative action (Against)                                 |     NA |    4 |    NA |
| Affirmative action (For)                                     |     NA |   34 |    NA |
| All Lives Matter                                             |     NA |    6 |    NA |
| Cultural appropriation                                       |     NA |   20 |    NA |
| Immigration (Against)                                        |     NA |   19 |    NA |
| K-12 education                                               |     NA |    1 |    NA |
| Pro-police                                                   |     NA |    5 |    NA |
| Racial/ethnic pride - minority                               |     NA |    1 |    NA |

## Counts of forms

| form                                          | Canada |   US | Total |
|:----------------------------------------------|-------:|-----:|------:|
| Rally/demonstration                           |    371 | 2390 |  2761 |
| March                                         |    242 | 1345 |  1587 |
| Blockade/slowdown/disruption                  |    147 |  397 |   544 |
| Symbolic display/symbolic action              |     37 |  502 |   539 |
| Petition                                      |    127 |  408 |   535 |
| Strike/walkout/lockout                        |    177 |  326 |   503 |
| \_Other Form                                  |     76 |  399 |   475 |
| Occupation/sit-in                             |     46 |  253 |   299 |
| Information distribution                      |     59 |  206 |   265 |
| NA                                            |     20 |  207 |   227 |
| Vigil                                         |     25 |  159 |   184 |
| Picketing                                     |     90 |   92 |   182 |
| Property damage                               |     19 |   24 |    43 |
| Boycott                                       |      9 |   18 |    27 |
| Press conference                              |      6 |   16 |    22 |
| Violence/attack against persons by protesters |      5 |   17 |    22 |
| Hunger Strike                                 |      3 |   13 |    16 |
| Riot                                          |      1 |    8 |     9 |
| Violence/attack                               |      1 |    1 |     2 |
| Civil disobedience                            |     NA |    2 |    NA |
| Information distribution/leafleting           |     NA |   22 |    NA |

## Counts of targets

| target                         | Canada |   US | Total |
|:-------------------------------|-------:|-----:|------:|
| University/school              |    366 | 1999 |  2365 |
| Domestic government            |    379 | 1006 |  1385 |
| Individual                     |     70 |  718 |   788 |
| \_No target                    |     96 |  624 |   720 |
| Police                         |     35 |  584 |   619 |
| \_Other target                 |     97 |  300 |   397 |
| Private/business               |     26 |  155 |   181 |
| Non-governmental organization  |     27 |   68 |    95 |
| NA                             |      6 |   58 |    64 |
| Foreign government             |     27 |   12 |    39 |
| Political party                |      1 |   16 |    17 |
| Other minority group           |      1 |    7 |     8 |
| Ethnic/racial group            |      1 |    4 |     5 |
| Intergovernmental organization |     NA |    2 |    NA |
| Medical facility/organization  |     NA |   22 |    NA |

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
| University governance, admin, policies, programs, curriculum          |                              27.93 |
| Tuition, fees, financial aid                                          |                              16.85 |
| Anti-racism (racial)                                                  |                              15.00 |
| Labor and work                                                        |                              11.74 |
| Police violence (racial)                                              |                              11.20 |
| \_Other Issue                                                         |                              10.76 |
| Trump and/or his administration (Against)                             |                              10.00 |
| Economy/inequality                                                    |                               8.15 |
| University governance, admin, policies, programs, curriculum (racial) |                               7.93 |
| Environmental                                                         |                               6.63 |
| Campus climate (racial)                                               |                               6.52 |
| Public funding for higher education                                   |                               5.54 |
| Far Right/Alt Right (Against)                                         |                               5.43 |
| Immigration (For) (racial)                                            |                               5.33 |
| White supremacy (Against) (racial)                                    |                               5.00 |
| LGB+/Sexual orientation (For)                                         |                               4.89 |
| Feminism/women’s issues                                               |                               4.57 |
| Sexual assault/violence                                               |                               4.24 |
| Faith-based discrimination                                            |                               4.13 |
| Police violence/anti-law enforcement/criminal justice                 |                               3.48 |
| Transgender issues (For)                                              |                               3.48 |
| Hate speech                                                           |                               2.93 |
| Abortion access                                                       |                               2.83 |
| Abortion (Against)/Pro-life                                           |                               2.61 |
| Far Right/Alt Right (For)                                             |                               2.28 |
| Free speech                                                           |                               2.28 |
| Social services and welfare                                           |                               2.17 |
| Hate speech (racial)                                                  |                               2.07 |
| Indigenous issues (racial)                                            |                               2.07 |
| LGB+/Sexual orientation (Against)                                     |                               1.85 |
| \_Other Issue (racial)                                                |                               1.85 |
| Anti-war/peace                                                        |                               1.74 |
| Pro-Palestine/BDS                                                     |                               1.63 |
| Racist/racialized symbols (racial)                                    |                               1.63 |
| White supremacy (For) (racial)                                        |                               1.63 |
| Transgender issues (Against)                                          |                               1.09 |
| Prison/mass incarceration (racial)                                    |                               0.98 |
| Trump and/or his administration (For)                                 |                               0.98 |
| Domestic foreign policy                                               |                               0.87 |
| Hate crimes/Anti-minority violence (racial)                           |                               0.87 |
| Gun control                                                           |                               0.76 |
| Affirmative action (For) (racial)                                     |                               0.54 |
| Animal rights                                                         |                               0.54 |
| Accessibility                                                         |                               0.43 |
| Anti-colonial/political independence                                  |                               0.43 |
| Political corruption/malfeasance                                      |                               0.43 |
| Pro-Israel/Zionism                                                    |                               0.43 |
| All Lives Matter (racial)                                             |                               0.33 |
| Human rights                                                          |                               0.33 |
| Immigration (Against) (racial)                                        |                               0.33 |
| Gun owner rights                                                      |                               0.22 |
| Hate crimes/Anti-minority violence                                    |                               0.22 |
| Memorials & anniversaries (racial)                                    |                               0.22 |
| Traditional marriage/family                                           |                               0.22 |
| Men’s rights                                                          |                               0.11 |
| Racial/ethnic pride - white (racial)                                  |                               0.11 |

![](exploratory_plots_files/figure-gfm/police_involvement_by_issue-1.png)<!-- -->![](exploratory_plots_files/figure-gfm/police_involvement_by_issue-2.png)<!-- -->![](exploratory_plots_files/figure-gfm/police_involvement_by_issue-3.png)<!-- -->

![](exploratory_plots_files/figure-gfm/police_issue_separate-1.png)<!-- -->![](exploratory_plots_files/figure-gfm/police_issue_separate-2.png)<!-- -->

# Police involvement by issue separated by country

| issue                                                                 |  US | Canada |
|:----------------------------------------------------------------------|----:|-------:|
| University governance, admin, policies, programs, curriculum          | 201 |     56 |
| Anti-racism (racial)                                                  | 125 |     13 |
| Police violence (racial)                                              |  98 |      5 |
| Trump and/or his administration (Against)                             |  91 |      1 |
| Labor and work                                                        |  83 |     25 |
| University governance, admin, policies, programs, curriculum (racial) |  73 |     NA |
| \_Other Issue                                                         |  66 |     33 |
| Campus climate (racial)                                               |  59 |      1 |
| Tuition, fees, financial aid                                          |  54 |    101 |
| Environmental                                                         |  49 |     12 |
| Immigration (For) (racial)                                            |  47 |      2 |
| Far Right/Alt Right (Against)                                         |  44 |      6 |
| Economy/inequality                                                    |  41 |     34 |
| White supremacy (Against) (racial)                                    |  40 |      6 |
| LGB+/Sexual orientation (For)                                         |  39 |      6 |
| Faith-based discrimination                                            |  35 |      3 |
| Sexual assault/violence                                               |  29 |     10 |
| Feminism/women’s issues                                               |  28 |     14 |
| Public funding for higher education                                   |  26 |     25 |
| Transgender issues (For)                                              |  26 |      6 |
| Hate speech                                                           |  23 |      4 |
| Hate speech (racial)                                                  |  19 |     NA |
| Far Right/Alt Right (For)                                             |  18 |      3 |
| Abortion (Against)/Pro-life                                           |  16 |      8 |
| LGB+/Sexual orientation (Against)                                     |  16 |      1 |
| Police violence/anti-law enforcement/criminal justice                 |  16 |     16 |
| Free speech                                                           |  15 |      6 |
| \_Other Issue (racial)                                                |  15 |      2 |
| Abortion access                                                       |  14 |     12 |
| Racist/racialized symbols (racial)                                    |  14 |      1 |
| White supremacy (For) (racial)                                        |  14 |      1 |
| Indigenous issues (racial)                                            |  11 |      8 |
| Prison/mass incarceration (racial)                                    |   9 |     NA |
| Trump and/or his administration (For)                                 |   9 |     NA |
| Anti-war/peace                                                        |   8 |      8 |
| Transgender issues (Against)                                          |   8 |      2 |
| Domestic foreign policy                                               |   7 |      1 |
| Gun control                                                           |   7 |     NA |
| Hate crimes/Anti-minority violence (racial)                           |   7 |      1 |
| Pro-Palestine/BDS                                                     |   6 |      9 |
| Affirmative action (For) (racial)                                     |   5 |     NA |
| Animal rights                                                         |   4 |      1 |
| Accessibility                                                         |   3 |      1 |
| All Lives Matter (racial)                                             |   3 |     NA |
| Immigration (Against) (racial)                                        |   3 |     NA |
| Political corruption/malfeasance                                      |   3 |      1 |
| Gun owner rights                                                      |   2 |     NA |
| Hate crimes/Anti-minority violence                                    |   2 |     NA |
| Memorials & anniversaries (racial)                                    |   2 |     NA |
| Traditional marriage/family                                           |   2 |     NA |
| Anti-colonial/political independence                                  |   1 |      3 |
| Human rights                                                          |   1 |      2 |
| Social services and welfare                                           |   1 |     19 |
| Men’s rights                                                          |  NA |      1 |
| Pro-Israel/Zionism                                                    |  NA |      4 |
| Racial/ethnic pride - white (racial)                                  |  NA |      1 |

# Police involvement for US disaggregated by public vs private universities

| issue                                                                 | Public | Private |
|:----------------------------------------------------------------------|-------:|--------:|
| University governance, admin, policies, programs, curriculum          |    122 |      68 |
| Anti-racism (racial)                                                  |     73 |      37 |
| Trump and/or his administration (Against)                             |     63 |      23 |
| Police violence (racial)                                              |     62 |      32 |
| Labor and work                                                        |     49 |      29 |
| University governance, admin, policies, programs, curriculum (racial) |     41 |      20 |
| Tuition, fees, financial aid                                          |     38 |       6 |
| \_Other Issue                                                         |     35 |      21 |
| Campus climate (racial)                                               |     33 |      16 |
| Immigration (For) (racial)                                            |     33 |      12 |
| Economy/inequality                                                    |     26 |      11 |
| Far Right/Alt Right (Against)                                         |     26 |      12 |
| White supremacy (Against) (racial)                                    |     26 |      11 |
| Environmental                                                         |     25 |      21 |
| LGB+/Sexual orientation (For)                                         |     24 |       7 |
| Faith-based discrimination                                            |     23 |       6 |
| Feminism/women’s issues                                               |     21 |       7 |
| Sexual assault/violence                                               |     19 |      10 |
| Hate speech                                                           |     17 |       4 |
| Transgender issues (For)                                              |     15 |       7 |
| Abortion (Against)/Pro-life                                           |     14 |       1 |
| Hate speech (racial)                                                  |     12 |       5 |
| \_Other Issue (racial)                                                |     12 |       2 |
| Abortion access                                                       |     11 |       3 |
| Free speech                                                           |     11 |       3 |
| Public funding for higher education                                   |     11 |       8 |
| LGB+/Sexual orientation (Against)                                     |     10 |       4 |
| White supremacy (For) (racial)                                        |     10 |       1 |
| Far Right/Alt Right (For)                                             |      9 |       4 |
| Police violence/anti-law enforcement/criminal justice                 |      9 |       6 |
| Racist/racialized symbols (racial)                                    |      8 |       2 |
| Trump and/or his administration (For)                                 |      7 |      NA |
| Anti-war/peace                                                        |      6 |       2 |
| Gun control                                                           |      6 |       1 |
| Indigenous issues (racial)                                            |      6 |       2 |
| Domestic foreign policy                                               |      5 |       2 |
| Hate crimes/Anti-minority violence (racial)                           |      5 |       2 |
| Pro-Palestine/BDS                                                     |      4 |       2 |
| Animal rights                                                         |      4 |      NA |
| Prison/mass incarceration (racial)                                    |      3 |       4 |
| Transgender issues (Against)                                          |      3 |       5 |
| Affirmative action (For) (racial)                                     |      3 |      NA |
| All Lives Matter (racial)                                             |      3 |      NA |
| Accessibility                                                         |      2 |       1 |
| Immigration (Against) (racial)                                        |      2 |       1 |
| Gun owner rights                                                      |      2 |      NA |
| Memorials & anniversaries (racial)                                    |      1 |       1 |
| Hate crimes/Anti-minority violence                                    |      1 |      NA |
| Human rights                                                          |      1 |      NA |
| Anti-colonial/political independence                                  |     NA |       1 |
| Political corruption/malfeasance                                      |     NA |       3 |
| Social services and welfare                                           |     NA |       1 |
| Traditional marriage/family                                           |     NA |       2 |

# Percentages of all protest with given preset

| issue                                                        |   pct |
|:-------------------------------------------------------------|------:|
| Percent of events with any value                             | 74.09 |
| University governance, admin, policies, programs, curriculum | 28.27 |
| \_Not relevant                                               | 17.27 |
| Labor and work                                               | 15.51 |
| Tuition, fees, financial aid                                 | 10.02 |
| Trump and/or his administration (Against)                    |  9.45 |
| NA                                                           |  8.76 |
| \_Other Issue                                                |  8.42 |
| Environmental                                                |  6.88 |
| Sexual assault/violence                                      |  5.33 |
| Economy/inequality                                           |  5.29 |
| Feminism/women’s issues                                      |  4.71 |
| Public funding for higher education                          |  4.25 |
| Faith-based discrimination                                   |  4.10 |
| LGB+/Sexual orientation (For)                                |  3.15 |
| Transgender issues (For)                                     |  2.18 |
| Far Right/Alt Right (Against)                                |  1.99 |
| Abortion access                                              |  1.71 |
| Hate speech                                                  |  1.71 |
| Gun control                                                  |  1.67 |
| Police violence/anti-law enforcement/criminal justice        |  1.67 |
| Abortion (Against)/Pro-life                                  |  1.56 |
| Free speech                                                  |  1.47 |
| Pro-Palestine/BDS                                            |  1.24 |
| Anti-war/peace                                               |  0.99 |
| Social services and welfare                                  |  0.94 |
| Trump and/or his administration (For)                        |  0.85 |
| LGB+/Sexual orientation (Against)                            |  0.84 |
| Human rights                                                 |  0.69 |
| Far Right/Alt Right (For)                                    |  0.62 |
| Domestic foreign policy                                      |  0.54 |
| Accessibility                                                |  0.39 |
| Hate crimes/Anti-minority violence                           |  0.39 |
| Animal rights                                                |  0.37 |
| Anti-colonial/political independence                         |  0.37 |
| Transgender issues (Against)                                 |  0.33 |
| Pro-Israel/Zionism                                           |  0.28 |
| Political corruption/malfeasance                             |  0.27 |
| Gun owner rights                                             |  0.22 |
| Pro-law enforcement                                          |  0.10 |
| Traditional marriage/family                                  |  0.10 |
| Men’s rights                                                 |  0.03 |
|                                                              |  0.02 |
| Transgender issues                                           |  0.02 |

| racial_issue                                                 |   pct |
|:-------------------------------------------------------------|------:|
| \_Not relevant                                               | 54.76 |
| Percent of events with any value                             | 45.35 |
| Anti-racism                                                  | 14.37 |
| Police violence                                              |  9.56 |
| University governance, admin, policies, programs, curriculum |  9.40 |
| Immigration (For)                                            |  7.77 |
| Campus climate                                               |  7.45 |
| Indigenous issues                                            |  2.78 |
| White supremacy (Against)                                    |  2.39 |
| \_Other Issue                                                |  2.06 |
| Racist/racialized symbols                                    |  1.61 |
| Hate speech                                                  |  1.54 |
| Hate crimes/Anti-minority violence                           |  1.19 |
| Prison/mass incarceration                                    |  0.80 |
| Memorials & anniversaries                                    |  0.64 |
| Affirmative action (For)                                     |  0.59 |
| White supremacy (For)                                        |  0.37 |
| Cultural appropriation                                       |  0.33 |
| Immigration (Against)                                        |  0.32 |
| All Lives Matter                                             |  0.10 |
| Pro-police                                                   |  0.08 |
| Racial/ethnic pride - white                                  |  0.08 |
| Reparations                                                  |  0.08 |
| Affirmative action (Against)                                 |  0.07 |
| K-12 education                                               |  0.02 |
| Racial/ethnic pride - minority                               |  0.02 |

# Counts over time

![](exploratory_plots_files/figure-gfm/basic_counts_over_time-1.png)<!-- -->![](exploratory_plots_files/figure-gfm/basic_counts_over_time-2.png)<!-- -->![](exploratory_plots_files/figure-gfm/basic_counts_over_time-3.png)<!-- -->

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
| Police violence                                              | 571 |
| University governance, admin, policies, programs, curriculum | 561 |
| Immigration (For)                                            | 464 |
| Campus climate                                               | 445 |
| Indigenous issues                                            | 166 |
| White supremacy (Against)                                    | 143 |
| \_Other Issue                                                | 123 |
| Racist/racialized symbols                                    |  96 |
| Hate speech                                                  |  92 |
| Hate crimes/Anti-minority violence                           |  71 |
| Prison/mass incarceration                                    |  48 |
| Memorials & anniversaries                                    |  38 |
| Affirmative action (For)                                     |  35 |
| White supremacy (For)                                        |  22 |
| Cultural appropriation                                       |  20 |
| Immigration (Against)                                        |  19 |
| All Lives Matter                                             |   6 |
| Pro-police                                                   |   5 |
| Racial/ethnic pride - white                                  |   5 |
| Reparations                                                  |   5 |
| Affirmative action (Against)                                 |   4 |
| K-12 education                                               |   1 |
| Racial/ethnic pride - minority                               |   1 |

![](exploratory_plots_files/figure-gfm/issues_over_time-1.png)<!-- -->![](exploratory_plots_files/figure-gfm/issues_over_time-2.png)<!-- -->![](exploratory_plots_files/figure-gfm/issues_over_time-3.png)<!-- -->

## Racial and “nonracial” issues over time (collapsed)

![](exploratory_plots_files/figure-gfm/unnamed-chunk-12-1.png)<!-- -->![](exploratory_plots_files/figure-gfm/unnamed-chunk-12-2.png)<!-- -->![](exploratory_plots_files/figure-gfm/unnamed-chunk-12-3.png)<!-- -->

I’ve collapsed both types of issues here to show racial and nonracial
issues alongside each other. Racial issue counts here are taken at a
maximum of one per canonical event, so that events that relate to many
issues do not outweight others and we have a clearer understanding of
the weight of protest occurrence. The same goes for nonracial issues.

We’re also interested in understanding if the biggest upticks in protest
counts are driven by an uptick in racial issues. This is

    ## `geom_smooth()` using method = 'loess' and formula = 'y ~ x'

![](exploratory_plots_files/figure-gfm/unnamed-chunk-13-1.png)<!-- -->![](exploratory_plots_files/figure-gfm/unnamed-chunk-13-2.png)<!-- -->

# Issue co-occurrence

![](exploratory_plots_files/figure-gfm/unnamed-chunk-14-1.png)<!-- -->![](exploratory_plots_files/figure-gfm/unnamed-chunk-14-2.png)<!-- -->

# Basic summary plots by variable

| name                 | type    |   mean |     sd |
|:---------------------|:--------|-------:|-------:|
| campaign             | boolean |  0.249 |     NA |
| counterprotest       | boolean |  0.048 |     NA |
| inaccurate_date      | boolean |  0.009 |     NA |
| multiple_cities      | boolean |  0.025 |     NA |
| off_campus           | boolean |  0.074 |     NA |
| on_campus_no_student | boolean |  0.072 |     NA |
| quotes               | boolean |  0.645 |     NA |
| ritual               | boolean |  0.030 |     NA |
| slogans              | boolean |  0.403 |     NA |
| adjudicator_id       | numeric | 53.332 |  2.562 |
| mhi                  | numeric | 64.408 | 16.752 |
| rent_burden          | numeric |  0.488 |  0.047 |
| republican_vote_prop | numeric |  0.339 |  0.145 |
| white_prop           | numeric |  0.694 |  0.166 |

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

![](exploratory_plots_files/figure-gfm/mpeds_map-1.png)<!-- -->

# Investigating specific movements

## 2015 Mizzou protests

| Statistics for Mizzou protests |   n |
|:-------------------------------|----:|
| Total number of links          |   0 |
| Unique events                  |   0 |

The discrepancy between the total number of links from the original
Mizzou event to the total number of unique events comes from some events
being both campaign events and counterprotest events, or campaign events
and solidarity events.

![](exploratory_plots_files/figure-gfm/mizzou_map-1.png)<!-- -->![](exploratory_plots_files/figure-gfm/mizzou_map-2.png)<!-- -->

### Mizzou issues

| value |   n |
|:------|----:|

### 2015 Antiracism protest profiles and comparison

![](exploratory_plots_files/figure-gfm/unnamed-chunk-15-1.png)<!-- -->

### Newspaper coverage for Mizzou umbrella

| canonical_key | Article Mentions | Newspaper Mentions |
|:--------------|-----------------:|-------------------:|

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
| 2016-11-09                      |           72 |
| 2015-11-12                      |           52 |
| 2016-11-16                      |           48 |
| 2018-03-14                      |           48 |
| 2014-12-01                      |           42 |
| 2014-11-25                      |           40 |

| Top dates for immigration-related protests |   n |
|:-------------------------------------------|----:|
| 2016-11-16                                 |  22 |
| 2017-05-01                                 |  17 |
| 2017-02-01                                 |  15 |
| 2017-02-09                                 |  14 |
| 2017-01-31                                 |  13 |
| 2017-01-29                                 |  12 |

| Top ten issues for November 9th, 2016                                 |   n |
|:----------------------------------------------------------------------|----:|
| Trump and/or his administration (Against)                             |  60 |
| Anti-racism (racial)                                                  |   9 |
| Immigration (For) (racial)                                            |   8 |
| University governance, admin, policies, programs, curriculum (racial) |   7 |
| Trump and/or his administration (For)                                 |   4 |
| White supremacy (Against) (racial)                                    |   3 |
| Sexual assault/violence                                               |   2 |
| Campus climate (racial)                                               |   1 |
| Faith-based discrimination                                            |   1 |
| Far Right/Alt Right (Against)                                         |   1 |

| Top ten issues for November 16th, 2016                                |   n |
|:----------------------------------------------------------------------|----:|
| Trump and/or his administration (Against)                             |  30 |
| Immigration (For) (racial)                                            |  22 |
| University governance, admin, policies, programs, curriculum (racial) |  18 |
| University governance, admin, policies, programs, curriculum          |   8 |
| Anti-racism (racial)                                                  |   6 |
| Campus climate (racial)                                               |   5 |
| Faith-based discrimination                                            |   3 |
| Hate crimes/Anti-minority violence (racial)                           |   3 |
| LGB+/Sexual orientation (For)                                         |   3 |
| \_Other Issue (racial)                                                |   3 |

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
