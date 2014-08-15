wrap_error = require('enkihelpers').wrap_error
Connection = require('../connection')
#ioc = require('socket.io-client')

module.exports = class SocketIOConnection extends Connection
  create_transport: (config) =>
    @error "Cannot create socket.io client connection, socket.io and socket.io-client don't play well together in the same process"
    throw new Error("Unsupported Operation - SocketIOConnection.create_transport")

  ###
  # Setup transport callbacks and return the function used to send data over the
  # transport.
  ###
  prepare_transport: =>
    @info "PREPARE SOCKET.IO TRANSPORT"

    @transport.on 'error', @handle_error
    @transport.on 'connect', wrap_error(@handle_open, @uncaught_exception)
    @transport.on 'disconnect', wrap_error(@handle_close, @uncaught_exception)
    @transport.on 'message', wrap_error(@handle_data, @uncaught_exception)

    return @transport.send

  shutdown_transport: (completed) =>
    @transport.once 'disconnect', completed
    @transport.disconnect()

  parse_data: JSON.parse
  prepare_data: JSON.stringify

