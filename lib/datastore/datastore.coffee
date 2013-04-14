BalanceSheet = require('./balancesheet')
SuperMarket = require('./supermarket')
BigDecimal = require('bigdecimal').BigDecimal

module.exports = class DataStore
  constructor: ->
    @balancesheet = new BalanceSheet()
    @supermarket = new SuperMarket()

  add_deposit: (args) =>
    if typeof args.amount == 'string'
      account = @balancesheet.get_account( args.account )
      currency = account.get_currency( args.currency )
      
      amount = 'not valid'
      try
        amount = new BigDecimal(args.amount)
      
      if amount == 'not valid'
        if args.callback
          args.callback( null, new Error('Amount string must be a valid BigDecimal') )      
      else
        currency.increase_balance(amount)
        if args.callback
          args.callback( currency.get_balance() )
    else
      if args.callback
        args.callback( null, new Error('Amount must be a string') )      

  add_order: (args) =>
    account = @balancesheet.get_account( args.account )
    market = @supermarket.get_market( args.name )

    if args.callback
      args.callback( market )

