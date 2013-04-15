WebSocket = require('ws')
WebSocketServer = require('ws').Server

Buttercoin = require('../lib/buttercoin')

describe 'Front', ->

  it 'can initialize', (done) ->
    @butter = new Buttercoin()
    done()

  it 'should start, connect to api, and provide a WS server', (done)->
    @butter.engine.start {port: 3043, host: "0.0.0.0" }, (err, server) =>
      @butter.api.start {port: 3042, host: "0.0.0.0", engineEndpoint: 'ws://0.0.0.0:3043' }, (err, server) =>
        @butter.front.start {port: 3044, host: "0.0.0.0", apiEndpoint: 'ws://0.0.0.0:3042' }, (err, server) =>
          done(null)