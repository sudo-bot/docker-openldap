#!/bin/sh -l
##
# @license http://unlicense.org/UNLICENSE The UNLICENSE
# @author William Desportes <williamdes@wdes.fr>
##

seedFile() {
    ldapadd -H ldap://openldap -D "cn=admin,dc=example,dc=org" -w admin < "/tests/data/$1.ldiff"
}

seedEmail() {
    echo "Seeding email: $1"
    seedFile "$1"
}

seedOrg() {
    echo "Seeding org: $1"
    seedFile "$1"
}

set -eu

ldapwhoami -H ldap://openldap -D cn=admin,dc=example,dc=org -w "admin"
ldapwhoami -H ldap://openldap -D cn=config -w "config"
ldapwhoami -H ldap://openldap -D cn=monitor -w "monitor"

seedOrg org
seedOrg org-email3
seedOrg org-email5

seedEmail email1
seedEmail email2
seedEmail email3
seedEmail email4
seedEmail email5
seedEmail email6

echo 'Print results'
ldapsearch -LLL -H ldap://openldap -D "cn=admin,dc=example,dc=org" -w admin -b "ou=people,dc=example,dc=org" '*'

echo 'Print config'
ldapsearch -LLL -H ldap://openldap -D "cn=config" -w config -b "cn=config" 'cn=config'

echo 'Print supported SASL Mechanisms'
saslauthd -v
ldapsearch -LLL -x -H ldap://openldap -b "" -s base supportedSASLMechanisms

echo 'Login as email 1'
ldapwhoami -H ldap://openldap -D "cn=John Pondu,ou=people,dc=example,dc=org" -w 'JohnPassWord!645987zefdm'
echo 'Login as email 1 bad password'
ldapwhoami -H ldap://openldap -D "cn=Pondu John,ou=people,dc=example,dc=org" -w 'JohnPassWord!s645987zefdm' && ret=$? || ret=$?
if [ $ret -ne 49 ]; then
    echo "Login should not work as the CN is wrong ($ret)"
    exit 1
fi

echo 'Login as email 1 no password'
ldapwhoami -H ldap://openldap -D "cn=John Pondu,ou=people,dc=example,dc=org" && ret=$? || ret=$?
if [ $ret -ne 53 ]; then
    echo "Login should not work as the password is missing ($ret)"
    exit 1
fi

echo 'Login as email 1 bad password'
ldapwhoami -H ldap://openldap -D "cn=John Pondu,ou=people,dc=example,dc=org" -w 'JohnPassWord!s645987zefdm' && ret=$? || ret=$?
if [ $ret -ne 49 ]; then
    echo "Login should not work as the password is wrong ($ret)"
    exit 1
fi

echo 'Login as email 2'
ldapwhoami -H ldap://openldap -D "cn=Cyrielle Pondu,ou=people,dc=example,dc=org" -w 'PassCyrielle!ILoveDogs'

echo 'Login as email 3'
ldapwhoami -H ldap://openldap -D "mail=alice@warz.eu,o=warz.eu,ou=people,dc=example,dc=org" -w 'oHHGf7YyJSihb6ifSwNWZPtEGzijjp8'

# -a slapd will make it use slapd.conf in the plugin config folder
#echo "oHHGf7YyJSihb6ifSwNWZPtEGzijjp8" | saslpasswd2 -a slapd -n -p -c -u warz.eu edwin@warz.eu

echo 'Login as email 4'
echo -e "\tUsing SASL auth"
ldapwhoami -Q -H ldap://openldap -U edwin@warz.eu -w 'oHHGf7YyJSihb6ifSwNWZPtEGzijjp8'
echo -e "\tUsing simple auth"
ldapwhoami -H ldap://openldap -D "mail=edwin@warz.eu,o=warz.eu,ou=people,dc=example,dc=org" -w 'oHHGf7YyJSihb6ifSwNWZPtEGzijjp8'

echo 'Login as email 5'
echo -e "\tUsing secure STARTTLS auth"
ldapwhoami -ZZ -H ldap://openldap -D "mail=elana@caldin.eu,o=caldin.eu,ou=people,dc=example,dc=org" -w 'bandedetsylish'
echo -e "\tUsing secure SSL auth"
ldapwhoami -H ldaps://openldap -D "mail=elana@caldin.eu,o=caldin.eu,ou=people,dc=example,dc=org" -w 'bandedetsylish'
echo -e "\tUsing simple auth"
ldapwhoami -H ldap://openldap -D "mail=elana@caldin.eu,o=caldin.eu,ou=people,dc=example,dc=org" -w 'bandedetsylish'
echo -e "\tUsing SASL auth"
ldapwhoami -Q -H ldap://openldap -U elana@caldin.eu -w 'bandedetsylish' && ret=$? || ret=$?
if [ $ret -ne 49 ]; then
    echo "Login can not work because the password is not usable for SASL and SRP secret is not set ($ret)"
    exit 1
fi

echo 'Login as email 6'
echo -e "\tUsing SASL auth"
ldapwhoami -Q -H ldap://openldap -U elon@caldin.eu -w 'HVxmD6ejZ9nUX6MSnQUvqKui5YYG56P' && ret=$? || ret=$?
if [ $ret -ne 49 ]; then
    echo "Login should not work for clear text passwords in the DB ($ret)"
    exit 1
fi

echo -e "\tUsing simple auth"
ldapwhoami -H ldap://openldap -D "mail=elon@caldin.eu,o=caldin.eu,ou=people,dc=example,dc=org" -w 'HVxmD6ejZ9nUX6MSnQUvqKui5YYG56P'
