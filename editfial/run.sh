#!/bin/bash

# Start PHP built-in webserver serving editfial.php at localhost:3005/

php --server localhost:3005 "$( dirname -- "$0"; )/editfial.php"
