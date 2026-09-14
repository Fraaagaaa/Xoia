local mapname, gametype, startlocation
local isDepot, isFarm, isTown, isTranzit, isNuketown, isDieRise, isMob, isBuried, isOrigins, isSurvival

CoD.Xoia = {}
CoD.Xoia.CurrentTabIndex = 1
CoD.Xoia.NeedVidRestart = false
CoD.Xoia.NeedPicmip = false
CoD.Xoia.NeedSndRestart = false

CoD.Xoia.RoundTimes = {30, 50, 70, 100, 150, 200, 255}

CoD.Xoia.RefreshMapFlags = function ()
    mapname = UIExpression.DvarString( nil, "mapname" )
	gametype = UIExpression.DvarString( nil, "ui_gametype")
	startlocation = UIExpression.DvarString( nil, "ui_zm_mapstartlocation")

    isDepot    = (mapname == "zm_transit" and gametype == "zstandard" and startlocation == "transit")
    isFarm     =  startlocation == "farm"
    isTown     =  startlocation == "town"
    isTranzit  = (mapname == "zm_transit" and gametype == "zclassic")
    isNuketown = (mapname == "zm_nuked")
    isDieRise  = (mapname == "zm_highrise")
    isMob      = (mapname == "zm_prison")
    isBuried   = (mapname == "zm_buried")
    isOrigins  = (mapname == "zm_tomb")
    isSurvival = (isDepot or isFarm or isTown or isNuketown)
end


CoD.Xoia.Back = function ( element, event )
	element:goBack( event.controller )
end

CoD.Xoia.TabChanged = function ( Widget, SettingsTab )
	Widget.buttonList = Widget.tabManager.buttonList
	local NextFocusableTab = Widget.buttonList:getFirstChild()
	while NextFocusableTab and not NextFocusableTab.m_focusable do
		NextFocusableTab = NextFocusableTab:getNextSibling()
	end
	if NextFocusableTab ~= nil then
		NextFocusableTab:processEvent( { name = "gain_focus" } )
	end
	CoD.Xoia.CurrentTabIndex = SettingsTab.tabIndex
end

CoD.Xoia.OnDvarChanged = function ( choice, isUserRequest )
	if isUserRequest ~= true then
		return 
	end

	local dvarName = choice.parentSelectorButton.m_profileVarName
	local value = choice.value

	Engine.SetDvar( dvarName, value )
end

CoD.Xoia.OnToggleChanged = function ( choice, isUserRequest )
    if isUserRequest ~= true then return end

    local controller = choice.parentSelectorButton.m_currentController
    if controller == nil then
        controller = 0
    end

    local dvarName = choice.parentSelectorButton.m_profileVarName
    local moduleName = choice.parentSelectorButton.m_stModule

    Engine.SetDvar( dvarName, choice.value )

    if moduleName ~= nil then
        CoD.Xoia.send_response( controller, moduleName, "set", { dvarName .. ":" .. tostring(choice.value) } )
    end
end

CoD.Xoia.SetDvarPersistent = function ( controller, dvarName, value )
    Engine.SetDvar( dvarName, value )

    if controller == nil then
        controller = 0
    end

    Engine.Exec( controller, "seta " .. dvarName .. " " .. tostring( value ) )
end

CoD.Xoia.OnCharacterChanged = function ( choice, isUserRequest )
    if isUserRequest ~= true then return end
    local controller = choice.parentSelectorButton.m_currentController
    if controller == nil then controller = 0 end

    local dvarName = choice.parentSelectorButton.m_profileVarName
    CoD.Xoia.SetDvarPersistent( controller, dvarName, choice.value )
    Engine.SendMenuResponse( controller, "restartgamepopup", "xoia+character+set+" .. tostring(choice.value) )
end

CoD.Xoia.sync_character_menu = function ( controller )
    if UIExpression.DvarString( nil, "xoia_character" ) == "" then return end

    local value = UIExpression.DvarInt( nil, "xoia_character" )
    if value == nil or value < 1 then return end

    CoD.Xoia.send_response( controller, "character", "set", { tostring(value) } )
