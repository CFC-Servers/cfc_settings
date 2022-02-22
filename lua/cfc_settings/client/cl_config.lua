-- Main formatting table
local settingsTable = {
    "Frequently used settings:",
    {
        proximity_voice_enabled = { bool = true, displayName = "Enable proximity voice" },
        pac_enable = { bool = true, displayName = "Enable pac" }
    },
    "CFC Specific Settings:",
    { -- CFC commands
        streamcore_disable = { bool = true, displayName = "Disable streamcore" },
        cfc_painsounds_enabled = { bool = true, displayName = "Enable painsounds" },
        cfc_pvp_transparent_builders = { bool = true, displayName = "Enable transparent builders in pvp" },
        cfc_tpa_disable = { bool = true, displayName = "Disable tpa requests" },
        cfc_punt_enabled = { bool = true, displayName = "Enable punt sounds" },
        voicebalancer_enabled = { bool = true, displayName = "Enable voice balancer" },
        cfc_pvp_acf_screenshake_intensity = { slider = true, decimals = 2, displayName = "ACF Screenshake" },
    },
    "Other addons:",
    {
        m9k_zoomtoggle = { bool = true, displayName = "M9K zoom toggle" },
        custom_hitmarkers_enabled = { bool = true, displayName = "Enable hitmarkers" },
        physgun_buildmode_enabled = { bool = true, displayName = "Enable physgun buildmode" }
    }
}

return settingsTable
