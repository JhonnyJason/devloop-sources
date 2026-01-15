############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("statemodule")
#endregion

############################################################
import fs from "node:fs/promises"
import path from "node:path"

############################################################
fileName = "devloopState.json" # default fileName
stateFilePath = ""
state = null

############################################################
defaultState = {
  "latest-taskId": 0,
  "latest-state": ""
}

############################################################
export initialize = (cfg) ->
    log "initialize"
    # fileName might be configured
    if cfg.fileName? then fileName = cfg.fileName
    return

############################################################
export readState = (wd) ->
    log "readState"
    if !wd? then throw new Error("No Working directory!")
    stateFilePath = path.resolve(wd, fileName)

    log stateFilePath

    try
        content = await fs.readFile(stateFilePath, "utf8")
        state = JSON.parse(content)
    catch err
        if err.code != "ENOENT" then throw err
    
    olog state

    if state? then return state

    state = defaultState
    await writeState()
    return state

############################################################
export writeState = ->
    log "writeState"
    content = JSON.stringify(state, null, 4)
    await fs.writeFile(stateFilePath, content, "utf8")
    return