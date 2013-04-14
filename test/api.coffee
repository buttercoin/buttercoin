chai = require 'chai'
chai.should()
expect = chai.expect
assert = chai.assert

Api = require('../lib/api')
WebSocket = require('ws')

describe 'Api', ->
  it 'should initialize', ->
    api = new Api
    api.start

  it 'should start and provide a WS server', ->
    api = new Api
    api.start =>

    client = new WebSocket("ws://localhost:3001")
    client.on 'connection', () ->
      client.send '{"itsjson":"morejson"}'

      client.on 'message', () ->
        console.log 'Client received message:' + message


