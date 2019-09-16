#!/bin/bash

set -e
set -x

function die {
  echo $1
  exit 1
}

[[ "${GITHUB_EVENT_NAME}" != "pull_request_review" ]] && \
  die "unsupported event: ${GITHUB_EVENT_NAME}"

[[ ! -f "${PWD}/.rultor.yml" ]] && die ".rultor.yml config was not found"

reviewer=$(jq -r .review.user.login ${GITHUB_EVENT_PATH})
[[ -z $(yq -r .architect[] .rultor.yml | grep "^${reviewer}$") ]] && \
  die "user ${reviewer} is not allowed to merge with rultor"

yq -r .install .rultor.yml | bash -e || \
  die "failed to install dependencies from .rultor.yml"

cmd=$(jq -r .review.body ${GITHUB_EVENT_PATH})
echo "reviewer is ${user}, command is ${cmd}"

if [[ "${cmd}" == "merge" ]]; then
  head=$(jq -r .pull_request.head.ref ${GITHUB_EVENT_PATH})
  git config user.email me@rultor.com
  git config user.name rultor
  git remote set-url --push origin \
    https://${GITHUB_ACTOR}:${INPUT_TOKEN}@github.com/${GITHUB_REPOSITORY}.git
  git checkout -B __rultor origin/${head}
  git checkout -B master origin/master
  git merge --no-ff __rultor
  yq -r .merge.script | bash -e || \
    (echo "merge failed" && exit 1)
  git push origin master
  echo "done: ${head} has been merged to master successfully"
else
  die "unsupported command ${cmd}"
fi
