##############################################################################
#region debug
import {createLogFunctions} from "thingy-debug"
{log, olog} = createLogFunctions("startupmodule")

#endregion

##############################################################################
#region imports

##############################################################################
import * as mp from "./mainprocessmodule.js"
import * as ca from "./cliargumentsmodule.js"
import * as pth from "./pathmodule.js"

#endregion


##############################################################################
export cliStartup = ->
    log "cliStartup"
    try
        e = ca.extractArguments()
        pth.setWorkingDirectory(e.wd)
        await mp.execute(e)
        log "gracefully terminated!"
    catch err
        console.error(err)
        process.exit(-1)
    return