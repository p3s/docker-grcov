FROM rust:1.45.0-buster

ARG GRCOV_VERSION

ADD https://github.com/mozilla/grcov/archive/v${GRCOV_VERSION}.tar.gz /

RUN tar xf v${GRCOV_VERSION}.tar.gz \
 && cd grcov-${GRCOV_VERSION} \
 && cargo build --release \
 && cargo test --lib --release \
 && strip target/release/grcov \
 && mkdir deps \
 && ldd target/release/grcov | \
    tr -s '[:blank:]' '\n' | \
    grep '^/' | \
    xargs -I % cp --parents % deps

FROM busybox

ARG GRCOV_VERSION

COPY --from=0 /grcov-${GRCOV_VERSION}/deps /
COPY --from=0 /grcov-${GRCOV_VERSION}/target/release/grcov /bin/grcov
