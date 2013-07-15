Translator = require('./routing').Translator
op = require('buttercoin-engine').operations

class OpenOrdersTranslator extends Translator
  @route "^(private/)?orders$", (match) ->

  translate: (params) =>
    result =
      query: op.OPEN_ORDERS
      # account: params.account_id

    return result

class OrderInfoTranslator extends Translator
  @route "^(private/)?order/result$", (match) ->

  translate: (params) =>
    result =
      query: op.ORDER_INFO
      order_id: params.order
      # account: params.account_id

    return result

class TickerTranslator extends Translator
  @route "^([A-Z]{6})/ticker$", (_, pair) ->
    currency_pair: [pair.slice(0,3), pair.slice(3)]

  translate: (params) =>
    result =
      query: op.TICKER
      currencies: @options.currency_pair
