Market = require('./market')

module.exports = class SuperMarket
  constructor: ->
    @markets = Object.create null

  get_market: (name) =>
    market = @markets[name]
    if not (market instanceof Market)
      @markets[name] = market = new Market()
    return market
