wrap_error = require('enkihelpers').wrap_error
Connection = require('./connection')

module.exports = class ProxyConnection extends Connection
  create_transport: (config) =>
    @config = config
    @info "CREATING PROXY CONNECTION"
    return this

  prepare_transport: =>
    @on 'transport_error', @handle_error
    @on 'transport_open', wrap_error(@handle_open, @uncaught_exception)
    @on 'transport_close', wrap_error(@handle_close, @uncaught_exception)
    @on 'transport_message', wrap_error(@handle_data, @uncaught_exception)

    return @send_local

  connect: (config) =>
    super(config)
    @emit 'transport_open'

  send_local: (data) =>
    @emit 'received_data', data

  shutdown_transport: (completed) =>
    completed()

  parse_data: (x) -> x
  prepare_data: (x) -> x
 
