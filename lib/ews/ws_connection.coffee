WebSocket = require('wsany')
wrap_error = require('enkihelpers').wrap_error

Connection = require('../connection')

module.exports = class WsConnection extends Connection
  create_transport: (config) =>
    @info "CREATING WEBSOCKET CONNECTION"
    new WebSocket( config )

  ###
  # Setup transport callbacks and return the function used to send data over the
  # transport.
  ###
  prepare_transport: =>
    @transport.on 'error', @handle_error
    @transport.on 'open', wrap_error(@handle_open, @uncaught_exception)
    @transport.on 'close', wrap_error(@handle_close, @uncaught_exception)
    @transport.on 'message', wrap_error(@handle_data, @uncaught_exception)

    return @transport.send

  shutdown_transport: (completed) =>
    @transport.once 'close', completed
    @transport.close()

  parse_data: JSON.parse
  prepare_data: JSON.stringify
