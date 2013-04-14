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
    @front.start {port: 3020, host: "0.0.0.0", apiEndpoint: "ws://localhost:3021"}
    client = new WebSocket("ws://localhost:3020")


  it 'should connect to the API', ->
    @front.start
    # test connection to API