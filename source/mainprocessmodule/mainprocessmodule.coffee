##############################################################################
#region debug
import {createLogFunctions} from "thingy-debug"
{log, olog} = createLogFunctions("mainprocessmodule")

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
export execute = (args) ->
    log "execute"
    state = await Stt.readState(args.wd)

    try loop await executionCycle()    
    catch err then console.log err
    return

##############################################################################
executionCycle = ->
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