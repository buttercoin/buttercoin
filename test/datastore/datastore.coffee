DataStore = require('../../lib/datastore/datastore')
BalanceSheet = require('../../lib/datastore/balancesheet')
SuperMarket = require('../../lib/datastore/supermarket')
BigDecimal = require('bigdecimal').BigDecimal

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
    it 'should error if amount is not a string', (done) =>
      dataStore = new DataStore()
      dataStore.add_deposit
        account: 'Peter'
        currency: 'USD'
        amount: 50
        callback: (balance, error) =>
          expect(balance).to.not.be.ok
          error.toString().should.equal((new Error('Amount must be a string')).toString())
          done()

    it 'should error if amount cannot be parsed into a BigDecimal', (done) =>
      dataStore = new DataStore()
      dataStore.add_deposit
        account: 'Peter'
        currency: 'USD'
        amount: 'this is not a number'
        callback: (balance, error) =>
          expect(balance).to.not.be.ok
          error.toString().should.equal((new Error('Amount string must be a valid BigDecimal')).toString())
          done()


    it 'should create accounts as needed, apply deposit and return the new balance of the account', (done) ->
      dataStore = new DataStore()
      dataStore.add_deposit
        account: 'Peter'
        currency: 'USD'
        amount: '50'
        callback: (balance) =>
          peter_account = dataStore.balancesheet.get_account('Peter')
          peter_usd_currency = peter_account.get_currency('USD')
          peter_usd_balance = peter_usd_currency.get_balance()
          peter_usd_balance.compareTo(new BigDecimal('50')).should.equal(0)
          balance.compareTo(peter_usd_balance).should.equal(0)
          dataStore.add_deposit
            account: 'Peter'
            currency: 'USD'
            amount: '150'
            callback: (balance) =>
              peter_usd_balance = peter_usd_currency.get_balance()
              peter_usd_balance.compareTo(new BigDecimal('200')).should.equal(0)
              balance.compareTo(peter_usd_balance).should.equal(0)
              dataStore.add_deposit
                account: 'Peter'
                currency: 'EUR'
                amount: '300'
                callback: (balance) =>
                  peter_eur_currency = peter_account.get_currency('EUR')
                  peter_eur_balance = peter_eur_currency.get_balance()
                  peter_eur_balance.compareTo(new BigDecimal('300')).should.equal(0)
                  balance.compareTo(peter_eur_balance).should.equal(0)
                  dataStore.add_deposit
                    account: 'Paul'
                    currency: 'USD'
                    amount: '75'
                    callback: (balance) =>
                      paul_account = dataStore.balancesheet.get_account('Paul')
                      paul_usd_currency = paul_account.get_currency('USD')
                      paul_usd_balance = paul_usd_currency.get_balance()
                      paul_usd_balance.compareTo(new BigDecimal('75')).should.equal(0)
                      balance.compareTo(paul_usd_balance).should.equal(0)
                      dataStore.add_deposit
                        account: 'Paul'
                        currency: 'USD'
                        amount: '200'
                        callback: (balance) =>
                          paul_usd_balance = paul_usd_currency.get_balance()
                          paul_usd_balance.compareTo(new BigDecimal('275')).should.equal(0)
                          balance.compareTo(paul_usd_balance).should.equal(0)
                          done()

