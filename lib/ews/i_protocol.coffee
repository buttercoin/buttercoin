helpers = require('enkihelpers')
Q = require('q')
Protocol = require('./protocol')

module.exports = class InitiatorProtocol extends Protocol
  handle_open: (connection) =>
    @protocol_ready.resolve(@)
    @operation_tracker = {}

  handle_parsed_data: (data) =>
    deferred = @operation_tracker[data?.operation?.opid]
    if deferred
      delete @operation_tracker[data.operation.opid]
      deferred.resolve(data)
    else
      # don't emit transactional responses
      @emit('data', data)

    #@emit 'data', data

  execute_operation: (_operation) =>
    operation = helpers.extend({}, _operation)

    deferred = Q.defer()
    opid = operation.opid = helpers.generate_id(128)
    @operation_tracker[opid] = deferred

    @protocol_ready.promise.then =>
      @connection.send_obj( operation )
      #@info "EXECUTE OPERATION", _operation
      return deferred.promise
