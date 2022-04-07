#!/bin/bash

show_usage() {
	echo
	echo "Usage: ${0##/*} [version] [build]"
	echo "       ${0##/*} <version> <build> ci"
	echo
	echo "To make a ci build specify both version and build followed by 'ci'."
	echo
	exit
}

# main

# show usage if '-h' or  '--help' is the first argument
case $1 in
	"-h"|"--help") show_usage ;;
esac

# exit when any command fails
set -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$3" == "ci" ]; then
	scheme="breadwallet"
else
	scheme="BRD Internal - TestFlight"
fi


echo
echo "Restore build updated files"
echo
git restore breadwallet/Resources/currencies.json
git restore breadwallet/Info.plist
git restore breadwalletWidget/Info.plist
git restore breadwalletIntentHandler/Info.plist

echo
echo "Set versioning"
echo
agvtool new-marketing-version $1
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

agvtool new-version $2
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo
echo "Download currencies"
echo

if [ ! -f ../.env ]; then
	echo ".env file not found or configured properlly."
	exit 1
fi

source ../.env
host="$API_URL/blocksatoshi"
json=$(curl -k -v -X POST -H 'Content-type: application/json' -d '{"deviceID": "b21f2253-51e1-4346-92b0-e32323733067", "pubKey": "rCxDp6qD8uGqK2Z3UgeQ5bvTCZegqGfVexyz5XkbvwfW"}'  https://${host}/wallet/token)

source ${script_dir}/download_currencylist.sh $host $token
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

echo
echo "Make $scheme version ${mainBundleShortVersionString} build ${mainBundleVersion} ..."
echo

source ${script_dir}/archive.sh "${scheme}"
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi
