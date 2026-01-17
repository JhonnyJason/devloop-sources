# Configmodule

Reads encrypted local config file (`~/.config/devloop/devloop.json`) and exports configuration.

## Design Choice: Static Exports

Properties are exported as static values read once at module initialization. This is intentional.

**Truly static** (never change):
- `appName`, `appVersion`

**Runtime-updatable** (may change during execution):
- `tgToken`, `tgChatId`, `maxCycles`

For updatable props, consuming modules must hook up an `onChange` listener to react to updates. The exported value itself won't change - the listener callback is responsible for re-reading or handling the new value.

## Interface

```coffee
# Static exports (read at init)
appName, appVersion          # CLI identity
tgToken, tgChatId, maxCycles # from localConfig

# Listen for runtime updates
onChange(prop, cb)           # cb called when prop changes

# Update config (writes to disk, triggers listeners)
updateConfig({ prop: value })
```    