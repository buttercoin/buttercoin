Tempfile = require('temporary/lib/file')

PCE = require('../lib/processingchainentrance')
Journal = require('../lib/journal')
TradeEngine = require('../lib/journal')

#sinon = require('sinon')
Q = require('Q')

journalFile = new Tempfile
replicationStub = (->
  deferred = Q.defer()
  deferred.resolve(undefined)
  {start: (-> deferred.promise), send: (-> deferred.promise)}
)()

pce = new PCE(new TradeEngine(), new Journal(journalFile.path), replicationStub)

count = 10000

old_log = console.log
console.log = ->

pce.start().then ->
  startTime = process.hrtime()
  qs = for n in [1..count]
    pce.forward_operation({kind: 'test'})
    #Q.fcall 1

  submitTime = process.hrtime(startTime)

  Q.all(qs).fail(->).fin(->
    elapsedTime = process.hrtime(startTime)
    elapsedTime = elapsedTime[0]*1000 + elapsedTime[1] / 1000000
    submitTime = submitTime[0]*1000 + submitTime[1] / 1000000

    console.log = old_log
    console.log "#{count} ops in #{submitTime.toFixed(3)} ms"
    tps = count/(submitTime/1000)
    console.log "\t#{tps.toFixed(0)} TPS, #{(submitTime/count).toFixed(3)} ms/op"
    console.log "\tjournal written in #{elapsedTime.toFixed(3)} ms"
    console.log "\t#{(count/(elapsedTime/1000)).toFixed(0)} JPS, #{(elapsedTime/count).toFixed(3)} ms/op"
    journalFile.unlink()
  ).done()