end

CoD.Xoia.AddChoices_OnOrOff = function ( selector, defaultVal, module )
    selector.m_stModule = module

    selector:addChoice(Engine.Localize("XOIA_MENU_OFF"), 0, nil, CoD.Xoia.OnToggleChanged )
    selector:addChoice(Engine.Localize("XOIA_MENU_ON"), 1, nil, CoD.Xoia.OnToggleChanged )

    local dvarName = selector.m_profileVarName
    local currentVal = UIExpression.DvarInt( nil, dvarName )

    if currentVal == nil or UIExpression.DvarString( nil, dvarName ) == "" then
        currentVal = defaultVal
        Engine.SetDvar( dvarName, currentVal )
    end

    selector:setChoice( currentVal )
end

CoD.Xoia.send_response = function ( controller, module, action, args )
    if Engine.SendMenuResponse == nil then return end

    local payload = "xoia+" .. module .. "+" .. action

    if args ~= nil then
        for _, a in ipairs( args ) do
            payload = payload .. "+" .. tostring( a )
        end
    end

    Engine.SendMenuResponse( controller, "restartgamepopup", payload )
end

CoD.Xoia.SendMonitorCommand = function ( controller, command )
    CoD.Xoia.send_response( controller, "game_monitor", "set", { command } )
end

CoD.Xoia.BuildMonitorCommands = function ()
    if isOrigins then
        CoD.Xoia.MonitorCommands = {
            { label = "XOIA_MENU_MONITOR_HELP", command = "help" },
            { label = "XOIA_MENU_MONITOR_PRINT_TIMES", command = "times" },
            { label = "XOIA_MENU_MONITOR_ZOMBIECOUNT", command = "zombiecount" },
            { label = "XOIA_MENU_MONITOR_BOXHITS", command = "boxhits" },
            { label = "XOIA_MENU_MONITOR_FROZEN", command = "frozen" },
            { label = "XOIA_MENU_MONITOR_NEXTTEMPLARS", command = "nexttemplars" },
            { label = "XOIA_MENU_MONITOR_TEMPLARS", command = "templars" },
            { label = "XOIA_MENU_MONITOR_NEXTPANZER", command = "nextpanzer" },
            { label = "XOIA_MENU_MONITOR_PANZERS", command = "panzers" },
            { label = "XOIA_MENU_MONITOR_ROUNDERS", command = "rounders" },
            { label = "XOIA_MENU_MONITOR_BACKSPEED", command = "backspeed" },
        }
    elseif isDieRise then
        CoD.Xoia.MonitorCommands = {
            { label = "XOIA_MENU_MONITOR_HELP", command = "help" },
            { label = "XOIA_MENU_MONITOR_PRINT_TIMES", command = "times" },
            { label = "XOIA_MENU_MONITOR_ZOMBIECOUNT", command = "zombiecount" },
            { label = "XOIA_MENU_MONITOR_BOXHITS", command = "boxhits" },
            { label = "XOIA_MENU_MONITOR_NEXTLEAPERS", command = "nextleapers" },
            { label = "XOIA_MENU_MONITOR_LEAPERS", command = "leapers" },
            { label = "XOIA_MENU_MONITOR_ROUNDERS", command = "rounders" },
            { label = "XOIA_MENU_MONITOR_BACKSPEED", command = "backspeed" },
        }
    elseif isMob then
        CoD.Xoia.MonitorCommands = {
            { label = "XOIA_MENU_MONITOR_HELP", command = "help" },
            { label = "XOIA_MENU_MONITOR_NEXT_KEY", command = "keymonitor"},
            { label = "XOIA_MENU_MONITOR_PRINT_TIMES", command = "times" },
            { label = "XOIA_MENU_MONITOR_ZOMBIECOUNT", command = "zombiecount" },
            { label = "XOIA_MENU_MONITOR_BOXHITS", command = "boxhits" },
            { label = "XOIA_MENU_MONITOR_NEXTBRUTUS", command = "nextbrutus" },
            { label = "XOIA_MENU_MONITOR_BRUTUS", command = "brutus" },
            { label = "XOIA_MENU_MONITOR_ROUNDERS", command = "rounders" },
            { label = "XOIA_MENU_MONITOR_BACKSPEED", command = "backspeed" },
        }
    else
        CoD.Xoia.MonitorCommands = {
            { label = "XOIA_MENU_MONITOR_HELP", command = "help" },
            { label = "XOIA_MENU_MONITOR_PRINT_TIMES", command = "times" },
            { label = "XOIA_MENU_MONITOR_ZOMBIECOUNT", command = "zombiecount" },
            { label = "XOIA_MENU_MONITOR_BOXHITS", command = "boxhits" },
            { label = "XOIA_MENU_MONITOR_BACKSPEED", command = "backspeed" },
        }
    end
