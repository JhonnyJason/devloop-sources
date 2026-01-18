############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("taskloopmodule")
#endregion

##############################################################################
import * as Stt from "./statemodule.js"
import * as tg from "./tgmodule.js"
import * as claude from "./claudemodule.js"
import fs from "node:fs/promises"

##############################################################################
state = null
iteration = 0
action = null

##############################################################################
maxCycles = -1 # is taken as infinite

##############################################################################
# Prompt file paths (set by pathmodule)
promptPaths = null

##############################################################################
run = false

##############################################################################



##############################################################################
export initialize = (cfg) ->
    log "initialize"
    if cfg.maxCycles? then maxCycles = cfg.maxCycles
    cfg.onChange("maxCycles", updateMaxCycles)

    process.on("SIGINT", stopExecution)
    return

##############################################################################
updateMaxCycles = (newVal) -> maxCycles = newVal

##############################################################################
export setPromptFilePaths = (paths) ->
    log "setPromptFilePaths"
    promptPaths = paths
    return

##############################################################################
export execute = ->
    log "execute"
    applyLatestState()
    iteration = 0
    run = true
    
    while(run)
        try await taskExecutionCycle()
        catch err then processError(err)
    return

##############################################################################
applyLatestState = ->
    log "applyLatestState"
    state = Stt.getState()
    stateString = state["latest-state"]

    ## TODO check if state is applicable
    ## TODO handle broken state (e.g. if last task execution might still be running)

    switch stateString
        when "" then return
        else console.error("We don't know how to apply State: #{stateString}")        
    return

##############################################################################
checkCycleLimit = ->
    return unless maxCycles > 0 # infinite
    if iteration >= maxCycles then throw new Error("Exceeded maxCycles!")
    return

##############################################################################
processError = (err) ->
    log "processError"
    log err
    ## TODO decide which errors should result in switching off the execution cycle
    run = false # For now: switch if off on every error
    return
    
##############################################################################
stopExecution = ->
    log "stopExecution - SIGINT received"
    run = false
    claude.abort()
    return

##############################################################################
runClaude = (prompt) ->
    log "runClaude"
    result = await claude.execute(prompt)
    if result?.aborted then throw new Error("Claude execution aborted")
    return result

##############################################################################
taskExecutionCycle = ->
    checkCycleLimit()
    logState()

    stateString = state["latest-state"]
    switch(stateString)
        when "" then await findNextTask()
        when "taskRetrieved" then executeTask()
        when "taskExecuted" then reviewTaskExecution()
        else log "unexpected state: #{stateString}"

    iteration++
    return

##############################################################################
findNextTask = ->
    log "findNextTask"
    prompt = await fs.readFile(promptPaths.findTaskPrompt, "utf8")
    await runClaude(prompt)
    ## TODO check for intervention request
    ## TODO do the git commits
    ## TODO save new state
    return

##############################################################################
executeTask = ->
    log "executeTask"
    prompt = await fs.readFile(promptPaths.taskFile, "utf8")
    await runClaude(prompt)
    ## TODO check for intervention request
    ## TODO do the git commits
    ## TODO save new state
    return

##############################################################################
reviewTaskExecution = ->
    log "reviewTaskExecution"
    prompt = await fs.readFile(promptPaths.reviewTaskPrompt, "utf8")
    await runClaude(prompt)
    ## TODO check for intervention request
    ## TODO do the git commits
    ## TODO save new state
    return
    



##############################################################################
logState = -> console.log("@#{(new Date()).toISOString()}:#{iteration} #{state["latest-state"]} TaskId:#{state["latest-taskId"]} action: #{action} ")

##############################################################################
setState = (taskId, stateString) ->
    log "setState"
    state["latest-taskId"] = taskId
    state["latest-state"] = stateString
    await Stt.writeState()
    return