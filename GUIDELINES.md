# Guidelines and code conventions for the protest-analyses project

- Principles
- Using `targets`
- Using `renv`
- Filename conventions

### Principles for coding

This section is continually developed.

1. We aren't here to simply publish papers or to play with cool tech
   tools, but to recognize and uplift the work of campus and student
   organizers across the nation through our research. Our research is
   one component of the larger, interconnected struggle for social
   transformation of all kinds.
2. We support one another as developers, researchers, and humans. We
   treat each other with respect, kindness, and love. We do not tolerate
   any form of racism, sexism, homophobia, transphobia, bigotry, or
   classist behavior within this project or among our collaborators.
3. We strive to understand the harms involved in our work, in all of the
   subject matter and livelihoods risked in the articles we analyze; in
   the necessity of diligent, honest, correct, and uplifting research;
   in the risks posed to organizers by interpreting and publicizing
   their work.

Inspired by similar agreements and statements made at the Anti-Eviction
Mapping Project.

There are a few additional principles that should be said with regards
to code. These goals work in tandem with each other; accomplishing one
helps with another, and failing at one likely means we fail with
another.

1. Correct. Correctness is _hard_, and sometimes impossible. It's not
   something we can check off on a box; it requires constant care,
   reflection, revision.
2. Reproducible. To promote collaboration, accessibility, extension,
   correctness, and maintainability.
3. Simple. For all the same reasons as reprodiciblity. It's also helpful
   to think of simplicity as finding workflows that divert brainpower to
   where it is most needed; we don't want to add needless complexity in
   things like locating files or working through convoluted code.

