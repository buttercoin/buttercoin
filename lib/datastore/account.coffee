Currency = require('./currency')

module.exports = class Account
  constructor: ->
    @currencies = Object.create null

  get_currency: (name) =>
    currency = @currencies[name]
    if not (currency instanceof Currency)
      @currencies[name] = currency = new Currency()
    return currency
