stump = require('stump')

enkihelpers = require('enkihelpers')

EventEmitter = require('eemitterport').EventEmitter
Q = require('q')
Connection = require('./websocket_connection')

# Protocol = require('./protocol')

module.exports = class Initiator extends EventEmitter
  constructor: (@options, @parent) ->
    if not @parent
      stump.stumpify(@, @constructor.name)
    else
      @parent.stumpify(@, @constructor.name)

    @operation_tracker = {}

  connect: () =>
    @connect_deferred = Q.defer()

    @connection = new Connection(@)
    @connection.once 'open', @establish_protocol
    @connection.connect( @options.wsconfig )

    return @connect_deferred.promise

  establish_protocol: (conn) =>
    conn.on 'parsed_data', (data) =>
      @info 'RESOLVING', data.operation.opid
      deferred = @operation_tracker[data.operation.opid]
      if deferred
        delete @operation_tracker[data.operation.opid] 
        deferred.resolve(data)
      
    @connect_deferred.resolve(true)

  execute_operation: (_operation) =>
    operation = enkihelpers.extend({}, _operation)

    deferred = Q.defer()
    opid = operation.opid = enkihelpers.generate_id(128)
    @operation_tracker[opid] = deferred

    @connect_deferred.promise.then =>
      @connection.send_obj( operation )
      return deferred.promise

if !module.parent
  initiator = new Initiator( {wsconfig: 'ws://localhost:6150/'} )
  initiator.connect()