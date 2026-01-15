##############################################################################
#region debug
import {createLogFunctions} from "thingy-debug"
{log, olog} = createLogFunctions("cliargumentsmodule")

#endregion

##############################################################
import meow from 'meow'

##############################################################
#region internal functions
getHelpText = ->
    log "getHelpText"
    return """
        Usage
            $ 
    
        Options
            optional:
                
        Examples
            $  -c
            ...
    """

getOptions = ->
    log "getOptions"
    return {
        importMeta: import.meta,
        flags:
            option: #optionsname
                type: "boolean" # or string
                alias: "o"
    }

##############################################################
extractMeowed = (meowed) ->
    log "extractMeowed"

    option = false # default
    if meowed.input[0] then option = meowed.input[0]
    if meowed.flags.option then option = true

    return {option}

throwErrorOnUsageFail = (extract) ->
    log "throwErrorOnUsageFail"
    if !extract.option then throw new Error("Usag error: no option has been defined!")
    return
#endregion

##############################################################
export extractArguments = ->
    log "extractArguments"
    meowed = meow(getHelpText(), getOptions())
    extract = extractMeowed(meowed)
    throwErrorOnUsageFail(extract)
    return extract
