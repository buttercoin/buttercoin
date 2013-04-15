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
    stub.on 'connection', () ->
      console.log 'Stub got a connection'
    stub.on 'message', (message) ->
      console.log "Stub got message:" + message
      stub.send 'Hello'

    @front.start {port: 3020, host: "0.0.0.0", apiEndpoint: "ws://localhost:3021"}
    client = new WebSocket("ws://localhost:3020")
    client.on 'connection', () ->
      client.send '{"itsjson":"morejson"}'
    client.on 'message', (message) ->
      console.log "Client of front-end got message:" + message

