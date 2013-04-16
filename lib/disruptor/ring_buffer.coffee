assert = require 'assert'

module.exports = class RingBuffer
  ###
  # Create a RingBuffer which pre-allocates a storage array with a given capacity
  #
  # @param {number} @capacity - the size of the ring buffer to allocate. MUST BE A POWER OF 2!!!
  # @return {object} a new RingBuffer instance
  ###
  constructor: (@capacity=1024) ->
    @capacityMask = @capacity - 1 # 1024 -> 100 0000 0000; 1023 -> 011 1111 1111; x & 1023 == x % 1024
    assert (@capacity & @capacityMask) is 0 # only support rings of size 2^n for fast modulo
    @buffer = new Array(@capacity)
    @available = -1
    @next = 0
    @consumers = {}

  ###
  # Reserve the next slot in the ring buffer.
  #
  # WARNING - The producer is currently responsible for not writing past the head of the buffer!
  # WARNING - We do not currently support multiple producers or out-of-order slot filling!!! 
  #
  # @return {function :: a ->()} a callback which accepts the generated value for this slot.
  #                              Calling this will place the value in the ring buffer and update
  #                              the sequence counter of the ring buffer.
  ###
  claim: ->
    # TODO - take a callback and block the producer if the buffer is full? 
    idx = @next & @capacityMask # bitmask modulo
    nxt = @next # copy for lambda capture 
    @next += 1
    (value) => # TODO - support multiple producers?
      @buffer[idx] = value
      @available = nxt # blindly set the next available sequence number to the one just published
                       # this isn't safe if we support multiple producers
      return null
  
  ###
  # Provide the n-th item, modulo capacity, in the ring buffer
  ###
  read: (n) ->
    @buffer[n & @capacityMask]

  ###
  # Get the current sequence number (supporting the SequenceBarrier protocol)
  #
  # @return {number} the current available sequence max of the buffer
  ###
  sequence: -> @available

