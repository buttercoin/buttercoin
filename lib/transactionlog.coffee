fs = require 'fs'

module.exports = class TransactionLog
  constructor: ->
    @filename = 'transaction.log'

  record: (message) =>
    l = len(message)
    buf = new Buffer( 4 + l )

    fs.appendFileSync(@filename, message)