--[[-------------------------------------------------------------------------
VGUI Options menu
---------------------------------------------------------------------------]]
local settingsMenu
local isValid = IsValid
local GetConVar = GetConVar

local developerVar = GetConVar( "developer" )

-- Palette
local uiColor = Color( 36, 41, 67 )
local titleBarColor = Color( 28, 32, 52 )
local cardColor = Color( 44, 50, 80 )
local cardHeaderColor = Color( 52, 59, 94 )
local searchBgColor = Color( 28, 32, 52 )
local txtColor = Color( 210, 210, 210, 255 )
local mutedColor = Color( 150, 156, 180 )
local accentColor = Color( 83, 227, 251, 255 )
local boxColor = Color( 30, 34, 55 )
local boxBorderColor = Color( 90, 98, 130 )

local btnColor = Color( 42, 47, 74, 255 )
local btnHoverColor = Color( 52, 59, 94, 255 )
local btnPressColor = Color( 83, 227, 251, 255 )
local btnTxtColor = Color( 210, 210, 210, 255 )

-- Layout constants
local CARD_HEADER_H = 30
local CARD_BODY_BOTTOM_PAD = 8

surface.CreateFont( "CFCSettingsTitle", { font = "Roboto", size = 19, weight = 700, antialias = true } )
surface.CreateFont( "CFCSettingsHeader", { font = "Roboto", size = 16, weight = 600, antialias = true } )
surface.CreateFont( "CFCSettingsSign", { font = "Roboto", size = 20, weight = 700, antialias = true } )

local convarTable = include( "cfc_settings/client/cl_config.lua" )

local function paintButton( panel )
    panel:SetTextColor( btnTxtColor )

    panel.Paint = function( self, w, h )
        local bg = btnColor
        if self:IsDown() then
            bg = btnPressColor
        elseif self:IsHovered() then
            bg = btnHoverColor
        end
        draw.RoundedBox( 4, 0, 0, w, h, bg )
    end
end

-- Custom checkbox skin, matches the dark theme
local function skinCheckBox( checkBox )
    local box = checkBox.Button
    if not isValid( box ) then return end

    box:SetSize( 16, 16 )
    box.Paint = function( self, w, h )
        if self:GetChecked() then
            draw.RoundedBox( 3, 0, 0, w, h, accentColor )
            surface.SetDrawColor( titleBarColor )
            surface.DrawLine( w * 0.22, h * 0.52, w * 0.42, h * 0.72 )
            surface.DrawLine( w * 0.42, h * 0.72, w * 0.78, h * 0.28 )
        else
            draw.RoundedBox( 3, 0, 0, w, h, boxColor )
            surface.SetDrawColor( boxBorderColor )
            surface.DrawOutlinedRect( 0, 0, w, h )
        end
    end
end

-- Convar settings
local function addBool( panel, text, cname, tooltip )
    local convar = GetConVar( cname )
    tooltip = tooltip or convar:GetHelpText()

    local checkBox = panel:Add( "DCheckBoxLabel" )
    checkBox:Dock( TOP )
    checkBox:DockMargin( 6, 0, 6, 6 )
    checkBox:SetTextColor( txtColor )
    checkBox:SetText( text or cname )
    checkBox:SetValue( convar:GetBool() )
    checkBox:SetTooltip( tooltip ~= "" and tooltip )
    checkBox:SetConVar( cname )
    checkBox:SizeToContents()
    skinCheckBox( checkBox )

    return checkBox
end

local function addSlider( panel, text, cname, decimal, tooltip )
    local convar = GetConVar( cname )
    tooltip = tooltip or convar:GetHelpText()

    local distanceSlider = vgui.Create( "DNumSlider", panel )
    distanceSlider:Dock( TOP )
    distanceSlider:DockMargin( 6, -6, 6, 0 )
    distanceSlider:GetChildren()[3]:SetTextColor( txtColor )
    distanceSlider:SetText( text )
    distanceSlider:SetMin( convar:GetMin() or 0 )
    distanceSlider:SetMax( convar:GetMax() or 1 )
    distanceSlider:SetValue( convar:GetFloat() )
    distanceSlider:SetDecimals( decimal or 0 )
    distanceSlider:SetTooltip( tooltip ~= "" and tooltip )
    distanceSlider:SetConVar( cname )

    return distanceSlider
end

-- Custom function settings
local function addFunctionBool( panel, info )
    local text = info.displayName
    local setfunc = info.setfunc
    local getfunc = info.getfunc
    local tooltip = info.tooltip

    local checkBox = panel:Add( "DCheckBoxLabel" )
    checkBox:Dock( TOP )
    checkBox:DockMargin( 6, 0, 6, 6 )
    checkBox:SetTextColor( txtColor )
    checkBox:SetText( text )
    checkBox:SetValue( getfunc() )
    checkBox:SetTooltip( tooltip )
    checkBox:SizeToContents()
    skinCheckBox( checkBox )

    function checkBox:OnChange( value )
        setfunc( value ) -- Expect a boolean
    end

    return checkBox
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
    distanceSlider:DockMargin( 6, -6, 6, 0 )
    distanceSlider:GetChildren()[3]:SetTextColor( txtColor )
    distanceSlider:SetText( text )
    distanceSlider:SetMin( min )
    distanceSlider:SetMax( max )
    distanceSlider:SetValue( getfunc() )
    distanceSlider:SetDecimals( decimals or 0 )
    distanceSlider:SetTooltip( tooltip )

    function distanceSlider:OnValueChanged( value )
        setfunc( value )
    end

    return distanceSlider