end

-- PESTAÑA 1: Monitor
CoD.Xoia.CreateMonitorTab = function ( Tab, LocalClientIndex )
    CoD.Xoia.RefreshMapFlags()
    CoD.Xoia.BuildMonitorCommands()
	local Container = LUI.UIContainer.new()
	local ButtonList = CoD.Options.CreateButtonList()

	Tab.buttonList = ButtonList
	Container:addElement( ButtonList )

    for i, entry in ipairs( CoD.Xoia.MonitorCommands ) do
        local Button = ButtonList:addButton( Engine.Localize( entry.label ) )
        Button:setActionEventName( "xoia_monitor_cmd_" .. i )
    end

    return Container
end

-- PESTAÑA 2: Configuración (contenido anteriormente en "Cosmetics")
CoD.Xoia.CreateConfigTab = function ( Tab, LocalClientIndex )
    CoD.Xoia.RefreshMapFlags()
    local Container = LUI.UIContainer.new()
    local ButtonList = CoD.Options.CreateButtonList()

    Tab.buttonList = ButtonList
    Container:addElement( ButtonList )

    local TimerChoice = ButtonList:addHardwareProfileLeftRightSelector(Engine.Localize("XOIA_MENU_HUD_TIMER_POSITION"), "timer", Engine.Localize("XOIA_MENU_HUD_TIMER_POSITION_DESC"))
    TimerChoice:addChoice(Engine.Localize("XOIA_MENU_HUD_TIMER_HIDDEN"), 0, nil, CoD.Xoia.OnDvarChanged )
    TimerChoice:addChoice(Engine.Localize("XOIA_MENU_HUD_TIMER_TOP_RIGHT"), 1, nil, CoD.Xoia.OnDvarChanged )
    TimerChoice:addChoice(Engine.Localize("XOIA_MENU_HUD_TIMER_TOP_LEFT"), 2, nil, CoD.Xoia.OnDvarChanged )
    TimerChoice:addChoice(Engine.Localize("XOIA_MENU_HUD_TIMER_MIDDLE_LEFT"), 3, nil, CoD.Xoia.OnDvarChanged )
    TimerChoice:addChoice(Engine.Localize("XOIA_MENU_HUD_TIMER_BOTTOM"), 4, nil, CoD.Xoia.OnDvarChanged )

    local currentTimerVal = UIExpression.DvarInt( nil, "timer")
    if UIExpression.DvarString( nil, "timer") == "" then
        currentTimerVal = 1
        Engine.SetDvar("timer", currentTimerVal )
    end

    TimerChoice:setChoice( currentTimerVal )

    if isNuketown then
        local NukeChoice = ButtonList:addHardwareProfileLeftRightSelector(Engine.Localize("XOIA_MENU_COSMETICS_NUKETOWN_RESTART"), "forcepap", Engine.Localize("XOIA_MENU_COSMETICS_NUKETOWN_RESTART_DESC"))
        CoD.Xoia.AddChoices_OnOrOff(NukeChoice, 0)
    end

    -- if isMob then
    --     local TrapTimerChoice = ButtonList:addHardwareProfileLeftRightSelector(Engine.Localize("XOIA_MENU_HUD_TRAP_TIMER"), "traptimer", Engine.Localize("XOIA_MENU_HUD_TRAP_TIMER_DESC"))
    --     CoD.Xoia.AddChoices_OnOrOff(TrapTimerChoice , 1 )
    --
    --     local KeyChoice = ButtonList:addHardwareProfileLeftRightSelector(Engine.Localize("XOIA_MENU_HUD_KEY_POSITION"), "mob_key", Engine.Localize("XOIA_MENU_HUD_KEY_POSITION_DESC"))
    --     KeyChoice:addChoice(Engine.Localize("XOIA_MENU_HUD_KEY_RANDOM"), 0, nil, CoD.Xoia.OnDvarChanged )
    --     KeyChoice:addChoice(Engine.Localize("XOIA_MENU_HUD_KEY_CAFE"), 1, nil, CoD.Xoia.OnDvarChanged )
    --     KeyChoice:addChoice(Engine.Localize("XOIA_MENU_HUD_KEY_WARDEN"), 2, nil, CoD.Xoia.OnDvarChanged )
    --
    --     local currentTimerVal = UIExpression.DvarInt( nil, "mob_key")
    --     if UIExpression.DvarString( nil, "mob_key") == "" then
    --         currentTimerVal = 1
    --         Engine.SetDvar("mob_key", currentTimerVal )
    --     end
    -- end

    local CharacterChoice = ButtonList:addHardwareProfileLeftRightSelector( Engine.Localize("XOIA_MENU_HUD_CHARACTER_POSITION"), "xoia_character", Engine.Localize("XOIA_MENU_HUD_CHARACTER_POSITION_DESC") )

    local characterEntries = {
        { "XOIA_MENU_MISTY", 1 },
        { "XOIA_MENU_RUSSMAN", 2 },
        { "XOIA_MENU_MARLTON", 3 },
        { "XOIA_MENU_STUHLINGER", 4 },
        { "XOIA_MENU_CDC", 5 },
        { "XOIA_MENU_CIA", 6 },
        { "XOIA_MENU_ARLINGTON", 7 },
        { "XOIA_MENU_OLEARY", 8 },
        { "XOIA_MENU_DELUCA", 9 },
        { "XOIA_MENU_HANDSOME", 10 },
        { "XOIA_MENU_AFTERLIFE", 11 },
        { "XOIA_MENU_DEMPSEY", 12 },
        { "XOIA_MENU_NIKOLAI", 13 },
        { "XOIA_MENU_TAKEO", 14 },
        { "XOIA_MENU_RICHTOFEN", 15 },
    }

    for _, entry in ipairs( characterEntries ) do
        CharacterChoice:addChoice( Engine.Localize( entry[1] ), entry[2], nil, CoD.Xoia.OnCharacterChanged )
    end

    local currentCharacterVal = UIExpression.DvarInt( nil, "xoia_character" )
    if currentCharacterVal == nil or UIExpression.DvarString( nil, "xoia_character" ) == "" or currentCharacterVal < 1 or currentCharacterVal > #characterEntries then
        currentCharacterVal = characterEntries[1][2]
    end
    CharacterChoice:setChoice( currentCharacterVal )

    if isMob or isBuried or isOrigins then
        local CamoChoice = ButtonList:addHardwareProfileLeftRightSelector(Engine.Localize("XOIA_MENU_COSMETIC_CAMO"), "papcamo", Engine.Localize("XOIA_MENU_COSMETIC_CAMO_DESC"))
        CamoChoice:addChoice(Engine.Localize("XOIA_MENU_COSMETIC_CAMO_NOCAMO"), 1, nil, CoD.Xoia.OnDvarChanged )
        CamoChoice:addChoice(Engine.Localize("XOIA_MENU_COSMETIC_CAMO_GREEN_RUN"), 39, nil, CoD.Xoia.OnDvarChanged )
        CamoChoice:addChoice(Engine.Localize("XOIA_MENU_COSMETIC_CAMO_MOB"), 40, nil, CoD.Xoia.OnDvarChanged )

        if isBuried or isOrigins then
            CamoChoice:addChoice(Engine.Localize("XOIA_MENU_COSMETIC_CAMO_AQUA"), 41, nil, CoD.Xoia.OnDvarChanged )
            CamoChoice:addChoice(Engine.Localize("XOIA_MENU_COSMETIC_CAMO_BREACH"), 42, nil, CoD.Xoia.OnDvarChanged )
            CamoChoice:addChoice(Engine.Localize("XOIA_MENU_COSMETIC_CAMO_COYOTE"), 43, nil, CoD.Xoia.OnDvarChanged )
            CamoChoice:addChoice(Engine.Localize("XOIA_MENU_COSMETIC_CAMO_GLAM"), 44, nil, CoD.Xoia.OnDvarChanged )
        end

        if isOrigins then
            CamoChoice:addChoice(Engine.Localize("XOIA_MENU_COSMETIC_CAMO_ORIGINS"), 45, nil, CoD.Xoia.OnDvarChanged )
        end

        local currentCamo = UIExpression.DvarInt( nil, "papcamo" )
        if currentCamo == nil or UIExpression.DvarString( nil, "papcamo" ) == "" then
            currentCamo = 1
            Engine.SetDvar( "papcamo", currentCamo )
        end
        CamoChoice:setChoice( currentCamo )
    end

    return Container
