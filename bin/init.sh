#!/bin/bash -e

echo '== Creating .env'
if [[ -e .env ]]; then
    echo '.env already exists, skipping'
else
    cp .env.template .env

    # provide a reasonable initial value for IN_ADIUTORIUM_SOURCES_PATH
    ruby -i -p -e '$_.sub! /(?<=IN_ADIUTORIUM_SOURCES_PATH=)/, File.expand_path("../adiutor-import-sources/In-adiutorium")' .env

    echo '.env created'
fi

echo
echo '== Looking for In adiutorium sources'
# valid IN_ADIUTORIUM_SOURCES_PATH setting in .env is required,
# as it's used in docker-compose.yml to set up a Docker volume
. .env
if [[ ! -e $IN_ADIUTORIUM_SOURCES_PATH ]]; then
    echo ".env specifies '$IN_ADIUTORIUM_SOURCES_PATH' as path of In adiutorium sources but the directory was not found. Going to clone In-adiutorium to $IN_ADIUTORIUM_SOURCES_PATH ."
    echo 'Press Enter to continue. (Or press Ctrl+C, edit .env and then run this script again.)'
    read

    git clone https://github.com/igneus/In-adiutorium $IN_ADIUTORIUM_SOURCES_PATH
fi

echo
echo '== Building Docker images'
./dc.sh pull
./dc.sh build

echo
echo '== Installing dependencies'
make deps

echo
echo '== Setting up databases'
./dc.sh up -d
sleep 15
./dc.sh run ruby bash -c 'rake db:create && rake db:migrate && rake db:seed'
./dc.sh down

echo
echo 'Setup complete.'
echo 'Now you should be able to `$ ./dc.sh up` and'
echo ' - browse the application at http://localhost:3000'
echo ' - run tests with `make test` (and they should be all green)'
echo
echo "Please review .env for available options. Make sure to configure and import at least one chant corpus, otherwise there isn't much fun with Adiutor."