end

local function addFunctionButton( panel, info )
    local text = info.displayName
    local leftfunc = info.leftfunc
    local rightfunc = info.rightfunc
    local tooltip = info.tooltip
    local isSub = info.issub

    local btn = panel:Add( "DButton" )
    btn:Dock( TOP )

    if isSub then
        btn:DockMargin( 26, 0, 26, 8 )
    else
        btn:DockMargin( 6, 0, 6, 8 )
    end

    btn:SetTextColor( txtColor )
    btn:SetText( text )
    btn:SetTooltip( tooltip )
    btn:SizeToContentsX()
    btn:SizeToContentsY( 7 )
    paintButton( btn )

    function btn:DoClick()
        if not leftfunc then return end
        leftfunc( settingsMenu )
    end

    function btn:DoRightClick()
        if not rightfunc then return end
        rightfunc( settingsMenu )
    end

    return btn
end

local function printInvalid( info, reason )
    if not developerVar:GetBool() then return end
    print( "CFC Settings: Config option, \"" .. info.displayName .. "\" not valid, " .. reason )
end

-- Option handler, returns the created row panel (or nil)
local function handleOptions( panel, action, info )
    -- Toggle convars
    if info.type == "bool" then
        if not GetConVar( action ) then printInvalid( info, "bool convar does not exist" ) return end
        return addBool( panel, info.displayName, action, info.tooltip )
    end
    -- Convars with multiple values
    if info.type == "slider" then
        if not GetConVar( action ) then printInvalid( info, "other convar does not exist" ) return end
        return addSlider( panel, info.displayName, action, info.decimals, info.tooltip )
    end

    -- Function slider
    if info.type == "sliderfunction" then
        if not info.exists() then printInvalid( info, ".exists returned false" )  return end
        return addFunctionSlider( panel, info )
    end

    -- Function bool
    if info.type == "boolfunction" then
        if not info.exists() then printInvalid( info, ".exists returned false" )  return end
        return addFunctionBool( panel, info )
    end

    -- Function button
    if info.type == "button" then
        if not info.exists() then printInvalid( info, ".exists returned false" )  return end
        return addFunctionButton( panel, info )
    end
end

-- Requests a resize; the actual sizing happens in the card's PerformLayout so
-- it runs after the body's children have been positioned.
local function layoutCard( card )
    card:InvalidateLayout()
    local parent = card:GetParent()
    if isValid( parent ) then parent:InvalidateLayout() end
end

