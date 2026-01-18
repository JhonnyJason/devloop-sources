##############################################################################
#region debug
import {createLogFunctions} from "thingy-debug"
{log, olog} = createLogFunctions("configutils")

#endregion

##############################################################################
#region imports

##############################################################################
import fs from "node:fs"
import os from "node:os"
import path from "node:path"
import crypto from "node:crypto"

##############################################################################
import * as secUtl from "secret-manager-crypto-utils"
import * as tbut from "thingy-byte-utils"
import { ThingyCryptoNode } from "thingy-crypto-node"

##############################################################################
import * as ui from "./uimodule.js"

#endregion

##############################################################################
#region local variables
configPath = path.join(os.homedir(), ".config", "devloop", "devloop.json")
envSalt = do ->
    base = os.homedir() + os.hostname() + os.userInfo().username
    try # Linux machine-id adds extra entropy
        machineId = fs.readFileSync("/etc/machine-id", "utf8").trim()
        return machineId + base
    catch then return base

##############################################################################
cryptoNode = ""

##############################################################################
localConfig = null


#endregion

##############################################################################
export readLocalConfig = ->
    log "readLocalConfig"
    try
        configString = fs.readFileSync(configPath, "utf8")
        cfg = JSON.parse(configString)
        await decryptContent(cfg)
    catch err
        if err.code == 'ENOENT' then await createNewConfig()
        else throw err
    
    return localConfig.content

##############################################################################
export updateLocalConfig = (content, validProps) ->
    log "updateLocalConfig"
    validProps = new Set(validProps)
    updated = []
    for lbl,val of content when validProps.has(lbl)
        if localConfig.content[lbl] != val
            localConfig.content[lbl] = val
            updated.push(lbl)
    if updated.length > 0 then await saveConfig()
    return updated

##############################################################################
createNewConfig = ->
    log "createNewConfig"
    console.log "No config found. Creating new config at #{configPath}"

    # Ask if user wants password protection
    try
        pwd = await ui.retrieveSecret("New Password:")
        confirmPw = await ui.retrieveSecret("Confirm password:")
    catch err then process.exit(0) # when user cancelled exit application

    if pwd != confirmPw
        console.error "Passwords don't match. Try again."
        return createNewConfig()

    # Generate random keyFragment (32 bytes = 64 hex chars)
    keyFragment = tbut.bytesToHex(crypto.randomBytes(32))

    # Derive key and setup crypto
    secretKeyHex = await getKey(pwd, keyFragment)
    publicKeyHex = await secUtl.createPublicKey(secretKeyHex)
    cryptoNode = new ThingyCryptoNode({secretKeyHex, publicKeyHex})

    # Initialize with empty content
    localConfig = { keyFragment, content: {} }

    # Save to disk
    await saveConfig()
    console.log "Config created successfully."
    return

##############################################################################
decryptContent = (cfg) ->
    log "decryptContent"
    try # first try to decrypt without password
        secretKeyHex = await getKey("", cfg.keyFragment)
        publicKeyHex = await secUtl.createPublicKey(secretKeyHex)
        cryptoNode = new ThingyCryptoNode({secretKeyHex, publicKeyHex})

        contentString = await cryptoNode.decrypt(cfg.content)
        content = JSON.parse(contentString)
        ## no exception - seems succesful :-)
        
        localConfig = {
            keyFragment: cfg.keyFragment
            content: content
        }
        console.log("Parsed config (#{configPath}).")
        return
    catch err then log err

    loop try # loop trough password attempts
        try password = await ui.retrieveSecret("Password:")
        catch err then process.exit(0) # when user cancelled exit application

        secretKeyHex = await getKey(password, cfg.keyFragment)
        publicKeyHex = await secUtl.createPublicKey(secretKeyHex)
        cryptoNode = new ThingyCryptoNode({secretKeyHex, publicKeyHex})
   
        contentString = await cryptoNode.decrypt(cfg.content)
        content = JSON.parse(contentString)
        ## no exception - seems succesful :-)

        localConfig = {
            keyFragment: cfg.keyFragment
            content: content
        }
        return
    catch err then console.error err
    return

saveConfig = ->
    log "saveConfig"
    cfg = {}
    cfg.keyFragment = localConfig.keyFragment
    cfg.content = await cryptoNode.encrypt(JSON.stringify(localConfig.content))

    # Ensure directory exists
    configDir = path.dirname(configPath)
    fs.mkdirSync(configDir, { recursive: true })

    # Write config
    fs.writeFileSync(configPath, JSON.stringify(cfg, null, 2))
    return

##############################################################################
getKey = (password, keyFrag1) ->
    log "getKey"
    keyFrag0 = await secUtl.sha512Hex(envSalt + password)
    return hexXOR(keyFrag0.slice(0, 64), keyFrag1) # 32 bytes = 64 hex chars    

hexXOR = (kHex, sHex) ->
    if kHex.length != sHex.length then throw new Error("Keys must have same length!")
    kBytes = tbut.hexToBytes(kHex)
    sBytes = tbut.hexToBytes(sHex)

    rBytes = new Uint8Array(kBytes.length)
    rBytes[i] = kByte ^ sBytes[i] for kByte, i in kBytes

    return tbut.bytesToHex(rBytes)
