BalanceSheet = require('./balancesheet')
SuperMarket = require('./supermarket')
Amount = require('./amount')

module.exports = class DataStore
  constructor: ->
    @balancesheet = new BalanceSheet()
    @supermarket = new SuperMarket()

  add_deposit: (args) =>
    account = @balancesheet.get_account( args.account )
    currency = account.get_currency( args.currency )

    try
      amount = new Amount(args.amount)
    catch e
      error = new Error('Only string amounts are supported in order to ensure accuracy')

    if typeof error == 'undefined'
      currency.increase_balance(amount)
      if args.callback
        args.callback( currency.get_balance() )
    else
      if args.callback
        args.callback(null, error)


  add_order: (args) =>
    account = @balancesheet.get_account( args.account )
    market = @supermarket.get_market( args.name )

    if args.callback
      args.callback( market )
