#!/usr/bin/env bash
script_path="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
output_path=$script_path/output

mkdir -p "$output_path"
if [ -e "$output_path/ca.crt" ]; then
  echo "Error : File [$output_path/ca.crt] already exist"
  exit 1
fi
if [ -z $1 ]; then
  echo "Error : Common name for certificate must be provided as first argument"
  exit 1
fi
if ! cp "${script_path}/ca.conf" "$output_path"; then
  echo "Error : Writing file failed"
  exit 1
fi
if ! sed -i 's/CN =/''CN = '"$1"'/g' "${output_path}/ca.conf"; then
  echo "Error : Writing file failed"
  exit 1
fi

openssl req -config "${output_path}/ca.conf" -newkey rsa -x509 -days 3650 -keyout "${output_path}/ca.key" -out "${output_path}/ca.crt" -set_serial 0
