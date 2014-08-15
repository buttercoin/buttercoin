Protocol = require('../ews/protocol')
operations = require('../operations')

module.exports = class ApiProtocol extends Protocol
  mkAcctListeners: (account_id) =>
    mkOp = (op) -> "#{op}?account=#{account_id}"
    [ [mkOp(operations.ADD_DEPOSIT), @report_deposit]
      [mkOp(operations.WITHDRAW_FUNDS), @report_withdrawl]
      [mkOp(operations.CREATE_LIMIT_ORDER), @report_user_order]
      [mkOp(operations.CANCEL_ORDER), @report_user_cancelled_order]]

  mkGeneralListeners: =>
    [ [operations.CREATE_LIMIT_ORDER, @report_order]
      [operations.CANCEL_ORDER, @report_cancelled]]

  handle_open: (connection) =>
    @authenticated = false
    @api = @options.event_source
    for x in @mkGeneralListeners()
      @api.on(x...)

    @protocol_ready.resolve(this)

  report_deposit: =>
  report_withdrawl: =>
  report_user_order: =>
  report_user_cancelled_order: =>

  handle_parsed_data: (data) =>
    if data.operation is 'AUTH'
      @handle_auth_request(data)
    else if data.operation isnt undefined
      @api.engine.execute_operation(data).then (result) =>
        @connection.send_obj result
    else if data.query isnt undefined
      @api.query.execute_operation(data).then (result) =>
        @connection.send_obj result
    else
      @connection.send_obj
        operation: data
        result: 'bad_request'

  handle_auth_request: (data) =>
    # TODO - real auth
    unless @authenticated and data.account_id
      @authenticated = true
      @handle_auth_success(data)
    else
      @handle_auth_failure(data)

  handle_auth_success: (data) =>
    @info "AUTH SUCCESS"
    for x in @mkAcctListeners(data.account_id)
      @options.event_source.on(x...)
  
    @connection.send_obj
      operation: data
      result: 'success'

  handle_auth_failure: (data) =>
    @info "AUTH FAILURE"
    @connection.send_obj
      operation: data
      result: 'failure'

  handle_close: =>
    for x in @mkGeneralListeners()
      @api.removeListener(x...)

    if @account_id
      for x in @mkAcctListeners(@account_id)
        @api.removeListener(x...)
