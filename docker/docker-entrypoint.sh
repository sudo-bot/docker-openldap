#!/bin/sh -l
##
# @license http://unlicense.org/UNLICENSE The UNLICENSE
# @author William Desportes <williamdes@wdes.fr>
##

set -eu

MODE="${1:-}"

if [ "${MODE}" = "--help" ]; then
    echo "help: Use 'sasl' or 'ldap'"
    exit 0
fi

if [ "${MODE}" = "ldap" ]; then
    /ldap-start.sh
fi

if [ "${MODE}" = "sasl" ]; then
    saslauthd -a ldap -d 1
fi

if [ "${MODE}" != "ldap" ] && [ "${MODE}" != "sasl" ]; then
    echo "Mode: '${MODE}' is not supported"
    exit 1;
fi
