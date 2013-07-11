crypto = require 'crypto'
Adaptor = require '../../../lib/api/mtgox/adaptor'

test_api_key = "534ae7aea872406cbbae6ba2dd5ec515" # 16-bytes
test_api_secret = "SEKRET-MESSAGE-KEY"

describe 'MtGoxAdaptor', ->
  beforeEach ->
    auth_provider = {}
    auth_provider[test_api_key] = test_api_secret
    @adaptor = new Adaptor(auth_provider)

  it 'should be able to decode an inbound REST-call', ->
    request = {foo: "bar"}
    request_json = JSON.stringify(request)
    hmac = crypto.createHmac('sha512', test_api_secret)
    hmac.update(request_json)
    signature = hmac.digest('hex')

    size = 16 + 64 + request_json.length
    buffer = new Buffer(size)
    cursor = 0

    buffer.write(test_api_key, cursor, 'hex')
    console.log "bin_key:", buffer.slice(0, 16).toString()
    cursor += 16
    buffer.write(signature, cursor, 'hex')
    cursor += 64
    buffer.write(request_json, cursor, 'utf8')

    request = buffer.toString('base64')

    result = @adaptor.decode_inbound(request)
    JSON.stringify(result).should.equal request_json

