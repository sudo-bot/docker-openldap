#!/bin/sh -l
##
# @license http://unlicense.org/UNLICENSE The UNLICENSE
# @author William Desportes <williamdes@wdes.fr>
##

set -eux

ldapwhoami -H ldap://openldap -D cn=admin,dc=example,dc=org -w "admin"
ldapwhoami -H ldap://openldap -D cn=config -w "config"
ldapwhoami -H ldap://openldap -D cn=monitor -w "monitor"

echo 'Seeding org'
ldapadd -H ldap://openldap -D "cn=admin,dc=example,dc=org" -w admin < /tests/data/org.ldiff

echo 'Seeding email 1'
ldapadd -H ldap://openldap -D "cn=admin,dc=example,dc=org" -w admin < /tests/data/email1.ldiff

echo 'Seeding email 2'
ldapadd -H ldap://openldap -D "cn=admin,dc=example,dc=org" -w admin < /tests/data/email2.ldiff

echo 'Seeding org for email 3'
ldapadd -H ldap://openldap -D "cn=admin,dc=example,dc=org" -w admin < /tests/data/org-email3.ldiff

echo 'Seeding email 3'
ldapadd -H ldap://openldap -D "cn=admin,dc=example,dc=org" -w admin < /tests/data/email3.ldiff

echo 'Seeding email 4'
ldapadd -H ldap://openldap -D "cn=admin,dc=example,dc=org" -w admin < /tests/data/email4.ldiff

echo 'Seeding org for email 5'
ldapadd -H ldap://openldap -D "cn=admin,dc=example,dc=org" -w admin < /tests/data/org-email5.ldiff

echo 'Seeding email 5'
ldapadd -H ldap://openldap -D "cn=admin,dc=example,dc=org" -w admin < /tests/data/email5.ldiff

echo 'Print results'
ldapsearch -LLL -H ldap://openldap -D "cn=admin,dc=example,dc=org" -w admin -b "ou=people,dc=example,dc=org" '*'

echo 'Print config'
ldapsearch -LLL -H ldap://openldap -D "cn=config" -w config -b "cn=config" 'cn=config'

echo 'Print supported SASL Mechanisms'
saslauthd -v
ldapsearch -LLL -x -H ldap://openldap -b "" -s base supportedSASLMechanisms

echo 'Login as email 1'
ldapwhoami -H ldap://openldap -D "cn=John Pondu,ou=people,dc=example,dc=org" -w 'JohnPassWord!645987zefdm'

echo 'Login as email 2'
ldapwhoami -H ldap://openldap -D "cn=Cyrielle Pondu,ou=people,dc=example,dc=org" -w 'PassCyrielle!ILoveDogs'

echo 'Login as email 3'
ldapwhoami -H ldap://openldap -D "mail=alice@warz.eu,o=warz.eu,ou=people,dc=example,dc=org" -w 'oHHGf7YyJSihb6ifSwNWZPtEGzijjp8'

echo 'Login as email 4'
#echo -e "\tUsing simple auth"
#ldapwhoami -H ldap://openldap -D "mail=edwin@warz.eu,o=warz.eu,ou=people,dc=example,dc=org" -w 'oHHGf7YyJSihb6ifSwNWZPtEGzijjp8'
echo -e "\tUsing SASL auth"
ldapwhoami -Q -H ldap://openldap -U edwin@warz.eu -w 'oHHGf7YyJSihb6ifSwNWZPtEGzijjp8'

echo 'Login as email 5'
ldapwhoami -H ldap://openldap -D "mail=elana@caldin.eu,o=caldin.eu,ou=people,dc=example,dc=org" -w 'bandedetsylish'
