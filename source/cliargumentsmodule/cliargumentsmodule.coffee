##############################################################################
#region debug
import {createLogFunctions} from "thingy-debug"
{log, olog} = createLogFunctions("cliargumentsmodule")

#endregion

##############################################################
import meow from 'meow'
import process from "node:process"

##############################################################
#region internal functions
getHelpText = ->
    log "getHelpText"
    return """
        Usage
            $ 
    
        Options
            optional:
                arg1, --root <root-directory>, -r <root-directory>
                    define the root directory of your project in which to run the devloop


        Examples
            $ devloop  ~/projects/my-mega-project
            $ devloop  -r ~/projects/my-mega-project
            $ devloop  -root ~/projects/my-mega-project
       """

getOptions = ->
    log "getOptions"
    return {
        importMeta: import.meta,
        flags:
            root: #optionsname
                type: "string" # or string
                alias: "r"
    }

##############################################################
extractMeowed = (meowed) ->
    log "extractMeowed"

    wd = process.cwd() # default
    if meowed.input[0] then wd = meowed.input[0]
    if meowed.flags.root then wd = meowed.flags.root

    return { wd }

#endregion

##############################################################
export extractArguments = ->
    log "extractArguments"
    meowed = meow(getHelpText(), getOptions())
    extract = extractMeowed(meowed)
    return extract
