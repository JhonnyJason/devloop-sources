############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("taskloopmodule")
#endregion

##############################################################################
import * as Stt from "./statemodule.js"

##############################################################################
state = null
iteration = 0
action = null

##############################################################################
maxCycles = Infinity 

##############################################################################
export initialize = (cfg) ->
    log "initialize"
    if cfg.maxCycles? then maxCycles = cfg.maxCycles
    return

##############################################################################
export execute = ->
    log "execute"
    process.on("SIGINT", stopExecution)
    try loop await taskExecutionCycle()
    catch err then console.log err
    return

##############################################################################
stopExecution = ->
    log "stopExecution - SIGINT received"
    ## TODO graceful shutdown
    process.exit(0)

##############################################################################
taskExecutionCycle = ->
    logState()
    if iteration == maxCycles then throw new Error("Exceeded maxCycles!")
    ## TODO implement
    
    iteration++
    return

##############################################################################
logState = -> log("@#{(new Date())}:#{iteration} #{state["latest-state"]} TaskId:#{state["latest-taskId"]} action: #{action} ")

##############################################################################
setState = (taskId, stateString) ->
    log "setState"
    state["latest-taskId"] = taskId
    state["latest-state"] = stateString
    await Stt.writeState()
    return