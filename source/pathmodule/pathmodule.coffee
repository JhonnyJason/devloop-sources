############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("pathmodule")
#endregion

############################################################
import path from "node:path"
import * as Stt from "./statemodule.js"
import * as claude from "./claudemodule.js"
import * as tl from "./taskloopmodule.js"

############################################################
# Manage all application paths
# keeps all paths and sets it correctly for the specific modules

############################################################
stateFileName = "devloopState.json" # default stateFileName

############################################################
# Prompt file paths (relative to working directory)
findTaskPromptPath = "ai/prompts/find-next-task.md"
taskFilePath = "ai/next-task.md"
reviewTaskPromptPath = "ai/prompts/review-task.md"

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
    Stt.setStateFilePath(path.resolve(wd, stateFileName))

    ## Claude module
    claude.setWorkingDirectory(wd)

    ## Prompt file paths for taskloop
    tl.setPromptFilePaths({
        findTaskPrompt: path.resolve(wd, findTaskPromptPath)
        taskFile: path.resolve(wd, taskFilePath)
        reviewTaskPrompt: path.resolve(wd, reviewTaskPromptPath)
    })
    return