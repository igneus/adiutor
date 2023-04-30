#!/bin/bash -e

# Convenience shortcut to retrieve filtered chants from the Rails app
# using the command line.
#
# Wraps httpie (https://httpie.io/), whose way of specifying GET arguments must be observed, e.g.
#
# $ chants.sh lyrics==andělé
# $ chants.sh lyrics==Maria page==2

APP_HOST=http://localhost:3000

http $APP_HOST/chants.json "$@"
