helpers = require('enkihelpers')
Q = require('q')
Protocol = require('./protocol')

module.exports = class SlaveProtocol extends Protocol
  handle_open: (connection) =>
    @protocol_ready.resolve(@)

  handle_close: =>
    # Protocol closed - tell the server to clean up.
    @info 'SLAVEPROTOCOL CLOSED'
    if @options.connection_lost
      @options.connection_lost(@connection)
    else
      @warn "Connection Lost Not Implemented"

    return true

  handle_parsed_data: (parsed_data) =>
    if parsed_data.operation.kind is "SNAPSHOT_RESULT"
      @info "IGNORING SNAPSHOT_RESULT"
      return true

    @info 'SLAVERESOLVING', parsed_data.operation.opid
    # Received Operation from connected client. Execute it through the PCE.
    Q.fcall =>
      @options.pce.forward_operation( parsed_data.operation ).then (result) =>
        @info 'PCE COMPLETED', result
        
        # @engine_server.send_all( result )
    .done()
    return true
