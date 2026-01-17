############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("userconfigurationmodule")
#endregion

############################################################
import * as ui from "./uimodule.js"

############################################################
configurationOptions = {
    "set telegram-bot token": -> await setTelegramToken()
    "set chat id": -> await setChatId()
    "check config": -> printConfig()
    "back": -> terminateConfiguration()
}

############################################################
export configure = ->
    log "configure"
    ## TODO start loop to Ask for user Choices
    return

############################################################
terminateConfiguration = ->
    log "terminateConfiguration"
    ## TODO implement
    return

printConfig = ->
    log "printConfig"
    ## TODO implement only print what we maintain here (tgToken + tgChatId)
    return

setTelegramToken = ->
    log "setTelegramToken"
    ## TODO implement
    return

setChatId = ->
    log "setChatId"
    ## TODO implement
    return



