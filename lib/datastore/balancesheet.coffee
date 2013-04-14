Account = require('./account')

module.exports = class BalanceSheet
  constructor: ->
    @accounts = Object.create null

  get_account: (name) =>
    account = @accounts[name]
    if not (account instanceof Account)
      @accounts[name] = account = new Account()
    return account
