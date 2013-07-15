crypto = require 'crypto'
Router = require('../translation/routing').Router
require '../translation/mtgox_queries'
require '../translation/mtgox_actions'

channels = {}
channels['dbf1dee9-4f2e-4a08-8cb7-748919a71b21'] = 'Trades'
channels['d5f06780-30a8-4a48-a2f8-7ed181b4a13f'] = 'Ticker'
channels['24e67e0d-1cad-4cc0-9e7a-f8523ef460fe'] = 'Depth'
for k, v of channels
  channels[v] = k.toLowerCase()

module.exports = class MtGoxAdaptor
  @api_key_bytes: 16
  @signature_start: @api_key_bytes
  @signature_bytes: 64
  @payload_start: @signature_start + @signature_bytes

  constructor: (@auth_provider) ->

  handle_open: (connection) =>
    for k, _ of channels
      connection.send_obj
        op: 'subscribe'
        channel: k

  decode_inbound: (msg) =>
    msg = msg.call
    buffer = new Buffer(msg, 'base64')
    api_key = buffer.slice(0, MtGoxAdaptor.api_key_bytes).toString('hex')
    signature = buffer.slice(MtGoxAdaptor.signature_start, MtGoxAdaptor.payload_start).toString('hex')
    message = buffer.slice(MtGoxAdaptor.payload_start).toString('utf8')

    secret = new Buffer(@auth_provider[api_key], 'base64')
    hmac = crypto.createHmac('sha512', secret)
    hmac.update(message)
    digest = hmac.digest('hex')
    if signature is digest
      return JSON.parse(message)
    else
      return false

  should_decode: (msg) =>
    return msg.op is 'call'

  translate_inbound: (msg) =>
    if msg.op is 'auth'
      return {
        kind: 'AUTH'
        account_id: msg.username
      }

    try
      translator = Router.route(msg.call)
    catch e
      console.log "error:", e
    msg = translator.translate(msg)
    
  translate_outbound: (msg) =>
    msg

