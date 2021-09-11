#!/bin/bash

# A script to set an environment variable
# containing the latest stable LBRY version
# (or a skip marker if it's built already)

# Get the latest (stable) LBRY version
LBRY_VERSION=`curl --silent "https://api.github.com/repos/lbryio/lbry-android/releases/latest" \
             | jq .tag_name | grep -Eo "[0-9]+.[0-9]+.[0-9+]"`

# Get the latest version of the fork
LBRY_FORK_VERSION=`curl --silent "https://api.github.com/repos/paveloom-f/lbry-android/releases/latest" \
                  | jq .tag_name | grep -Eo "[0-9]+.[0-9]+.[0-9+]"`

# Compare the versions
if [ "${LBRY_VERSION}" = "" ]; then
    LBRY_VERSION="SKIP"
    echo -e "\nA problem occurred when trying to get the last stable version. Skipping.\n"
elif [ "${LBRY_VERSION}" = "${LBRY_FORK_VERSION}" ]; then
    LBRY_VERSION="SKIP"
    echo -e "\nThe latest version of LBRY Android is built already. Skipping.\n"
else
    echo -e "\nA new version of LBRY Android will be built: v$LBRY_VERSION.\n"
fi

# Save the version / skip mark as an environment variable
echo "LBRY_VERSION=${LBRY_VERSION}" >> ${GITHUB_ENV}