end

-- PESTAÑA 3: TRACKERS
CoD.Xoia.CreateTrackersTab = function ( Tab, LocalClientIndex )
    CoD.Xoia.RefreshMapFlags()
    local Container = LUI.UIContainer.new()
    local ButtonList = CoD.Options.CreateButtonList()

    Tab.buttonList = ButtonList
    Container:addElement( ButtonList )

    local Tracker1Choice = ButtonList:addHardwareProfileLeftRightSelector(
        Engine.Localize("XOIA_MENU_TRACKER_RESET"),
        "cg_drawReset",
        Engine.Localize("XOIA_MENU_TRACKER_RESET_DESC")
    )
    CoD.Xoia.AddChoices_OnOrOff( Tracker1Choice, 0 )

    local Tracker2Choice = ButtonList:addHardwareProfileLeftRightSelector(
        Engine.Localize("XOIA_MENU_TRACKER_SCRIPT_USAGE"),
        "cg_drawScriptUsage",
        Engine.Localize("XOIA_MENU_TRACKER_SCRIPT_USAGE_DESC")
    )
    CoD.Xoia.AddChoices_OnOrOff( Tracker2Choice, 0 )

    local Tracker3Choice = ButtonList:addHardwareProfileLeftRightSelector(
        Engine.Localize("XOIA_MENU_TRACKER_ENTITY_USAGE"),
        "cg_drawEntityUsage",
        Engine.Localize("XOIA_MENU_TRACKER_ENTITY_USAGE_DESC")
    )
    CoD.Xoia.AddChoices_OnOrOff( Tracker3Choice, 0 )

    local Tracker4Choice = ButtonList:addHardwareProfileLeftRightSelector(
        Engine.Localize("XOIA_MENU_TRACKER_ANIM_INFO"),
        "cg_drawAnimInfo",
        Engine.Localize("XOIA_MENU_TRACKER_ANIM_INFO_DESC")
    )
    CoD.Xoia.AddChoices_OnOrOff( Tracker4Choice, 0 )

    local Tracker5Choice = ButtonList:addHardwareProfileLeftRightSelector(
        Engine.Localize("XOIA_MENU_TRACKER_MEM_USAGE"),
        "cg_drawMemUsage",
        Engine.Localize("XOIA_MENU_TRACKER_MEM_USAGE_DESC")
    )
    CoD.Xoia.AddChoices_OnOrOff( Tracker5Choice, 0 )

    local Tracker6Choice = ButtonList:addHardwareProfileLeftRightSelector(
        Engine.Localize("XOIA_MENU_TRACKER_STRING_USAGE"),
        "cg_drawStringUsage",
        Engine.Localize("XOIA_MENU_TRACKER_STRING_USAGE_DESC")
    )
    CoD.Xoia.AddChoices_OnOrOff( Tracker6Choice, 0 )

    local Tracker7Choice = ButtonList:addHardwareProfileLeftRightSelector(
        Engine.Localize("XOIA_MENU_TRACKER_VIEW_ANGLES"),
        "cg_drawViewAngles",
        Engine.Localize("XOIA_MENU_TRACKER_VIEW_ANGLES_DESC")
    )
    CoD.Xoia.AddChoices_OnOrOff( Tracker7Choice, 0 )

    local Tracker8Choice = ButtonList:addHardwareProfileLeftRightSelector(
        Engine.Localize("XOIA_MENU_TRACKER_SOUNDDONE_REFCOUNT"),
        "cg_drawSounddoneRefCount",
        Engine.Localize("XOIA_MENU_TRACKER_SOUNDDONE_REFCOUNT_DESC")
    )
    CoD.Xoia.AddChoices_OnOrOff( Tracker8Choice, 0 )

    return Container
