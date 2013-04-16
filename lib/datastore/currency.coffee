Amount = require('./amount')

module.exports = class Currency
  constructor: ->
    @balance = new Amount()

  increase_balance: (amount) =>
    @balance = @balance.add(amount)

  get_balance: =>
    return @balance
