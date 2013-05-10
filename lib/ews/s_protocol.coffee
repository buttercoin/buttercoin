helpers = require('enkihelpers')

Q = require('q')

Protocol = require('./protocol')

# module.exports = class SlaveProtocol extends Protocol
#   handle_close: =>
#     # Protocol closed - tell the server to clean up.
#     @info 'PROTOCOL CLOSED'
#     @engine_server.connection_lost(@connection)

#   handle_parsed_data: (parsed_data) =>
#     # Received Operation from connected client. Execute it through the PCE.
#     @pce.forward_operation( parsed_data ).then (result) =>
#       @info 'PCE COMPLETED', result
      
#       @engine_server.send_all( result )
#     .done()