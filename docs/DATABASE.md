# The MPEDS database system

This document is an introduction to the MPEDS database. It's not a
comprehensive document, and doesn't aim to desecribe every variable. But
we do have some goals:

- Explain important and potentially confusing variables
- Explain how tables are related to each other
- Give practical tips on interacting with the database

## Contents

- [Preqrequisites and setup](#prerequisites-and-setup)
- [coder_event_creator](#coder-event-creator)
- [canonical_event_link](#canonical-event-link)
- [canonical_event](#canonical-event)
- [Other tables](#other-tables)
- [Other guidelines and considerations](#other-guidelines-and-considerations)

## Prerequisites and setup

Before any of this, it's good to:

- know how to SSH into a server
- know basic SQL syntax, and how to perform joins
- have access to and have looked over the Higher Education Protest
  Project Codebook. It is especially helpful to understand "candidate
  event," "canonical event," and the two-pass adjudication/event coding
  process
- have a MySQL or MariaDB client installed on your machine

Most importantly, you must be able to access to `sheriff` server. If you
do not have credentials or access to the server, please contact Dr. Alex
Hanna <alex[dot]hanna[at]gmail.com>.

How you choose to interact with the database is up to you; you can SSH
into the server and interact in that environment, or (as I do) you may
set up an SSH tunnel that forwards and receives all interactions on the
`sheriff` server's MySQL port to your local machine. This is also the
approach taken by the R code in this repository. You can do this with
the following command:

```sh
ssh -L 3306:localhost:3306 <YOUR_USERNAME>@sheriff.ssc.wisc.edu -fN
```

Lastly, I recommend installing a graphical SQL explorer. I use
[DBeaver Community](https://dbeaver.io).

## `coder_event_creator`

This is the largest table in the database. It contains pre-adjudication
events, in other words the "first pass" that coders take to extract
information from articles and assign them to "candidate events."

Each row in `coder_event_creator` represents a single variable of a
single candidate event; in R tidyverse lingo, the dataset is long on
variable. This means that many rows make up a single candidate event.
Also, the exact set of variables present for a candidate event varies,
so one candidate event may correspond to seven rows in
`coder_event_creator` while other events may corespond to eight or any
other number.

Pay close attention to the `variable` and `value` columns. `value`
generally holds the value of interest, except for variables ending in
`-text`, for which `value` holds metadata about a snippet from an
article and the `text` column contains the actual corresponding value
(the actual snippet, or article extract).

Rows can be assigned to candidate events via `event_id`. Articles can be
assigned to these rows via `article_id`.

## `canonical_event_link`

Is a very important table to understand, and shouldn't be confused with
`canonical_event_relationship`. It contains five fields:

- `id` identifying the link. Can mostly be ignored
- `coder_id` identifies the human coders that created the link through
  the adjudication interface. Corresponds to the `id` column of the
  `user` table.
- `canonical_id` identifies the associated canonical event. Corresponds
  to the `id` column of the `canonical_event` table
- `cec_id` identifies a single row in `coder_event_creator`, in other
  words a single value for a single variable. Coresponds to `id` column
  of `coder_event_creator`
- `timestamp` of when the link was established.

The two most useful columns here for joins are `canonical_id` and
`cec_id`, which are useful for joins.

## `canonical_event`

This contains metadata for canonical events:

- `id`: a unique integer ID identifying a single canonical event
- `coder_id`: the integer ID of the person coding this event.
  Corresponds to the `id` column of the `users` table.
- `key`: a string representing the event. This is useful for grouping
  events under an umbrella together, through a join with the
  `canonical_event_relationship` table
- `description`, `notes` -- text columns for annotations about events
- `last_updated`: Date column marking the time of update

You'll notice that this dataset doesn't actually contain much
information about the canonical events. Information about each canonical
event comes straight from rows in `coder_event_creator`, mediated by a
join with `canonical_event_link`. The next section discusses this
process.

### How to obtain the dataset of canonical events

1. Begin with `canonical_event`. Left-join `canonical_event_link` by
   matching the `id` column of `canonical_event` with the `canonical_id`
   column of `canonical_event_link`
2. Left-join `coder_event_creator` table by matching the `id` column of
   `coder_event_creator` with the `cec_id` column of the table joined
   from step 1.

In SQL (you should select specific columns to avoid name collisions in
`SELECT`):

```sql
SELECT *
FROM (
  SELECT *
  FROM `canonical_event` AS `LHS`
  LEFT JOIN `canonical_event_link` AS `RHS`
    ON (`LHS`.`id` = `RHS`.`canonical_id`)
) `LHS`
LEFT JOIN `coder_event_creator` AS `RHS`
  ON (`LHS`.`cec_id` = `RHS`.`id`)
```

In R:

```r
ces <- tbl(con, "canonical_event") |>
  left_join(tbl(con, "canonical_event_link"), by = c("id" = "canonical_id")) |> 
  left_join(tbl(con, "coder_event_creator"), by = c("cec_id" = "id"))
```

Things to watch out for here:

- If joining to create a dataset of canonical events, many variables in
  `coder-event-creator` will be dropped. That is okay.
- When doing joins, you may end up columns with duplicate names,
  especially on the `id`, `timestamp`, and `coder_id` columns, which are
  present in several tables. The latter two are mostly harmless, but be
  careful to judiciously name or remove the `id` column to avoid name
  collisions and ensure you have a meaningful ID. You wouldn't want to
  join the canonical event ID with the `coder_event_creator` ID, and
  doing so inadvertently can be harmful.
- Many-to-many joins, which can be created by mistake, can result in an
  exponential increase in the number of rows returned in a query, and
  can sometimes freeze the SQL server from giving you any further
  results. Please take care when writing your joins.

## `article_metadata`

Each row here represents a single article. This table contains the
following variables:

- `id` identifies unique articles. Each row has a unique ID
- `db_name`
- `db_id`
- `filename`
- `pub_date`
- `publication`
- `source_description`
- `text`

Of special note here is the `publication` variable, which are usually
formatted in parseable strings following the format
`PUBLICATION NAME: SCHOOL NAME`. Beware that:

- some values do not match this format
- many universities report on events from another university
- some schools have many newspapers

Rows from this table have a one-to-many correspondence with the rows of
the `coder_event_creator` table, which are single variables observed for
an event. Many variables and even several different events can be drawn
from a single article.

Rows from this table have a many-to-many correspondence with canonical
events. Canonical events can be made up of many candidate events, and
though each candidate event usually comes from a single article, it is
impossible to completely and unambiguously assign a single article to a
canonical event.

You can join `article_metadata` with `coder_event_creator` by matching
the `id` column of `article_metadata` with `article_id` from
`coder_event_creator`.

## Other tables

The other tables in the database are important for its functionality,
but are less important for analysis. They manage interactions with the
UI and ensure that coder input makes its way to the end tables.

## Other guidelines and considerations

- Please try to use the `campus_protest_staging` database, to avoid any
  potential overwrites of the main database.
- If you are working on or reading the analysis code, please note that
  all of it is in R, and in that spirit we (implicitly) use `dbplyr` to
  essentially write SQL queries in tidyverse syntax.
- If you are abroad, your SSH queries or entry may not work. You must
  use a VPN in this case from a country that has access to the server