end


-- PESTAÑA 4: INFO
CoD.Xoia.CreateInfoTab = function ( Tab, LocalClientIndex )
    CoD.Xoia.RefreshMapFlags()
    local Container = LUI.UIContainer.new()
    local ButtonList = CoD.Options.CreateButtonList()
    Tab.buttonList = ButtonList
    Container:addElement( ButtonList )

    local function addInfo(title, dvar)
        local val = UIExpression.DvarString(nil, dvar)
        if val == "" then val = "N/A" end
        local btn = ButtonList:addButton( title .. ": " .. val )
    end
    ButtonList:addButton( Engine.Localize("XOIA_MENU_INFO_ROUND_TIMES") )

    for _, round in ipairs( CoD.Xoia.RoundTimes ) do
        addInfo( tostring( round ), "timeto" .. tostring( round ) )
    end

    local lobbyPlayers = Engine.GetPlayersInLobby()
    local playerCount = lobbyPlayers and #lobbyPlayers or 1

    if playerCount == 1 then
        ButtonList:addButton( Engine.Localize("XOIA_MENU_INFO_DOWNS") )
        addInfo( Engine.Localize("XOIA_MENU_INFO_DOWNS_LIST_1"), "xoia_info_down1" )
        addInfo( Engine.Localize("XOIA_MENU_INFO_DOWNS_LIST_2"), "xoia_info_down2" )
        addInfo( Engine.Localize("XOIA_MENU_INFO_DOWNS_LIST_3"), "xoia_info_down3" )
    end

    return Container
