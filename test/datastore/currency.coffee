Currency = require('../../lib/datastore/currency')
Amount = require('../../lib/datastore/amount')

describe 'Currency', ->
  describe '#get_balance', ->
    it 'should return an Amount instance', ->
      currency = new Currency()
      amount = currency.get_balance()
      amount.should.be.an.instanceOf(Amount)

  it 'should initialize with an empty balance', ->
    currency = new Currency()
    currency.get_balance().compareTo(new Amount()).should.equal(0)

  it 'should be possible to cumulatively add to the balance', ->
    currency = new Currency()
    currency.increase_balance(new Amount('50'))
    currency.get_balance().compareTo(new Amount('50')).should.equal(0)
    currency.increase_balance(new Amount('100'))
    currency.get_balance().compareTo(new Amount('150')).should.equal(0)
    currency.increase_balance(new Amount('75'))
    currency.get_balance().compareTo(new Amount('225')).should.equal(0)

  it 'should be able to increase a balance of 0.1 by 0.2 accurately so that we do not suffer from Javascript Number issues', ->
    currency = new Currency()
    currency.increase_balance(new Amount('0.1'))
    currency.increase_balance(new Amount('0.2'))
    currency.get_balance().compareTo(new Amount('0.3')).should.equal(0)
