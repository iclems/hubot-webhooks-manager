# hubot-webhooks-manager

Webhooks Manager enables you to quickly get a webhook URL from a specific room.
By default, all incoming webhooks will be displayed (POST request body with basic formatting). It is though very easy to add support for specific services by adding a listener for this webhook type (see github's example). 
A webhook can later be removed and blocked from the room. 

Commands: 
*add webhook service*: will generate a new unique URL for this service (e.g. github, jira) to be registered in your service as the webhook URL (expecting POST requests). The service is used to support specific formatters for webhook messages rendering. 
*list webhooks*: provides the list of all registered tokens and services. Useful to remove a webhook or register the URL again.
*remove webhook token*: the exact token must be provided from the right conversation to block a previously registered webhook.
