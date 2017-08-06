# Required: WEHOOKS_MANAGER_SECRET
# Optional: HUBOT_URL

jwt = require "jsonwebtoken"
_ = require "underscore"

HUBOT_URL = process.env.HUBOT_URL || ""
WEBHOOKS_MANAGER_SECRET = process.env.WEBHOOKS_MANAGER_SECRET || ""

INCOMING_PATH = "/hubot/webhooks-manager/incoming/"

envelope_key = (e) ->
  e.room || e.user.i

keyFromToken = (t) ->
  t.replace /\./g, "_"

module.exports = (robot) ->

  robot.brain.data.webhooksManager ?= {}

  addWebhook = (service, room) ->
    info = { service: service, room: room }
    token = jwt.sign info, WEBHOOKS_MANAGER_SECRET
    robot.brain.data.webhooksManager[room] ?= {}
    robot.brain.data.webhooksManager[room][keyFromToken(token)] = { service: service, token: token, ts: new Date().getTime() }
    return token

  removeWebhook = (token, room) ->
    error = null
    try
      decoded = jwt.verify token, WEBHOOKS_MANAGER_SECRET
      if (room && room == decoded.room)
        robot.brain.data.webhooksManager[room][keyFromToken(token)] = null
      else
        error = "room mismatch"
    catch e
      error = e
    return error

  robot.respond /add\s+webhook\s+(\w+)/i, (msg) ->
    service = msg.match[1]
    room = envelope_key msg.envelope
    token = addWebhook(service, room)
    msg.send "Webhook configured. Listening for "+service+" at URL: "+HUBOT_URL+INCOMING_PATH+token

  robot.respond /remove\s+webhook\s+([^\s]+)/i, (msg) ->
    token = msg.match[1]
    room = envelope_key msg.envelope
    error = removeWebhook(token, room)
    msg.send "Webhook "+error?error:"removed."

  robot.respond /(list|show|all)\s+webhook(s)?/i, (msg) ->
    room = envelope_key msg.envelope
    webhooks = robot.brain.data.webhooksManager[room] || {}
    if _.keys(webhooks).length
      msg.send _.map(webhooks, (w, k) -> ( w.service+": "+w.token )).join "\n"
    else
      msg.send "No webhook configured for this room."

  robot.router.post "/"+INCOMING_PATH+":token", (req, res) ->
    token = req.params.token
    try
      webhook = jwt.verify token, WEBHOOKS_MANAGER_SECRET
      room = webhook.room
      if (debug)
        robot.logger.info "Webhooks manager received: ", req
      if (robot.brain.data.webhooksManager[room][keyFromToken(token)])
        robot.emit "incoming-webhook:"+webhook.service, webhook, req
    catch error
      robot.logger.error "Webhooks manager error: #{error.stack}. Request: #{req.body}"

    res.end ""
