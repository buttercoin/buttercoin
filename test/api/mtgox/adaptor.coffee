crypto = require 'crypto'
Adaptor = require '../../../lib/api/mtgox/adaptor'
Router = require('../../../lib/api/translation/routing').Router
require '../../../lib/api/translation/mtgox_actions'

test_api_key = "534ae7aea872406cbbae6ba2dd5ec515" # 16-bytes
test_api_secret = (new Buffer("SEKRET-MESSAGE-KEY")).toString('base64')

create_signed_message = (message) ->
  hmac = crypto.createHmac('sha512', new Buffer(test_api_secret, 'base64'))
  hmac.update(message)
  signature = hmac.digest('hex')

  size = Adaptor.payload_start + message.length
  buffer = new Buffer(size)
  cursor = 0

  buffer.write(test_api_key, cursor, 'hex')
  cursor += Adaptor.api_key_bytes
  buffer.write(signature, cursor, 'hex')
  cursor += Adaptor.signature_bytes
  buffer.write(message, cursor, 'utf8')

  request = buffer.toString('base64')

describe 'MtGoxAdaptor', ->
  beforeEach ->
    auth_provider = {}
    auth_provider[test_api_key] = test_api_secret
    @adaptor = new Adaptor(auth_provider)

  it 'should be able to decode an inbound message', ->
    request = {foo: "bar"}
    request_json = JSON.stringify(request)
    signed_msg = create_signed_message(request_json)
    result = @adaptor.decode_inbound(call: signed_msg)
    JSON.stringify(result).should.equal request_json

  it 'should decode an inbound message if required', ->
    msg =
      op: 'call'
      call: 'this is the message'

    @adaptor.should_decode(msg).should.be.true

  it 'should decode an inbound message if required', ->
    msg =
      op: 'auth'
      call: 'this is the message'

    @adaptor.should_decode(msg).should.be.false

  it 'should invoke translator in translate_inbound', =>
    # TODO - test translate_inbound w/ mocking
    msg =
      op: 'call'
      call: 'bitcoin/sendsimple'
    
    translator = Router.route(msg.call)
    msg = translator.translate(msg)
    msg.operation.should.equal "SEND_BITCOINS"

    


