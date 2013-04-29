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
    conn.send_obj( {a: 6} )

if !module.parent
  initiator = new Initiator( {wsconfig: 'ws://localhost:6150/'} )
  initiator.connect()