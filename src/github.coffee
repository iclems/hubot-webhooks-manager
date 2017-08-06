module.exports = (robot) ->
  robot.on "incoming-webhook:github", (info, req) ->
    eventType   = req.headers["x-github-event"]
    signature   = req.headers["X-Hub-Signature"]
    deliveryId  = req.headers["X-Github-Delivery"]
    payload     = req.body
    robot.logger.info "incoming-webhook:github", eventType, deliveryId
    message = "[#{payload.repository.full_name}] #{payload.sender.login}: #{eventType}"
    switch eventType
      when "push"
        robot.reply { room: info.room }, "[#{payload.repository.full_name}] #{payload.sender.login} pushed #{payload.commits.length} commits #{payload.compare}"
    robot.reply { room: info.room }, message
