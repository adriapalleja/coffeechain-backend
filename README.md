# Coffeechain

## What is it?

TODO

Connecting specialty coffee producers and coffee shops in a decentralized app

To create a decentralised market place for coffee by providing a trustless system via blockchain. To connect coffee shop owners and coffee producers all around the world. To remove intermediaries between them and support fair trade. To learn blockchain, to code, to have fun.

## Tech Stack

Blockchain:
* [EOS](https://eos.io/)

Back-end:
* [Koa](https://koajs.com/)
* [MySQL](https://www.mysql.com/)
* [Sequelize](http://docs.sequelizejs.com/)
* [Redis](https://redis.io/)
* [Demux](https://github.com/EOSIO/demux-js)
* [Stripe](https://stripe.com/)

Front-end:
* [React](https://reactjs.org/)
* [Redux](https://redux.js.org/)
* [Emotion](https://emotion.sh/)
* [Mapbox](https://www.mapbox.com/)
* [Stripe](https://stripe.com/)

## How does it work?

<p align="center">
  <img style="max-width:600px;" src="./docs/diagram.png" />
</p>

TODO

## Screenshots and details

<p align="center">
  <img style="max-width:600px;" src="./docs/add-coffee.png" />
</p>

---

<p align="center">
  <img style="max-width:600px;" src="./docs/coffee-shops.png" />
</p>

---

<p align="center">
  <img style="max-width:600px;" src="./docs/coffees.png" />
</p>

---

<p align="center">
  <img style="max-width:600px;" src="./docs/my-orders.png" />
</p>

TODO

## Getting started

### Prerequisites

* Either **Ubuntu 18.04** or **MacOS Darwin** or higher. Other operating systems will **not** work, sorry.
* [Docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/)
* [Node.js](https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions)
* You will also need the [Coffeechain client](https://github.com/chinins/coffee-chain-frontend) if you want any sort of useful interaction with the application.

### Run the dApp

With default settings, the dApp, eosio, redis and MySQL will occupy the ports 3306, 4000, 5555, 6379 and 7777. Make sure nothing else is running on these ports or change them when creating the `.env` file.

1. First, clone the repository and create a `.env` file as shown in `.env.example`:
```shell
git clone https://github.com/leonhfr/coffee-blockchain-backend
cd coffee-blockchain-backend
cp .env.example .env
# Atom or your favorite editor:
atom .env
# Adjust variables.
# Save the file.
```
2. Then, run the script `blockchain.sh`: `sh blockchain.sh`

The above script will:
* Check that you have Docker and Node.js installed
* Install backend dependencies (`npm install`)
* Pull a redis image and start it
* Pull a MySQL image and start it
* Pull an eosio/eos image and start it
* Start a private EOS blockchain and configure it
* Deploy the `beancoin` smart contract
* Populate the database and the blockchain with mock data
* Start the backend API server (`npm start`)

### Troubleshooting
* Docker needs to be able to run [without `sudo`](https://docs.docker.com/install/linux/linux-postinstall/).
* You may need to make the scripts executable. Run this command from the `coffee-blockchain-backend` directory:
```sh
chmod +x blockchain.sh \
  ./blockchain/scripts/redis.sh \
  ./blockchain/scripts/mysql.sh \
  ./blockchain/scripts/eosio.config.sh \
  ./blockchain/scripts/eosio.data.sh \
  ./blockchain/scripts/eosio.start.sh
```

### Stop the dApp

In the terminal, press `ctrl+c` on your keyboard. Then run: `sh blockchain.sh stop`

You can check with `docker ps` whether some containers are still running.

### Useful stuff

The backend and the frontend are already configured to interact with the blockchain. However, should you wish to interact with it directly, the easiest way is to alias the `docker exec` command to avoid having to enter the Docker containers' bashes every time.

```shell
# For MySQL:
alias sqlcoffee='docker exec -it mysql_coffeechain mysql -u root --password=[your DB_PASS from .env]'
# For the eosis/eos image:
alias cleos='docker exec -it eosio_coffeechain /opt/eosio/bin/cleos --url http://127.0.0.1:7777 --wallet-url http://127.0.0.1:5555'
```

Please note that the aliases will only be valid within your current terminal. To save them permanently add them to your `~/.bash_profile`.

For interacting with **cleos**, the `blockchain.sh` script saves the password of the `eosiomain` and `beancoin` wallets to the folder `/blockchain/data`, you may need them to unlock the wallets. You should also take a look at the mock keys in `/blockchain/scripts/mock.data.user.json`.

## Future features

* Authentication using [Scatter](https://get-scatter.com/)
* Payments via a decentralized network like [EOS](https://eos.io/) or [Stellar](https://www.stellar.org/)
* Shipping
* Reviews
* messaging

## Authors

* Olga Chinina - [Github](https://github.com/chinins)
* Marco Galizzi - [Github](https://github.com/Tezenn) - [LinkedIn](https://www.linkedin.com/in/marco-galizzi-8084a5173/)
* Léon Hollender - [Github](https://github.com/leonhfr) - [LinkedIn](https://www.linkedin.com/in/leonhollender/)
* Adria Palleja - [Github](https://github.com/adriapalleja) - [LinkedIn](https://www.linkedin.com/in/adri%C3%A0-pallej%C3%A0-3876a186/)
* Nathalia Rus - [Github](https://github.com/nathaliarus)
