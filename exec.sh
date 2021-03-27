#!/bin/bash
set -o pipefail
set -eux

: "$GITHUB_REF"
: "$CACHE_DIRECTORY"
: "$DOCKER_REPOSITORY"

build_only () {
  docker buildx build . \
    "$@" \
    "--output=type=image,push=false" \
    "--cache-from=type=local,src=$CACHE_DIRECTORY" \
    "--cache-to=type=local,mode=max,dest=$CACHE_DIRECTORY"
}

build_push () {
  docker buildx build . \
    "$@" \
    --push \
    "--tag=$DOCKER_REPOSITORY:$docker_tag" \
    "--cache-from=type=local,src=$CACHE_DIRECTORY" \
    "--cache-to=type=local,mode=max,dest=$CACHE_DIRECTORY.$$"
  # refresh the cache to prevent growth
  rm -fr "$CACHE_DIRECTORY"
  mv "$CACHE_DIRECTORY.$$" "$CACHE_DIRECTORY"
}

# push latest tag when a branch is pushed
if [[ $GITHUB_REF == refs/heads/* ]]; then
  docker_tag=latest
  build_push "$@"
  exit 0
fi

# push the corresponding tag when a tag is pushed
if [[ $GITHUB_REF == refs/tags/* ]]; then
  docker_tag="${GITHUB_REF##*/}"
  build_push "$@"
  exit 0
fi

# build only when a pull request is created or updated
build_only "$@"
exit 0
