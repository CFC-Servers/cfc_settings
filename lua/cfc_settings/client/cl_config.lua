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
                    flashPanel( controlpanel.Get( "Falco's prop protection buddies" ), true )
                end,
                rightfunc = function( settingsMenu )
                    LocalPlayer():ConCommand( "+menu" )
                    spawnmenu.ActivateTool( "Falco's prop protection buddies", true )
                    settingsMenu:SetVisible( false )
                    flashPanel( controlpanel.Get( "Falco's prop protection buddies" ), true )
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
