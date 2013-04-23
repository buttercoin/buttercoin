assert = require('assert')

module.exports = class SequenceBarrier
  ###
  # Create a SequnceBarrier which aggregates a set of upstream dependency counters.
  #
  # @param {object or [object]} @deps the upstream dependencies to gate against. 
  ###
  constructor: (@deps) ->
    assert @deps isnt undefined and @deps isnt null
    @deps = [@deps] unless Array.isArray(@deps)

  ###
  # Get the lowest sequence number shared by upstream dependencies. 
  #
  # @return {number} the sequence number to consume against
  ###
  sequence: ->
    seqs = @deps.map (x) ->
      if x.sequence.constructor is Function
        x.sequence()
      else
        x.sequence
    Math.min.apply(Math, seqs)

  
