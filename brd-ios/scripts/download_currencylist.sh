#!/bin/bash
# Downlaods the latest currencies list to be embedded

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
API_URL=$1
BREAD_TOKEN=$2
filename="currencies.json"
echo "Downloading ${filename} from ${API_URL}/wallet/currencies
curl -H "Authorization: bread ${BREAD_TOKEN}" --silent --show-error --output "$SCRIPT_DIR/../breadwallet/Resources/${filename}" https://${API_URL}/wallet/currencies"
