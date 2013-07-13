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

class OpenOrdersTranslator extends Translator
  @route "^/api/1/generic/private/orders$", (match) ->

  translate: (params) =>
    result =
      operation: 'OPEN_ORDERS'
      # account: params.account_id

    return result

class OrderInfoTranslator extends Translator
  @route "^/api/1/generic/private/order/result$", (match) ->

  translate: (params) =>
    result =
      operation: 'ORDER_INFO'
      order_id: params.order
      # account: params.account_id

    return result

