Translator = require('./translator').Translator
op = require('buttercoin-engine').operations

class OpenOrdersTranslator extends Translator
  @route "^(private/)?orders$", (match) ->

  translate: (params) =>
    result =
      operation: op.OPEN_ORDERS
      # account: params.account_id

    return result

class OrderInfoTranslator extends Translator
  @route "^(private/)?order/result$", (match) ->

  translate: (params) =>
    result =
      operation: op.ORDER_INFO
      order_id: params.order
      # account: params.account_id

    return result

