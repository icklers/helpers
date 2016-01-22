#!/bin/bash

DOMAIN="$1"
BASEDIR="/www/CA"
KEYDIR="${BASEDIR}/private"
KEYFILE="${DOMAIN}-key.pem"
CERTDIR="${BASEDIR}/certs"
CERTFILE="${DOMAIN}-cert.pem"
REQUESTDIR="${BASEDIR}/requests"
REQUESTFILE="${DOMAIN}-req.pem"
SSLCONF="/etc/pki/tls/openssl.cnf"
OPENSSL_BIN="/bin/openssl"
WWW_SSL_DIR="/www/${DOMAIN}/ssl"

if [ "${DOMAIN}" == "" ]; then
  echo "Error: No domain specified."
  echo ""
  echo "Usage: $0 <domain>"
  exit 1
fi

# Create domain cert request
if [[ -e ${KEYDIR}/${KEYFILE} ]]; then
	echo "${KEYFILE} already exists."
else
	echo "Creating domain certificate:"
	echo -n "Certificate request will be saved to: "
	echo    "${REQUESTDIR}/${REQUESTFILE}"
	echo -n "Private key will be saved to:         "
	echo    "${KEYDIR}/${KEYFILE}"
	echo ""
	
	${OPENSSL_BIN} req -new -nodes -out ${REQUESTDIR}/${REQUESTFILE} -keyout ${KEYDIR}/${KEYFILE} -config ${SSLCONF}
fi

# Create domain cert
if [[ -e ${CERTDIR}/${CERTFILE} ]]; then
	echo "${CERTFILE} already exist."
else
	echo "Creating domain certificate:"
	echo -n "Certificate will be saved to: "
	echo    "${CERTDIR}/${CERTFILE}"
	echo ""
	
	${OPENSSL_BIN} ca -config ${SSLCONF} -out ${CERTDIR}/${CERTFILE} -infiles ${REQUESTDIR}/${REQUESTFILE}
fi

# Copy key/cert to webdir
[[ ! -e $WWW_SSL_DIR ]] && mkdir $WWW_SSL_DIR && chown apache:apache $WWW_SSL_DIR

cp ${KEYDIR}/${KEYFILE} ${CERTDIR}/${CERTFILE} $WWW_SSL_DIR
