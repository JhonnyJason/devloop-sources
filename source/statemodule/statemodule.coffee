############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("statemodule")
#endregion

############################################################
import fs from "node:fs/promises"

############################################################
state = null
stateFilePath = ""

############################################################
defaultState = {
  "latest-taskId": 0,
  "latest-state": ""
}

############################################################
export setStateFilePath = (path) -> stateFilePath = path

############################################################
export readState = ->
    log "readState"
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