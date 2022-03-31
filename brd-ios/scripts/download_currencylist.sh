#!/bin/bash
# Downlaods the latest currencies list to be embedded

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/../.env"

filename="currencies.json"
host="${API_URL}/blocksatoshi/"
echo "Downloading ${filename} from ${host}..."
curl -H "Authorization: bread ${BREAD_TOKEN}" --silent --show-error --output "$SCRIPT_DIR/../breadwallet/Resources/${filename}" https://${host}/currencies
