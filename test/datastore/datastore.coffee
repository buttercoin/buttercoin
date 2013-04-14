chai = require 'chai'  
chai.should()
expect = chai.expect
assert = chai.assert

DataStore = require('../../lib/datastore/datastore')
BalanceSheet = require('../../lib/datastore/balancesheet')
SuperMarket = require('../../lib/datastore/supermarket')

describe 'DataStore', ->
  it 'should initialize with a balance sheet and supermarket', ->
    datastore = new DataStore()
    datastore.balancesheet.should.be.an.instanceOf(BalanceSheet)
    datastore.supermarket.should.be.an.instanceOf(SuperMarket)

  describe '#add_order', ->
    it 'should ?', (done) ->
      # TODO
      done()

  describe '#add_deposit', ->
    beforeEach ->
      @dataStore = new DataStore()

    it 'should create accounts as needed, apply deposit and return the new balance of the account', (done) ->
      @dataStore.add_deposit
        account: 'Peter'
        currency: 'USD'
        amount: 50
        callback: (balance) =>
          peter_account = @dataStore.balancesheet.get_account('Peter')
          peter_usd_currency = peter_account.get_currency('USD')
          peter_usd_balance = peter_usd_currency.get_balance()
          peter_usd_balance.should.equal(50)
          balance.should.equal(peter_usd_balance)
          @dataStore.add_deposit
            account: 'Peter'
            currency: 'USD'
            amount: 150
            callback: (balance) =>
              peter_usd_balance = peter_usd_currency.get_balance()
              peter_usd_balance.should.equal(200)
              balance.should.equal(peter_usd_balance)
              @dataStore.add_deposit
                account: 'Peter'
                currency: 'EUR'
                amount: 300
                callback: (balance) =>
                  peter_eur_currency = peter_account.get_currency('EUR')
                  peter_eur_balance = peter_eur_currency.get_balance()
                  peter_eur_balance.should.equal(300)
                  balance.should.equal(peter_eur_balance)
                  @dataStore.add_deposit
                    account: 'Paul'
                    currency: 'USD'
                    amount: 75
                    callback: (balance) =>
                      paul_account = @dataStore.balancesheet.get_account('Paul')
                      paul_usd_currency = paul_account.get_currency('USD')
                      paul_usd_balance = paul_usd_currency.get_balance()
                      paul_usd_balance.should.equal(75)
                      balance.should.equal(paul_usd_balance)
                      @dataStore.add_deposit
                        account: 'Paul'
                        currency: 'USD'
                        amount: 200
                        callback: (balance) =>
                          paul_usd_balance = paul_usd_currency.get_balance()
                          paul_usd_balance.should.equal(275)
                          balance.should.equal(paul_usd_balance)
                          done()

