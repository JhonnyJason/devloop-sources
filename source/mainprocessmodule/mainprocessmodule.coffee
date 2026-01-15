##############################################################################
#region debug
import {createLogFunctions} from "thingy-debug"
{log, olog} = createLogFunctions("mainprocessmodule")

#endregion

##############################################################################
import * as Stt from "./statemodule.js" 

##############################################################################
state = null


##############################################################################
export initialize = (cfg) ->
    log "initialize"

    return

##############################################################################
export execute = (args) ->
    log "execute"
    state = await Stt.readState(args.wd)
    loop
        await executionCycle()    
    return

##############################################################################
executionCycle = ->
    log "executionCycle"
    ## TODO implement
    return

##############################################################################
setState = (taskId, stateString) ->
    log "setState"
    state["latest-taskId"] = taskId
    state["latest-state"] = stateString
    await Stt.writeState()
    return