A good starting point for our technical guidelines lies in Patrick
Ball's
[Principled Data Processing](https://www.youtube.com/watch?v=ZSunU9GQdcI).
You may also be interested in
[other resources](https://gist.github.com/alexhanna/d6897e2e4c011b4519231c672https://www.youtube.com/watch?v=ZSunU9GQdcI)
shared by Dr. Hanna. Of course, we diverge a bit from these practicians
and clarify

### `targets`

[`targets`](https://books.ropensci.org/targets/) is a relatively new (as
of 2022) package helping to ensure simple, reproducible, and
understandable data processing workflows in R. It does this by:

- Requiring high-level instructions be placed in a single file, in a
  relatively simple (but extensible) syntax
- Storing (without developer intervention) all data and intermediary
  components in the `_targets/` folder. This helps developers reduce
  clutter, and most importantly allows `targets` to track when changes
  have been made, and thus selectively run data processing steps
- Forcing all targets-related code to be written into functions.
  Functions, as named blocks of code easily annotated by `roxygen2`,
  lend themselves easily to self-documentation.
- Constructing a new R environment when the pipeline is run. Unlike
  naive usage of the console in R, this ensures no leftover R objects or
  extraneous packages are loaded, potentially in conflict with our code.

Read
[the walkthrough](https://books.ropensci.org/targets/walkthrough.html)
in Chapter 2 of the `targets` user manual for a how-to.

### `renv`

`targets` is great, but even a rock-solid pipeline can be inconsistent
across different R environments. `renv` helps ensure that any machine,
across any (theoretical) point in time, uses the same packages in this
environment.

If you'd like to use a new package, make sure to:

- call `install.packages()` from **within the `protests-analysis` R
  project** so that `renv` can install it correctly.
- Use it in the project by inserting it into `tar_option_set` in
  `_targets.R`.
- Run `renv::snapshot()` to ensure it is written to `renv.lock`. This
  way collaborators can access the same file.

Read more on the [overview page](https://rstudio.github.io/renv/) for
the package.

### The tidyverse and R packages at large

The R community is large and beautiful because of the proliferation of
many, many useful packages. R is strong because of its contributors, and
we should stand on the shoulders of giants when writing our code. It
goes the other way, too; not standing on the shoulders of said giants
means worrying about technical details instead of focusing on our chosen
area of expertise (analyses of campus- and protest-related data).

That being said, packages can introduce unnecessary complexity into a
project. New packages mean new interfaces for potentially more mistakes,
and can even be sources of mistakes themselves in ways that are not
transparent to us. And even with `renv`, packages can be a source of
inconsistencies even when our codebase has no changes, for example
because a package or its dependency is removed from CRAN (or GitHub,
which is much more transient! stick to CRAN-published packages).

Package usage, in a word: cautiously. Stick to CRAN-published packages
that have solid documentation and a history of maintenance and use.

### File and filename conventions

Here is an avenue where the exact principles we stick to can be
important, but even more important is just the fact that we have
principles. Sticking to something ensures structure and uniformity,
which helps ensure complexity. All the usual caveats and exceptions
apply.

- All code goes in the `tasks/` folder, labeled by dataset. `tasks/all`
  is the folder for the combined analysis.
- Each dataset folder contains three folders: `import`, `clean`, and
  `merge`, for those respective within-dataset tasks.
- Within each folder, try to keep one script to a single function, and
  name the script that function.
- Tasks should be code-independent, so try not to `source` a file in a
  different folder. If utility code or an exception is needed, use
  symlinks to put it in multiple locations. This ensures synchronization
  while letting us maintain folders as conceptually whole pieces of
  code.
- Try not to save data in separate files; use `targets` and the
  `_targets/` folder.
- Prefer underscores `_` when naming a script over dashes `-`, which
  should be preferred for folder names over spaces. Spaces should never,
  ever be used. :D
- Filenames should be lowercase, except for markdown documents like this
  one. Please try not to add any additional non-script documents.

### Within scripts

Ball et. al don't mention much about within-script practices of code
organization. Here are some rules that help follow the principles of
pipeline-oriented reproducible work:

- Use the pipe operator `|>`, which chains the outputs of one function
  into the second. It helps us write code that we can read from left to
  right, cuts down on repeating names, and prevents naming conflicts.
- If it adds insight to code behavior, use `roxygen2` commment syntax to
  annotate function inputs and returns. Do not discuss implementation
  details in `roxygen2` comments, leave those for function innards. See
  more in
  [Best Practices for Scientific Computing](https://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.1001745#s8).
-

As well as a few for formatting:

- Keep lines more or less than 100 characters, or about 3/4th of a
  laptop's screen space. Putting in line breaks ourselves is better than
  having the edge of the screen make that decision for us, often in an
  unreadable way.
- Always maintain one level of indentation per curly bracket ("block")
  level of code. E.g. code in an `if` statement in a function requires
  two indents.
- Use spaces between blocks of code to denote logical separation between
  different actions.

### Misc.

- Documentation
  - Patrick Ball and the Human Rights Data Analytics Group assert that
    documentation for the most part isn't necessary, and instead
    _self_-documenting code should have emphasis instead. I find this
    view correct but need to add a few qualifiers. Documentation through
    code is good, but how would we document principles, conventions for
    filenames, or in general anything qualitative?
  - This codebase is curated with the intent of sharing. Social science
    researchers have a wide array of skillsets and practices. It makes
    sense to provide human-readable documentation and guides in prose,
    since not everyone is familiar with our tools. If the underlying
    code changes, it is a possible inconvenience, but that is something
    we should take in stride and adjust as we go along.
- Take care of how you name things!
  - Unlike most other languages, R doesn't really have a concept of
    immutable code, meaning `import` in line 19 and a different `import`
    in line 31 will clash without R shouting it in your face; only one
    of these can exist in R (in the default global environment) at a
    time
  - R, also unlike other languages, has no concept of files as modules
    or of immutable code, meaning that a function nonspecifically called
    `import` in one file can conflict silently with a function of the
    same name in another file. That's not good! There are some solutions
    out there in R packages, but nothing perfect or simple enough for
    our use.
