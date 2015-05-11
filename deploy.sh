#!/usr/bin/env bash

REMOTE_LOCATION="@github.com/rokob/rokob.github.com.git"
SITE="_site"
DEPLOY="_deploy/"

info() {
  printf "  \033[00;32m+\033[0m $1\n"
}

success() {
  printf "  \033[00;32m+\033[0m $1\n"
}

fail() {
  printf "  \033[0;31m-\033[0m $1\n"
  exit
}

git_check() {
  git rev-parse || fail "$PWD is already under git control"
}

setup() {
  rm -rf $DEPLOY
  mkdir $DEPLOY

  info "created $DEPLOY"
  cd $DEPLOY
  git_check

  git init -q
  info "initialized git"
  git checkout --orphan master -q
  info "established master branch"
  if [ $TRAVIS ]
  then
    git remote add origin "https://rokob:${GH_TOKEN}${REMOTE_LOCATION}"
  else
    git remote add origin "https://rokob${REMOTE_LOCATION}"
  fi
  info "established git remote"

  success "setup complete"
}

travis_setup() {
  git config --global user.name "$GIT_NAME"
  git config --global user.email "$GIT_EMAIL"
  git config credential.helper "store --file=.git/credentials"
  echo "https://${GH_TOKEN}:@github.com" > .git/credentials
  info "set-up complete with ${GIT_NAME}, ${GIT_EMAIL}, and ${GH_TOKEN}"
}

travis_teardown() {
  rm .git/credentials
}

deploy() {
  COMMIT=$(git log -1 HEAD --pretty=format:%H)
  SHA=${COMMIT:0:8}

  info "commencing deploy operation based off of $SHA"

  # clean out deploy and move in the new files
  rm -rf "$DEPLOY"/*
  info "cleaned out $DEPLOY"

  info "building site"
  
  bundle exec jekyll build > /dev/null
  
  cp -r "$SITE"/* $DEPLOY
  info "copied $SITE into $DEPLOY"

  cd $DEPLOY

  if [ $TRAVIS ]
  then
    info "setting up travis"
    travis_setup
  fi

  git add --all .
  info "added files to git"

  git commit -m "generated from $SHA" -q
  info "committed site"

  git push origin master --force -q
  success "deployed site"

  if [ $TRAVIS ]
  then
    info "tearing down travis"
    travis_teardown
  fi
}

case "$1" in
  setup )
    setup;;
  deploy )
    deploy;;
  * )
    fail "invalid operation";;
  esac

