helpers = require('enkihelpers')

Q = require('q')

Protocol = require('./protocol')

module.exports = class InitiatorProtocol extends Protocol
  handle_open: (connection) =>
    @protocol_ready.resolve(@)

    @operation_tracker = {}

  handle_close: =>
    # Protocol closed - tell the server to clean up.
    @info 'PROTOCOL CLOSED'
    if @options.connection_lost
      @options.connection_lost(@connection)
    else
      @warn "Connection Lost Not Implemented"

  handle_parsed_data: (data) =>
    @info 'RESOLVING', data.operation.opid
    deferred = @operation_tracker[data.operation.opid]
    if deferred
      delete @operation_tracker[data.operation.opid] 
      deferred.resolve(data)

  execute_operation: (_operation) =>
    operation = helpers.extend({}, _operation)

    deferred = Q.defer()
    opid = operation.opid = helpers.generate_id(128)
    @operation_tracker[opid] = deferred

    @protocol_ready.promise.then =>
      @connection.send_obj( operation )
      return deferred.promise
