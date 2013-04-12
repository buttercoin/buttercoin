

module.exports = class API
  constructor: (@engine) ->

  add_deposit: ( args ) ->
    message = ['ADD_DEPOSIT', args ]

    @engine.receive_message(message)

