#!/usr/bin/env bash

# exit shell if something fails
set -o errexit

# make sure the OS is supported
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  echo "Linux detected."
elif [[ "$OSTYPE" == "darwin"* ]]; then
  echo "MacOS detected."
else
  echo ""
  echo -e "\033[0;31mYour OS is not supported.\033[0m"
  echo ""
  exit
fi

# make sure Docker and Node.js are installed
if [ ! -x "$(command -v docker)" ] ||
   [ ! -x "$(command -v node)" ]; then
     echo ""
     echo -e "\033[0;31m[Error with Exception]\033[0m"
     echo "Make sure Docker and Node.js are installed"
     echo ""
     exit
fi

# make sure the .env file has been set up
if [ ! -f "./.env" ]
then
  echo ""
  echo -e "\033[0;31mThe .env file has not been set up!\033[0m"
  echo "Make sure to copy the contents of the .env.example to .env"
  echo ""
  exit
fi

echo "\033[0;34m+++ starting blockchain and backend +++\033[0m"

### NPM INSTALL

echo ""
echo "\033[0;34m+++ npm install for the backend app +++\033[0m"
echo ""
npm install

#### REDIS

sh -ac '. ./.env; ./blockchain/scripts/redis.sh'

### MYSQL

sh -ac '. ./.env; ./blockchain/scripts/mysql.sh'

### EOSIO/EOS

sh -ac '. ./.env; ./blockchain/scripts/eosio.start.sh'
sh -ac '. ./.env; ./blockchain/scripts/eosio.config.sh'
sh -ac '. ./.env; ./blockchain/scripts/eosio.data.sh'

### BACKEND SERVER/API

echo ""
echo "\033[0;34m+++ populating MySQL database with mock data +++\033[0m"
npm run populate
sleep 1s

echo ""
echo "\033[0;34m+++ starting backend API +++\033[0m"
echo "After this you should be able to interact with the blockchain and the backend with the frontend"
npm run dev