end

CoD.Xoia.AddPausedAtRoundText = function ( menu, LocalClientIndex )
    if UIExpression.IsInGame( LocalClientIndex ) ~= 1 then return end

    local RoundText = LUI.UIText.new()

    RoundText:setLeftRight( true, true, 0, 0 )
    RoundText:setTopBottom( true, false, 40, 40 + CoD.textSize.Default )
    RoundText:setFont( CoD.fonts.Default )
    RoundText:setAlignment( LUI.Alignment.Center )

    local currentRound = UIExpression.DvarInt( LocalClientIndex, "xoia_info_round" )
    if currentRound == nil then currentRound = 0 end

    RoundText:setText( Engine.Localize("XOIA_MENU_PAUSED_AT_ROUND") .. " " .. tostring( currentRound ) )

    menu:addElement( RoundText )
end

LUI.createMenu.XoiaMenu = function ( LocalClientIndex )
    local menu = CoD.Menu.New("XoiaMenu")

    local isInGame = UIExpression.IsInGame( LocalClientIndex ) == 1

    if isInGame then
        menu:addTitle( Engine.Localize("XOIA_MENU_TITLE"), LUI.Alignment.Left )
    else
        menu:addTitle( Engine.Localize("XOIA_MENU_TITLE"), LUI.Alignment.Center )
    end

    menu:addBackButton()
    menu:registerEventHandler("button_prompt_back", CoD.Xoia.Back )
    menu:registerEventHandler("tab_changed", CoD.Xoia.TabChanged )

    CoD.Xoia.RefreshMapFlags()
    CoD.Xoia.BuildMonitorCommands()

    for i, entry in ipairs( CoD.Xoia.MonitorCommands ) do
        local command = entry.command
        menu:registerEventHandler( "xoia_monitor_cmd_" .. i, function( element, event )
            CoD.Xoia.SendMonitorCommand( event.controller, command )
        end )
    end
    menu:setAlpha(1)

    CoD.Xoia.AddPausedAtRoundText( menu, LocalClientIndex )

    local SettingsTabs = CoD.Options.SetupTabManager( menu, 500 )

    SettingsTabs:addTab(LocalClientIndex, Engine.Localize("XOIA_MENU_TAB_CONFIG"), CoD.Xoia.CreateConfigTab)
    SettingsTabs:addTab(LocalClientIndex, Engine.Localize("XOIA_MENU_TAB_MONITOR"), CoD.Xoia.CreateMonitorTab)
    SettingsTabs:addTab(LocalClientIndex, Engine.Localize("XOIA_MENU_TAB_TRACKERS"), CoD.Xoia.CreateTrackersTab)
    SettingsTabs:addTab(LocalClientIndex, Engine.Localize("XOIA_MENU_TAB_INFO"), CoD.Xoia.CreateInfoTab)

    local maxTabs = 4

    if CoD.Xoia.CurrentTabIndex and CoD.Xoia.CurrentTabIndex <= maxTabs then
        SettingsTabs:loadTab(LocalClientIndex, CoD.Xoia.CurrentTabIndex)
    else
        CoD.Xoia.CurrentTabIndex = 1
        if SettingsTabs.loadTab then
            SettingsTabs:loadTab(LocalClientIndex, 1)
        else
            SettingsTabs:refreshTab(LocalClientIndex)
        end
    end

    return menu
