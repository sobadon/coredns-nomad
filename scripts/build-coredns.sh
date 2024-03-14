#!/bin/bash

# ./scripts/build-coredns.sh <coredns git version (tag, branch)>
# ./scripts/build-coredns.sh v1.11.1

set -ex

COREDNS_GIT_VERSION=$1
if [ -z "$COREDNS_GIT_VERSION" ]; then
    COREDNS_GIT_VERSION=master
fi

COREDNS_NOMAD_DIR=$(pwd)
COREDNS_NOMAD_GO_PKG_NAME=$(go list -m)

tmpdir=$(mktemp -d)
echo "tmpdir: $tmpdir"
pushd $tmpdir

git clone https://github.com/coredns/coredns.git
cd coredns
git checkout "${COREDNS_GIT_VERSION}"

echo "nomad:${COREDNS_NOMAD_GO_PKG_NAME}" >> plugin.cfg
go mod edit -replace ${COREDNS_NOMAD_GO_PKG_NAME}=$COREDNS_NOMAD_DIR
make

COREDNS_BINARY_PATH=$(readlink -f ./coredns)
if [ -n "$GITHUB_ACTIONS" ]; then
    echo "COREDNS_BINARY_PATH=${COREDNS_BINARY_PATH}" >> "${GITHUB_OUTPUT}"
fi

popd

echo "tmpdir: $tmpdir"
