############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("userconfigurationmodule")
#endregion

############################################################
import * as ui from "./uimodule.js"
import * as config from "./configmodule.js"

############################################################
configurationOptions = {
    "set telegram-bot token": -> await setTelegramToken()
    "set chat id": -> await setChatId()
    "set max cycles": -> await setMaxCycles()
    "check config": -> printConfig()
    "back": -> # handled in loop
}

############################################################
done = false

# local state for immediate feedback
localTgToken = config.tgToken
localTgChatId = config.tgChatId
localMaxCycles = config.maxCycles

############################################################
export configure = ->
    log "configure"
    done = false
    while !done
        choice = await ui.retrieveChoice("Configuration:", Object.keys(configurationOptions))
        if choice == "back" then done = true
        else await configurationOptions[choice]()
    return

############################################################
printConfig = ->
    log "printConfig"
    console.log "tgToken:    #{localTgToken || '(not set)'}"
    console.log "tgChatId:   #{localTgChatId || '(not set)'}"
    console.log "maxCycles:  #{localMaxCycles}"
    return

setTelegramToken = ->
    log "setTelegramToken"
    token = await ui.retrieveSecret("Telegram Bot Token:")
    await config.updateConfig({ tgToken: token })
    localTgToken = token
    console.log "Token updated."
    return

setChatId = ->
    log "setChatId"
    chatId = await ui.retrieveString("Telegram Chat ID:")
    await config.updateConfig({ tgChatId: chatId })
    localTgChatId = chatId
    console.log "Chat ID updated."
    return

setMaxCycles = ->
    log "setMaxCycles"
    input = await ui.retrieveString("Max Cycles (current: #{localMaxCycles}):")
    num = parseInt(input, 10)
    if isNaN(num)
        console.log "Invalid input. Please enter a number."
        return
    await config.updateConfig({ maxCycles: num })
    localMaxCycles = num
    console.log "Max cycles updated."
    return



