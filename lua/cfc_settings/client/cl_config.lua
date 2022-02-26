-- Main formatting table
local settingsTable = {
    ["Frequently used settings:"] = {
        proximity_voice_enabled = { type = "bool", displayName = "Enable proximity voice" },
        pac_enable = { type = "bool", displayName = "Enable pac" }
    },
    ["CFC Specific Settings:"] = { -- CFC commands
        streamcore_disable = { type = "bool", displayName = "Disable streamcore" },
        cfc_painsounds_enabled = { type = "bool", displayName = "Enable painsounds" },
        cfc_pvp_transparent_builders = { type = "bool", displayName = "Enable transparent builders in pvp" },
        cfc_tpa_disable = { type = "bool", displayName = "Disable tpa requests" },
        cfc_punt_enabled = { type = "bool", displayName = "Enable punt sounds" },
        voicebalancer_enabled = { type = "bool", displayName = "Enable voice balancer" },
        cfc_pvp_acf_screenshake_intensity = { type = "slider", decimals = 2, displayName = "ACF Screenshake" },
    },
    ["Other addons:"] = {
        m9k_zoomtoggle = { type = "bool", displayName = "M9K zoom toggle" },
        custom_hitmarkers_enabled = { type = "bool", displayName = "Enable hitmarkers" },
        physgun_buildmode_enabled = { type = "bool", displayName = "Enable physgun buildmode" }
    }
}

return settingsTable
