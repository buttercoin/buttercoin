crypto = require 'crypto'

api_key_bytes = 16
signature_start = api_key_bytes
payload_start = signature_start + 64

channels = {}
channels['dbf1dee9-4f2e-4a08-8cb7-748919a71b21'] = 'Trades'
channels['d5f06780-30a8-4a48-a2f8-7ed181b4a13f'] = 'Ticker'
channels['24e67e0d-1cad-4cc0-9e7a-f8523ef460fe'] = 'Depth'
for k, v of channels
  channels[v] = k.toLowerCase()

module.exports = class MtGoxAdaptor
  constructor: (@auth_provider) ->

  handle_open: (connection) =>
    for k, _ of channels
      connection.send_obj
        op: 'subscribe'
        channel: k

  decode_inbound: (msg) =>
    buffer = new Buffer(msg, 'base64')
    api_key = buffer.slice(0, api_key_bytes).toString('hex')
    signature = buffer.slice(signature_start, payload_start).toString('hex')
    message = buffer.slice(payload_start).toString('utf8')

    secret = new Buffer(@auth_provider[api_key], 'base64')
    hmac = crypto.createHmac('sha512', secret)
    hmac.update(message)
    digest = hmac.digest('hex')
    if signature is digest
      return JSON.parse(message)
    else
      return false

  translate_inbound: (msg) =>
    if msg.op is 'auth'
      return {
        kind: 'AUTH'
        account_id: msg.username
      }
      
    if msg.op is 'call'
      msg = @decode_inbound(msg.call)

  translate_outbound: (msg) =>
    msg

