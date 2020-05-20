FROM rust:1.43.1-buster

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

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 /bin/dumb-init
RUN chmod +x /bin/dumb-init

FROM scratch

ARG GRCOV_VERSION

COPY --from=0 /grcov-${GRCOV_VERSION}/deps /
COPY --from=0 /grcov-${GRCOV_VERSION}/target/release/grcov /bin/grcov
COPY --from=0 /bin/dumb-init /bin/dumb-init

ENTRYPOINT ["/bin/dumb-init", "--"]
