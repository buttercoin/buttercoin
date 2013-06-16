crypto = require 'crypto'

api_key_bytes = 16
signature_start = api_key_bytes
payload_start = signature_start + 64

module.exports = class MtGoxAdaptor
  constructor: (@auth_provider) ->

  decode_inbound: (msg) =>
    buffer = new Buffer(msg, 'base64')
    api_key = buffer.slice(0, api_key_bytes).toString('hex')
    signature = buffer.slice(signature_start, payload_start).toString('hex')
    message = buffer.slice(payload_start).toString('utf8')

    hmac = crypto.createHmac('sha512', @auth_provider[api_key])
    hmac.update(message)
    digest = hmac.digest('hex')
    if signature is digest
      return JSON.parse(message)
    else
      return false

  translate_inbound: (msg) =>
    msg

  translate_outbound: (msg) =>
    msg

