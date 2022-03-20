-- Main formatting table
local settingsTable = {
    {
        ["Frequently used settings:"] = {
            { proximity_voice_enabled = { type = "bool", displayName = "Enable proximity voice" } },
            { pac_enable = { type = "bool", displayName = "Enable PAC3" } },
            { pac_request_outfits = {
                type = "button",
                displayName = "Request PAC3 outfits",
                tooltip = "Reacquire PACs that may not have worn correctly",
                issub = true,
                exists = function()
                    return istable( pac )
                end,
                leftfunc = function()
                    LocalPlayer():ConCommand( "pac_request_outfits" )
                end,
                rightfunc = function( settingsMenu )
                    LocalPlayer():ConCommand( "pac_request_outfits" )
                end,
            } },
            { fpp_openbuddies = {
                type = "button",
                displayName = "Open FPP buddy settings",
                tooltip = "Opens more options\nRight click will auto-close this menu",
                issub = false,
                exists = function()
                    return istable( FPP )
                end,
                leftfunc = function()
                    LocalPlayer():ConCommand( "+menu" )
                    spawnmenu.ActivateTool( "Falco's prop protection buddies", true )
                end,
                rightfunc = function( settingsMenu )
                    LocalPlayer():ConCommand( "+menu" )
                    spawnmenu.ActivateTool( "Falco's prop protection buddies", true )
                    settingsMenu:SetVisible( false )
                end,
            } },
        }
    },
    {
        ["CFC Specific Settings:"] = {
            { streamcore_disable = { type = "bool", displayName = "Disable streamcore" } },
            { cfc_painsounds_enabled = { type = "bool", displayName = "Enable painsounds" } },
            { cfc_pvp_transparent_builders = { type = "bool", displayName = "Enable transparent builders in pvp" } },
            { cfc_tpa_disable = { type = "bool", displayName = "Disable tpa requests" } },
            { cfc_punt_enabled = { type = "bool", displayName = "Enable punt sounds" } },
            { voicebalancer_enabled = { type = "bool", displayName = "Enable voice balancer" } },
            { cfc_pvp_acf_screenshake_intensity = { type = "slider", decimals = 2, displayName = "ACF screenshake" } },
        }
    },
    {
        ["Other addons:"] = {
            { m9k_zoomtoggle = { type = "bool", displayName = "M9K zoom toggle" } },
            { sitting_disallow_on_me = { type = "bool", displayName = "Dissallow players sitting on you" } },
            { betterchat_enable = {
                type = "boolfunction",
                displayName = "Enable Betterchat",
                tooltip = "Enables Betterchat",
                exists = function()
                    return istable( bc )
                end,
                setfunc = function( val )
                    LocalPlayer():ConCommand( val and "bc_enable" or "bc_disable" )
                end,
                getfunc = function()
                    return bc.base.enabled
                end
            } },
            { custom_hitmarkers_enabled = { type = "bool", displayName = "Enable hitmarkers" } },
            { custom_hitmarkers_openmenu = {
                type = "button",
                displayName = "Open Hitmarkers config",
                tooltip = "Opens more options\nRight click will auto-close this menu",
                issub = true,
                exists = function()
                    return istable( CustomHitmarkers )
                end,
                leftfunc = function()
                    LocalPlayer():ConCommand( "+menu" )
                    spawnmenu.ActivateTool( "custom_hitmarkers", true )
                end,
                rightfunc = function( settingsMenu )
                    LocalPlayer():ConCommand( "+menu" )
                    spawnmenu.ActivateTool( "custom_hitmarkers", true )
                    settingsMenu:SetVisible( false )
                end,
            } },
            { custom_propinfo_enabled = { type = "bool", displayName = "Enable prop info" } },
            { custom_propinfo_openmenu = {
                type = "button",
                displayName = "Open Prop Info config",
                tooltip = "Opens more options\nRight click will auto-close this menu",
                issub = true,
                exists = function()
                    return istable( CustomPropInfo )
                end,
                leftfunc = function()
                    LocalPlayer():ConCommand( "+menu" )
                    spawnmenu.ActivateTool( "custom_propinfo", true )
                end,
                rightfunc = function( settingsMenu )
                    LocalPlayer():ConCommand( "+menu" )
                    spawnmenu.ActivateTool( "custom_propinfo", true )
                    settingsMenu:SetVisible( false )
                end,
            } },
            { physgun_buildmode_enabled = { type = "bool", displayName = "Enable physgun buildmode" } },
            { lfs_volume = { type = "slider", decimals = 2, displayName = "LFS volume" } },
            { acf_volume = {
                type = "sliderfunction",
                decimals = 2,
                displayName = "ACF Volume",
                tooltip = "Sets the ACF volume",
                exists = function()
                    return istable( ACF )
                end,
                setfunc = function( val )
                    ACF.Volume = val
                end,
                getfunc = function()
                    return ACF.Volume
                end,
                min = 0,
                max = 1
            } },
            { pac_enable_camera_as_bone = {
                type = "bool",
                displayName = "Allow PACs to attach to your screen",
                tooltip = "WARNING: This allows for extra creative PACs,\n  but can be very obnoxious.\nEnable with caution."
            } },
        }
    }
}

return settingsTable
