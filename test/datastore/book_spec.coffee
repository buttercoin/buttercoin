Book = require('../../lib/datastore/book')
Order = require('../../lib/datastore/order')


buyBTC = (acct, numBtc, numDollars) ->
  new Order(acct, 'USD', numDollars, 'BTC', numBtc)

sellBTC = (acct, numBtc, numDollars) ->
  new Order(acct, 'BTC', numBtc, 'USD', numDollars)

Number::leq = (y) -> @ <= y

describe 'Book', ->
  beforeEach ->
    @book = new Book()
    @account1 = {}
    @account2 = {}

  it 'should be able to add an order', ->
    order = buyBTC(@account1, 1, 1)
    @book.store.is_empty().should.be.true
    @book.add_order(order)
    @book.store.is_empty().should.be.false

  it 'should be able to match an order', ->
    @book.add_order(sellBTC(@account1, 1, 1))
    @book.fill_orders_with(buyBTC(@account2, 1, 1))
    @book.store.is_empty().should.be.true

  it 'should be able to partially close an order', ->
    @book.add_order(sellBTC(@account1, 2, 2))
    @book.fill_orders_with(buyBTC(@account2, 1, 1))
    @book.store.is_empty().should.be.false

    @book.fill_orders_with(buyBTC(@account2, 1, 1))
    @book.store.is_empty().should.be.true
    
