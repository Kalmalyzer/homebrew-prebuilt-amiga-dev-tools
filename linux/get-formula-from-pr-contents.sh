#!/bin/bash

if [ $# -ne 2 ]; then
 echo 1>&2 "Usage: $0 <github organization/github repository> <PR number>"
 exit 1
fi

GITHUB_REPOSITORY=$1
GITHUB_PR_NUMBER=$2

URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/pulls/${GITHUB_PR_NUMBER}/files"
CHANGED_FILES=$(curl -s -X GET -G $URL | jq -r '.[].filename') # | jq -r '.[] | .filename')
CHANGED_FORMULAS=$(echo "${CHANGED_FILES}" | grep "^Formula/.*\.rb" | sed -E "s|^Formula/(.*)\.rb|\1|g")
NUM_CHANGED_FORMULAS=$(echo "${CHANGED_FORMULAS}" | wc -l)

if [[ "${CHANGED_FORMULAS}" == "" ]]; then
    echo "No changed formulas in pull request." >&2
    exit 1
elif [[ ${NUM_CHANGED_FORMULAS} -eq 1 ]]; then
    echo "${CHANGED_FORMULAS}"
else
    echo "More than one changed formula in pull request." >&2
    exit 1
fi
