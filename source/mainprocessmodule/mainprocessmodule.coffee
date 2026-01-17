##############################################################################
#region debug
import {createLogFunctions} from "thingy-debug"
{log, olog} = createLogFunctions("mainprocessmodule")

#endregion

##############################################################################
# This is the Main Process which runs the "outer" userDecisionCycle

##############################################################################
import * as Stt from "./statemodule.js" 
import * as ui from "./uimodule.js"
import * as taskLoop from "./taskloopmodule.js"
import * as uConf from "./userconfigurationmodule.js"

##############################################################################
outerCycleActions = {
    "start task execution": -> taskLoop.execute()
    "configure": -> uConf.configure()
    "die!": -> process.exit(0)
}   

##############################################################################
export execute = ->
    log "execute"
    state = await Stt.readState()
    ## TODO: figure out how to apply state

    try loop await userDecisionCycle()    
    catch err then console.log err
    return

##############################################################################
userDecisionCycle = ->
    log "outerCycle"
    uiChoices = Object.keys(outerCycleActions)
    choice = await ui.retrieveChoice("Welcome to the Devloop!", uiChoices)
    return await outerCycleActions[choice]()

##############################################################################
setState = (taskId, stateString) ->
    log "setState"
    state["latest-taskId"] = taskId
    state["latest-state"] = stateString
    await Stt.writeState()
    return