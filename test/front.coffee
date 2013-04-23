WebSocket = require('ws')
WebSocketServer = require('ws').Server

Buttercoin = require('../lib/buttercoin')

message = ["ADD_DEPOSIT", {'account': 'Marak', 'password': 'foo', 'currency': 'USD', 'amount': 200.0}]

describe 'Front', ->

  describe 'new Front', ->

    it 'can initialize', ->
      butter = new Buttercoin

    xit 'should start, connect to api, and provide a WS server', (done) ->
      butter = new Buttercoin
      butter.engine.start {port: 3043, host: "localhost" }, (err, server) =>
        butter.api.start {port: 3042, host: "localhost", engineEndpoint: 'ws://localhost:3043' }, (err, server) =>
          butter.front.start {port: 3044, host: "localhost", apiEndpoint: 'ws://localhost:3042' }, (err, server) =>
            done(null)

    it 'should be able to have a generic ws client connect and send message', (done) ->

      socket = require('engine.io-client')('ws://localhost:3044');

      return done(null)

      socket.onopen = ->
        socket.send JSON.stringify(message)

      socket.onmessage = (data) ->
        data = JSON.parse data
        console.log data
