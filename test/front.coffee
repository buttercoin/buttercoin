Api = require('../lib/api')
Engine = require('../lib/engine')
Front = require('../lib/front/front')
WebSocket = require('ws')
WebSocketServer = require('ws').Server

describe 'Front', ->
  beforeEach ->
    @front = new Front

  it 'should initialize', ->
    @front.start

  it 'should start, connect to api, and provide a WS server', ->
    api = new Api
    engine = new Engine
    engine.start {port: 3043, host: "0.0.0.0" }, () =>
      api.start {port: 3042, host: "0.0.0.0", engineEndpoint: 'ws://0.0.0.0:3043' }, () =>
        front.start {port: 3044, host: "0.0.0.0", apiEndpoint: 'ws://0.0.0.0:3042' }, () =>
          done
