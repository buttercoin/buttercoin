Market = require('../../lib/datastore/market')
Book = require('../../lib/datastore/book')
Order = require('../../lib/datastore/order')

# TODO, ISSUE, HACK - don't monkey patch Number!
Number::leq = (y) -> @ <= y

describe 'Market', ->
  bob = {name: 'bob'}
  sue = {name: 'sue'}
  jen = {name: 'jen'}

  beforeEach ->
    @market = new Market('BTC', 'USD')

  it 'should initialize with a buy book and a sell book', ->
    @market.left_book.should.be.an.instanceOf(Book)
    @market.right_book.should.be.an.instanceOf(Book)

  it 'should add an order to the correct book', ->
    @market.right_book.add_order = sinon.spy()
    @market.left_book.add_order = sinon.spy()

    order1 = new Order(@bob, 'BTC', 1, 'USD', 10)
    order2 = new Order(@sue, 'USD', 1, 'BTC', 10)

    @market.add_order(order1)
    @market.right_book.add_order.should.have.been.calledOnce
    @market.left_book.add_order.should.not.have.been.called

    @market.add_order(order2)
    @market.left_book.add_order.should.have.been.calledOnce

  it 'should close an order if there is a full match', ->
    order1 = new Order(@bob, 'BTC', 1, 'USD', 10)
    order2 = new Order(@sue, 'USD', 10, 'BTC', 1)
    
    @market.add_order(order1)
    results = @market.add_order(order2)
    results.should.have.length(2)
    closed = results.shift()
    closed.kind.should.equal('order_filled')

    filled = results.shift()
    filled.kind.should.equal('order_filled')


  it 'should close an order if there are multiple partial matches', ->
    @market.add_order sellBTC(jen, 1, 10)
    @market.add_order sellBTC(sue, 1, 10)
    results = @market.add_order buyBTC(bob, 2, 20)
    results.should.have.length(3)
    
    closed = results.shift()
    closed.should.succeed_with('order_filled')
    closed = results.shift()
    closed.should.succeed_with('order_filled')
    closed = results.shift()
    closed.should.succeed_with('order_filled')

  it 'should open a partial order if demand remains after closing out other orders', ->
    #@market.add_order sellBTC(sue, 1, 15)
    @market.add_order sellBTC(jen, 1, 10)
    @market.add_order sellBTC(sue, 1, 10)
    @market.add_order sellBTC(jen, 1, 15)
    results = @market.add_order buyBTC(bob, 3, 30)

    results.should.have.length(4)

    closed = results.shift()
    closed.should.succeed_with('order_filled')
    closed = results.shift()
    closed.should.succeed_with('order_filled')
    opened = results.shift()
    opened.should.succeed_with('order_opened')
    partial = results.shift()
    partial.should.succeed_with('order_partially_filled')

  xit 'should do the right thing', ->
    bob = {name: 'bob'}
    sue = {name: 'sue'}
    jen = {name: 'jen'}

    ###console.log "\n*** Even matching"
    console.log "bob -> buy 1 BTC @ 10 USD"
    logResults @market.add_order(buyBTC(bob, 1, 10))
    console.log "sue -> buy 1 BTC @ 9 USD"
    logResults @market.add_order(buyBTC(sue, 1, 9))
    console.log "sue -> sell 1 BTC @ 10 USD"
    logResults @market.add_order(sellBTC(sue, 1, 10))
    console.log "bob -> sell 1 BTC @ 9 USD"
    logResults @market.add_order(sellBTC(bob, 1, 9))


    console.log "\n*** Progressive closing"
    console.log "bob -> sell 2 BTC @ 11 USD"
    logResults @market.add_order(sellBTC(bob, 2, 22))
    console.log "sue -> buy 1 BTC @ 11 USD"
    logResults @market.add_order(buyBTC(sue, 1, 11))
    console.log "sue -> buy 1 BTC @ 11 USD"
    logResults @market.add_order(buyBTC(sue, 1, 11))

    console.log "\n*** Multiple closing"
    console.log "jen -> sell 1 BTC @ 10 USD"
    logResults @market.add_order(sellBTC(jen, 1, 10))
    console.log "bob -> sell 1 BTC @ 10 USD"
    logResults @market.add_order(sellBTC(bob, 1, 10))
    console.log "sue -> sell 2 BTC @ 10 USD"
    logResults @market.add_order(buyBTC(sue, 2, 20))
    ###

    console.log "\n*** Overlapped Unequal Orders"
    console.log "bob -> sell 2 BTC @ 11 USD"
    logResults @market.add_order(sellBTC(bob, 2, 22))
    console.log "sue -> buy 1 BTC @ 11 USD"
    logResults @market.add_order(buyBTC(sue, 1, 11))
    console.log "sue -> buy 1 BTC @ 12 USD"
    logResults @market.add_order(buyBTC(sue, 1, 12))

