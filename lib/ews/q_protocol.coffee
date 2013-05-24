_ = require('underscore')
Q = require('q')
Protocol = require('./protocol')

module.exports = class QueryProtocol extends Protocol
  constructor: (options, parent) ->
    super(options, parent)

    @query_interface = @options.query_provider
    @handlers =
      GET_BALANCES: @get_balances

  handle_close: =>
    @info 'QUERY PROTOCOL CLOSED'
    @options.connection_lost(@connection)

  handle_parsed_data: (parsed_data) =>
    unless parsed_data?.kind in _.keys(@handlers)
      @info "INVALID OPERATION", parsed_data?.kind
      @options.send({
        status: "error",
        message: "Invalid operation: #{parsed_data?.kind}"
        operation: parsed_data
      })

    result = @handlers[parsed_data.kind](parsed_data.args...)
    result.operation = parsed_data
    @options.send(result)

  get_balances: (account_id) =>
    res = @query_interface.get_balances(account_id)
    return {balances: res}
