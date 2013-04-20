Book = require('../../lib/datastore/book')
Order = require('../../lib/datastore/order')


buyBTC = (acct, numBtc, numDollars) ->
  new Order(acct, 'USD', numDollars, 'BTC', numBtc)

sellBTC = (acct, numBtc, numDollars) ->
  new Order(acct, 'BTC', numBtc, 'USD', numDollars)

# TODO, ISSUE, HACK - don't monkey patch Number!
Number::leq = (y) -> @ <= y

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
    result.status.should.equal('success')
    result.kind.should.equal('order_opened')
    result.order.should.equal(order)

  it 'should be able to open a higher order', ->
    @book.add_order buyBTC(@account1, 2, 20)
    result = @book.add_order buyBTC(@account1, 1, 11)
    result.status.should.equal('success')
    result.kind.should.equal('order_opened')

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
    result.status.should.equal('success')
    result.kind.should.equal('order_opened')

    expectedLevels = [9, 10]
    expectedSizes = [9, 20]
    @book.store.forEach (order_level, price) ->
      price.should.equal expectedLevels.shift()
      order_level.size.should.equal expectedSizes.shift()

  xit 'should preserve the order in which orders are received'

  it 'should be able to match an order', ->
    @book.add_order(sellBTC(@account1, 1, 10))
    results = @book.fill_orders_with(buyBTC(@account2, 1, 10))
    @book.store.is_empty().should.be.true
    
    results.should.have.length(2)
    sold = results.shift()
    sold.status.should.equal('success')
    sold.kind.should.equal('order_filled')
    sold.order.account.should.equal(@account1)

    bought = results.shift()
    bought.status.should.equal('success')
    bought.kind.should.equal('order_filled')
    bought.order.account.should.equal(@account2)

  it 'should be able to partially close an open order', ->
    @book.add_order(sellBTC(@account1, 2, 2))
    results = @book.fill_orders_with(buyBTC(@account2, 1, 1))
    @book.store.is_empty().should.be.false
    results.should.have.length(2)

    bought = results.shift()
    bought.status.should.equal('success')
    bought.kind.should.equal('order_partially_filled')
    bought.original_order.account.should.equal(@account1)
    bought.filled_order.account.should.equal(@account1)
    bought.residual_order.account.should.equal(@account1)

    sold = results.shift()
    sold.status.should.equal('success')
    sold.kind.should.equal('order_filled')
    sold.order.account.should.equal(@account2)

    # TODO - move sum checks to spec for Order.split
    sum = bought.filled_order.offered_amount + bought.residual_order.offered_amount
    sum.should.equal(bought.original_order.offered_amount)

    sum = bought.filled_order.received_amount + bought.residual_order.received_amount
    sum.should.equal(bought.original_order.received_amount)

    @book.fill_orders_with(buyBTC(@account2, 1, 1))
    @book.store.is_empty().should.be.true

  it 'should be able to partially fill a new order', ->
    @book.add_order(buyBTC(@account1, 1, 1))
    results = @book.fill_orders_with(sellBTC(@account2, 3, 3).clone(true))
    results.should.have.length(2)
    filled = results.shift()
    filled.status.should.equal('success')
    filled.kind.should.equal('order_filled')
    filled.order.account.should.equal(@account1)

    partial = results.shift()
    partial.status.should.equal('success')
    partial.kind.should.equal('order_partially_filled')
    partial.original_order.account.should.equal(@account2)
    partial.filled_order.account.should.equal(@account2)
    partial.residual_order.account.should.equal(@account2)

  it 'should indicate that there are not matches when orders don\'t overlap', ->
    @book.add_order(buyBTC(@account1, 1, 20))
    result = @book.fill_orders_with(sellBTC(@account2, 1, 40).clone(true))
    #result.should.have.length(1)
    result = result.shift()
    result.status.should.equal('success')
    result.kind.should.equal('not_filled')
    result.residual_order.account.should.equal(@account2)
