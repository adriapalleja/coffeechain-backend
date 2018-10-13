const Producer = require('../schemas/producer');
const Customer = require('../schemas/customer');
const Shipper = require('../schemas/shipper');

exports.getMe = async id => {
  let producer = await Producer.find({
    where: { id: id }
  });
  let customer = await Customer.find({
    where: { id: id }
  });
  let shipper = await Shipper.find({
    where: { id: id }
  });

  if (producer) return producer;
  if (customer) return customer;
  if (shipper) return shipper;
};

exports.updateMe = async (id, info) => {
  let updateValue = {};
  if (
    await Producer.find({
      where: { id: id }
    })
  ) {
    if (info.producer_name) updateValue.producer_name = info.producer_name;
    if (info.country) updateValue.country = info.country;
    if (info.description) updateValue.description = info.description;
    await Producer.update(updateValue, {
      returning: true,
      plain: true,
      where: { id: id }
    });
    let producer = await Producer.find({
      where: { id: id }
    });
    return producer;
  }
  if (
    await Customer.find({
      where: { id: id }
    })
  ) {
    if (info.customer_name) updateValue.customer_name = info.customer_name;
    if (info.country) updateValue.country = info.country;
    if (info.description) updateValue.description = info.description;
    if (info.geo_location) updateValue.geo_location = info.geo_location;
    console.log('update value: ', updateValue);
    await Customer.update(updateValue, {
      returning: true,
      plain: true,
      where: { id: id }
    });
    let customer = await Customer.find({
      where: { id: id }
    });
    return customer;
  }
  if (
    await Shipper.find({
      where: { id: id }
    })
  ) {
    if (info.shipper_name) updateValue.shipper_name = info.shipper_name;
    if (info.country) updateValue.country = info.country;
    if (info.description) updateValue.description = info.description;
    await Shipper.update(updateValue, {
      returning: true,
      plain: true,
      where: { id: id }
    });
    shipper = await Shipper.find({
      where: { id: id }
    });
    return shipper;
  }
};
