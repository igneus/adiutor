# Adiutor

Private chant database assisting work on the [In adiutorium][ia] project.
Internal tool, not intended for public deployment.

# Setting up

## Prerequisites

- Docker
- docker-compose
- for the parts not dockerized:
  - Bash
  - GNU Make (other Make implementations may work, too)
  - Ruby 3.x
  - LilyPond >= 2.18
  - Inkscape
  - LuaLaTeX and gregorio (only if you are going to import and render also Gregorio-based chant corpora)
  - PHP (only if you are going to use the "open in editor" functionality)

## Setup steps

### Configure and start the dockerized web app

1. copy `.env.template` to `.env`, populate with required values (follow comments)
1. `./dc.sh up`
1. TODO: create databases, install Ruby and Python packages
1. check that the application works:
  - `http://localhost:3000/` serves Adiutor homepage
  - `make test` succeeds (or at least `make test-rails test-python` succeeds)

### Import data

Data import is not dockerized, so these steps install dependencies
and execute code of the Rails application outside of Docker.
(The dockerized database is still being used.)

1. `cd rails_app`
1. `bundle install`
1. check that the application works outside of Docker: `bundle exec rake spec`
1. `bundle exec rake import` to import the main corpus of chants
1. optionally import more chant corpora for comparative purposes
   (respective optional settings in `.env` must be set)
    - `bundle exec rake antiphonarius:import` to import chants from the 1960 Liber antiphonarius
    - `bundle exec rake antiphonale83:import` to import chants from the 1983 Ordo cantus officii
1. `bundle exec rake images` to render each chant in notation (takes a lot of time to finish,
   requires LilyPond and Inkscape, for the gabc-based chant corpora also LuaLaTex and Gregorio)

### Generate computed content

1. TODO: generate relations between imported chants
1. TODO: generate Volpiano

[ia]: https://github.com/igneus/In-adiutorium
