ApiClient = require('../lib/api_client')
Api = require('../lib/api')
TestHelper = require('./test_helper')

WebSocket = require('ws')

describe 'ApiClient', ->
  beforeEach  =>
    TestHelper.clean_state_sync

  afterEach =>
    TestHelper.clean_state_sync

  it 'should initialize', ->
    api_client = new ApiClient
    api_client.start

  xit 'should start, connect to engine, and provide a WS server', (done) ->
    api_client = new ApiClient
    engine = new Api
    engine.start {port: 3033, host: "0.0.0.0" }, () =>
      api_client.start {port: 3022, host: "0.0.0.0", engineEndpoint: 'ws://0.0.0.0:3033' }, () =>
        done()
