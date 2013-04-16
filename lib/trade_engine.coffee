Q = require('q')

operations = require('./operations')

DataStore = require('./datastore/datastore')

module.exports = class TradeEngine
  constructor: ->
    @datastore = new DataStore

  execute_operation: (op) ->
    # Makes calls into datastore and then handles callbacks for operation.
    ###
    if op.kind == operations.ADD_DEPOSIT
      datastore.add_deposit( op )
    else
    ###
    throw Error("Unknown Operation")

