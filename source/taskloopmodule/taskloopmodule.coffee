############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("taskloopmodule")
#endregion

##############################################################################
import * as Stt from "./statemodule.js"
import * as tg from "./tgmodule.js"

##############################################################################
state = null
iteration = 0
action = null

##############################################################################
maxCycles = -1 # is taken as infinite
##############################################################################
claudeAbortion = null

##############################################################################
run = false

##############################################################################



##############################################################################
export initialize = (cfg) ->
    log "initialize"
    if cfg.maxCycles? then maxCycles = cfg.maxCycles
    cfg.onChange("maxCylces", updateMaxCycles)

    process.on("SIGINT", stopExecution)
    return

##############################################################################
updateMaxCycles = (newVal) -> maxCycles = newVal

##############################################################################
export execute = ->
    log "execute"
    applyLatestState()
    iteration = 0
    run = true
    tg.send("Started Devloop - now tasks are executed autonomously.\n")
    
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
    if claudeAbortion? then claudeAbortion()
    return

##############################################################################
runClaude = ->
    log "runClaude"
    ## TODO implement
    
    fakeClaudProcess = (rslv, rjct) -> # mocked claude Process with simple delay
        setTimeout(rslv, 33333)
        claudeAbortion = rjct
        return
    await new Promise(fakeClaudProcess)   
    return

##############################################################################
taskExecutionCycle = ->
    checkCycleLimit()
    logState()
    ## TODO implement

    await runClaude()
    ## Save new State.
    iteration++
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