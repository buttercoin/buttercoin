Market = require('../../lib/datastore/market')
Book = require('../../lib/datastore/book')
Order = require('../../lib/datastore/order')

buyBTC = (acct, numBtc, numDollars) ->
  new Order(acct, 'USD', numDollars, 'BTC', numBtc)

sellBTC = (acct, numBtc, numDollars) ->
  new Order(acct, 'BTC', numBtc, 'USD', numDollars)

# TODO, ISSUE, HACK - don't monkey patch Number!
Number::leq = (y) -> @ <= y

logResults = (results) ->
  displaySold = (x) ->
    console.log "\t#{x.account.name} sold #{x.received_amount} #{x.received_currency} for #{x.offered_amount} #{x.offered_currency}"
  displayOpened = (x) ->
    console.log "\t#{x.account.name} listed #{x.received_amount} #{x.received_currency} for #{x.offered_amount} #{x.offered_currency}"
  while results.length > 0
    x = results.shift()
    if x.kind is 'order_opened' or x.kind is 'order_partially_filled'
      displayOpened(x.order || x.residual_order)
    if x.kind is 'order_filled' or x.kind is 'order_partially_filled'
      displaySold(x.order || x.filled_order)
    #displayOrder(x.

describe 'Market', ->
  beforeEach ->
    @market = new Market('BTC', 'USD')
    @account1 = {name: 'acct1'}
    @account2 = {name: 'acct2'}

  it 'should initialize with a buy book and a sell book', ->
    @market.left_book.should.be.an.instanceOf(Book)
    @market.right_book.should.be.an.instanceOf(Book)

  it 'should add an order to the correct book', ->
    @market.right_book.add_order = sinon.spy()
    @market.left_book.add_order = sinon.spy()

    order1 = new Order(@account1, 'BTC', 1, 'USD', 10)
    order2 = new Order(@account2, 'USD', 1, 'BTC', 10)

    @market.add_order(order1)
    @market.right_book.add_order.should.have.been.calledOnce
    @market.left_book.add_order.should.not.have.been.called

    @market.add_order(order2)
    @market.left_book.add_order.should.have.been.calledOnce

  it 'should close an order if there is overlap', ->
    order1 = new Order(@account1, 'BTC', 1, 'USD', 10)
    order2 = new Order(@account2, 'USD', 10, 'BTC', 1)
    
    @market.add_order(order1)
    results = @market.add_order(order2)
    results.should.have.length(2)
    closed = results.shift()
    closed.kind.should.equal('order_filled')

    filled = results.shift()
    filled.kind.should.equal('order_filled')

  it 'should do the right thing', ->
    bob = {name: 'bob'}
    sue = {name: 'sue'}

    console.log "\n*** Even matching"
    console.log "bob -> buy 1 BTC @ 10 USD"
    logResults @market.add_order(buyBTC(bob, 1, 10))
    console.log "sue -> buy 1 BTC @ 9 USD"
    logResults @market.add_order(buyBTC(sue, 1, 9))
    console.log "sue -> sell 1 BTC @ 10 USD"
    logResults @market.add_order(sellBTC(sue, 1, 10))
    console.log "bob -> sell 1 BTC @ 9 USD"
    logResults @market.add_order(sellBTC(bob, 1, 9))


    ###
    console.log "bob -> sell 2 BTC @ 11 USD"
    logResults @market.add_order(sellBTC(bob, 2, 22))
    console.log "sue -> buy 1 BTC @ 11 USD"
    logResults @market.add_order(buyBTC(sue, 1, 11))
    console.log "sue -> buy 1 BTC @ 12 USD"
    logResults @market.add_order(buyBTC(sue, 1, 12))
    ###
