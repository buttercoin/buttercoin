op = require('buttercoin-engine').operations

module.exports = class Router
  routers = {}
  @register: (route, builder) => routers[route] = builder

  @route: (request) =>
    for k,v of routers
      regex = new RegExp(k)
      match = regex.exec(request.url)
      return v(match) unless match is null or match is undefined

    throw new Error("Couldn't match route: #{request.url}")

class Translator
  @route: (pattern, builder) ->
    _builder = (match) => new this(builder(match...))
    Router.register(pattern, _builder)
  constructor: (@options) ->

class CreateOrderTranslator extends Translator
  @route "^/api/1/([A-Z]{6})/(private/)?order/add$", (_, pair) ->
    currency_pair: [pair.slice(0,3), pair.slice(3)]

  translate: (params) =>
    result = {operation: op.CREATE_LIMIT_ORDER}

    price_int = (params.amount_int * params.price_int / 1e8) | 0

    if params.type is 'ask'
      result.offered_amount = params.amount_int
      result.offered_currency = @options.currency_pair[0]
      result.received_amount = price_int
      result.received_currency = @options.currency_pair[1]
    else if params.type is 'bid'
      result.offered_amount = price_int
      result.offered_currency = @options.currency_pair[1]
      result.received_amount = params.amount_int
      result.received_currency = @options.currency_pair[0]
    else
      #error

    return result

class CancelOrderTranslator extends Translator
  @route "^/api/1/([A-Z]{6})/(private/)?order/cancel$", (_, pair) ->
    currency_pair: [pair.slice(0,3), pair.slice(3)]

  translate: (params) =>
    result = 
      operation: 'CANCEL_ORDER'
      order_id: params.oid
    
    return result

class SendBitCoinTranslator extends Translator
  @route "^/api/1/generic/bitcoin/sendsimple$", (match) ->

  translate: (params) =>
    console.log ('@@@@@@@@@ TRANSLATE @@@@@@@@@@')
    result = 
      operation: 'SEND_BITCOINS'
      address: params.address
      amount: params.amount_int

    return result

