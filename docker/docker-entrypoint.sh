#!/bin/sh -l
##
# @license http://unlicense.org/UNLICENSE The UNLICENSE
# @author William Desportes <williamdes@wdes.fr>
# Inspired by https://github.com/osixia/docker-openldap/blob/v1.5.0/image/service/slapd/startup.sh
##

set -eu

# Reduce maximum number of number of open file descriptors to 1024
# otherwise slapd consumes two orders of magnitude more of RAM
# see https://github.com/docker/docker/issues/8231
# See: https://github.com/moby/moby/issues/8231
ulimit -n $LDAP_NOFILE

echo 'Replacing values with ENV values'
sed -i "s|{{ LDAP_ADMIN_PASSWORD }}|${LDAP_ADMIN_PASSWORD}|" /etc/saslauthd.conf
sed -i "s|{{ LDAP_AUTH_BASE_DN }}|${LDAP_AUTH_BASE_DN}|" /etc/saslauthd.conf
sed -i "s|{{ LDAP_BASE_DN }}|${LDAP_BASE_DN}|" /etc/saslauthd.conf
sed -i "s|{{ LDAP_AUTH_BASE_DN }}|${LDAP_AUTH_BASE_DN}|" /etc/openldap/slapd.conf
sed -i "s|{{ LDAP_BASE_DN }}|${LDAP_BASE_DN}|" /etc/openldap/slapd.conf
sed -i "s|{{ LDAP_CONFIG_PASSWORD }}|${LDAP_CONFIG_PASSWORD}|" /etc/openldap/slapd.conf
sed -i "s|{{ LDAP_ADMIN_PASSWORD }}|${LDAP_ADMIN_PASSWORD}|" /etc/openldap/slapd.conf
sed -i "s|{{ LDAP_MONITOR_PASSWORD }}|${LDAP_MONITOR_PASSWORD}|" /etc/openldap/slapd.conf

echo 'Checking if replacement worked'
set -x
grep -q -F "ldap_bind_dn: cn=admin,${LDAP_BASE_DN}" /etc/saslauthd.conf
grep -q -F "ldap_search_base: ${LDAP_AUTH_BASE_DN}" /etc/saslauthd.conf
grep -q -F "ldap_bind_pw: ${LDAP_ADMIN_PASSWORD}" /etc/saslauthd.conf
grep -q -F ",${LDAP_AUTH_BASE_DN}" /etc/openldap/slapd.conf
grep -q -F "suffix		\"${LDAP_BASE_DN}\"" /etc/openldap/slapd.conf
grep -q -F "${LDAP_CONFIG_PASSWORD}" /etc/openldap/slapd.conf
grep -q -F "${LDAP_ADMIN_PASSWORD}" /etc/openldap/slapd.conf
grep -q -F "${LDAP_MONITOR_PASSWORD}" /etc/openldap/slapd.conf
set +x

echo 'Starting...'
horust --unsuccessful-exit-finished-failed
ldap_bind_pw: {{ LDAP_ADMIN_PASSWORD }}
