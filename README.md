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
  - [Verovio][verovio] (only if you are going to import and render also MEI-based chant corpora)
  - PHP (only if you are going to use the "open in editor" functionality)

## Setup steps

### Configure and start the dockerized web app

1. copy `.env.template` to `.env`, populate with required values (follow comments)
1. `./dc.sh up`
1. TODO: create databases
1. `make install-pkgs`
1. check that the application works:
  - `http://localhost:3000/` serves Adiutor homepage
  - `make test` succeeds (or at least `make test-rails test-python` succeeds)
1. optionally create some user account: `rake user:add[your@email.org]`
   (only needed if you plan to use the data-modifying functionalities like reviewing
   parent-child mismatches and marking them resolved)

### Import data

Data import is not dockerized, so these steps install dependencies
and execute code of the Rails application outside of Docker.
(The dockerized database is still being used.)

1. in section 3 of `.env` configure local paths to the data of corpora you plan to import
1. `cd rails_app`
1. `bundle install`
1. check that the application works outside of Docker: `bundle exec rake spec`
1. `bundle exec rake refresh` to import the main corpus of chants
1. optionally import more chant corpora for comparative purposes
   (respective optional settings in `.env` must be set)
    - `bundle exec rake antiphonarius:import` to import chants from the 1960 Liber antiphonarius
      https://github.com/ahinkley/liber-antiphonarius-1960
    - `bundle exec rake antiphonale83:import` to import chants from the 1983 Ordo cantus officii
      https://github.com/igneus/antiphonale83
    - `bundle exec rake nocturnale:import` to import chants from the Nocturnale Romanum project
      https://github.com/Nocturnale-Romanum/nocturnale-romanum
    - `bundle exec rake hughes:import` to import chants from the Andrew Hughes chant corpus
      https://github.com/DDMAL/Andrew-Hughes-Chant
    - `bundle exec rake gregobase:load_dump gregobase:import` to import relevant chants from a GregoBase DB dump
      https://github.com/gregorio-project/GregoBase
1. `bundle exec rake images` to render each chant in notation (takes a lot of time to finish,
   requires LilyPond and Inkscape, for the gabc-based chant corpora also LuaLaTex and Gregorio)
1. `cd ..` (return to the project root directory)
1. `make volpiano` to generate normalized representations of the melodies (required for music search and other features)

[ia]: https://github.com/igneus/In-adiutorium
[verovio]: https://www.verovio.org
