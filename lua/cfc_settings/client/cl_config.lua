-- Main formatting table
local settingsTable = {
    {
        ["Frequently used settings:"] = {
            [1] = { proximity_voice_enabled = { type = "bool", displayName = "Enable proximity voice" } },
            [2] = { pac_enable = {
                type = "boolfunction",
                displayName = "Enable PAC3",
                tooltip = "Enables PAC3",
                exists = function()
                    return istable( pac )
                end,
                setfunc = function( val )
                    LocalPlayer():ConCommand( "pac_enable " .. ( val and "1" or "0" ) )

                    if val then
                        LocalPlayer():ConCommand( "pac_request_outfits" )
                    end
                end,
                getfunc = function()
                    return GetConVar( "pac_enable" ):GetBool()
                end
            } },
            [3] = { fpp_openbuddies = {
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
            [1] = { streamcore_disable = { type = "bool", displayName = "Disable streamcore" } },
            [2] = { cfc_painsounds_enabled = { type = "bool", displayName = "Enable painsounds" } },
            [3] = { cfc_pvp_transparent_builders = { type = "bool", displayName = "Enable transparent builders in pvp" } },
            [4] = { cfc_tpa_disable = { type = "bool", displayName = "Disable tpa requests" } },
            [5] = { cfc_punt_enabled = { type = "bool", displayName = "Enable punt sounds" } },
            [6] = { voicebalancer_enabled = { type = "bool", displayName = "Enable voice balancer" } },
            [7] = { cfc_pvp_acf_screenshake_intensity = { type = "slider", decimals = 2, displayName = "ACF screenshake" } },
        }
    },
    {
        ["Other addons:"] = {
            [1] = { m9k_zoomtoggle = { type = "bool", displayName = "M9K zoom toggle" } },
            [2] = { sitting_disallow_on_me = { type = "bool", displayName = "Dissallow players sitting on you" } },
            [3] = { cl_legs = { type = "bool", displayName = "View your legs in first-person" } },
            [4] = { cl_vehlegs = { type = "bool", displayName = "View your legs in cars" } },
            [5] = { betterchat_enable = {
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
            [6] = { custom_hitmarkers_enabled = { type = "bool", displayName = "Enable hitmarkers" } },
            [7] = { custom_hitmarkers_openmenu = {
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
            [8] = { custom_propinfo_enabled = { type = "bool", displayName = "Enable prop info" } },
            [9] = { custom_propinfo_openmenu = {
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
            [10] = { physgun_buildmode_enabled = { type = "bool", displayName = "Enable physgun buildmode" } },
            [11] = { lfs_volume = { type = "slider", decimals = 2, displayName = "LFS volume" } },
            [12] = { acf_volume = {
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
            [13] = { pac_enable_camera_as_bone = {
                type = "bool",
                displayName = "Allow PACs to attach to your screen",
                tooltip = "WARNING: This allows for extra creative PACs,\n  but can be very obnoxious.\nEnable with caution."
            } },
        }
    }
}

return settingsTable
