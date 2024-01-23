#!/bin/bash

set -e

pushd mobilecoin

export GIT_REV=`git rev-parse HEAD`
echo "GIT_REV = ${GIT_REV}"

cargo clean

export NETWORK="prod.mobilecoin.com"
echo "NETWORK = ${NETWORK}"

source ./tools/download_sigstruct.sh
export SGX_MODE=HW
export IAS_MODE=PROD

echo "Building mobilecoind"

cargo build --release --locked -p mc-mobilecoind -p mc-admin-http-gateway

export ARTIFACTS=/tmp/mobilecoind-mainnet-package
echo "Bundling artifacts at ${ARTIFACTS}"

rm -rf ${ARTIFACTS}
mkdir -p ${ARTIFACTS}

cp target/release/mobilecoind ${ARTIFACTS}/
cp ingest-enclave.css ${ARTIFACTS}/
cp consensus-enclave.css ${ARTIFACTS}/
cat << EOF > "${ARTIFACTS}/README.md"
# mobilecoind-mainnet (mobilecoin.git @ ${GIT_REV})

* The mobilecoind wallet
* A CSS SGX Enclave Measurement file for the fog ingest enclave. ingest-enclave.css
* The same for consensus enclave, although this should not be necessary.
* The mc-admin-http-gateway

We don't include the mobilecoind-json. I would really like to kill that off,
please consider using go-grpc-gateway to build an http-grpc bridge instead.
(I suppose we could do that and bundle it here...)
EOF

popd

tar -czvf mobilecoind-mainnet.tar.gz -C ${ARTIFACTS} .
