#!/bin/bash

set -ex

cd mobilecoin

export IAS_MODE=PROD SGX_MODE=HW
echo "Network: $NETWORK"

export GIT_REV=`git rev-parse HEAD`
echo "GIT_REV = ${GIT_REV}"

source ./tools/download_sigstruct.sh

# Fix multiplatform build memory issues
# https://github.com/docker/build-push-action/issues/621#issuecomment-1383624173
export CARGO_NET_GIT_FETCH_WITH_CLI=true
#cargo build --release --locked -p mc-mobilecoind -p mc-admin-http-gateway

cat << EOF > "docker-readme.md"
# mobilecoind ($NETWORK, mobilecoin.git @ ${GIT_REV})

This package includes:

* The mobilecoind wallet
* A CSS SGX Enclave Measurement file for the fog ingest enclave. ingest-enclave.css
* The same for consensus enclave, although this should not be necessary.
* The mc-admin-http-gateway

Enclave css files downloaded from ${NETWORK}

We don't include the mobilecoind-json. I would really like to kill that off,
please consider using go-grpc-gateway to build an http-grpc bridge instead.
(I suppose we could do that and bundle it here...)
EOF

