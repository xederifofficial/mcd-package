# syntax=docker/dockerfile:1


FROM ubuntu:focal-20230126 as mc-builder
SHELL ["/bin/bash", "-c"]

ARG NETWORK
ENV NETWORK ${NETWORK}

RUN echo "Network: $NETWORK"

RUN  ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime \
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
     build-essential \
     cmake \
     curl \
     git \
     libclang-dev \
     libprotobuf-dev \
     unzip \
     wget \
     zlib1g-dev \
  && apt-get clean \
  && rm -r /var/lib/apt/lists

# Install a newer version of the protobuf compiler, that's not available in apt
RUN export ARCH=$(uname -m | sed -e 's/arch64/arch_64/') ;\
  echo "Arch: $ARCH" && \
  wget https://github.com/protocolbuffers/protobuf/releases/download/v25.2/protoc-25.2-linux-$ARCH.zip \
  && unzip protoc-25.2-linux-$ARCH.zip -d protoc \
  && cp protoc/bin/protoc /usr/bin/protoc \
  && cp -r protoc/include/google /usr/include/google \
  && rm -rf protoc 


# Github actions overwrites the runtime home directory, so we need to install in a global directory.
ENV RUSTUP_HOME=/opt/rustup
ENV CARGO_HOME=/opt/cargo
RUN  mkdir -p ${RUSTUP_HOME} \
  && mkdir -p ${CARGO_HOME}/bin

# Install rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
  sh -s -- -y --default-toolchain nightly-2023-01-22

ENV PATH=/opt/cargo/bin:$PATH


COPY ./ ./mc-build
RUN cd mc-build && ./build.sh


FROM ubuntu:focal-20230126 as mc-mobilecoind

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        lmdb-utils \
        rsync \
        wget \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=mc-builder /mc-build/mobilecoin/target/release/mobilecoind /usr/local/bin/
COPY --from=mc-builder /mc-build/mobilecoin/target/release/mc-admin-http-gateway /usr/local/bin/
COPY --from=mc-builder /mc-build/mobilecoin/consensus-enclave.css /usr/local/bin/
COPY --from=mc-builder /mc-build/mobilecoin/ingest-enclave.css /usr/local/bin/
COPY --from=mc-builder /mc-build/mobilecoin/docker-readme.md /README.md
CMD ["/usr/local/bin/mobilecoind"]
