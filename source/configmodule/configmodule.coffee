
##############################################################################
import * as utils from "./configutils.js"

onChangeListeners = {}

##############################################################################
localConfig = {}
try localConfig = await utils.readLocalConfig()
catch err then console.error(err)

##############################################################################
export onChange = (prop, cb) ->
    ## one-way hookup to receive changes.
    if !onChangeListeners[prop]? then onChangeListeners[prop] = []
    onChangeListeners[prop].push(cb)
    return

export updateConfig = (content) ->
    updated = await utils.updateLocalConfig(content, localConfigProps)
    for prop in updated when onChangeListeners[prop]?
        callbacks = onChangeListeners[prop]
        cb(content[prop]) for cb in callbacks
    return


##############################################################################
# possible localConfig Props
##############################################################################
export tgToken = localConfig.tgToken || ""
export tgChatId = localConfig.tgChatId || ""
export maxCycles = localConfig.maxCycles || 10

##############################################################################
# Should contain all possible localConfig Props
export localConfigProps = ["tgToken", "tgChatId", "maxCycles"]

##############################################################################
# static cli config
##############################################################################
export appName = "devloop"
export appVersion = "0.0.1"


