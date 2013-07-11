Q = require('q')
Protocol = require('../../ews/protocol')
ApiProtocol = require('../api_protocol')
ProxyConnection = require('../../proxy_connection')
MtGoxAdaptor = require('./adaptor')

tmp_auth_provider = {}
tmp_auth_provider["534ae7aea872406cbbae6ba2dd5ec515"] = "UW+9oWmPtmeNwOv8hVSY5QBmg51r74aSlyUe3x3r/UhaCsyNZDSFidNCfQfjQCIFfPLHjpPi7hT7PYQzghZcmw=="

module.exports = class MtGoxProtocol extends Protocol
  constructor: (options, parent) ->
    super(options, parent)
    options.api ||= {}

    @api = new ApiProtocol(options.api, this)
    @adaptor = new MtGoxAdaptor(tmp_auth_provider)
    @proxy = new ProxyConnection()
    @proxy.on('received_data', @handle_proxied_data)

  start: (connection) =>
    @proxy.connect()
    Q.all([
      super(connection)
      @api.start(@proxy) ])

  handle_open: (connection) =>
    @protocol_ready.resolve(this)
    @adaptor.handle_open(connection)

  handle_proxied_data: (data) =>
    @info "PROTOCOL SAID:", data
    @connection.send_obj(@adaptor.translate_outbound(data))

  handle_parsed_data: (data) =>
    data = @adaptor.translate_inbound(data)
    @info "CLIENT SAID:", data
    @proxy.emit(
      'transport_message',
      data)
