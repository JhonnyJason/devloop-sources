
##############################################################################
import * as utils from "./configutils.js"

##############################################################################
localConfig = {}
try localConfig = await utils.readLocalConfig()
catch err then console.error(err)

##############################################################################
export tgToken = localConfig.tgToken || ""
export tgChatId = localConfig.chatId || ""

##############################################################################
export maxCycles = 10

##############################################################################
export appName = "devloop"
export appVersion = "0.0.1"


##############################################################################
## TODO implement mechanics for updating the config -> calling utils.updateLocalConfig(content)
## TODO implement listeners such that other modules also receive the updates