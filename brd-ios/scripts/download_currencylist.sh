#!/bin/bash
# Downlaods the latest currencies list to be embedded
source .env
filename="currencies.json"
host="stage2.breadwallet.com"
echo "Downloading ${filename} from ${host}..."
curl -H "Authorization: Bearer ${API_TOKEN}" --silent --show-error --output "breadwallet/Resources/${filename}" https://${host}/currencies
