op = require('buttercoin-engine').operations
Translator = require('./routing').Translator

class CreateOrderTranslator extends Translator
  @route "^([A-Z]{6})/(private/)?order/add$", (_, pair) ->
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
  @route "^([A-Z]{6})/(private/)?order/cancel$", (_, pair) ->
    currency_pair: [pair.slice(0,3), pair.slice(3)]

  translate: (params) =>
    result =
      operation: op.CANCEL_ORDER
      order_id: params.oid
    
    return result

class SendBitCoinTranslator extends Translator
  @route "^bitcoin/sendsimple$", (match) ->

  translate: (params) =>
    result =
      operation: op.SEND_BITCOINS
      address: params.address
      amount: params.amount_int

    return result
