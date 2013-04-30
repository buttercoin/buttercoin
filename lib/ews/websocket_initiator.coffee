stump = require('stump')

EventEmitter = require('eemitterport').EventEmitter
Q = require('q')
Connection = require('./websocket_connection')
# Protocol = require('./protocol')

module.exports = class Initiator extends EventEmitter
  constructor: (@options) ->
    stump.stumpify(@, @constructor.name)

    @node = null

  connect: () =>
    @deferred = Q.defer()

    @connection = new Connection(@)
    @connection.once 'open', @establish_protocol
    @connection.connect( @options.wsconfig )

    return @deferred.promise

  establish_protocol: (conn) =>
    conn.on 'parsed_data', (data) =>
      @info 'GOT', data
    conn.send_obj( {kind: "ADD_DEPOSIT", account: "peter", amount: "5", currency: 'BTC'} )

if !module.parent
  initiator = new Initiator( {wsconfig: 'ws://localhost:6150/'} )
  initiator.connect()