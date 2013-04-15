Api = require('../lib/api')
Engine = require('../lib/engine')
Front = require('../lib/front/front')
WebSocket = require('ws')
WebSocketServer = require('ws').Server

describe 'Front', ->

  it 'should initialize', ->
    front = new Front

  describe 'Front.start', ->
    it 'should start, connect to api, and provide a WS server', ->
      api = new Api
      front = new Front
      engine = new Engine
      engine.start {port: 3043, host: "0.0.0.0" }, (err, server) =>
        # console.log err, server
        api.start {port: 3042, host: "0.0.0.0", engineEndpoint: 'ws://0.0.0.0:3043' }, (err, server) =>
          # console.log err, server
          front.start {port: 3044, host: "0.0.0.0", apiEndpoint: 'ws://0.0.0.0:3022' }, (err, server) =>
            # console.log err, server
