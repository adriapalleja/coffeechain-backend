#!/usr/bin/env bash
set -o errexit

# store the contracts directory absolute path to mount it in docker
directory="$(pwd -P)/blockchain/contracts"

# forward ports 7777 and 5555 to the host (your) machine
# alias a work volume on your local drive to the docker container
# run the nodeos (blockchain node) startup in bash
# keosd = wallet manager
# nodeos = blockchain node
# !!! CORS is enabled for * for developement purposes only
docker run --rm --name eosio_coffeechain \
  --detach \
  --publish $EOSIO_NETWORK_PORT:$EOSIO_NETWORK_PORT \
  --publish 127.0.0.1:$EOSIO_WALLET_PORT:$EOSIO_WALLET_PORT \
  --volume "$directory:$directory" \
  eosio/eos:v1.3.2 \
  /bin/bash -c \
  "keosd --http-server-address=0.0.0.0:$EOSIO_WALLET_PORT & exec \
  nodeos -e -p eosio \
    --plugin eosio::producer_plugin \
    --plugin eosio::history_plugin \
    --plugin eosio::chain_api_plugin \
    --plugin eosio::history_api_plugin \
    --plugin eosio::http_plugin \
    -d /mnt/dev/data \
    --config-dir /mnt/dev/config \
    --http-server-address=0.0.0.0:$EOSIO_NETWORK_PORT \
    --access-control-allow-origin=* \
    --http-validate-host=false \
    --contracts-console \
    --filter-on='*'"

# sleep for 2 seconds to allow time to create some blocks
sleep 2s

# checking block production
echo ""
echo "+ you should see some blocks produced:"
docker logs --tail 3 eosio_coffeechain
echo -e "\033[0;35m+ nodeos is producing blocks!\033[0m"

# checking that the server is running and answering
echo ""
echo "+ you should see a JSON response with some info on the blockchain"
curl http://$EOSIO_NETWORK_HOST:$EOSIO_NETWORK_PORT/v1/chain/get_info
echo ""
echo -e "\033[0;35m+ nodeos is answering correctly!\033[0m"

echo ""
echo -e "\033[0;34m+++ /!\ The blockchain has started! /!\ +++\033[0m"

# aliasing cleos to shorten future command lines
# cleos = eos cli
shopt -s expand_aliases
alias cleos="docker exec -i eosio_coffeechain /opt/eosio/bin/cleos \
  --url http://127.0.0.1:$EOSIO_NETWORK_PORT --wallet-url http://127.0.0.1:$EOSIO_WALLET_PORT"

# create a clean data directory to store temporary data and set it as working directory
rm -rf "$(pwd -P)/blockchain/data"
mkdir "$(pwd -P)/blockchain/data"
cd "$(pwd -P)/blockchain/data"

echo ""
echo -e "\033[0;35m+ setup wallet eosiomain\033[0m"
echo -e "\033[0;35m+ this would not be needed to connect to the real EOS network, it is for test purposes only\033[0m"
# create default wallet and save password to file
cleos wallet create -n eosiomain --to-console | tail -1 | \
  sed -e 's/^"//' -e 's/"$//' > eosiomain_wallet_password.txt
# import the eos provided private key for eosio system account into default wallet
cleos wallet import -n eosiomain --private-key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3

echo ""
echo -e "\033[0;35m+ setup wallet beancoin\033[0m"
# wallet for beancoin and export the generated password to a file for unlocking wallet later
cleos wallet create -n beancoin --to-console | tail -1 | \
  sed -e 's/^"//' -e 's/"$//' > beancoin_wallet_password.txt
# create account for beancoin with above wallet's public keys
cleos create account eosio beancoin EOS6PUh9rs7eddJNzqgqDx1QrspSHLRxLMcRdwHZZRL4tpbtvia5B \
  EOS8BCgapgYA2L4LJfCzekzeSr3rzgSTUXRXwNi8bNRoz31D14en9
# Owner key
cleos wallet import -n beancoin \
--private-key 5JpWT4ehouB2FF9aCfdfnZ5AwbQbTtHBAwebRXt94FmjyhXwL4K
# Active key
cleos wallet import -n beancoin \
--private-key 5JD9AGTuTeD5BXZwGQ5AtwBqHK21aHmYnTetHgk1B3pjj7krT8N

echo ""
echo -e "\033[0;35m+ deploy the smart contract\033[0m"
echo "Note: it is normal to see an error 'Wallet already unlocked'"
# unlocking beancoin's wallet, ignore the error if it's alreday unlocked
#
cleos wallet unlock -n beancoin --password $(cat ./beancoin_wallet_password.txt) || true
# the contract is already compiled, we just need to deploy it using beancoin's active key
cd ..
cleos set contract beancoin "$(pwd -P)/contracts/beancoin/" -p beancoin@active

echo ""
echo -e "\033[0;35m+ downloading jq (json reader) to create mock data\033[0m"
cd "$(pwd -P)/scripts"
mkdir -p ~/bin && curl -sSL -o ~/bin/jq \
  https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && \
  chmod +x ~/bin/jq && export PATH=$PATH:~/bin

echo ""
echo -e "\033[0;35m+ create mock accounts and register them\033[0m"
jq -c '.[]' mock.data.user.json | while read i; do
  name=$(jq -r '.name' <<< "$i")
  pubkey=$(jq -r '.publicKey' <<< "$i")
  privkey=$(jq -r '.privateKey' <<< "$i")
  role=$(jq -r '.role' <<< "$i")
  hash=$(jq -r '.hash' <<< "$i")

  docker exec -t eosio_coffeechain /opt/eosio/bin/cleos \
    --url http://127.0.0.1:$EOSIO_NETWORK_PORT \
    --wallet-url http://127.0.0.1:$EOSIO_WALLET_PORT \
    create account eosio $name $pubkey $pubkey

  docker exec -t eosio_coffeechain /opt/eosio/bin/cleos \
    --url http://127.0.0.1:$EOSIO_NETWORK_PORT \
    --wallet-url http://127.0.0.1:$EOSIO_WALLET_PORT \
    wallet import -n beancoin --private-key $privkey

  docker exec -t eosio_coffeechain /opt/eosio/bin/cleos \
    --url http://127.0.0.1:$EOSIO_NETWORK_PORT \
    --wallet-url http://127.0.0.1:$EOSIO_WALLET_PORT \
    push action beancoin upsertuser \
    "[ "\""$name"\"", "\""$role"\"", "\""$hash"\"" ]" \
    -p $name@active
done

echo ""
echo -e "\033[0;35m+ create mock coffees\033[0m"
jq -c '.[]' mock.data.coffee.json | while read i; do
  name=$(jq -r '.name' <<< "$i")
  uuid=$(jq -r '.id' <<< "$i")
  hash=$(jq -r '.hash' <<< "$i")
  price=$(jq -r '.price' <<< "$i")
  quantity=$(jq -r '.quantity' <<< "$i")

  docker exec -t eosio_coffeechain /opt/eosio/bin/cleos \
    --url http://127.0.0.1:$EOSIO_NETWORK_PORT \
    --wallet-url http://127.0.0.1:$EOSIO_WALLET_PORT \
    push action beancoin upsertcoffee \
    "[ "\""$name"\"", $uuid, "\""$hash"\"", $price, $quantity ]" \
    -p $name@active
done
