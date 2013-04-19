module.exports = class Order
  constructor: (@account, @offered_currency, @offered_amount, @received_currency, @received_amount) ->
    @price = @offered_amount / @received_amount

  clone: (reversed=false) =>
    new Order(
      @account,
      if reversed then @received_currency else @offered_currency,
      if reversed then @received_amount   else @offered_amount,
      if reversed then @offered_currency  else @received_currency,
      if reversed then @offered_amount    else @received_amount)

  split: (amount) ->
    # TODO - use amount type
    r_amount = (@received_amount/@offered_amount)*amount

    filled = new Order(
      @account,
      @offered_currency, amount,
      @received_currency, r_amount)

    remaining = new Order(
      @account,
      @offered_currency, @offered_amount - amount,
      @received_currency, @received_amount - r_amount)

    return [filled, remaining]
