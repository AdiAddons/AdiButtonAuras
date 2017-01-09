#!/bin/bash
WOWACE_PROJECT="$1"

# Do push
# DO NOT REMOVE the quiet flag and the output redirection
git push -q "https://${WOWACE_USER}:${WOWACE_PASS}@repos.wowace.com/wow/${WOWACE_PROJECT}" "${TRAVIS_TAG:-$TRAVIS_BRANCH}" > /dev/null 2>&1
