chai = require 'chai'  
chai.should()
expect = chai.expect
assert = chai.assert

BalanceSheet = require('../../lib/datastore/balancesheet')
Account = require('../../lib/datastore/account')

describe 'BalanceSheet', ->
  it 'should initialize with no accounts', ->
    balancesheet = new BalanceSheet()
    Object.keys(balancesheet.accounts).should.be.empty

  it 'should add new account instances as they are requested if and only if they dont already exist', ->
    balancesheet = new BalanceSheet()

    # get_account should return instances of Account
    tom_account = balancesheet.get_account('Tom')
    tom_account.should.be.an.instanceOf(Account)
    dick_account = balancesheet.get_account('Dick')
    dick_account.should.be.an.instanceOf(Account)
    harry_account = balancesheet.get_account('Harry')
    harry_account.should.be.an.instanceOf(Account)

    # currencies should be different instances
    harry_account.should.not.equal(tom_account)
    harry_account.should.not.equal(dick_account)
    tom_account.should.not.equal(dick_account)

    # get the currencies again and should get the same instances
    another_tom_account = balancesheet.get_account('Tom')
    another_tom_account.should.equal(tom_account)
    another_dick_account = balancesheet.get_account('Dick')
    another_dick_account.should.equal(dick_account)
    another_harry_account = balancesheet.get_account('Harry')
    another_harry_account.should.equal(harry_account)
