#!/bin/bash
# This script is taken from:
# http://superuser.com/questions/109213/is-there-a-tool-that-can-test-what-ssl-tls-cipher-suites-a-particular-website-of
#
if [[ "x$1" == "x" ]]; then
    echo "must give ip or host name as parameter"
    exit 1
fi

server=$1
echo "Testing Server $server..."

# OpenSSL requires the port number.
DELAY=1
ciphers=`openssl ciphers 'ALL:eNULL' | sed -e 's/:/ /g'`

echo Obtaining cipher list from `openssl version`.

for cipher in ${ciphers[@]}
do
echo -n Testing $cipher...
result=`echo -n | openssl s_client -cipher "$cipher" -connect $server:443 2>&1`
if [[ "$result" =~ "Cipher is " ]] ; then
  echo YES
else
  if [[ "$result" =~ ":error:" ]] ; then
    error=`echo -n $result | cut -d':' -f6`
    echo NO \($error\)
  else
    echo UNKNOWN RESPONSE
    echo $result
  fi
fi
sleep $DELAY
done
