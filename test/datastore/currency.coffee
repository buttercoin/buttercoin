chai = require 'chai'  
chai.should()
expect = chai.expect
assert = chai.assert

Currency = require('../../lib/datastore/currency')

describe 'Currency', ->
  it 'should initialize with an empty balance', ->
    currency = new Currency()
    currency.get_balance().should.equal(0)

  it 'should be possible to cumulatively add to the balance', ->
    currency = new Currency()
    currency.increase_balance(50)
    currency.get_balance().should.equal(50)
    currency.increase_balance(100)
    currency.get_balance().should.equal(150)
    currency.increase_balance(75)
    currency.get_balance().should.equal(225)
