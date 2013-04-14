
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
    if not currency
      @currencies[name] = currency = new Currency()
    return currency

class BalanceSheet
  constructor: ->
    @accounts = Object.create null

  get_account: (name) =>
    account = @accounts[name]
    if not account
      @accounts[name] = account = new Account()
    return account

class OrderBook
  constructor: ->

module.exports = class DataStore
  constructor: ->
    @balance_sheet = new BalanceSheet()
    @order_book = new OrderBook()

  add_deposit: (args) =>
    account = @balance_sheet.get_account( args.account )
    currency = account.get_currency( args.currency )

    currency.increase_balance( args.amount )

    if args.callback
      args.callback( currency.get_balance() )
