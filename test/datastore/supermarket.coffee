chai = require 'chai'  
chai.should()
expect = chai.expect
assert = chai.assert

SuperMarket = require('../../lib/datastore/supermarket')
Market = require('../../lib/datastore/market')

describe 'SuperMarket', ->
  it 'should initialize with no markets', ->
    supermarket = new SuperMarket()
    Object.keys(supermarket.markets).should.be.empty

  it 'should add new market instances as they are requested if and only if they dont already exist', ->
    supermarket = new SuperMarket()

    # get_market should return instances of Market
    btceur_market = supermarket.get_market('BTCEUR')
    btceur_market.should.be.an.instanceOf(Market)
    btcusd_market = supermarket.get_market('BTCUSD')
    btcusd_market.should.be.an.instanceOf(Market)
    usdeur_market = supermarket.get_market('USDEUR')
    usdeur_market.should.be.an.instanceOf(Market)

    # markets should be different instances
    usdeur_market.should.not.equal(btceur_market)
    usdeur_market.should.not.equal(btcusd_market)
    btceur_market.should.not.equal(btcusd_market)

    # get the markets again and should get the same instances
    another_btceur_market = supermarket.get_market('BTCEUR')
    another_btceur_market.should.equal(btceur_market)
    another_btcusd_market = supermarket.get_market('BTCUSD')
    another_btcusd_market.should.equal(btcusd_market)
    another_usdeur_market = supermarket.get_market('USDEUR')
    another_usdeur_market.should.equal(usdeur_market)
