# Nutscript Plugins

Publicly available plugins. Ranging from mundane to unique.
Most if not all are made for Nutscript 1.2, so if you are using another version of NS (namely the non-beta 1.1), you may experience errors.

## Crafting

This is a slightly editted version of Chancer's crafting plugin from respite, found here: https://github.com/Chancerawr/respite/tree/master/respite/plugins/crafting
This is posted here for everyone who needs a working crafting plugin but is unable or unwilling to spend 10 minutes to fix it themselves.

## Cinematic Text

Text that appears with blackbars, for that extra cinematic effect. Useful for GMs when the players enter a new area for an event, for instance.

## GMTeleportPoints
This plugin allows admins/gms to set up teleport points across the map. Allowing for quick teleportation and navigation.
For convenience, use /gmtpmenu.

## Crosshair

This is basically the default plugin, but now has a config option to disable it without the need of deleting/disabling the plugin completely

## Ranks

Adds ranks that appear as part of a character's name. Setting a rank does not affect the character's name, and changing the character's name does not affect the displayed Rank.
Each faction that uses the rank system should add a rankTable to the faction file.

```lua
    FACTION.rankTable = {
    "Recruit",
    "Private",
    "Corporal",
}
```

## Medical

This plugin adds a medical system to Nutscript. It allows players to heal themselves and others, includes bleeding, fractures, concussions

Setup: Go to `sh_configs.lua` and set up the plugin before using it.

Visual effects are toggleable via C-menu quick settings.

Please be advised that this plugin may have bugs, and will not receive updates, unless for security reasons. If you wish to improve this plugin, feel free to make a pull request. Thank you.

## chatColorFix

!!!NUTSCRIPT 1.2 HAS FIXED THIS ISSUE ALREADY. YOU DO NOT NEED THIS IF YOU ARE USING THE LATEST VERSION OF 1.2!!!
This plugin was made by Sample Name (Sample Name#2010). It fixes the chatbox colour setting, which is broken in NS 1.1. If you want to customize the chat color, use this plugin to avoid errors.

# Support Me

These plugins are provided for free. Supporting me is really appreciated, as it helps me continue to make plugins and other content for the community.

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/W7W05B5E4)