WebSocket = require('ws')
WebSocketServer = require('ws').Server

Buttercoin = require('../lib/buttercoin')

message = ["ADD_DEPOSIT", {'account': 'Marak', 'password': 'foo', 'currency': 'USD', 'amount': 200.0}]

describe 'Front', ->

  describe 'new Front', ->

    it 'can initialize', ->
      butter = new Buttercoin

    it 'should start, connect to api, and provide a WS server', (done) ->
      butter = new Buttercoin
      butter.api.start {port: 3043, host: "0.0.0.0" }, (err, server) =>
        butter.api_client.start {port: 3042, host: "0.0.0.0", engineEndpoint: 'ws://0.0.0.0:3043' }, (err, server) =>
          butter.front.start {port: 3044, host: "0.0.0.0", apiEndpoint: 'ws://0.0.0.0:3042' }, (err, server) =>
            done(null)

    it 'should be able to have a generic ws client connect and send message', (done) ->

      socket = require('engine.io-client')('ws://0.0.0.0:3044');

      return done(null)

      socket.onopen = ->
        socket.send JSON.stringify(message)

      socket.onmessage = (data) ->
        data = JSON.parse data
        console.log data
