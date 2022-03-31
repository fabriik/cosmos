#!/bin/bash
# Downlaods the latest app resource bundles to be embedded
API_URL=$1
BREAD_TOKEN=$2

function downloadBundle() {
    bundle_name="$1-staging"
    host="${API_URL}/wallet"
    echo AAAAA
    echo $host
    echo AAAA
    if [[ "$2" == "prod" ]]; then
        bundle_name="$1"
    fi
    echo "Downloading ${bundle_name}.tar from ${host}..."
    curl -H "Authorization: bread ${BREAD_TOKEN}" --silent --show-error --output "$SCRIPT_DIR/../breadwallet/Resources/${bundle_name}.tar" https://${host}/assets/bundles/${bundle_name}/download
}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
plistBuddy="/usr/libexec/PlistBuddy"
plist="$SCRIPT_DIR/../breadwallet/Resources/AssetBundles.plist"
bundleNames=($("${plistBuddy}" -c "print" "${plist}" | sed -e 1d -e '$d'))

for bundleName in "${bundleNames[@]}"
do
  downloadBundle ${bundleName}
  downloadBundle ${bundleName} "prod"
done
