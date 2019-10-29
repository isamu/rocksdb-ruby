#!/bin/bash

# Fail if anything fails
set -e

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then
  # BUG: https://discourse.brew.sh/t/octave-require-relative-problem/6043
  # BUG: https://travis-ci.community/t/homebrew-syntax-error/5623
  export HOMEBREW_NO_AUTO_UPDATE=1

  if [[ -z "${ROCKSDB_VERSION}" ]]; then
    echo "Brewing latest available version"
    brew install "rocksdb"
  else
    BREW_CORE_URI="https://raw.githubusercontent.com/Homebrew/homebrew-core"
    FORMULA_URI="${BREW_CORE_URI}/${ROCKSDB_VERSION_COMMIT}/Formula/rocksdb.rb"
    echo "Installing ${ROCKSDB_VERSION} from ${ROCKSDB_VERSION_COMMIT}"
    brew install "${FORMULA_URI}"
    brew switch rocksdb "${ROCKSDB_VERSION}"
  fi

  echo "Building bundle"
  bundle install
elif [[ $TRAVIS_OS_NAME == 'linux' ]]; then
  export PATH="/usr/lib/ccache/:$PATH"

  if [[ -z "${ROCKSDB_VERSION}" ]]; then
    echo "Building from rocksdb master in ${ROCKSDB_FOLDER}"
    git clone -b "master" --single-branch --depth 1 https://github.com/facebook/rocksdb.git $ROCKSDB_FOLDER
  else
    echo "Building ${ROCKSDB_VERSION} in ${ROCKSDB_FOLDER}"
    git clone -b "v$ROCKSDB_VERSION" --single-branch --depth 1 https://github.com/facebook/rocksdb.git $ROCKSDB_FOLDER
  fi

  pushd $ROCKSDB_FOLDER
  ccache -s

  if [[ $DEBUG_LEVEL == '1' ]]; then
    echo "Building with DEBUG_LEVEL=1"
    # TODO: I think it's better to try to satisfy all the rocksdb checks
    make -j4 shared_lib DEBUG_LEVEL=1
  else
    make -j4 shared_lib
  fi

  ccache -s
  popd

  echo "Building bundle with params:"
  echo "${ROCKSDB_RUBY_BUILD_PARAMS}"
  bundle install
else
  echo "Unsupported OS ${TRAVIS_OS_NAME}"
  exit 1
fi
