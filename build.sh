#!/bin/bash

set -ex

cd mobilecoin

export NETWORK="test.mobilecoin.com" IAS_MODE=PROD SGX_MODE=HW

export GIT_REV=`git rev-parse HEAD`
echo "GIT_REV = ${GIT_REV}"

source ./tools/download_sigstruct.sh
cargo build --jobs 1 --release --locked -p mc-mobilecoind -p mc-admin-http-gateway

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

