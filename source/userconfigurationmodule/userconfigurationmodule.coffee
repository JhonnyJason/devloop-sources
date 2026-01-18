############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("userconfigurationmodule")
#endregion

############################################################
import * as ui from "./uimodule.js"
import * as cfg from "./configmodule.js"

############################################################
configurationOptions = {
    "set telegram-bot token": -> await setTelegramToken()
    "set chat id": -> await setChatId()
    "set max cycles": -> await setMaxCycles()
    "check config": -> printConfig()
    "back": -> # handled in loop
}

############################################################
# handle values locally - for updates
localTgToken = cfg.tgToken
localTgChatId = cfg.tgChatId
localMaxCycles = cfg.maxCycles

############################################################
export configure = ->
    log "configure"
    choices = Object.keys(configurationOptions)
    loop
        try choice = await ui.retrieveChoice("Configuration:", choices)
        catch err then return
        if choice == "back" then return

        await configurationOptions[choice]()
    return

############################################################
effectiveMaxCycles = ->
    if (localMaxCycles < 1) then return "Infinite"
    return localMaxCycles

############################################################
printConfig = ->
    log "printConfig"
    console.log "_________________________________ currently configured:"
    console.log ""
    console.log "tgToken:    #{localTgToken || '(not set)'}"
    console.log "tgChatId:   #{localTgChatId || '(not set)'}"
    console.log "maxCycles:  #{effectiveMaxCycles()}"
    console.log ""
    return

############################################################
setTelegramToken = ->
    log "setTelegramToken"
    try token = await ui.retrieveSecret("Telegram Bot Token:")
    catch err then return

    await cfg.updateConfig({ tgToken: token })
    localTgToken = token
    console.log "Token updated."
    return

setChatId = ->
    log "setChatId"
    try chatId = await ui.retrieveString("Telegram Chat ID:")
    catch err then return

    await cfg.updateConfig({ tgChatId: chatId })
    localTgChatId = chatId
    console.log "Chat ID updated."
    return

setMaxCycles = ->
    log "setMaxCycles"
    try input = await ui.retrieveString("Max Cycles (current: #{effectiveMaxCycles()}):")
    catch err then return

    num = parseInt(input, 10)
    if !input or num < 1 then num = -1 # interpreted as Infinite
    if input and isNaN(num)
        console.log 'Invalid input.\n  Please enter a positive number for setting a finite maximum ot task cylces.\n  Notice: 0, negative numbers and empty input leads to "Infinite".'
        return
    
    await cfg.updateConfig({ maxCycles: num })
    localMaxCycles = num
    console.log "Max cycles updated."
    return



