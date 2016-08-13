#!/bin/sh
##
## netscreen/jnpr ssl vpn connection magic
## oogali@idlepattern.com / @oogali
##
## i wrote this about a year ago (2009), when i had continuous access
## to a jnpr ssl vpn box and had to connect via it.
##
## if bits of this script are broken, i'll be glad to fix if someone
## gives me client access to a ssl vpn box to test against.
##
## Usage:
##   start-vpn <your-ssl-vpn-endpoint-hostname>
##
## the jnpr client doesn't fork/background on success, so you should
## start this with screen (http://www.gnu.org/software/screen)
##
## - oo / 20101209

NCPATH=/usr/local/nc

## compile libncui.so into binary
if [ ! -f "${NCPATH}/nc" ]; then
  gcc -m32 -o -Wl,rpath=${NCPATH} -o ${NCPATH}/ncui ${NCPATH}/libncui.so
  if [ $? -ne 0 ]; then
    echo "$0: could not compile ncui binary"
    exit 1
  fi
fi

## check for no ssl check argument
if [ $# -gt 0 ]; then
  if [ "${1}" == "-nocertcheck" ]; then
    no_cert_check="-k"
    shift
  fi
fi

## use user-provided vpn host or round-robin through available hosts (via magic.round.robin.dns.name.for.vpn.endpoints)
if [ $# -eq 1 ]; then
  dnshostname=$1
else
  for vpndevice in `dig +short magic.round.robin.dns.name.for.vpn.endpoints` ; do
    nc -z ${vpnhost} 443 >/dev/null
    if [ $? == 0 ]; then
      dnshostname=${vpndevice}
      break
    fi
  done
fi

## if reverse dns is missing, use original provided host
vpn_host=`dig +short -x ${dnshostname}`
if [ -z "${vpn_host}" ]; then
  vpn_host=${dnshostname}
fi

## display banner and get credentials
echo "Organization-Name SSL VPN (${vpn_host})"
echo

echo -n "Username: "
read username

if [ ! -f "${NCPATH}/${username}.pem" ]; then
  echo "could not find client certificate"
  exit 1
fi

echo -n "Password: "
read -s passwd

REALM="YOUR-ACTIVE-DIRECTORY-REALM"

## get the ssl certificate
echo nohandshake | openssl s_client -connect ${vpn_host}:443 2>&1 | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' > ${NCPATH}/${vpn_host}.pem
openssl x509 -inform PEM -in ${NCPATH}/${vpn_host}.pem -outform DER -out ${NCPATH}/${vpn_host}.der

## perform session login via web
CURL=`which curl 2>/dev/null`
if [ -z "${CURL}" ]; then
  echo "could not find curl installation"
  exit 1
fi

cookie_jar=`mktemp /tmp/vpn.XXXXXX`
if [ ! -f "${cookie_jar}" ]; then
  echo "could not create cookie jar"
  exit 1
fi

CURL_FLAGS="${no_cert_check} -i -b ${cookie_jar} -c ${cookie_jar} --cert ${NCPATH}/${username}.pem --cert-type PEM"
${CURL} ${CURL_FLAGS} -s -o /dev/null https://${vpn_host}
${CURL} ${CURL_FLAGS} -s -o /dev/null https://${vpn_host}/dana-na/auth/url_default/welcome.cgi

temp_output=`mktemp /tmp/vpn.XXXXXX`
if [ ! -f "${temp_output}" ]; then
  echo "could not create temporary output"
  rm -f ${cookie_jar}
  exit 1
fi

auth_data="username=${username}&password=${passwd}&realm=${REALM}&tz_offset=`date '+%z'`"
${CURL} ${CURL_FLAGS} -s -o ${temp_output} --data-ascii "${auth_data}&btnSubmit=Sign+In" https://${vpn_host}/dana-na/auth/url_default/login.cgi
grep -iq 'welcome.cgi' ${temp_output}
if [ $? -ne 0 ]; then
  echo "unsuccessful login! ($?)"
  rm -f ${cookie_jar} ${temp_output}
  exit 1
fi

newurl=`grep -i '^location:' ${temp_output} | cut -f2 -d ' '`
if [ $? -ne 0 ]; then
  echo "expected 302/redirect, didn't find it"
  rm -f ${cookie_jar} ${temp_output}
  exit 1
fi

if [ -z "${newurl}" ]; then
  echo "expected 302/redirect, didn't find it"
  rm -f ${cookie_jar} ${temp_output}
  exit 1
fi

${CURL} ${CURL_FLAGS} -s -o ${temp_output} ${newurl}

grep -iq 'frmConfirmation' ${temp_output}
if [ $? -eq 0 ]; then
  form_data=`grep 'DSIDFormDataStr' ${temp_output} | sed 's/.*name="\(.*\)".*value="\(.*\)">/\1=\2/; s/;/%3b/g; s/\+/%2b/g;'`
  ${CURL} ${CURL_FLAGS} -s -o ${temp_output} -H "Referer: ${referer}" --data "${form_data}&btnContinue=Continue%20the%20session" https://${vpn_host}/dana-na/auth/url_default/login.cgi
fi

grep -iq 'welcome.cgi?p=failed' ${temp_output}
if [ $? -eq 0 ]; then
  echo "unsuccessful login after redirect"
  rm -f ${cookie_jar} ${temp_output}
  exit 1
fi

newurl=`grep -i '^location:' ${temp_output} | cut -f2 -d ' '`
if [ $? -ne 0 ]; then
  echo "expected 302/redirect, didn't find it"
  rm -f ${cookie_jar} ${temp_output}
  exit 1
fi

${CURL} ${CURL_FLAGS} -s -o ${temp_output} ${newurl}
dsid=`grep 'DSID' ${cookie_jar} | awk '{ print $7 }'`
if [ -z "${dsid}" ]; then
  echo "could not login successfully: could not get DSID"
  cat "${temp_output}"
  exit 1
fi

rm -f ${temp_output}
rm -f ${cookie_jar}

## save original resolv.conf
cp /etc/resolv.conf /etc/resolv.conf.vpn$$

## connect to the vpn
echo
echo "Connecting to VPN... Ctrl+C to disconnect"
${NCPATH}/ncui -L5 -c "DSID=${dsid}" -u "${REALM}\\${username}" -p "${passwd}" -r "${REALM}" -h ${vpn_host} -f ${NCPATH}/${vpn_host}.der

## restore original resolv.conf after disconnection
cp /etc/resolv.conf.vpn$$ /etc/resolv.conf

