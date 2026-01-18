############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("tgmodule")
#endregion

############################################################
#region Local Variables
tgUrlSendMessage = null
chatId = null

#endregion

############################################################
export initialize = (cfg) ->
    log "initialize"
    cfg.onChange("tgChatId", updateChatId)
    chatId = cfg.tgChatId
    cfg.onChange("tgChatId", updateChatId)

    tgUrlSendMessage = 'https://api.telegram.org/bot' + cfg.tgToken + '/sendMessage'
    cfg.onChange("tgToken", updateToken)
    return

############################################################
updateChatId = (newVal) -> chatId = newVal
updateToken = (newVal) -> tgUrlSendMessage = 'https://api.telegram.org/bot' + newVal + '/sendMessage'

############################################################
export send = (msg) ->
    options = {
        method: 'POST'
        headers: { 'Content-Type': 'application/json' }
        body: '{"chat_id":'+chatId+',"text":"'+msg+'"}'
    }
    try resp = await fetch(tgUrlSendMessage, options)
    catch err then console.error(err)
    
    if !resp.ok then console.error("Telegram Response was not OK! (#{resp.status})")
    return
