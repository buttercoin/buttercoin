BalanceSheet = require('./balancesheet')
SuperMarket = require('./supermarket')
Amount = require('./amount')

# Datastore exposes actual memory modifying Operations
# SYNCHRONOUS: returns when it returns!

# NON REENTRANT

isString = (s) ->
  return typeof(s) == 'string' || s instanceof String

isNumber = (s) ->
  return typeof(s) == 'number' || s instanceof Number

module.exports = class DataStore
  constructor: ->
    @balancesheet = new BalanceSheet()
    @supermarket = new SuperMarket()

  add_deposit: (args) =>
    if not isString(args.account)
      throw Error("Account must be a String")
    account = @balancesheet.get_account( args.account )

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
    if not isString(args.currency)
      throw Error("Currency must be a String")
    currency = account.get_currency( args.currency )

    if not isNumber(args.amount)
      throw Error("Number must be a Number")

    currency.increase_balance( args.amount )

  add_order: (args) =>
    account = @balancesheet.get_account( args.account )

    if not isString(args.account)
      throw Error("Account must be a String")
    account = @balancesheet.get_account( args.account )

    if not isString(args.offered_currency)
      throw Error("Offered Currency must be a String")
    currency = account.get_currency( args.currency )

    if not isString(args.received_currency)
      throw Error("Received Currency must be a String")
    currency = account.get_currency( args.currency )

    if not isNumber(args.offered_amount)
      throw Error("Offered Amount must be a Number")

    if not isNumber(args.received_amount)
      throw Error("Received Amount must be a Number")

    market = @supermarket.get_market( args.offered_currency, args.received_currency )

    market.add_order( account, args.offered_currency, args.offered_amount, args.received_amount )



