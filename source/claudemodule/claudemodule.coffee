############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("claudemodule")
#endregion

############################################################
import { query } from "@anthropic-ai/claude-agent-sdk"

############################################################
workingDirectory = null
abortController = null

############################################################
export initialize = (cfg) ->
    log "initialize"
    return

############################################################
export setWorkingDirectory = (wd) ->
    log "setWorkingDirectory"
    workingDirectory = wd
    return

############################################################
export execute = (prompt) ->
    log "execute"
    throw new Error("Working directory not set!") unless workingDirectory?

    abortController = new AbortController()
    result = null

    try
        for await message from query({ prompt, options: getOptions() })
            handleMessage(message)
            if message.type == "result" then result = message
    catch err
        if err.name == "AbortError"
            log "Execution aborted"
            return { aborted: true }
        throw err
    finally
        abortController = null

    return result

############################################################
getOptions = ->
    return {
        cwd: workingDirectory
        abortController: abortController
        permissionMode: "bypassPermissions"
        allowDangerouslySkipPermissions: true
    }

############################################################
handleMessage = (message) ->
    switch message.type
        when "assistant"
            logAssistantMessage(message)
        when "result"
            log "Result: #{message.subtype}"
        else
            log "Message type: #{message.type}"
    return

############################################################
logAssistantMessage = (message) ->
    return unless message.message?.content?
    for block in message.message.content
        if block.text? then log block.text
        else if block.name? then log "Tool: #{block.name}"
    return

############################################################
export abort = ->
    log "abort"
    if abortController? then abortController.abort()
    return
