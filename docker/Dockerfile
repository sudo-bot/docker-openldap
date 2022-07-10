FROM alpine:3.16

# See: https://www.openldap.org/software/release/changes.html
# See: https://git.openldap.org/openldap/openldap/-/tree/OPENLDAP_REL_ENG_2_6_2
# See: https://pkgs.alpinelinux.org/packages?name=openldap&branch=edge
ARG RELEASE_VERSION=2.6.2-r0
ARG CYRUS_SASL_VERSION=2.1.28-r0

# Metadata params
ARG VCS_REF
ARG BUILD_DATE

ENV LDAP_LOG_LEVEL=0
ENV LDAP_NOFILE=1024

RUN apk add --no-cache --update \
    openldap=${RELEASE_VERSION} \
    openldap-clients \
    cyrus-sasl=${CYRUS_SASL_VERSION} \
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
        /etc/openldap/schema/dsee.schema

COPY slapd.conf /etc/openldap/
COPY postfix-book.schema /etc/openldap/schema-custom/
COPY docker-entrypoint.sh ldap-start.sh /

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


ENTRYPOINT ["/docker-entrypoint.sh"]
