-- Main formatting table
local settingsTable = {
    {
        ["Frequently used settings:"] = {
            { proximity_voice_enabled = { type = "bool", displayName = "Enable proximity voice" } },
            { pac_enable = { type = "bool", displayName = "Enable pac" } },
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
            { cfc_pvp_acf_screenshake_intensity = { type = "slider", decimals = 2, displayName = "ACF Screenshake" } },
        }
    },
    {
        ["Other addons:"] = {
            { m9k_zoomtoggle = { type = "bool", displayName = "M9K zoom toggle" } },
            { custom_hitmarkers_enabled = { type = "bool", displayName = "Enable hitmarkers" } },
            { physgun_buildmode_enabled = { type = "bool", displayName = "Enable physgun buildmode" } },
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
        }
    }
}

return settingsTable
