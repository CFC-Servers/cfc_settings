--[[-------------------------------------------------------------------------
VGUI Options menu

Registers two panels:
    CFCSettingsCard  - a collapsible, self-sizing section
    CFCSettingsPanel - the search box + scrolling list of cards

CFCSettingsPanel paints no background and takes its width from its parent, so it
can be docked into any container. Standalone, it lives in the DFrame built by
toggleSettingsMenu.
---------------------------------------------------------------------------]]
local isValid = IsValid
local GetConVar = GetConVar

local settingsMenu -- the standalone DFrame, reused across toggles
local developerVar = GetConVar( "developer" )

-- Palette
local uiColor = Color( 36, 41, 67 )
local titleBarColor = Color( 28, 32, 52 )
local cardColor = Color( 44, 50, 80 )
local cardHeaderColor = Color( 52, 59, 94 )
local searchBgColor = Color( 28, 32, 52 )
local txtColor = Color( 210, 210, 210, 255 )
local mutedColor = Color( 150, 156, 180 )
local descColor = Color( 210, 210, 210, 115 )
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
local DESC_INDENT_CHECK = 26 -- clears the checkbox, aligns under its label
local DESC_INDENT_PLAIN = 8

surface.CreateFont( "CFCSettingsTitle", { font = "Roboto", size = 19, weight = 700, antialias = true } )
surface.CreateFont( "CFCSettingsHeader", { font = "Roboto", size = 16, weight = 600, antialias = true } )
surface.CreateFont( "CFCSettingsSign", { font = "Roboto", size = 20, weight = 700, antialias = true } )
surface.CreateFont( "CFCSettingsLabel", { font = "Roboto", size = 16, weight = 500, antialias = true } )
surface.CreateFont( "CFCSettingsDesc", { font = "Roboto", size = 13, weight = 400, antialias = true } )

local defaultConfig = include( "cfc_settings/client/cl_config.lua" )

-- Outermost ancestor, stopping short of the vgui root
local function findRoot( panel )
    local root = panel
    local world = vgui.GetWorldPanel()

    while true do
        local parent = root:GetParent()
        if not isValid( parent ) or parent == world then break end
        root = parent
    end

    return root
end

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

-- Explanatory text shown under a setting. Falls back to the tooltip, then the
-- convar's help text.
local function descriptionFor( info, cname )
    local text = info.description or info.tooltip
    if text and text ~= "" then return text end

    local convar = cname and GetConVar( cname )
    if convar then
        local help = convar:GetHelpText()
        if help and help ~= "" then return help end
    end
end

-- Dimmed, wrapped description under a setting row. Returns the label, or nil.
local function addDescription( panel, text, indent )
    if not text or text == "" then return end

    local desc = panel:Add( "DLabel" )
    desc:Dock( TOP )
    desc:DockMargin( indent, 0, 8, 8 )
    desc:SetFont( "CFCSettingsDesc" )
    desc:SetTextColor( descColor )
    desc:SetText( text )
    desc:SetContentAlignment( 7 )
    desc:SetWrap( true )
    desc:SetAutoStretchVertical( true )

    return desc
end

-- Convar settings
local function addBool( panel, text, cname, tooltip )
    local convar = GetConVar( cname )
    tooltip = tooltip or convar:GetHelpText()

    local checkBox = panel:Add( "DCheckBoxLabel" )
    checkBox:Dock( TOP )
    checkBox:DockMargin( 6, 0, 6, 6 )
    checkBox:SetTextColor( txtColor )
    checkBox:SetFont( "CFCSettingsLabel" )
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
    local sliderLabel = distanceSlider:GetChildren()[3]
    sliderLabel:SetTextColor( txtColor )
    sliderLabel:SetFont( "CFCSettingsLabel" )
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
    checkBox:SetFont( "CFCSettingsLabel" )
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
    local sliderLabel = distanceSlider:GetChildren()[3]
    sliderLabel:SetTextColor( txtColor )
    sliderLabel:SetFont( "CFCSettingsLabel" )
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

-- menu is passed to the config's callbacks so they can act on the settings panel
local function addFunctionButton( menu, panel, info )
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
    btn:SetFont( "CFCSettingsLabel" )
    btn:SetText( text )
    btn:SetTooltip( tooltip )
    btn:SizeToContentsY( 7 )
    paintButton( btn )

    function btn:DoClick()
        if not leftfunc then return end
        leftfunc( menu )
    end

    function btn:DoRightClick()
        if not rightfunc then return end
        rightfunc( menu )
    end

    return btn
end

local function printInvalid( info, reason )
    if not developerVar:GetBool() then return end
    print( "CFC Settings: Config option, \"" .. info.displayName .. "\" not valid, " .. reason )
end

