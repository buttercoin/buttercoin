Q = require('q')
Protocol = require('../../ews/protocol')
ApiProtocol = require('../api_protocol')
ProxyConnection = require('../../proxy_connection')
MtGoxAdaptor = require('./adaptor')

module.exports = class MtGoxProtocol extends Protocol
  constructor: (options, parent) ->
    super(options, parent)
    options.api ||= {}

    @api = new ApiProtocol(options.api, this)
    @adaptor = new MtGoxAdaptor()
    @proxy = new ProxyConnection()
    @proxy.on('received_data', @handle_proxied_data)

  start: (connection) =>
    @proxy.connect()
    Q.all([
      super(connection)
      @api.start(@proxy) ])

  handle_open: (connection) =>
    @protocol_ready.resolve(this)

  handle_proxied_data: (data) =>
    @info "PROTOCOL SAID:", data
    @connection.send_obj(@adaptor.translate_outbound(data))

  handle_parsed_data: (data) =>
    @info "CLIENT SAID:", data
    @proxy.emit(
      'transport_message',
      @adaptor.translate_inbound(data))

