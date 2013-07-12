crypto = require 'crypto'
Adaptor = require '../../../lib/api/mtgox/adaptor'

test_api_key = "534ae7aea872406cbbae6ba2dd5ec515" # 16-bytes
test_api_secret = (new Buffer("SEKRET-MESSAGE-KEY")).toString('base64')

describe 'MtGoxAdaptor', ->
  beforeEach ->
    auth_provider = {}
    auth_provider[test_api_key] = test_api_secret
    @adaptor = new Adaptor(auth_provider)

  it 'should be able to decode an inbound message', ->
    request = {foo: "bar"}
    request_json = JSON.stringify(request)
    hmac = crypto.createHmac('sha512', new Buffer(test_api_secret, 'base64'))
    hmac.update(request_json)
    signature = hmac.digest('hex')

    size = Adaptor.payload_start + request_json.length
    buffer = new Buffer(size)
    cursor = 0

    buffer.write(test_api_key, cursor, 'hex')
    cursor += Adaptor.api_key_bytes
    buffer.write(signature, cursor, 'hex')
    cursor += Adaptor.signature_bytes
    buffer.write(request_json, cursor, 'utf8')

    request = buffer.toString('base64')

    result = @adaptor.decode_inbound(request)
    JSON.stringify(result).should.equal request_json

