--[[-------------------------------------------------------------------------
VGUI Options menu
---------------------------------------------------------------------------]]
local settingsMenu
local isValid = IsValid
local GetConVar = GetConVar

local convarTable = include( "cfc_settings/client/cl_config.lua" )

local function addLabel( panel, text )
    local label = vgui.Create( "DLabel", panel )
    label:Dock( TOP )
    label:DockMargin( 5, 0, 0, 0 )
    label:SetText( text )
end

local function addBool( panel, text, cname )
    local convar = GetConVar( cname )
    local checkBox = panel:Add( "DCheckBoxLabel" )
    checkBox:Dock( TOP )
    checkBox:DockMargin( 10, 0, 0, 5 )
    checkBox:SetText( text )
    checkBox:SetValue( convar:GetBool() )
    checkBox:SetTooltip( convar:GetHelpText() )
    checkBox:SetConVar( cname )
    checkBox:SizeToContents()
end

local function addSlider( panel, text, cname, decimal )
    local convar = GetConVar( cname )
    local distanceSlider = vgui.Create( "DNumSlider", panel )
    distanceSlider:Dock( TOP )
    distanceSlider:DockMargin( 5, 5, 0, 0 )
    distanceSlider:SetText( text )
    distanceSlider:SetMin( convar:GetMin() )
    distanceSlider:SetMax( convar:GetMax() )
    distanceSlider:SetValue( convar:GetFloat() )
    distanceSlider:SetDecimals( decimal or 0 )
    distanceSlider:SetTooltip( convar:GetHelpText() )
    distanceSlider:SetConVar( cname )
end

local function handleOptions( panel, cmd, info )
    if not GetConVar( cmd ) then return end

    -- Toggle convars
    if info.type == "bool" then
        addBool( panel, info.displayName, cmd )
        return
    end
    -- Convars with multiple values
    if info.type == "slider" then
        addSlider( panel, info.displayName, cmd, info.decimals )
        return
    end
end

local function configHandler( panel, tbl  )
    for title, sub in pairs( tbl ) do
        -- Check if convars exist
        local validConvars = 0
        for cmd in pairs( sub ) do
            if GetConVar( cmd ) then
                validConvars = validConvars + 1
            end
        end
        -- Only add title if convars exist
        if validConvars ~= 0 then
            -- Title
            addLabel( panel, title )
            -- Settings table
            for cmd, info in pairs( sub ) do
                handleOptions( panel, cmd, info )
            end
        end
    end
end

local function toggleSettingsMenu()
    if isValid( settingsMenu ) then
        settingsMenu:Remove()
        return
    end

    settingsMenu = vgui.Create( "DFrame" )
    settingsMenu:SetSize( 270, 400 )
    settingsMenu:Center()
    settingsMenu:SetTitle( "Settings:" )
    settingsMenu:MakePopup()
    settingsMenu:SetKeyboardInputEnabled( false )

     -- "Parse" the config table
    configHandler( settingsMenu, convarTable )

    settingsMenu:InvalidateLayout( true )
    settingsMenu:SizeToChildren( true, true )
end

hook.Add( "OnPlayerChat", "NotShitSettings", function( ply, text )
    local lower = string.lower( text ) -- make the string lower case
    if lower ~= "!settings" then return end
    if ply == LocalPlayer() then
        toggleSettingsMenu()
    end
    return true
end)

concommand.Add( "cfc_settings", toggleSettingsMenu )