end

CoD.Xoia.sync_hud_menu = function (controller)
    local elements = {
        { "timer",                 1 },
        { "st_remaining",          1 },
        { "st_remaining_denizens", 1 },
        { "st_sph",                1 },
        { "st_zone",               1 },
        { "st_boxhits",            1 },
        { "st_bustimer",           0 },
        { "st_busloc",             0 },
    }

    local args = {}
    for _, e in ipairs( elements ) do
        local dvarName = e[1]
        local value = e[2]
        if UIExpression.DvarString( nil, dvarName ) ~= "" then
            value = UIExpression.DvarInt( nil, dvarName )
        end
        table.insert( args, e[1] .. ":" .. tostring(value) )
    end

    CoD.Xoia.send_response( controller, "hud", "sync", args )
end

CoD.Xoia.SyncPulse = function ( menu, event )
    if menu.syncCount == nil then
        menu.syncCount = 0
    end

    menu.syncCount = menu.syncCount + 1

    local controller = (event and event.controller) or menu.controller or 0
    CoD.Xoia.sync_character_menu( controller )
    CoD.Xoia.sync_hud_menu( controller )

    if menu.syncCount >= 5 then
        menu:close()
    end
end

LUI.createMenu.XoiaSync = function ( LocalClientIndex )
    local menu = CoD.Menu.New( "XoiaSync" )
    menu.controller = LocalClientIndex
    menu:setAlpha( 0 )

    CoD.Xoia.sync_character_menu( LocalClientIndex )
    CoD.Xoia.sync_hud_menu( LocalClientIndex )

    menu:registerEventHandler( "xoia_sync_pulse", CoD.Xoia.SyncPulse )
    menu:addElement( LUI.UITimer.new( 100, "xoia_sync_pulse", false, menu ) )

    return menu
end