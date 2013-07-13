Translator = require('./routing').Translator
op = require('buttercoin-engine').operations

class OpenOrdersTranslator extends Translator
  @route "^/api/1/generic/private/orders$", (match) ->

  translate: (params) =>
    result =
      operation: op.OPEN_ORDERS
      # account: params.account_id

    return result

class OrderInfoTranslator extends Translator
  @route "^/api/1/generic/private/order/result$", (match) ->

  translate: (params) =>
    result =
      operation: op.ORDER_INFO
      order_id: params.order
      # account: params.account_id

    return result

