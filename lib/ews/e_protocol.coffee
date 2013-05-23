helpers = require('enkihelpers')

Q = require('q')

Protocol = require('./protocol')

module.exports = class EngineProtocol extends Protocol
  handle_close: =>
    # Protocol closed - tell the server to clean up.
    @info 'PROTOCOL CLOSED'
    @options.connection_lost(@connection)

  handle_parsed_data: (parsed_data) =>
    if parsed_data.kind is 'SNAPSHOT'
      @info 'TAKING PCE SNAPSHOT'
      @options.pce.create_snapshot().then (result) =>
        @info 'SNAPSHOT DONE'
        result =
          operation:
            kind: 'SNAPSHOT_RESULT'
            opid: parsed_data.opid
            serial: result.serial
            snapshot: result.snapshot
        @options.send_all( result )
      #.done()
    else
      # Received Operation from connected client. Execute it through the PCE.
      @options.pce.forward_operation( parsed_data ).then (result) =>
        @info 'PCE COMPLETED', result
        
        @options.send_all( result )
      #.done()
