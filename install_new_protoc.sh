#!/bin/bash

echo "Installing new protoc"

set -ex

cd /tmp
apt update
apt install unzip
wget https://github.com/protocolbuffers/protobuf/releases/download/v25.2/protoc-25.2-linux-x86_64.zip
unzip protoc-25.2-linux-x86_64.zip 
cp bin/protoc /usr/bin/protoc
