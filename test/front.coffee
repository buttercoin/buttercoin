Front = require('../lib/front/front')
WebSocket = require('ws')
WebSocketServer = require('ws').Server

logger.set_levels 'development'
describe 'Front', ->
  beforeEach ->
    @front = new Front

  it 'should initialize', ->
    @front.start

  it 'should start a WSS', ->
    stub = new WebSocketServer({port: 3021, host: "0.0.0.0"});
    stub.on 'connection', () ->
      logger.info 'Stub got a connection'
    stub.on 'message', (message) ->
      logger.info "Stub got message:" + message
      stub.send 'Hello'

    @front.start {port: 3020, host: "0.0.0.0", apiEndpoint: "ws://localhost:3021"}
    client = new WebSocket("ws://localhost:3021")
    client.on 'connection', () ->
      client.send '{"itsjson":"morejson"}'
    client.on 'message', (message) ->
      logger.info "Client of front-end got message:" + message

  it 'should connect to the API', ->
    @front.start
    # test connection to API
