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
    "run devloop": -> taskLoop.execute()
    "configure": -> uConf.configure()
    "die!": -> process.exit(0)
}   

##############################################################################
export execute = ->
    log "execute"
    await Stt.readState()
    
    try loop await userDecisionCycle()    
    catch err then return
    return

##############################################################################
userDecisionCycle = ->
    log "outerCycle"
    uiChoices = Object.keys(outerCycleActions)
    choice = await ui.retrieveChoice("Welcome to the Devloop!", uiChoices)
    return await outerCycleActions[choice]()
