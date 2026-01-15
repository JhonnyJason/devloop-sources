import Modules from "./allmodules.js"

############################################################
global.allModules = Modules

############################################################
import * as cfg from "./configmodule.js"

############################################################
run = ->
    try
        promises = (m.initialize(cfg) for n,m of Modules when m.initialize?) 
        await Promise.all(promises)
        await Modules.startupmodule.cliStartup()
    catch err then console.error(err)

############################################################
run()
