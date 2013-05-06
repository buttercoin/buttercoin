helpers = require('enkihelpers')

Q = require('q')

Protocol = require('./protocol')

module.exports = class EngineProtocol extends Protocol
  handle_close: =>
    @info 'PROTOCOL CLOSED'
    @engine_server.connection_lost(@connection)

  handle_parsed_data: (parsed_data) =>
    # @info 'RECEIVED', parsed_data
    @pce.forward_operation( parsed_data ).then (result) =>
      @info 'PCE COMPLETED', result
      
      @engine_server.send_all( result )
    .done()