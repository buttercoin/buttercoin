SkipList = require("../experimental/skiplist").SkipList

class Currency
  constructor: ->
    @balance = 0

  increase_balance: (amount) =>
    @balance += amount

  get_balance: =>
    return @balance

class Account
  constructor: ->
    @currencies = Object.create null

  get_currency: (name) =>
    currency = @currencies[name]
    if not (currency instanceof Currency)
      @currencies[name] = currency = new Currency()
    return currency

class BalanceSheet
  constructor: ->
    @accounts = Object.create null

  get_account: (name) =>
    account = @accounts[name]
    if not (account instanceof Account)
      @accounts[name] = account = new Account()
    return account

class Market
  constructor: ->
    @buy_book = new SkipList()
    @sell_book = new SkipList()

class SuperMarket
  constructor: ->
    @markets = Object.create null

  get_market: (name) =>
    market = @markets[name]
    if not (market instanceof Market)
      @market[name] = market = new Market()
    return market

module.exports = class DataStore
  constructor: ->
    @balance_sheet = new BalanceSheet()
    @supermarket = new SuperMarket()

  add_deposit: (args) =>
    account = @balance_sheet.get_account( args.account )
    currency = account.get_currency( args.currency )

    currency.increase_balance( args.amount )

    if args.callback
      args.callback( currency.get_balance() )


  add_order: (args) =>
    account = @balance_sheet.get_account( args.account )
    market = @supermarket.get_market( args.name )

    if args.callback
      args.callback( market )

