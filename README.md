# Adiutor

Web app assisting work on the [In adiutorium][ia] project.
Basically a database of chant pieces from the aforementioned project
(and other chant corpora imported for comparative purposes).
Internal tool, not intended for public deployment.

Secondary purpose is trying out recent Rails.

# Setting up

## Prerequisites

TBD

## Setup steps

1. optionally start dockerized dependencies by running `docker-compose up` in the `/docker` directory
2. populate `.env` with required values (follow comments in `.env.template`)
3. `rails s` start the app and make sure that it works (although it doesn't contain any data yet)
4. `rake import` to import the main corpus of chants in the database
5. optionally import more chant corpora for comparison
    - `rake antiphonarius:import` to import chants from the 1960 Liber antiphonarius
    - `rake antiphonale83:import` to import chants from the 1983 Ordo cantus officii
6. `rake images` to render each chant in notation (takes a lot of time to finish,
   requires LilyPond and Inkscape, for the gabc-based chant corpora also LuaLaTex and Gregorio)

[ia]: https://github.com/igneus/In-adiutorium
