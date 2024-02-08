#!/bin/bash

set -e

cp install_new_protoc.sh mobilecoin/

pushd mobilecoin

export GIT_REV=`git rev-parse HEAD`
echo "GIT_REV = ${GIT_REV}"

cargo clean

export NETWORK="prod.mobilecoin.com"
echo "NETWORK = ${NETWORK}"

echo "Building mobilecoind"

./mob --verbose --no-publish --hw --ias-prod --env="NETWORK=${NETWORK}" "source ./tools/download_sigstruct.sh; sudo ./install_new_protoc.sh; cargo build --release --locked -p mc-mobilecoind -p mc-admin-http-gateway"

rm install_new_protoc.sh

export ARTIFACTS=/tmp/mobilecoind-mainnet-package
echo "Bundling artifacts at ${ARTIFACTS}"

rm -rf ${ARTIFACTS}
mkdir -p ${ARTIFACTS}/bin

cp target/docker/release/mobilecoind ${ARTIFACTS}/bin/
cp target/docker/release/mc-admin-http-gateway ${ARTIFACTS}/bin/
cp ingest-enclave.css ${ARTIFACTS}/bin/
cp consensus-enclave.css ${ARTIFACTS}/bin/
cat << EOF > "${ARTIFACTS}/README.md"
# mobilecoind-mainnet (mobilecoin.git @ ${GIT_REV})

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

popd

tar -czvf mobilecoind-mainnet.tar.gz -C ${ARTIFACTS} .
