-- Main formatting table
local settingsTable = {
    [1] = {
        ["Frequently used settings:"] = {
            [1] = { proximity_voice_enabled = { type = "bool", displayName = "Enable proximity voice" } },
            [2] = { pac_enable = { type = "bool", displayName = "Enable pac" } },
        }
    },
    [2] = {
        ["CFC Specific Settings:"] = {
            [1] = { streamcore_disable = { type = "bool", displayName = "Disable streamcore" } },
            [2] = { cfc_painsounds_enabled = { type = "bool", displayName = "Enable painsounds" } },
            [3] = { cfc_pvp_transparent_builders = { type = "bool", displayName = "Enable transparent builders in pvp" } },
            [4] = { cfc_tpa_disable = { type = "bool", displayName = "Disable tpa requests" } },
            [5] = { cfc_punt_enabled = { type = "bool", displayName = "Enable punt sounds" } },
            [6] = { voicebalancer_enabled = { type = "bool", displayName = "Enable voice balancer" } },
            [7] = { cfc_pvp_acf_screenshake_intensity = { type = "slider", decimals = 2, displayName = "ACF Screenshake" } },
        }
    },
    [3] = {
        ["Other addons:"] = {
            [1] = { m9k_zoomtoggle = { type = "bool", displayName = "M9K zoom toggle" } },
            [2] = { custom_hitmarkers_enabled = { type = "bool", displayName = "Enable hitmarkers" } },
            [3] = { physgun_buildmode_enabled = { type = "bool", displayName = "Enable physgun buildmode" } },
            [4] = { acf_volume = {
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
