chai = require 'chai'  
chai.should()
expect = chai.expect
assert = chai.assert

Currency = require('../../lib/datastore/currency')
BigDecimal = require('bigdecimal').BigDecimal

describe 'Currency', ->
  it 'should initialize with an empty balance', ->
    currency = new Currency()
    currency.get_balance().compareTo(new BigDecimal('0')).should.equal(0)

  it 'should be possible to cumulatively add to the balance', ->
    currency = new Currency()
    currency.increase_balance(new BigDecimal('50'))
    currency.get_balance().compareTo(new BigDecimal('50')).should.equal(0, 'expected balance of 50')
    currency.increase_balance(new BigDecimal('100'))
    currency.get_balance().compareTo(new BigDecimal('150')).should.equal(0, 'expected balance of 150')
    currency.increase_balance(new BigDecimal('75'))
    currency.get_balance().compareTo(new BigDecimal('225')).should.equal(0, 'expected balance of 225')

  it 'should be possible to add 0.1 and 0.2 (bigdecimal stuff)', ->
    currency = new Currency()
    currency.increase_balance(new BigDecimal('0.1'))
    currency.get_balance().compareTo(new BigDecimal('0.1')).should.equal(0, 'expected balance of 0.1')
    currency.increase_balance(new BigDecimal('0.2'))
    currency.get_balance().compareTo(new BigDecimal('0.3')).should.equal(0, 'expected balance of 0.3')

