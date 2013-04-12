
class BalanceSheet
  constructor: ->
    @accounts = {}

module.exports = class DataStore
  constructor: ->
    @balance_sheet = new BalanceSheet
    @order_book = 