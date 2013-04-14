module.exports = class Currency
  constructor: ->
    @balance = 0

  get_balance: =>
    return @balance

  increase_balance: (amount) =>
    @balance += amount