-- Builds a collapsible card. Returns card, body.
local function createCard( parent, title )
    local card = parent:Add( "DPanel" )
    card:Dock( TOP )
    card:DockMargin( 0, 0, 0, 10 )
    card.collapsed = false
    card.Paint = function( _, w, h )
        draw.RoundedBox( 6, 0, 0, w, h, cardColor )
    end

    local header = card:Add( "DButton" )
    header:Dock( TOP )
    header:SetTall( CARD_HEADER_H )
    header:SetText( "" )
    header.Paint = function( _, w, h )
        draw.RoundedBoxEx( 6, 0, 0, w, h, cardHeaderColor, true, true, false, false )
        surface.SetDrawColor( accentColor )
        surface.DrawRect( 0, 0, 3, h )
        draw.SimpleText( title, "CFCSettingsHeader", 12, h * 0.5, txtColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
        local sign = card.collapsed and "+" or "-"
        draw.SimpleText( sign, "CFCSettingsSign", w - 14, h * 0.5 - 1, mutedColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    end

    local body = card:Add( "DPanel" )
    body:Dock( TOP )
    body:DockPadding( 4, 8, 4, 0 )
    body.Paint = nil
    card.body = body

    -- Self-correcting height: runs after docked children are positioned, so the
    -- measured body height is accurate. Only relayouts the parent when it changes.
    card.PerformLayout = function( self )
        local collapsed = self.collapsed and not self.forceOpen
        body:SetVisible( not collapsed )

        local target
        if collapsed then
            target = CARD_HEADER_H
        else
            body:InvalidateLayout( true ) -- force immediate layout of the rows
            body:SizeToChildren( false, true )
            target = CARD_HEADER_H + body:GetTall() + CARD_BODY_BOTTOM_PAD
        end

        if self:GetTall() ~= target then
            self:SetTall( target )
            local scrollParent = self:GetParent()
            if isValid( scrollParent ) then scrollParent:InvalidateLayout() end
        end
    end

    header.DoClick = function()
        card.collapsed = not card.collapsed
        layoutCard( card )
        if isValid( settingsMenu ) and isValid( settingsMenu.scroll ) then
            settingsMenu.scroll:InvalidateLayout( true )
        end
    end

    return card, body
end

-- Parses the config table and generates cards from it.
local function configHandler( scroll, config, rows, cards )
    for _, tbl in ipairs( config ) do
        for title, subtbl in pairs( tbl ) do
            -- Check if convars or functions exist before building the card.
            local valid = 0
            for _, settingtbl in ipairs( subtbl ) do
                for action, info in pairs( settingtbl ) do
                    if ( isfunction( info.exists ) and info.exists() ) or GetConVar( action ) then
                        valid = valid + 1
                    end
                end
            end
            if valid == 0 then continue end

            local card, body = createCard( scroll, title )
            cards[#cards + 1] = card

            for _, settingTbl in ipairs( subtbl ) do
                for action, info in pairs( settingTbl ) do
                    local rowPanel = handleOptions( body, action, info )
                    if rowPanel then
                        rows[#rows + 1] = {
                            panel = rowPanel,
                            card = card,
                            text = string.lower( info.displayName or action )
                        }
                    end
                end
            end

            layoutCard( card )
        end
    end
end

-- Filters visible rows/cards against the search query
local function applySearch( menu, query )
    query = string.lower( string.Trim( query or "" ) )
    local searching = query ~= ""

    local cardHasMatch = {}
    for _, row in ipairs( menu.rows ) do
        local show = not searching or string.find( row.text, query, 1, true ) ~= nil
        row.panel:SetVisible( show )
        if show then cardHasMatch[row.card] = true end
    end

    for _, card in ipairs( menu.cards ) do
        local vis = not searching or cardHasMatch[card] == true
        card:SetVisible( vis )
        card.forceOpen = searching -- expand matching cards while searching
        if vis then layoutCard( card ) end
    end

    if isValid( menu.scroll ) then
        menu.scroll:InvalidateLayout( true )
    end
end

local function toggleSettingsMenu()
    if isValid( settingsMenu ) and ispanel( settingsMenu ) then
        settingsMenu:ToggleVisible()
        return
    end

    settingsMenu = vgui.Create( "DFrame" )
    settingsMenu:SetSize( 340, 460 )
    settingsMenu:Center()
    settingsMenu:SetTitle( "" )
    settingsMenu:MakePopup()
    settingsMenu:SetKeyboardInputEnabled( false )
    settingsMenu:SetDeleteOnClose( false )
    settingsMenu:DockPadding( 8, 30, 8, 8 )

    settingsMenu.rows = {}
    settingsMenu.cards = {}

    function settingsMenu:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, uiColor )
        draw.RoundedBoxEx( 8, 0, 0, w, 26, titleBarColor, true, true, false, false )
        draw.SimpleText( "Settings", "CFCSettingsTitle", 12, 13, txtColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
    end

    -- Search box
    local search = settingsMenu:Add( "DTextEntry" )
    search:Dock( TOP )
    search:DockMargin( 0, 0, 0, 8 )
    search:SetTall( 26 )
    search:SetPlaceholderText( "Search..." )
    search:SetTextColor( txtColor )
    search:SetCursorColor( txtColor )
    search:SetPaintBackground( false )
    search.Paint = function( self, w, h )
        draw.RoundedBox( 4, 0, 0, w, h, searchBgColor )
        self:DrawTextEntryText( txtColor, accentColor, txtColor )
        if self:GetText() == "" and not self:HasFocus() then
            draw.SimpleText( "Search...", "DermaDefault", 8, h * 0.5, mutedColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
        end
    end
    -- Only capture the keyboard while typing so movement keys still work otherwise
    search.OnGetFocus = function()
        if isValid( settingsMenu ) then settingsMenu:SetKeyboardInputEnabled( true ) end
    end
    search.OnLoseFocus = function()
        if isValid( settingsMenu ) then settingsMenu:SetKeyboardInputEnabled( false ) end
    end
    search.OnChange = function( self )
        applySearch( settingsMenu, self:GetText() )
    end

    -- Scrolling content area
    local scroll = settingsMenu:Add( "DScrollPanel" )
    scroll:Dock( FILL )
    settingsMenu.scroll = scroll

    local sbar = scroll:GetVBar()
    sbar:SetWide( 8 )
    sbar:SetHideButtons( true )
    sbar.Paint = function() end
    sbar.btnGrip.Paint = function( _, w, h )
        draw.RoundedBox( 4, 2, 0, w - 4, h, cardHeaderColor )
    end

    -- "Parse" the config table
    configHandler( scroll, convarTable, settingsMenu.rows, settingsMenu.cards )
end

hook.Add( "OnPlayerChat", "CFCSettingsHideCommand", function( ply, text )
    local lower = string.lower( text ) -- make the string lower case
    if lower ~= "!settings" then return end
    if ply == LocalPlayer() then
        toggleSettingsMenu()
    end
    return true
end )

concommand.Add( "cfc_settings", toggleSettingsMenu )
