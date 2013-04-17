Market = require('./market')

module.exports = class SuperMarket
  constructor: ->
    @markets = Object.create null

  get_market: (offered_currency, received_currency) =>

    if offered_currency == received_currency
      throw Error("Currencies the same")

    if offered_currency < received_currency
      canonical_pair =  [offered_currency, received_currency]
    else
      canonical_pair = [received_currency, offered_currency]

    canonical_pair_string = canonical_pair.join('|') # XXX: no | in name

    market = @markets[canonical_pair_string]
    if not (market instanceof Market)
      @markets[canonical_pair_string] = market = new Market( canonical_pair[0], canonical_pair[1] )
    return market
