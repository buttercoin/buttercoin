module.exports.Router = class Router
  routers = {}
  @register: (route, builder) => routers[route] = builder

  @route: (request) =>
    for k,v of routers
      regex = new RegExp(k)
      match = regex.exec(request.call)
      return v(match) unless match is null or match is undefined

    throw new Error("Couldn't match route: #{request.call}")

module.exports.Translator = class Translator
  @route: (pattern, builder) ->
    _builder = (match) => new this(builder(match...))
    Router.register(pattern, _builder)
  constructor: (@options) ->
