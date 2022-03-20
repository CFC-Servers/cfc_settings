local isValid = IsValid
local mFloor = math.floor
local mMax = math.max

local COLOR_RED = Color( 255, 0, 0, 255 )

-- Utility functions
local function flashPanel( panel, noRepeats, length, blinkLength, thickness )
    if not isValid( panel ) or not ispanel( panel ) then return end
    if noRepeats and panel.cfcSettings_hasFlashed then return end

    panel.cfcSettings_hasFlashed = true
    length = mMax( length or 2, 0.01 )
    blinkLength = mMax( blinkLength or 0.2, 0.01 )
    thickness = thickness or 5

    local blinkState = true
    local panelStr = tostring( panel )

    timer.Create( "CFC_Settings_FlashPanel_" .. panelStr, blinkLength, mFloor( length / blinkLength ), function()
        blinkState = not blinkState
    end )

    timer.Create( "CFC_Settings_FlashPanel_RemoveHook_" .. panelStr, length, 1, function()
        hook.Remove( "PostRenderVGUI", "CFC_Settings_FlashPanel_" .. panelStr )
    end )

    hook.Add( "PostRenderVGUI", "CFC_Settings_FlashPanel_" .. panelStr, function()
        if not blinkState then return end

        local x, y = panel:LocalToScreen()
        local w, h = panel:GetSize()

        surface.SetDrawColor( COLOR_RED )
        surface.DrawOutlinedRect( x, y, w, h, thickness )
    end )
end


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
                    flashPanel( controlpanel.Get( "custom_hitmarkers" ), true )
                end,
                rightfunc = function( settingsMenu )
                    LocalPlayer():ConCommand( "+menu" )
                    spawnmenu.ActivateTool( "custom_hitmarkers", true )
                    settingsMenu:SetVisible( false )
                    flashPanel( controlpanel.Get( "custom_hitmarkers" ), true )
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
