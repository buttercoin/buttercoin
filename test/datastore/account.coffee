chai = require 'chai'  
chai.should()
expect = chai.expect
assert = chai.assert

Account = require('../../lib/datastore/account')
Currency = require('../../lib/datastore/currency')

describe 'Account', ->
  it 'should initialize with no currencies', ->
    account = new Account()
    Object.keys(account.currencies).should.be.empty

  it 'should add new currency instances as they are requested if and only if they dont already exist', ->
    account = new Account()

    # get_currency should return instances of Currency
    usd_currency = account.get_currency('USD')
    usd_currency.should.be.an.instanceOf(Currency)
    eur_currency = account.get_currency('EUR')
    eur_currency.should.be.an.instanceOf(Currency)
    btc_currency = account.get_currency('BTC')
    btc_currency.should.be.an.instanceOf(Currency)

    # currencies should be different instances
    btc_currency.should.not.equal(usd_currency)
    btc_currency.should.not.equal(eur_currency)
    usd_currency.should.not.equal(eur_currency)

    # get the currencies again and should get the same instances
    another_usd_currency = account.get_currency('USD')
    another_usd_currency.should.equal(usd_currency)
    another_eur_currency = account.get_currency('EUR')
    another_eur_currency.should.equal(eur_currency)
    another_btc_currency = account.get_currency('BTC')
    another_btc_currency.should.equal(btc_currency)
