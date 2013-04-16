Api = require('../lib/api')
Engine = require('../lib/engine')
TestHelper = require('./test_helper')

WebSocket = require('ws')

describe 'Api', ->
  beforeEach  =>
    TestHelper.clean_state_sync

  afterEach =>
    TestHelper.clean_state_sync

  it 'should initialize', ->
    api = new Api
    api.start

  it 'should start, connect to engine, and provide a WS server', (done) ->
    api = new Api
    engine = new Engine
    engine.start {port: 3033, host: "localhost" }, () =>
      api.start {port: 3022, host: "localhost", engineEndpoint: 'ws://localhost:3033' }, () =>
        done()
