##############################################################################
#region debug
import {createLogFunctions} from "thingy-debug"
{log, olog} = createLogFunctions("mainprocessmodule")

#endregion

##############################################################################
import * as cfg from "configmodule.js"

##############################################################################
export execute = () ->
    log "execute"
    return
