Q = require('q')

operations = require('operations')

DataStore = require('datastore')

module.exports = class TradeEngine
  constructor: ->
    @datastore = new DataStore

  execute_operation: (op) ->
    # Makes calls into datastore and then handles callbacks for operation.

    if op.kind == operations.ADD_DEPOSIT
      retval = datastore.add_deposit( op )
    else
      throw Error("Unknown Operation")

    # call callback with retval