-- Option handler, returns the created control and its description label (both may be nil)
local function handleOptions( menu, panel, action, info )
    -- Toggle convars
    if info.type == "bool" then
        if not GetConVar( action ) then printInvalid( info, "bool convar does not exist" ) return end
        local control = addBool( panel, info.displayName, action, info.tooltip )
        local desc = addDescription( panel, descriptionFor( info, action ), DESC_INDENT_CHECK )
        if desc then control:DockMargin( 6, 0, 6, 2 ) end
        return control, desc
    end
    -- Convars with multiple values
    if info.type == "slider" then
        if not GetConVar( action ) then printInvalid( info, "other convar does not exist" ) return end
        local control = addSlider( panel, info.displayName, action, info.decimals, info.tooltip )
        return control, addDescription( panel, descriptionFor( info, action ), DESC_INDENT_PLAIN )
    end

    -- Function slider
    if info.type == "sliderfunction" then
        if not info.exists() then printInvalid( info, ".exists returned false" )  return end
        local control = addFunctionSlider( panel, info )
        return control, addDescription( panel, descriptionFor( info ), DESC_INDENT_PLAIN )
    end

    -- Function bool
    if info.type == "boolfunction" then
        if not info.exists() then printInvalid( info, ".exists returned false" )  return end
        local control = addFunctionBool( panel, info )
        local desc = addDescription( panel, descriptionFor( info ), DESC_INDENT_CHECK )
        if desc then control:DockMargin( 6, 0, 6, 2 ) end
        return control, desc
    end

    -- Function button
    if info.type == "button" then
        if not info.exists() then printInvalid( info, ".exists returned false" )  return end
        local control = addFunctionButton( menu, panel, info )
        local indent = info.issub and DESC_INDENT_CHECK or DESC_INDENT_PLAIN
        return control, addDescription( panel, descriptionFor( info ), indent )
    end
end

-- How many of a category's settings have a live convar or a passing exists() check
local function countValidSettings( subtbl )
    local valid = 0

    for _, settingTbl in ipairs( subtbl ) do
        for action, info in pairs( settingTbl ) do
            if ( isfunction( info.exists ) and info.exists() ) or GetConVar( action ) then
                valid = valid + 1
            end
        end
    end

    return valid
end

--[[-------------------------------------------------------------------------
CFCSettingsCard - a collapsible section that sizes itself to its contents
---------------------------------------------------------------------------]]
local CARD = {}

AccessorFunc( CARD, "m_title", "Title", FORCE_STRING )
AccessorFunc( CARD, "m_collapsed", "Collapsed", FORCE_BOOL )
AccessorFunc( CARD, "m_forceOpen", "ForceOpen", FORCE_BOOL )

