BalanceSheet = require('./balancesheet')
SuperMarket = require('./supermarket')

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

    if not isString(args.currency)
      throw Error("Currency must be a String")
    currency = account.get_currency( args.currency )

    if not isNumber(args.amount)
      throw Error("Number must be a Number")

    currency.increase_balance( args.amount )

  add_order: (args) =>
    account = @balancesheet.get_account( args.account )
    market = @supermarket.get_market( args.name )
