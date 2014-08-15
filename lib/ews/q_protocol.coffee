Q = require('q')
Protocol = require('./protocol')

module.exports = class QueryProtocol extends Protocol
  constructor: (options, parent) ->
    super(options, parent)

    @query_interface = @options.query_provider
    @handlers =
      GET_BALANCES: @get_balances
      TICKER: @get_ticker

  handle_close: =>
    @info 'QUERY PROTOCOL CLOSED'
    @options.connection_lost(@connection)

  handle_parsed_data: (parsed_data) =>
    unless parsed_data?.query in Object.keys(@handlers)
      @info "INVALID QUERY", parsed_data?.kind
      @options.send({
        status: "error",
        message: "Invalid operation: #{parsed_data?.kind}"
        operation: parsed_data
      })

    result = @handlers[parsed_data.query](parsed_data)
    result.operation = parsed_data
    @options.send(result)

  get_balances: (query) =>
    res = @query_interface.get_balances(query.account)
    return {balances: res}

  get_ticker: (query) =>
    return @query_interface.get_ticker(query.currencies...)
    
    
