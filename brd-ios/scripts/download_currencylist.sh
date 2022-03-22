#!/bin/bash
# Downlaods the latest currencies list to be embedded

filename="currencies.json"
host="${API_URL}/blocksatoshi/"
echo "Downloading ${filename} from ${host}..."
curl -H "Authorization: bread ${BREAD_TOKEN}" --silent --show-error --output "breadwallet/Resources/${filename}" https://${host}/currencies
