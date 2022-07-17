FROM rust:1.62.0-alpine3.16 as build-env

WORKDIR /workspace

RUN apk add --no-cache curl musl-dev openssl-dev && \
    curl -s -L -# -o ./Horust.tar.gz https://github.com/FedericoPonzi/Horust/archive/c6a4cedb5f53836f14d12fd809272fdac9c8969b.tar.gz && \
    tar -C ./ --strip-components=1 -xzf ./Horust.tar.gz && \
    # https://users.rust-lang.org/t/sigsegv-with-program-linked-against-openssl-in-an-alpine-container/52172
    RUSTFLAGS="-C target-feature=-crt-static" cargo build --release

FROM alpine:3.16 as build-env-sasl

WORKDIR /workspace

COPY saslauth-APKBUILD /workspace/APKBUILD
RUN apk add --no-cache --update alpine-sdk && \
    curl -L -o /workspace/saslauthd.initd https://gitlab.alpinelinux.org/alpine/aports/-/raw/6ac417c97348b55bb824a88dd8a6dff24c87f487/main/cyrus-sasl/saslauthd.initd && \
    abuild-keygen -a -n && \
    apk add --no-cache gdbm-dev openssl1.1-compat-dev linux-pam-dev py3-sphinx sqlite-dev openldap-dev automake autoconf libtool && \
    abuild -F

FROM alpine:3.16

# See: https://www.openldap.org/software/release/changes.html
# See: https://git.openldap.org/openldap/openldap/-/tree/OPENLDAP_REL_ENG_2_6_3
# See: https://pkgs.alpinelinux.org/packages?name=openldap&branch=edge
ARG RELEASE_VERSION=2.6.3-r0
ARG CYRUS_SASL_VERSION=2.1.28-r0

# Metadata params
ARG VCS_REF
ARG BUILD_DATE

ENV LDAP_LOG_LEVEL=0
ENV LDAP_NOFILE=1024

COPY --from=build-env /workspace/target/release/horust /sbin/horust
COPY --from=build-env-sasl /root/packages /root/packages
RUN apk add --no-cache --update \
    # https://github.com/mischov/meeseeks/issues/98#issuecomment-636615680
    openssl libgcc \
    openldap=${RELEASE_VERSION} \
    openldap-clients \
    libsasl curl \
    syslog-ng \
    openldap-back-mdb openldap-back-sql \
    openldap-passwd-sha2 openldap-passwd-argon2 openldap-passwd-pbkdf2 \
    openldap-overlay-otp openldap-overlay-ppolicy openldap-overlay-proxycache \
    openldap-overlay-refint openldap-overlay-remoteauth openldap-overlay-retcode \
    openldap-overlay-rwm openldap-overlay-seqmod openldap-overlay-sssvlv \
    openldap-overlay-syncprov openldap-overlay-translucent openldap-overlay-unique openldap-overlay-valsort && \
    mkdir -p /run/openldap /var/lib/openldap/openldap-data && \
    rm -rf /var/cache/apk/* && \
    # Remove some schemas we are not friends with
    rm \
        /etc/openldap/schema/java.ldif \
        /etc/openldap/schema/java.schema \
        /etc/openldap/schema/msuser.ldif \
        /etc/openldap/schema/msuser.schema \
        /etc/openldap/schema/dsee.ldif \
        /etc/openldap/schema/dsee.schema && \
        # Enable ldapi:///
        mkdir /var/lib/openldap/run && \
        touch /var/lib/openldap/run/ldapi && \
    /sbin/horust --version && \
    apk add --no-cache --allow-untrusted \
        /root/packages/x86_64/cyrus-sasl-${CYRUS_SASL_VERSION}.apk \
        /root/packages/x86_64/cyrus-sasl-ldapdb-${CYRUS_SASL_VERSION}.apk \
        /root/packages/x86_64/cyrus-sasl-sql-${CYRUS_SASL_VERSION}.apk \
        /root/packages/x86_64/cyrus-sasl-scram-${CYRUS_SASL_VERSION}.apk && \
    mkdir -p /var/run/saslauthd/

COPY sasl2-slapd.conf /etc/sasl2/slapd.conf
COPY horust/ /etc/horust/
# See: https://github.com/p42/syslog-alpine-docker
# https://openldap-technical.openldap.narkive.com/VHoH0O93/can-t-get-slapd-to-do-pass-through-authentication
# Because of --with-configdir, thanks Brent Bice 12 years ago !
COPY saslauthd.conf syslog-ng.conf /etc/
COPY slapd.conf /etc/openldap/
COPY postfix-book.schema /etc/openldap/schema-custom/
COPY docker-entrypoint.sh /

# Metadata
LABEL org.label-schema.vendor="Sudo-Bot" \
    org.label-schema.url="https://www.openldap.org/" \
    org.label-schema.name="docker-openldap" \
    org.label-schema.description="An openldap image" \
    org.label-schema.version=${RELEASE_VERSION} \
    org.label-schema.vcs-url="https://github.com/sudo-bot/docker-openldap.git" \
    org.label-schema.vcs-ref=${VCS_REF} \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.docker.schema-version="1.0"

# Expose default ldap and ldaps ports
EXPOSE 389 636

VOLUME ["/ldif", "/var/lib/openldap/openldap-data"]
VOLUME ["/ldif", "/var/lib/openldap/openldap-data"]

ENTRYPOINT ["/docker-entrypoint.sh"]
