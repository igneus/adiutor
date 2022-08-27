#!/bin/bash

this_dir=$( dirname -- "$0"; )

# load .env, make one important variable available to the PHP script as environment variable
. $this_dir/../.env
export IN_ADIUTORIUM_SOURCES_PATH=$IN_ADIUTORIUM_SOURCES_PATH;

# Start PHP built-in webserver serving editfial.php at localhost:3005/
php --server localhost:3005 "$this_dir/editfial.php"
