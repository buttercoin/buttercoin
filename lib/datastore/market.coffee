
module.exports = class Market
  constructor: (@left_currency, @right_currency) ->
    @left_book = new Book()
    @right_book = new Book()

  add_order: (account, offered_currency, offered_amount, received_amount) =>
    book = null
    if offered_currency == @left_currency
      book = @right_book
      other_book = @left_book
    else
      book = @left_book
      other_book = @right_book

    # check against other book

    other_book.orders_filled_by( offered )

    # put in book

    @book.insert( @offered_currency )

    # we check for overlap