stump = require('stump')

enkihelpers = require('enkihelpers')

# EventEmitter = require('eemitterport').EventEmitter
EventEmitter = require('chained-emitter').EventEmitter

Q = require('q')
Connection = require('./ws_connection')

# Protocol = require('./protocol')

module.exports = class Initiator extends EventEmitter
  constructor: (@options, @parent) ->
    if not @parent
      stump.stumpify(this, @constructor.name)
    else
      @parent.stumpify(this, @constructor.name)

    @operation_tracker = {}

  connect: () =>
    # Create Connection, hook up protocol, and get socket.connect
    #    - return promise to fire when connected

    @connection = new Connection(this)
    if @options.protocol
      promise = @options.protocol.start(@connection)
    else
      throw Error("No Protocol in Initiator")
    @connection.connect( @options.wsconfig )

    # XXX - this promise sometimes doesn't get a .done() call
    # (i.e. exceptions can get swallowed"
    return promise

  execute_operation: (_operation) =>
  # Send operation to server, provide promise
  #  - call promise when operation either succeeded or failed.
    @options.protocol.execute_operation(_operation)

if !module.parent
  initiator = new Initiator( {wsconfig: 'ws://localhost:6150/'} )
  initiator.connect()
