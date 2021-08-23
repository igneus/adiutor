# Adiutor

Web app assisting work on the [In adiutorium][ia] project.
Basically a database of chant pieces.
Internal tool, not intended for public deployment.

Secondary purpose is trying out recent Rails.

# Setting up

1. optionally start dockerized dependencies by running `docker-compose up` in the `/docker` directory
2. populate `.env` with required values
3. `rails s` start the app and make sure that it works (although it doesn't contain any data yet)
4. `rake import` to import the corpus of chants in the database
5. `rake images` to render each chant in notation

[ia]: https://github.com/igneus/In-adiutorium
