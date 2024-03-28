#!/bin/bash -e

echo '== Creating .env'
if [[ -e .env ]]; then
    echo '.env already exists, skipping'
else
    cp .env.template .env
    echo '.env created'
fi

echo '== Building Docker images'
./dc.sh pull
./dc.sh build

echo '== Installing dependencies'
make install-pkgs

echo '== Setting up databases'
./dc.sh up -d
sleep 15
./dc.sh run ruby bash -c 'rake db:create && rake db:migrate && rake init_data'
./dc.sh down

echo 'Setup complete.'
echo 'Now you should be able to `$ ./dc.sh up` and'
echo ' - browse the application at http://localhost:3000'
echo ' - run tests with `make test` (and they should be all green)'
echo ''
echo "Please review .env for available options. Make sure to configure and import at least one chant corpus, otherwise there isn't much fun with Adiutor."
