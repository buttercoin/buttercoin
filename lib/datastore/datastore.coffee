BalanceSheet = require('./balancesheet')
SuperMarket = require('./supermarket')

module.exports = class DataStore
  constructor: ->
    @balancesheet = new BalanceSheet()
    @supermarket = new SuperMarket()

  add_deposit: (args) =>
    account = @balancesheet.get_account( args.account )
    currency = account.get_currency( args.currency )

    currency.increase_balance( args.amount )

    if args.callback
      args.callback( currency.get_balance() )


  add_order: (args) =>
    account = @balancesheet.get_account( args.account )
    market = @supermarket.get_market( args.name )

    if args.callback
      args.callback( market )
