Book = require('../../lib/datastore/book')
Order = require('../../lib/datastore/order')

sellBTC = (args...) ->
  order = global.sellBTC(args...)
  order.price = 1/order.price
  return order

describe 'Book', ->
  beforeEach ->
    @book = new Book()
    @account1 = {name: "acct1"}
    @account2 = {name: "acct2"}

  it 'should be able to add an order', ->
    order = buyBTC(@account1, 1, 10)
    @book.store.is_empty().should.be.true
    result = @book.add_order(order)
    @book.store.is_empty().should.be.false

    expect(result).to.exist
    result.should.succeed_with('order_opened')
    result.order.should.equal(order)

  it 'should be able to open a higher order', ->
    @book.add_order buyBTC(@account1, 2, 20)
    result = @book.add_order buyBTC(@account1, 1, 11)
    result.should.succeed_with('order_opened')

    expectedBTC = [2, 1]
    expectedUSD = [20, 11]
    expectedLevels = [10, 11]
    # TODO sizes and prices should be inverse of one another?
    expectedSizes = [20, 11]
    @book.store.forEach (order_level, price) ->
      price.should.equal expectedLevels.shift()
      order_level.size.should.equal expectedSizes.shift()

      until order_level.orders.isEmpty()
        order = order_level.orders.shift()
        order.received_amount.should.equal expectedBTC.shift()
        order.offered_amount.should.equal expectedUSD.shift()

  it 'should be able to open a lower order', ->
    @book.add_order buyBTC(@account1, 2, 20)
    result = @book.add_order buyBTC(@account1, 1, 9)
    result.should.succeed_with('order_opened')

    expectedLevels = [9, 10]
    expectedSizes = [9, 20]
    @book.store.forEach (order_level, price) ->
      price.should.equal expectedLevels.shift()
      order_level.size.should.equal expectedSizes.shift()

  it 'should preserve the order in which orders are received', ->
    @book.add_order(sellBTC(@account1, 1, 10))
    @book.add_order(sellBTC(@account2, 1, 10))
    results = @book.fill_orders_with(buyBTC({name: 'acct3'}, 1, 10))
    results.should.have.length(2)

    sold = results.shift()
    sold.should.succeed_with('order_filled')
    sold.order.account.should.equal(@account1)

  it 'should be able to match an order', ->
    @book.add_order(sellBTC(@account1, 1, 10))
    results = @book.fill_orders_with(buyBTC(@account2, 1, 10))
    @book.store.is_empty().should.be.true
    
    results.should.have.length(2)
    sold = results.shift()
    sold.should.succeed_with('order_filled')
    sold.order.account.should.equal(@account1)

    bought = results.shift()
    bought.should.succeed_with('order_filled')
    bought.order.account.should.equal(@account2)

  it 'should be able to partially close an open order', ->
    @book.add_order(sellBTC(@account1, 2, 2))
    results = @book.fill_orders_with(buyBTC(@account2, 1, 1))
    @book.store.is_empty().should.be.false
    results.should.have.length(2)

    bought = results.shift()
    bought.should.succeed_with('order_partially_filled')
    bought.original_order.account.should.equal(@account1)
    bought.filled_order.account.should.equal(@account1)
    bought.residual_order.account.should.equal(@account1)

    sold = results.shift()
    sold.should.succeed_with('order_filled')
    sold.order.account.should.equal(@account2)

    # TODO - move sum checks to spec for Order.split
    sum = bought.filled_order.offered_amount + bought.residual_order.offered_amount
    sum.should.equal(bought.original_order.offered_amount)

    sum = bought.filled_order.received_amount + bought.residual_order.received_amount
    sum.should.equal(bought.original_order.received_amount)

    @book.fill_orders_with(buyBTC(@account2, 1, 1))
    @book.store.is_empty().should.be.true

  it 'should be able to partially fill a new order', ->
    # TODO - sell must always be first!
    @book.add_order(buyBTC(@account1, 1, 1))
    results = @book.fill_orders_with(sellBTC(@account2, 3, 3))
    results.should.have.length(2)
    filled = results.shift()
    filled.should.succeed_with('order_filled')
    filled.order.account.should.equal(@account1)

    partial = results.shift()
    partial.should.succeed_with('order_partially_filled')
    partial.original_order.account.should.equal(@account2)
    partial.filled_order.account.should.equal(@account2)
    partial.residual_order.account.should.equal(@account2)

  it 'should indicate that there are not matches when orders don\'t overlap', ->
    @book.add_order(sellBTC(@account1, 1, 40))
    result = @book.fill_orders_with(buyBTC(@account2, 1, 20))
    result.should.have.length(1)
    result = result.shift()
    result.should.succeed_with('not_filled')
    result.residual_order.account.should.equal(@account2)

  it 'should report the correct closing price when closing a mismatched order', ->
    order1 = sellBTC(@account1, 1, 10)
    @book.add_order(order1)
    results = @book.fill_orders_with(buyBTC(@account2, 1, 11))
    results.should.have.length(2)
    original = results.shift()
    original.should.succeed_with('order_filled')
    original.order.account.should.equal(@account1)
    original.order.price.should.equal(order1.price)
    
    filling = results.shift()
    filling.should.succeed_with('order_filled')
    filling.order.account.should.equal(@account2)
    filling.order.price.should.equal(order1.price)


  it 'should partially fill across price levels and provide a correct residual order', ->
    @book.add_order(sellBTC(@account1, 1, 11))
    @book.add_order(sellBTC(@account1, 1, 12))
    @book.add_order(sellBTC(@account1, 1, 13))

    buy_amt = 4
    buy_price = 14
    offered_amt = buy_price * buy_amt
    results = @book.fill_orders_with(buyBTC(@account2, buy_amt, offered_amt))
    results.length.should.equal(4)

    closed = results.shift()
    closed.should.succeed_with('order_filled')
    closed.order.price.should.equal(11)

    closed = results.shift()
    closed.should.succeed_with('order_filled')
    closed.order.price.should.equal(12)

    closed = results.shift()
    closed.should.succeed_with('order_filled')
    closed.order.price.should.equal(13)

    partial = results.shift()
    partial.should.succeed_with('order_partially_filled')
    partial.filled_order.price.should.equal(12)
    partial.filled_order.received_amount.should.equal(3)
    partial.filled_order.offered_amount.should.equal(12*3)

    partial.residual_order.price.should.equal(1/buy_price)
    partial.residual_order.received_amount.should.equal(1)
    partial.residual_order.offered_amount.should.equal(1/buy_price)

  xit 'should handle random orders and end up in a good state', ->
    # TODO - write a 'canonical' simulation for the book, throw random data at both, verify
    
