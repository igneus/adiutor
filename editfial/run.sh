#!/bin/bash

this_dir=$( dirname -- "$0"; )

# load .env, make selected variables available to the PHP script as environment variables
. $this_dir/../.env
export IN_ADIUTORIUM_SOURCES_PATH EDIT_FIAL_SECRET

# Start PHP built-in webserver serving editfial.php at localhost:3005/editfial.php
cd $this_dir && php --server localhost:3005
