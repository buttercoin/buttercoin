module.exports = class Order
  constructor: (@account, @offered_currency, @offered_amount, @received_currency, @received_amount) ->
    @price = @offered_amount / @received_amount
