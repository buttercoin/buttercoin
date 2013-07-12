class Translator

class CreateOrderTranslator extends Translator
  constructor: (@options) ->
  translate: (params) ->
    result = {operation: 'CREATE_LIMIT_ORDER'}

    if params.type is 'ask'
      result.offered_amount = params.amount_int
      result.offered_currency = 'BTC'
      result.received_amount = params.price_int
      result.received_currency = 'USD'
    else if params.type is 'bid'
      result.offered_amount = params.price_int
      result.offered_currency = 'USD'
      result.received_amount = params.amount_int
      result.received_currency = 'BTC'
    else
      #error

    return result
    

routers = {
  #"^/api/1/(.*)/(private/)?order/add$"
  "^/api/1/(.*)/(private/)?order/add$": (match) ->
    new CreateOrderTranslator
      currency_pair: match[1]
}

module.exports = class Router
  @route: (request) =>
    for k,v of routers
      regex = new RegExp(k)
      match = regex.exec(request.url)
      return v(match) unless match is null or match is undefined

    throw new Error("Couldn't match route: #{request.url}")

  #@CreateOrder = class CreateOrder
    #@translate_inbound: ->

