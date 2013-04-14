BigDecimal = require('bigdecimal').BigDecimal

module.exports = class Currency
  constructor: ->
    @balance = new BigDecimal('0')

  get_balance: =>
    return @balance

  increase_balance: (amount) =>
    @balance = @balance.add(amount)

