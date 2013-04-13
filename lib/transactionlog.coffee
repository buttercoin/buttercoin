Q = require('q')
FS = require("q-io/fs")
jspack = require('jspack').jspack

module.exports = class TransactionLog
  constructor: (engine) ->
    @filename = 'transaction.log'

  start: =>
    return FS.exists(@filename).then (retval) =>
      if retval
        console.log 'LOG EXISTS'
        Q.fcall =>
          @replay_log().then =>
            # This is dangerous
            @initialize_log()
      else
        console.log 'LOG DOES NOT EXIST'
        Q.fcall =>
          @initialize_log().then =>
            return null

  initialize_log: =>
    console.log 'INITIALIZING LOG'
    FS.open(@filename, {flags: "w"}).then (writestream) =>
      @writestream = writestream
      return null

  replay_log: =>
    FS.open(@filename, {flags: "r"}).then (readstream) =>
      @readstream = readstream
      @readstream.forEach (chunk) =>
        # XXX: buffered read and replay
        console.log 'READ CHUNK', chunk

  record: (message) =>
    console.log 'RECORDING', message
    l = message.length

    part = jspack.Pack('I', [l])

    buf = Buffer.concat [ Buffer(part), Buffer(message) ]

    @writestream.write(buf)