function CARD:Init()
    self:SetTitle( "" )
    self:SetCollapsed( false )
    self:SetForceOpen( false )
    self:Dock( TOP )
    self:DockMargin( 0, 0, 0, 10 )

    local header = self:Add( "DButton" )
    header:Dock( TOP )
    header:SetTall( CARD_HEADER_H )
    header:SetText( "" )
    header.Paint = function( _, w, h )
        draw.RoundedBoxEx( 6, 0, 0, w, h, cardHeaderColor, true, true, false, false )
        surface.SetDrawColor( accentColor )
        surface.DrawRect( 0, 0, 3, h )
        draw.SimpleText( self:GetTitle(), "CFCSettingsHeader", 12, h * 0.5, txtColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
        local sign = self:IsOpen() and "-" or "+"
        draw.SimpleText( sign, "CFCSettingsSign", w - 14, h * 0.5 - 1, mutedColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    end
    header.DoClick = function()
        self:Toggle()
    end
    self.Header = header

    local body = self:Add( "DPanel" )
    body:Dock( TOP )
    body:DockPadding( 4, 8, 4, 0 )
    body.Paint = nil
    self.Body = body
end

function CARD:Paint( w, h )
    draw.RoundedBox( 6, 0, 0, w, h, cardColor )
end

function CARD:GetBody()
    return self.Body
end

-- ForceOpen wins over Collapsed, so a search can reveal a folded card
function CARD:IsOpen()
    return not self:GetCollapsed() or self:GetForceOpen()
end

function CARD:Toggle()
    self:SetCollapsed( not self:GetCollapsed() )
    self:InvalidateLayout()

    local parent = self:GetParent()
    if isValid( parent ) then parent:InvalidateLayout() end
end

-- Runs after the body's docked children are positioned, so the measured height is
-- accurate. Only touches the parent when the height actually changed.
function CARD:PerformLayout()
    local open = self:IsOpen()
    local body = self.Body
    body:SetVisible( open )

    local target = CARD_HEADER_H
    if open then
        body:InvalidateLayout( true ) -- force immediate layout of the rows
        body:SizeToChildren( false, true )
        target = target + body:GetTall() + CARD_BODY_BOTTOM_PAD
    end

    if self:GetTall() == target then return end

    self:SetTall( target )
    local parent = self:GetParent()
    if isValid( parent ) then parent:InvalidateLayout() end
end

vgui.Register( "CFCSettingsCard", CARD, "DPanel" )

--[[-------------------------------------------------------------------------
CFCSettingsPanel - search box over a scrolling list of cards
---------------------------------------------------------------------------]]
local PANEL = {}

-- When true, the search box grabs the keyboard from the root panel while focused.
-- Hosts that manage keyboard input themselves should turn this off.
AccessorFunc( PANEL, "m_manageKeyboard", "ManageKeyboard", FORCE_BOOL )

function PANEL:Init()
    self:SetManageKeyboard( true )
    self.rows = {}
    self.cards = {}

    local search = self:Add( "DTextEntry" )
    search:Dock( TOP )
    search:DockMargin( 0, 0, 0, 8 )
    search:SetTall( 26 )
    search:SetPlaceholderText( "Search..." )
    search:SetTextColor( txtColor )
    search:SetCursorColor( txtColor )
    search:SetPaintBackground( false )
    search.Paint = function( entry, w, h )
        draw.RoundedBox( 4, 0, 0, w, h, searchBgColor )
        entry:DrawTextEntryText( txtColor, accentColor, txtColor )
        if entry:GetText() == "" and not entry:HasFocus() then
            draw.SimpleText( "Search...", "DermaDefault", 8, h * 0.5, mutedColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
        end
    end
    -- Only capture the keyboard while typing so movement keys still work otherwise
    search.OnGetFocus = function()
        self:CaptureKeyboard( true )
    end
    search.OnLoseFocus = function()
        self:CaptureKeyboard( false )
    end
    search.OnChange = function( entry )
        self:ApplySearch( entry:GetText() )
    end
    self.Search = search

    local scroll = self:Add( "DScrollPanel" )
    scroll:Dock( FILL )
    self.Scroll = scroll

    local sbar = scroll:GetVBar()
    sbar:SetWide( 8 )
    sbar:SetHideButtons( true )
    sbar.Paint = function() end
    sbar.btnGrip.Paint = function( _, w, h )
        draw.RoundedBox( 4, 2, 0, w - 4, h, cardHeaderColor )
    end

    self:SetConfig( defaultConfig )
end

-- Transparent by default so the panel takes on its host's background
function PANEL:Paint()
end

function PANEL:CaptureKeyboard( enabled )
    if not self:GetManageKeyboard() then return end

    local root = findRoot( self )
    if isValid( root ) then root:SetKeyboardInputEnabled( enabled ) end
end

-- Hides the containing frame. Override this when embedding to close whatever the
-- settings panel actually lives in.
function PANEL:RequestClose()
    local root = findRoot( self )
    if isValid( root ) then root:SetVisible( false ) end
end

-- Builds one setting and registers it for search. The description is matched too.
function PANEL:AddSetting( card, action, info )
    local rowPanel, descPanel = handleOptions( self, card:GetBody(), action, info )
    if not rowPanel then return end

    local searchText = info.displayName or action
    if descPanel then
        searchText = searchText .. " " .. descPanel:GetText()
    end

    self.rows[#self.rows + 1] = {
        panel = rowPanel,
        desc = descPanel,
        card = card,
        text = string.lower( searchText )
    }
end

function PANEL:AddCard( title, subtbl )
    local card = self.Scroll:Add( "CFCSettingsCard" )
    card:SetTitle( title )
    self.cards[#self.cards + 1] = card

    for _, settingTbl in ipairs( subtbl ) do
        for action, info in pairs( settingTbl ) do
            self:AddSetting( card, action, info )
        end
    end

    card:InvalidateLayout()

    return card
end

-- Rebuilds the whole list from a config table (see cl_config.lua for the shape)
function PANEL:SetConfig( config )
    self.Scroll:Clear()
    self.rows = {}
    self.cards = {}

    for _, tbl in ipairs( config ) do
        for title, subtbl in pairs( tbl ) do
            -- Only build the card if something in it exists
            if countValidSettings( subtbl ) ~= 0 then
                self:AddCard( title, subtbl )
            end
        end
    end
end

-- Filters visible rows/cards against the search query
function PANEL:ApplySearch( query )
    query = string.lower( string.Trim( query or "" ) )
    local searching = query ~= ""

    local cardHasMatch = {}
    for _, row in ipairs( self.rows ) do
        local show = not searching or string.find( row.text, query, 1, true ) ~= nil
        row.panel:SetVisible( show )
        if row.desc then row.desc:SetVisible( show ) end
        if show then cardHasMatch[row.card] = true end
    end

    for _, card in ipairs( self.cards ) do
        local vis = not searching or cardHasMatch[card] == true
        card:SetVisible( vis )
        card:SetForceOpen( searching )
        if vis then card:InvalidateLayout() end
    end

    self.Scroll:InvalidateLayout( true )
end

vgui.Register( "CFCSettingsPanel", PANEL, "DPanel" )

--[[-------------------------------------------------------------------------
Standalone frame
---------------------------------------------------------------------------]]
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

    function settingsMenu:Paint( w, h )
        draw.RoundedBox( 8, 0, 0, w, h, uiColor )
        draw.RoundedBoxEx( 8, 0, 0, w, 26, titleBarColor, true, true, false, false )
        draw.SimpleText( "Settings", "CFCSettingsTitle", 12, 13, txtColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
    end

    settingsMenu.settings = settingsMenu:Add( "CFCSettingsPanel" )
    settingsMenu.settings:Dock( FILL )
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
