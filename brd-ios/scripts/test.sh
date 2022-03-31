SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source "$SCRIPT_DIR/../.env"

host="$API_URL/blocksatoshi"
json=$(curl -k -v -X POST -H 'Content-type: application/json' -d '{"deviceID": "b21f2253-51e1-4346-92b0-e32323733067", "pubKey": "rCxDp6qD8uGqK2Z3UgeQ5bvTCZegqGfVexyz5XkbvwfW"}'  https://${host}/wallet/token)

token="$(echo $json | sed "s/{.*\"token\":\"\([^\"]*\).*}/\1/g"):sig"
./download_bundles.sh $host $token
./download_currencylist.sh $host $token
