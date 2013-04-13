fs = require('fs')

jspack = require('jspack').jspack

module.exports = class TransactionLog
  constructor: (engine) ->
    @filename = 'transaction.log'

    @writestream = fs.createWriteStream(@filename)

  read: =>
    data = fs.readFileSync(@filename)

  record: (message) =>
    l = message.length

    part = jspack.Pack('I', [l])

    buf = Buffer.concat [ Buffer(part), Buffer(message)]

    @writestream.write(buf)
