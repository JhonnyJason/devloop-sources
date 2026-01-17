############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("pathmodule")
#endregion

############################################################
import path from "node:path"
import * as Stt from "./statemodule.js"

############################################################
# Manage all application paths
# keeps all paths and sets it correctly for the specific modules

############################################################
stateFileName = "devloopState.json" # default stateFileName

############################################################
baseDir = ""
configPath = ""
stateFilePath = ""

############################################################
export initialize = (cfg) ->
    log "initialize"
    # fileName might be configured
    if cfg.stateFileName? then stateFileName = cfg.stateFileName

    return

############################################################
export setWorkingDirectory = (wd) ->
    log "setWorkingDirectory"
    if !wd? then throw new Error("No Working directory!")

    ## StateFile
    stateFilePath = path.resolve(wd, stateFileName)
    Stt.setStateFilePath(stateFilePath)
    log stateFilePath
    return