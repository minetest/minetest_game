#!/bin/bash

# Colors with 0 alpha need to be preserved, because opaque leaves ignore alpha.
# For that purpose, the use of indexed colors is disabled (-nc).

find -name '../*.png' -print0 | xargs -0 optipng -o7 -zm1-9 -nc -strip all -clobber
