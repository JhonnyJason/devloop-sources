############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("uimodule")
#endregion

############################################################
# Adapter layer over enquirer - exposes only what we need

############################################################
import enquirer from "enquirer"

############################################################
export initialize = ->
    log "initialize"
    ## let's see if we need to initialize anything here
    return

############################################################
#region Main Interface
export retrieveString = (prompt) ->
    log "retrieveString"
    try
        response = await enquirer.prompt({
            type: "input"
            name: "value"
            message: prompt
        })
        log "received response"
        olog response
        return response.value
    catch err then log err
    console.log("User input rejected - Bye!")
    process.exit(0)
    return

############################################################
export retrieveSecret = (prompt) ->
    log "retrieveSecret"
    try
        response = await enquirer.prompt({
            type: "password"
            name: "value"
            message: prompt
        })
        log "received response"
        olog response
        return response.value
    catch err then log err
    console.log("User input rejected - Bye!")
    process.exit(0)
    return

############################################################
export retrieveChoice = (prompt, choices) ->
    log "retrieveChoice"
    try
        response = await enquirer.prompt({
            type: "select"
            name: "value"
            message: prompt
            choices: choices
        })
        return response.value
    catch err then log err
    console.log("User input rejected - Bye!")
    process.exit(0)
    return

#endregion