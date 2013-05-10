helpers = require('enkihelpers')

Q = require('q')

Protocol = require('./protocol')

module.exports = class EngineProtocol extends Protocol
  handle_close: =>
    # Protocol closed - tell the server to clean up.
    @info 'PROTOCOL CLOSED'
    @options.connection_lost(@connection)

  handle_parsed_data: (parsed_data) =>
    # Received Operation from connected client. Execute it through the PCE.
    @options.pce.forward_operation( parsed_data ).then (result) =>
      @info 'PCE COMPLETED', result
      
      @options.send_all( result )
    .done()