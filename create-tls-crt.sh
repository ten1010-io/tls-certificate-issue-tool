#!/usr/bin/env bash
script_path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
output_path=$script_path/output

if [ -z $1 ]; then
  echo "Error : Domain name for tls certificate must be provided as first argument"
  exit 1
fi
if ! echo $1 | grep -P '([a-z0-9A-Z]\.)*[a-z0-9-]+\.([a-z0-9]{2,24})+(\.co\.([a-z0-9]{2,24})|\.([a-z0-9]{2,24}))*'; then
  echo "Error : Invalid domain name provided"
  exit 1
fi
mkdir -p ${output_path}/$1
if [ ! -f "$output_path/ca.crt" ]; then
  echo "Error : File [$output_path/ca.crt] not exist"
  exit 1
fi
if [ -e "${output_path}/$1/tls.crt" ]; then
  echo "Error : File [${output_path}/$1/tls.crt] already exist"
  exit 1
fi
if ! cp "${script_path}/tls.conf" "${output_path}/$1"; then
  echo "Error : Writing file failed"
  exit 1
fi
if ! cp "${script_path}/tls.ext" "${output_path}/$1"; then
  echo "Error : Writing file failed"
  exit 1
fi
if ! sed -i 's/CN =/''CN = '"$1"'/g' "${output_path}/$1/tls.conf"; then
  echo "Error : Writing file failed"
  exit 1
fi
if ! sed -i 's/DNS.1 =/''DNS.1 = '"$1"'/g' "${output_path}/$1/tls.ext"; then
  echo "Error : Writing file failed"
  exit 1
fi

openssl req -newkey rsa -config "${output_path}/$1/tls.conf" -keyout "${output_path}/$1/tls.key" -out "${output_path}/$1/tls.csr"
openssl x509 -req -CA "${output_path}/ca.crt" -CAkey "${output_path}/ca.key" -CAserial "${output_path}/.srl" -CAcreateserial -in "${output_path}/$1/tls.csr" -extfile "${output_path}/$1/tls.ext" -out "${output_path}/$1/tls.crt" -days 365
