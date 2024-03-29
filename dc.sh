#!/bin/bash -e

# Wrapper for more convenient invocation of docker-compose

cd docker && docker-compose --env-file=../.env "$@"
