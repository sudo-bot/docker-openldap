# See: https://www.docker.com/blog/faster-multi-platform-builds-dockerfile-cross-compilation-guide/

# fetch the vendor with the builder platform to avoid qemu issues (https://github.com/docker/buildx/issues/395)
FROM --platform=$TARGETPLATFORM alpine:3.19 as build-env-sasl

ARG TARGETPLATFORM
ARG BUILDPLATFORM

WORKDIR /workspace

COPY saslauth-APKBUILD /workspace/APKBUILD
COPY fix-srp-setpass.patch /workspace/fix-srp-setpass.patch
ENV RSA_PRIVATE_KEY_NAME="sudo-bot@wdes.fr-temp.rsa"

RUN apk add --no-cache --update alpine-sdk && \
    mkdir /root/.abuild && \
    echo -e '\nPACKAGER="Sudo Bot <sudo-bot@wdes.fr>"' >> /root/.abuild/abuild.conf && \
    abuild-keygen -a -n && \
    apk add --no-cache gdbm-dev openssl-dev linux-pam-dev py3-sphinx sqlite-dev openldap-dev automake autoconf libtool && \
    abuild -F && \
    mv /root/.abuild/sudo-bot@wdes.fr-*.rsa.pub /root/packages/${RSA_PRIVATE_KEY_NAME}.pub && \
    mv /root/.abuild/sudo-bot@wdes.fr-*.rsa /root/packages/${RSA_PRIVATE_KEY_NAME}

# fetch the vendor with the builder platform to avoid qemu issues (https://github.com/docker/buildx/issues/395)
FROM --platform=$TARGETPLATFORM alpine:3.19

ARG TARGETPLATFORM
ARG BUILDPLATFORM

# See: https://www.openldap.org/software/release/changes.html
# See: https://git.openldap.org/openldap/openldap/-/tree/OPENLDAP_REL_ENG_2_6_5
# See: https://pkgs.alpinelinux.org/packages?name=openldap&branch=v3.19
ARG RELEASE_VERSION=2.6.6-r1
# See: https://pkgs.alpinelinux.org/packages?name=cyrus-sasl&branch=v3.19
ARG CYRUS_SASL_VERSION=2.1.28-r5

# Metadata params
ARG VCS_REF
ARG BUILD_DATE

ENV LDAP_LOG_LEVEL=0
ENV LDAP_NOFILE=1024

COPY --from=build-env-sasl /root/packages/ /root/packages/
RUN apk add --no-cache --update \
    # https://github.com/mischov/meeseeks/issues/98#issuecomment-636615680
    openssl libgcc \
    openldap=${RELEASE_VERSION} \
    openldap-clients \
    libsasl curl \
    syslog-ng \
    openssl-dev \
    openldap-back-mdb openldap-back-sql \
    openldap-passwd-sha2 openldap-passwd-argon2 openldap-passwd-pbkdf2 \
    openldap-overlay-otp openldap-overlay-ppolicy openldap-overlay-proxycache \
    openldap-overlay-refint openldap-overlay-remoteauth openldap-overlay-retcode \
    openldap-overlay-rwm openldap-overlay-seqmod openldap-overlay-sssvlv \
    openldap-overlay-syncprov openldap-overlay-translucent openldap-overlay-unique openldap-overlay-valsort && \
    apk add --no-cache --repository=https://dl-cdn.alpinelinux.org/alpine/edge/testing horust && \
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
    horust --help && \
    # Add dependencies that the next step can not add without a network repo
    apk add --no-cache linux-pam sqlite-libs && \
    echo '/root/packages/' > /root/packages/repositories && \
    apk add --allow-untrusted --keys-dir=/root/packages/ --no-network --no-cache --repositories-file=/root/packages/repositories \
        cyrus-sasl=${CYRUS_SASL_VERSION} \
        cyrus-sasl-static=${CYRUS_SASL_VERSION} \
        cyrus-sasl-srp=${CYRUS_SASL_VERSION} && \
    rm -rv /root/packages/* && \
    mkdir -p /var/run/saslauthd/

# See: https://github.com/p42/syslog-alpine-docker
# https://openldap-technical.openldap.narkive.com/VHoH0O93/can-t-get-slapd-to-do-pass-through-authentication
# Because of --with-configdir, thanks Brent Bice 12 years ago !
COPY sasl2-slapd.conf /etc/sasl2/slapd.conf
COPY horust/ /etc/horust/
COPY saslauthd.conf syslog-ng.conf /etc/

COPY slapd.conf /etc/openldap/
COPY postfix-book.schema /etc/openldap/schema-custom/
COPY docker-entrypoint.sh /

# Metadata
LABEL org.label-schema.vendor="Sudo-Bot" \
    org.label-schema.url="https://github.com/sudo-bot/docker-openldap#readme" \
    org.label-schema.name="docker-openldap" \
    org.label-schema.description="An OpenLDAP image" \
    org.label-schema.version=${RELEASE_VERSION} \
    org.label-schema.vcs-url="https://github.com/sudo-bot/docker-openldap.git" \
    org.label-schema.vcs-ref=${VCS_REF} \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.docker.schema-version="1.0" \
    \
    com.docker.extension.publisher-url="https://github.com/sudo-bot" \
    \
    org.opencontainers.image.title="Docker OpenLDAP server" \
    org.opencontainers.image.description="An OpenLDAP image" \
    org.opencontainers.image.authors="williamdes@wdes.fr" \
    org.opencontainers.image.url="https://github.com/sudo-bot/docker-openldap#readme" \
    org.opencontainers.image.documentation="https://github.com/sudo-bot/docker-openldap#readme" \
    org.opencontainers.image.source="https://github.com/sudo-bot/docker-openldap" \
    org.opencontainers.image.vendor="Sudo-Bot" \
    org.opencontainers.image.licenses="MPL-2.0" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.version=${RELEASE_VERSION} \
    org.opencontainers.image.revision=${VCS_REF} \
    org.opencontainers.image.ref.name="latest"

# Expose default ldap and ldaps ports
EXPOSE 389 636

VOLUME ["/var/lib/openldap/openldap-data"]

ENTRYPOINT ["/docker-entrypoint.sh"]
