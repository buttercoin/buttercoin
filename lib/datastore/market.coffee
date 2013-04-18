Order = require('./order')

module.exports = class Market
  constructor: (@left_currency, @right_currency) ->
    @left_book = new Book()
    @right_book = new Book()

  add_order: (order) =>
    book = null
    if order.offered_currency == @left_currency
      book = @right_book
      other_book = @left_book
    else
      book = @left_book
      other_book = @right_book

    # check against other book

    result = other_book.orders_filled_by( order )

    unless result.kind == 'filled'
      # put in book
      book.add_order( result.residual_order )

    return result
