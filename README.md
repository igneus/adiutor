# Adiutor

Private chant database assisting work on the [In adiutorium][ia] project.
Internal tool, not intended for public deployment.

# What it's used for

The application's main purpose is to transform a heap of sheet music into
a database of pieces which can be conveniently searched and filtered
by lyrics, tune and metadata.
Many features are specific to the corpus being worked on
(keeping track of relations between pieces,
of settings for a few special psalms and canticles required to match the respective antiphons,
of non-standard tunes worth occasional re-evaluation;
continual focus on pieces marked as needing a revision).

The application is only used as visualization and accessibility tool,
not to edit the data. The music corpus is maintained as a source code
repository edited using standard music editing applications
and the source code is regularly re-imported in the web app.
(Hence the feature of opening a selected piece in an external text editor.)

Various publicly available corpora of Gregorian chant pieces
are imported as additional reference material and for research purposes
not directly related to the work on the vernacular chant corpus.

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
  - LuaLaTeX and gregorio (only if you are going to import and render also gabc-based chant corpora)
  - [Verovio][verovio] (only if you are going to import and render also MEI-based chant corpora)
  - PHP (only if you are going to use the "open in editor" functionality)

## Setup steps

### Configure and start the dockerized web app

1. `./bin/init.sh`
1. spin the application up by `./dc.sh up` (Ctrl+C to stop, `./dc.sh down` to remove the containers)
1. check that the application works:
    - `http://localhost:3000/` serves Adiutor homepage
    - `make test` succeeds (or at least `make test-rails test-python` succeeds)
1. optionally create some user account: `rake user:add[your@email.org]`
   (only needed if you plan to use the data-modifying functionalities like reviewing
   parent-child mismatches and marking them resolved)

### Import data

Data import is not dockerized, so these steps install dependencies
and execute parts of the Rails application outside of Docker.
(The dockerized database is still being used.)

1. in section 3 of `.env` configure local paths to the data of corpora you plan to import
1. `cd rails_app`
1. `bundle install`
1. check that the application works outside of Docker: `bundle exec rake spec`
1. `bundle exec rake refresh` to import (or re-import) the In adiutorium corpus
1. optionally import more chant corpora for comparative purposes
   (respective optional settings in `.env` must be set)
    - gabc-based corpora
      - `bundle exec rake gregobase:load_dump gregobase:import` to import relevant chants from a GregoBase DB dump
        https://github.com/gregorio-project/GregoBase
      - `bundle exec rake nocturnale:import` to import chants from the Nocturnale Romanum project
        https://github.com/Nocturnale-Romanum/nocturnale-romanum
      - `bundle exec rake antiphonarius:import` to import chants from the 1960 Liber antiphonarius
        https://github.com/ahinkley/liber-antiphonarius-1960
        (note: if you import GregoBase, complete contents of this dataset are included,
        so there's no need to import both)
      - `bundle exec rake antiphonale83:import` to import chants from the 1983 Ordo cantus officii
        https://github.com/igneus/antiphonale83
    - MEI-based corpora
      - `bundle exec rake hughes:import` to import chants from the Andrew Hughes chant corpus
        https://github.com/DDMAL/Andrew-Hughes-Chant
      - `bundle exec rake neuma:fetch neuma:import` to import chants from the Sequentia collection
        http://neuma.huma-num.fr/home/corpus/sequentia/
      - `bundle exec rake echoes:import` to import chants from the Echoes from the Past corpus
        https://github.com/ECHOES-from-the-Past/GABCtoMEI
1. `bundle exec rake images` to render each chant in notation (takes a lot of time to finish,
   requires LilyPond and Inkscape, for the gabc-based chant corpora also LuaLaTex and Gregorio)
1. `cd ..` (return to the project root directory)
1. `make volpiano` to generate normalized representations of melodies (required for music search and other features)

[ia]: https://github.com/igneus/In-adiutorium
[verovio]: https://www.verovio.org
