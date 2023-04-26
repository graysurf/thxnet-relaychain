# syntax=docker/dockerfile:1.4

# This is the build stage for THXNET. node. Here we create the binary in a temporary image.
FROM 886360478228.dkr.ecr.us-west-2.amazonaws.com/ci-containers/substrate-based:build-2023.04.26-b6f17a1 as builder

WORKDIR /build
COPY . /build

RUN cargo build --locked --release

# This is the 2nd stage: a very small image where we copy the THXENT. binary."
FROM docker.io/library/ubuntu:22.04 as rootchain

LABEL description="Container image for THXNET." \
    io.thxnet.image.type="final" \
    io.thxnet.image.authors="contact@thxlab.io" \
    io.thxnet.image.vendor="thxlab.io" \
    io.thxnet.image.description="THXNET.: The Hybrid Next-Gen Blockchain Network"

COPY --from=builder /build/target/release/polkadot /usr/local/bin

RUN <<EOF
#!/usr/bin/env bash

set -eu

useradd -m -u 1000 -U -s /bin/sh -d /rootchain thxnet

mkdir -p /data /rootchain/.local/share

chown -R thxnet:thxnet /data

ln -s /data /rootchain/.local/share/polkadot

# unclutter and minimize the attack surface
rm -rf /usr/bin /usr/sbin

# check if executable works in this container
/usr/local/bin/polkadot --version

EOF

USER thxnet

VOLUME ["/data"]

ENTRYPOINT ["/usr/local/bin/polkadot"]
