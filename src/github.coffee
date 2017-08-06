module.exports = (robot) ->
  robot.on "incoming-webhook:github", (info, req) ->
    eventBody =
      eventType   : req.headers["x-github-event"]
      signature   : req.headers["X-Hub-Signature"]
      deliveryId  : req.headers["X-Github-Delivery"]
      payload     : req.body
    robot.logger.info "incoming-webhook:github", eventBody
