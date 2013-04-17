BalanceSheet = require('./balancesheet')
SuperMarket = require('./supermarket')

# Datastore exposes actual memory modifying Operations
# SYNCHRONOUS: returns when it returns!

# NON REENTRANT

module.exports = class DataStore
  constructor: ->
    @balancesheet = new BalanceSheet()
    @supermarket = new SuperMarket()

  add_deposit: (args) =>
    account = @balancesheet.get_account( args.account )
    currency = account.get_currency( args.currency )

    currency.increase_balance( args.amount )

  add_order: (args) =>
    account = @balancesheet.get_account( args.account )
    market = @supermarket.get_market( args.name )
