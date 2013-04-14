chai = require 'chai'
chai.should()
expect = chai.expect
assert = chai.assert

Front = require('../lib/front')
WebSocket = require('ws')
WebSocketServer = require('ws').Server

describe 'Front', ->
  beforeEach ->
    @front = new Front

  it 'should initialize', ->
    @front.start

  it 'should start a WSS', ->
    stub = new WebSocketServer({port: 3021, host: "0.0.0.0"});
    stub.on 'connection', (ws) ->
      console.log 'input was' + ws
    stub.on 'message', (message) ->
      console.log message

    @front.start {port: 3020, host: "0.0.0.0", apiEndpoint: "ws://localhost:3021"}
    client = new WebSocket("ws://localhost:3020")
    client.on 'connection', () ->
      client.send 'my message is foo'


  it 'should connect to the API', ->
    @front.start
    # test connection to API