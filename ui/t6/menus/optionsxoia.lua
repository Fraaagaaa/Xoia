local mapname, gametype, startlocation
local isDepot, isFarm, isTown, isTranzit, isNuketown, isDieRise, isMob, isBuried, isOrigins, isSurvival

CoD.Xoia = {}
CoD.Xoia.CurrentTabIndex = 1
CoD.Xoia.NeedVidRestart = false
CoD.Xoia.NeedPicmip = false
CoD.Xoia.NeedSndRestart = false

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


-- FIX v2 (correccion sobre la iteracion anterior): mi primer intento
-- evitaba dvars por completo y guardaba la seleccion en una tabla Lua en
-- memoria. Eso resolvia la fuga entre jugadores, pero rompia la
-- persistencia: una tabla Lua en memoria se pierde en cuanto se cierra la
-- partida (no sobrevive a un reinicio del juego), que es justo el segundo
-- problema reportado ("no recuerda que personaje escogio en la partida
-- anterior").
--
-- Mirando optionsstrattester.lua del mod de referencia, el patron correcto
-- SI usa un dvar, pero de un tipo distinto al que causaba el problema
-- original: un dvar de PERFIL DE CLIENTE, grabado a disco con el comando
-- de consola "seta" (ver CoD.StratTester.SetPerkDvarPersistent). Este dvar:
--   - vive SOLO en el perfil local de cada cliente (se guarda en su config,
--     sobrevive a cerrar el juego) -> soluciona "no recuerda personaje".
--   - GSC nunca lo lee directamente (a diferencia de "papcamo"/"timer",
--     que Xoia.gsc fija con setDvar() de SERVIDOR y por eso son globales).
--     El indice sigue viajando solo como argumento de SendMenuResponse,
--     recibido por el servidor siempre asociado a "self" -> sigue sin
--     haber fuga entre jugadores en cooperativo.
-- Para que el GSC se entere del valor persistido nada mas empezar la
-- partida (sin que el jugador tenga que abrir el menu), replicamos tambien
-- el mecanismo de "sync": CoD.Xoia.sync_character_menu() lee el dvar
-- persistido y lo reenvia por SendMenuResponse, y un menu invisible
-- (LUI.createMenu.XoiaSync, mas abajo) lo dispara varias veces nada mas
-- conectar, igual que hace LUI.createMenu.StratTesterPerkSync en el mod de
-- referencia.
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

    -- El indice viaja SIEMPRE como argumento del propio mensaje; el
    -- servidor lo aplica a "self" (el jugador dueño de este controller).
    Engine.SendMenuResponse( controller, "restartgamepopup", "xoia+character+set+" .. tostring(choice.value) )
end

-- FIX v3: ya no hay 4 dvars por tipo de mapa, solo uno ("xoia_character"),
-- porque change_player_model() ahora es un unico switch plano con los 15
-- personajes. Ya no hace falta mirar el mapa para decidir que dvar leer.
-- Si el jugador nunca eligio personaje (dvar vacio), no se manda nada: no
-- queremos forzar un personaje que el jugador jamas pidio.
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

-- PESTAÑA 1: TIMES
-- FIX (pedido por el usuario): "PAUSE HARD" se ha movido a options.lua,
-- junto a los botones de Ajustes/Controles/XOIA (mismo sitio que en el
-- menu de pausa original del juego). Ya no vive dentro del menu XOIA.
CoD.Xoia.CreateTimesTab = function ( Tab, LocalClientIndex )
    CoD.Xoia.RefreshMapFlags()
	local Container = LUI.UIContainer.new()
	local ButtonList = CoD.Options.CreateButtonList()

	Tab.buttonList = ButtonList
	Container:addElement( ButtonList )

    -- TODO no verificado: "tiempos de la partida" (game/round/trap timers en
    -- pantalla) no tenia mas especificacion en el comentario original que
    -- "hacer un tab". Los timers de HUD ya existen como dvars ("timer",
    -- "traptimer", etc.) gestionados en Xoia.gsc; si quieres que aqui se
    -- muestren tiempos concretos (p.ej. duracion de la ronda actual,
    -- tiempo total de partida) dime el formato exacto que quieres y lo
    -- añado con un addInfo() como en el tab de INFO.

    return Container
end

-- PESTAÑA 2: Cosmetics
CoD.Xoia.CreateCosmeticsTab = function ( Tab, LocalClientIndex )
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

    -- BACKSPEED
    local BackSpeedChoice = ButtonList:addHardwareProfileLeftRightSelector(Engine.Localize("XOIA_MENU_BACKSPEED"), "backspeed", Engine.Localize("XOIA_MENU_BACKSPEED_DESC"))
    BackSpeedChoice:addChoice(Engine.Localize("XOIA_MENU_BACKSPEED_FIXED"), 0, nil, CoD.Xoia.OnDvarChanged )
    BackSpeedChoice:addChoice(Engine.Localize("XOIA_MENU_BACKSPEED_STEAM"), 1, nil, CoD.Xoia.OnDvarChanged )

    local currentBS = UIExpression.DvarInt( nil, "backspeed")
    if UIExpression.DvarString( nil, "backspeed") == "" then
        currentBS = 1
        Engine.SetDvar("backspeed", currentBS )
    end
    BackSpeedChoice:setChoice( currentBS )

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

    -- ================================================================
    -- SELECTOR DE PERSONAJE
    -- ----------------------------------------------------------------
    -- FIX v3: change_player_model() ha cambiado de arquitectura. Ya NO usa
    -- un switch distinto por tipo de mapa (isvictismap/issurvivalmap/
    -- ismob/isorigins) — ahora es UN UNICO switch plano con los 15
    -- personajes, numerados con los defines MISTY=1 .. RICHTOFEN=15 al
    -- principio de Xoia.gsc. Por eso el selector deja de estar dividido en
    -- 4 variantes segun el mapa: ahora es un unico selector con los 15
    -- personajes, siempre visible, con esos mismos indices 1-15. El dvar
    -- de perfil tambien pasa a ser uno solo ("xoia_character" en vez de
    -- los 4 anteriores "_victis"/"_survival"/"_mob"/"_origins").
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

    -- Solo LEER el dvar para mostrar la seleccion actual. A proposito NO
    -- llamamos Engine.SetDvar aqui: el dvar se persiste unicamente cuando
    -- el jugador cambia el selector de verdad (OnCharacterChanged).
    local currentCharacterVal = UIExpression.DvarInt( nil, "xoia_character" )
    if currentCharacterVal == nil or UIExpression.DvarString( nil, "xoia_character" ) == "" or currentCharacterVal < 1 or currentCharacterVal > #characterEntries then
        currentCharacterVal = characterEntries[1][2]
    end
    CharacterChoice:setChoice( currentCharacterVal )

    -- ================================================================
    -- SELECTOR DE CAMO DE PACK-A-PUNCH
    -- ----------------------------------------------------------------
    -- FIX: "is Origins" (con espacio) es un error de sintaxis en Lua que
    -- probablemente impedia cargar el archivo entero. Ademas este selector
    -- reutilizaba por copy-paste el dvar "mob_key" (colision con el
    -- selector de personaje) y OnDvarChanged, cuyos valores (0-7) no
    -- coincidian con los que realmente lee Xoia.gsc::camo() (dvar
    -- "papcamo", valores 1 y CAMO_* = 39-45).
    --
    -- ATENCION - MISMO RIESGO QUE EL PERSONAJE, SIN RESOLVER TODAVIA:
    -- Xoia.gsc::camo() fija el camo con setDvar("papcamo", ...) SIN "self"
    -- delante, es decir, es un dvar de SERVIDOR compartido por toda la
    -- partida (igual que "timer", "forcepap", "traptimer", "boxhits"...),
    -- no uno por jugador. Por eso el comando de chat "!papcamo" cambia el
    -- camo para todos los jugadores a la vez. He dejado el selector tal
    -- cual (fijando el dvar "papcamo" directamente desde el cliente, como
    -- ya hacia el codigo original) porque no se si esto es un bug o un
    -- diseño intencional (un cosmetico global de testing, no un skin por
    -- jugador). Si quieres que el camo tambien sea independiente por
    -- jugador, dimelo: habria que cambiar camo() en Xoia.gsc para que
    -- aplique el camo a "self" en vez de a un dvar global (revisando antes
    -- si el motor de T6 realmente soporta aplicar PaP camo por jugador o si
    -- es una limitacion del sistema de camo en si).
    if isMob or isBuried or isOrigins then
        local CamoChoice = ButtonList:addHardwareProfileLeftRightSelector(Engine.Localize("XOIA_MENU_COSMETIC_CAMO_GREEN_RUN"), "papcamo", Engine.Localize("XOIA_MENU_HUD_CHARACTER_POSITION_DESC"))
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

-- PESTAÑA 3: INFO
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
        btn:disable() 
    end

    addInfo("Ronda Actual", "xoia_info_round")
    addInfo("Zombis (Vivos / Total)", "xoia_info_zombies")
    addInfo("Tiradas de Caja", "xoia_info_boxhits")


    -- Zombis esta ronda
    -- Boxhits
    -- NextSpecialRound
    -- Ronda actual
    -- Downs
    -- Si se ha usado firstbox
    -- SPH actual, Mejor SPH, SPH de la última ronda

    return Container
end

-- FIX ("PAUSED AT ROUND", visto en options.lua base del juego,
-- LUI.createMenu.OptionsMenu): texto informativo que muestra en que ronda
-- se pauso la partida. Lo saco a una funcion aparte para poder añadirlo a
-- cualquier menu de este mod (de momento solo XoiaMenu, pero si en el
-- futuro se añaden mas menus visibles se reutiliza igual).
--
-- FIX v2 (dvar equivocado + centrado):
-- 1) "ui_zm_round" no existe en este entorno (Plutonium/este mod nunca lo
--    define). El dvar que SI existe y se actualiza en tiempo real es
--    "xoia_info_round", que Xoia_ui.gsc::update_info_dvars() fija cada
--    segundo con setdvar("xoia_info_round", level.round_number) — el mismo
--    dvar que ya usa el tab de INFO (addInfo("Ronda Actual", "xoia_info_round")).
-- 2) Centrado: antes el texto estaba anclado a la derecha (-300,-50,
--    alignment Right), igual que en el options.lua original (que lo pone
--    en la esquina, al lado del boton de sistema). Aqui lo centramos: todo
--    el ancho del menu, alineacion Center.
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

    -- FIX (pedido por el usuario): "XOIA" es accesible tanto en pausa
    -- (options.lua, rama in-game) como desde el menu principal (misma
    -- funcion, rama no in-game) — asi que el titulo debe alinearse segun
    -- el contexto en el que se abra, no siempre igual. En pausa, a la
    -- izquierda (igual que el resto de menus, donde lo hace
    -- CoD.InGameMenu.New automaticamente); en el menu principal, centrado.
    local isInGame = UIExpression.IsInGame( LocalClientIndex ) == 1

    if isInGame then
        menu:addTitle( Engine.Localize("XOIA_MENU_TITLE"), LUI.Alignment.Left )
    else
        menu:addTitle( Engine.Localize("XOIA_MENU_TITLE"), LUI.Alignment.Center )
    end

    menu:addBackButton()
    menu:registerEventHandler("button_prompt_back", CoD.Xoia.Back )
    menu:registerEventHandler("tab_changed", CoD.Xoia.TabChanged )
    menu:setAlpha(1)

    CoD.Xoia.AddPausedAtRoundText( menu, LocalClientIndex )

    local SettingsTabs = CoD.Options.SetupTabManager( menu, 500 )

    SettingsTabs:addTab(LocalClientIndex, Engine.Localize("XOIA_MENU_TAB_TIMES"), CoD.Xoia.CreateTimesTab)
    SettingsTabs:addTab(LocalClientIndex, Engine.Localize("XOIA_MENU_TAB_COSMETICS"), CoD.Xoia.CreateCosmeticsTab)
    SettingsTabs:addTab(LocalClientIndex, Engine.Localize("XOIA_MENU_TAB_INFO"), CoD.Xoia.CreateInfoTab)

    local maxTabs = 2
    if isInGame then
        maxTabs = 5
    end

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

-- FIX (persistencia al empezar la partida): en el mod de referencia,
-- LUI.createMenu.StratTesterPerkSync es un menu invisible (alpha 0) que se
-- crea nada mas conectar y dispara CoD.StratTester.sync_perk_menu /
-- sync_hud_menu varias veces seguidas (una "pulsacion" cada 100ms, 5 veces)
-- antes de cerrarse solo. Repetirlo varias veces es defensivo: si la
-- primera llamada llega antes de que el jugador este completamente
-- inicializado en el servidor, las siguientes lo cubren. CoD.Xoia.sync_hud_menu
-- ya existia en este archivo pero nunca se llamaba desde ningun sitio: por
-- eso el personaje (y el resto de ajustes de HUD) no se recuperaban al
-- empezar la partida. Replicamos el mismo mecanismo aqui para el personaje.
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