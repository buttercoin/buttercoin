Order = require('../../lib/datastore/order')

describe 'Order', ->
  beforeEach ->
    @account = {}
    @order = new Order({}, 'USD', 1, 'BTC', 10)

  it 'should be clonable', ->
    @order.clone.should.exist
    order2 = @order.clone()
    
    order2.account.should.equal(@order.account)
    @order.account = null
    order2.account.should.not.equal(@order.account)

    order2.offered_currency.should.equal(@order.offered_currency)
    @order.offered_currency = null
    order2.offered_currency.should.not.equal(@order.offered_currency)

    order2.offered_amount.should.equal(@order.offered_amount)
    @order.offered_amount = null
    order2.offered_amount.should.not.equal(@order.offered_amount)

    order2.received_currency.should.equal(@order.received_currency)
    @order.received_currency = null
    order2.received_currency.should.not.equal(@order.received_currency)

    order2.received_amount.should.equal(@order.received_amount)
    @order.received_amount = null
    order2.received_amount.should.not.equal(@order.received_amount)
    
  it 'should be able to produce a mirrored copy', ->
    order2 = @order.clone(true)
    order2.account.should.equal(@order.account)
    order2.offered_currency.should.equal(@order.received_currency)
    order2.offered_amount.should.equal(@order.received_amount)
    order2.received_currency.should.equal(@order.offered_currency)
    order2.received_amount.should.equal(@order.offered_amount)

    
