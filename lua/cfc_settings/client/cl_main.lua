--[[-------------------------------------------------------------------------
VGUI Options menu
---------------------------------------------------------------------------]]
local settingsMenu
local isValid = IsValid
local GetConVar = GetConVar
local uiColor = Color( 36, 41, 67 )

local convarTable = include( "cfc_settings/client/cl_config.lua" )

local function addLabel( panel, text )
    local label = vgui.Create( "DLabel", panel )
    label:Dock( TOP )
    label:DockMargin( 5, 0, 0, 0 )
    label:SetText( text )
end

-- Convar settings
local function addBool( panel, text, cname )
    local convar = GetConVar( cname )
    local checkBox = panel:Add( "DCheckBoxLabel" )
    checkBox:Dock( TOP )
    checkBox:DockMargin( 10, 0, 0, 5 )
    checkBox:SetText( text or cname )
    checkBox:SetValue( convar:GetBool() )
    checkBox:SetTooltip( convar:GetHelpText() )
    checkBox:SetConVar( cname )
    checkBox:SizeToContents()
end

local function addSlider( panel, text, cname, decimal )
    local convar = GetConVar( cname )
    local distanceSlider = vgui.Create( "DNumSlider", panel )
    distanceSlider:Dock( TOP )
    distanceSlider:DockMargin( 10, -10, 0, 0 )
    distanceSlider:SetText( text )
    distanceSlider:SetMin( convar:GetMin() )
    distanceSlider:SetMax( convar:GetMax() )
    distanceSlider:SetValue( convar:GetFloat() )
    distanceSlider:SetDecimals( decimal or 0 )
    distanceSlider:SetTooltip( convar:GetHelpText() )
    distanceSlider:SetConVar( cname )
end

-- Custom function settings
local function addFunctionBool( panel, info )
    local text = info.displayName
    local setfunc = info.setfunc
    local getfunc = info.getfunc
    local tooltip = info.tooltip

    local checkBox = panel:Add( "DCheckBoxLabel" )
    checkBox:Dock( TOP )
    checkBox:DockMargin( 10, 0, 0, 5 )
    checkBox:SetText( text )
    checkBox:SetValue( getfunc() )
    checkBox:SetTooltip( tooltip )
    checkBox:SizeToContents()

    function checkBox:OnChange( value )
        setfunc( value ) -- Expect a boolean
    end
end

local function addFunctionSlider( panel, info )
    local max = info.max
    local min = info.min
    local text = info.displayName
    local decimals = info.decimals
    local setfunc = info.setfunc
    local getfunc = info.getfunc
    local tooltip = info.tooltip

    local distanceSlider = vgui.Create( "DNumSlider", panel )
    distanceSlider:Dock( TOP )
    distanceSlider:DockMargin( 10, -10, 0, 0 )
    distanceSlider:SetText( text )
    distanceSlider:SetMin( min )
    distanceSlider:SetMax( max )
    distanceSlider:SetValue( getfunc() )
    distanceSlider:SetDecimals( decimals or 0 )
    distanceSlider:SetTooltip( tooltip )

    function distanceSlider:OnValueChanged( value )
        setfunc( value )
    end
end

local function handleOptions( panel, action, info )
    -- Toggle convars
    if info.type == "bool" then
        if not GetConVar( action ) then return end
        addBool( panel, info.displayName, action )
        return
    end
    -- Convars with multiple values
    if info.type == "slider" then
        if not GetConVar( action ) then return end
        addSlider( panel, info.displayName, action, info.decimals )
        return
    end

    -- Function boolean
    if info.type == "sliderfunction" then
        if not info.exists() then return end
        addFunctionSlider( panel, info )
        return
    end

    -- Function slider
    if info.type == "sliderbool" then
        if not info.exist() then return end
        addFunctionBool( panel, info )
        return
    end
end

-- Parses the config table and generates vgui elements from it.
local function configHandler( panel, config  )
    for _, tbl in ipairs ( config ) do
        for title, subtbl in pairs( tbl ) do
            -- Check if convars or functions exist, has to happen before options get added for each block.
            local valid = 0
            for _, settingtbl in ipairs( subtbl ) do
                for action, info in pairs( settingtbl ) do
                    if GetConVar( action ) or ( isfunction( info.exists ) and info.exists() ) then
                        valid = valid + 1
                    end
                end
            end
            -- Only add title if convars exist
            if valid ~= 0 then
                addLabel( panel, title )
            end
            for _, settingTbl in ipairs( subtbl ) do
                -- Settings table
                for action, info in pairs( settingTbl ) do
                    handleOptions( panel, action, info )
                end
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

    function settingsMenu:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, uiColor )
    end
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
