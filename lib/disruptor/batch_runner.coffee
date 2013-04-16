# TODO - handle sequence overflow
module.exports = class BatchRunner
  constructor: (@buffer, @barrier, @processor) ->
    @sequence = -1

  getBatch: ->
    return [] unless @sequence < @barrier.sequence()
    [(@sequence + 1) .. @barrier.sequence()].map (n) => @buffer.read(n)

  sync: ->
    batch = @getBatch()
    batch.forEach @processor # TODO - maybe wrap this so processors can't grab the ring-buffer storage array
    @sequence += batch.length

