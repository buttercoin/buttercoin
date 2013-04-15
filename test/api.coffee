Api = require('../lib/api')
Engine = require('../lib/engine')

WebSocket = require('ws')

describe 'Api', ->
  it 'should initialize', ->
    api = new Api
    api.start

  it 'should start, connect to engine, and provide a WS server', ->
    api = new Api
    engine = new Engine
    engine.start {port: 3033, host: "0.0.0.0" }, () =>
      api.start {port: 3022, host: "0.0.0.0", apiEndpoint: 'ws://0.0.0.0:3033' }, () =>
        logger.info 'called api callback'
        done()