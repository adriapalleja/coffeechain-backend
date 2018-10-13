#include "beancoin.hpp"

namespace CoffeeBlockchain {

  // PUBLIC METHODS

  void Beancoin::notify(
    account_name user,
    string message
  ) {
    require_auth(get_self());
    require_recipient(user);
  }

  // USER

  void Beancoin::upsertuser(
    account_name user,
    string role,
    string hash
  ) {
    require_auth(user); // ONLY THE USER CAN REGISTER OR MODIFY ITSELF
    user_index users(_self, _self);
    auto iterator = users.find(user);
    if (iterator == users.end()) {
      users.emplace(user, [&](auto& row) {
        row.username = user;
        row.role = role;
        row.hash = hash;
      });
      print("Inserted user(", role.c_str(), ") ", user, " of hash: '", hash.c_str(), "'.");
    } else {
      users.modify(iterator, user, [&](auto& row) {
        row.username = user;
        row.role = role;
        row.hash = hash;
      });
      print("Updated user(", role.c_str(), ") ", user, " of hash: '", hash.c_str(), "'.");
    }
  }

  void Beancoin::deluser(
    account_name user
  ) {
    require_auth(user); // ONLY THE USER CAN DELETE ITSELF
    user_index users(_self, _self);
    auto iterator = users.find(user);
    // THROW AN ERROR IF THE USER IS NOT REGISTERED
    eosio_assert(iterator != users.end(), "User does not exist.");
    users.erase(iterator);
    print("Deleted user ", user, ".");
  }

  void Beancoin::getuser(
    account_name user
  ) {
    // EVERYONE CAN QUERY THE BLOCKCHAIN TO CHECK THE HASHES
    user_index users(_self, _self);
    auto iterator = users.find(user);
    // THROW AN ERROR IF THE USER IS NOT REGISTERED
    eosio_assert(iterator != users.end(), "User does not exist.");
    auto queriedUser = users.get(user);
    // TODO: user data
    string message = "User role: '" + queriedUser.role +
      "' | User hash: '" + queriedUser.hash + "'";
    send_data(user, message);
  }

  // COFFEE

  void Beancoin::upsertcoffee(
    account_name owner,
    uint64_t uuid,
    string hash,
    int64_t price,
    int64_t quantity
  ) {
    require_auth(owner); // ONLY THE OWNER CAN ADD COFFEE TO SALE
    coffee_index coffees(_self, _self);
    auto iterator = coffees.find(uuid);
    if (iterator == coffees.end()) {
      coffees.emplace(owner, [&](auto& row) {
        row.uuid = uuid;
        row.owner = owner;
        row.hash = hash;
        row.price = price;
        row.quantity = quantity;
      });
      print(
        "Inserted coffee | Owner: ", owner,
        " | uuid: ", uuid,
        " | hash: ", hash.c_str(),
        " | price: ", price,
        " | quantity: ", quantity
      );
    } else {
      auto queriedCoffee = coffees.get(uuid);
      if (queriedCoffee.owner == owner) {
        coffees.modify(iterator, owner, [&](auto& row) {
          row.uuid = uuid;
          row.owner = owner;
          row.hash = hash;
          row.price = price;
          row.quantity = quantity;
        });
        print(
          "Updated coffee | Owner: ", owner,
          " | uuid: ", uuid,
          " | hash: ", hash.c_str(),
          " | price: ", price,
          " | quantity: ", quantity
        );
      } else {
        print("Unauthorized coffee upsert prevented.");
      }
    }
  }

  void Beancoin::delcoffee(
    account_name owner,
    uint64_t uuid
  ) {
    // TODO: delete coffee
    print(
      "Delete coffee | Owner: ", owner,
      " | uuid: ", uuid
    );
  }

  void Beancoin::getcoffee(
    account_name owner,
    uint64_t uuid
  ) {
    // TODO: get coffee hash
    print(
      "Get coffee | Owner: ", owner,
      " | uuid: ", uuid
    );
  }

  // SALE

  void Beancoin::requestsale(
    uint64_t uuid,
    uint64_t uuid_coffee,
    account_name seller,
    account_name buyer,
    uint64_t quantity
  ) {
    // TODO request sale
    print("requestsale");
  }

  void Beancoin::getsale(
    uint64_t uuid
  ) {
    // TODO: get sale hash
    print("getsale");
  }

  void Beancoin::fulfillsale(
    uint64_t uuid
  ) {
    // TODO: fulfill sale
    print("fulfillsale");
  }

  // PRIVATE METHODS

  void Beancoin::send_data(
    account_name user,
    string data
  ) {
    action(
      permission_level{get_self(), N(active)},
      get_self(),
      N(notify),
      std::make_tuple(user, name{user}.to_string() + " " + data)
    ).send();
  }
}
