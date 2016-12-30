#!/bin/bash
WOWACE_PROJECT="$1"
ENCRYPT_KEY="$2"
ENCRYPT_IV="$3"
DEPLOY_DIR="$TRAVIS_BUILD_DIR/deploy"

# Setup SSH
mkdir -p "$HOME/.ssh"
cp "$DEPLOY_DIR/wowace.hostkeys" "$HOME/.ssh/known_hosts"
openssl aes-256-cbc -K "$ENCRYPT_KEY" -iv "$ENCRYPT_IV" -in "$DEPLOY_DIR/wowace.key.enc" -out "$HOME/.ssh/id_rsa" -d
chmod -R og= "$HOME/.ssh"

# Do push
git push "https://repos.wowace.com/wow/${WOWACE_PROJECT}" "${TRAVIS_TAG:-$TRAVIS_BRANCH}"
