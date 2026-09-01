require( "T6.MainLobby" )
require( "T6.Menus.MOTD" )

if CoD.isWIIU then
	require( "T6.Menus.InvalidAccountPopup" )
	require( "T6.WiiUControllerSettings" )
end
if CoD.isZombie == false then
	require( "T6.Menus.EliteRegistrationPopup" )
	require( "T6.Menus.EliteWelcomePopup" )
	require( "T6.Menus.EliteMarketingOptInPopup" )
	require( "T6.Menus.DLCPopup" )
	require( "T6.Menus.VotingPopup" )
	require( "T6.Menus.SPReminderPopup" )
	require( "T6.Menus.DSPPromotionPopup" )
end
CoD.MainMenu = {}
CoD.MainMenu.SystemLinkLastUsedButton = 0
CoD.MainMenu.ShowStoreButtonEvent = function ( f1_arg0, f1_arg1 )
	if CoD.MainMenu.ShowStoreButton( f1_arg1.controller ) == true and f1_arg0.ingameStoreButton == nil then
		CoD.MainMenu.AddStoreButton( f1_arg0 )
	end
end

CoD.MainMenu.AddStoreButton = function ( f2_arg0 )
	f2_arg0.ingameStoreButton = f2_arg0.buttonList:addButton( Engine.Localize( "MENU_INGAMESTORE" ), nil, 5 )
	f2_arg0.ingameStoreButton:setActionEventName( "open_store" )
end

CoD.MainMenu.ShowStoreButton = function ( f3_arg0 )
	if not CoD.isPC and not CoD.isWIIU and UIExpression.IsFFOTDFetched( f3_arg0 ) == 1 and Dvar.ui_inGameStoreVisible:get() == true and (CoD.isPS3 ~= true or CoD.isZombie ~= true) then
		return true
	else
		return false
	end
end

LUI.createMenu.MainMenu = function ( f4_arg0 )
	local f4_local0 = CoD.Menu.New( "MainMenu" )
	f4_local0.anyControllerAllowed = true
	f4_local0:registerEventHandler( "open_main_lobby_requested", CoD.MainMenu.OpenMainLobbyRequested )
	f4_local0:registerEventHandler( "open_system_link_flyout", CoD.MainMenu.OpenSystemLinkFlyout )
	f4_local0:registerEventHandler( "open_system_link_lobby", CoD.MainMenu.OpenSystemLinkLobby )
	f4_local0:registerEventHandler( "open_server_browser", CoD.MainMenu.OpenServerBrowser )
	f4_local0:registerEventHandler( "open_local_match_lobby", CoD.MainMenu.OpenLocalMatchLobby )
	if CoD.isWIIU then
		f4_local0:registerEventHandler( "open_controls_menu", CoD.MainMenu.OpenControlsMenu )
	end
	f4_local0:registerEventHandler( "open_options_menu", CoD.MainMenu.OpenOptionsMenu )
	f4_local0:registerEventHandler( "start_zombies", CoD.MainMenu.StartZombies )
	f4_local0:registerEventHandler( "start_mp", CoD.MainMenu.StartMP )
	f4_local0:registerEventHandler( "start_sp", CoD.MainMenu.StartSP )
	f4_local0:registerEventHandler( "button_prompt_back", CoD.MainMenu.Back )
	f4_local0:registerEventHandler( "first_signed_in", CoD.MainMenu.SignedIntoLive )
	f4_local0:registerEventHandler( "last_signed_out", CoD.MainMenu.SignedOut )
	f4_local0:registerEventHandler( "open_menu", CoD.Lobby.OpenMenu )
	f4_local0:registerEventHandler( "reopen_serverbrowser", CoD.MainMenu.ReopenServerBrowser )
	f4_local0:registerEventHandler( "invite_accepted", CoD.inviteAccepted )
	f4_local0:registerEventHandler( "button_prompt_friends", CoD.MainMenu.ButtonPromptFriendsMenu )
	f4_local0:registerEventHandler( "open_store", CoD.MainLobby.OpenStore )
	f4_local0:registerEventHandler( "showstorebutton", CoD.MainMenu.ShowStoreButtonEvent )
	if CoD.isPS3 then
		f4_local0:registerEventHandler( "corrupt_install", CoD.MainMenu.CorruptInstall )
	end
	if CoD.isPC then
		f4_local0:registerEventHandler( "open_quit_popup", CoD.MainMenu.OpenQuitPopup )
		f4_local0:registerEventHandler( "open_sp_switch_popup", CoD.MainMenu.OpenConfirmSwitchToSP )
		f4_local0:registerEventHandler( "open_mp_switch_popup", CoD.MainMenu.OpenConfirmSwitchToMP )
		f4_local0:registerEventHandler( "open_zm_switch_popup", CoD.MainMenu.OpenConfirmSwitchToZM )
	end
	if CoD.isZombie == false then
		f4_local0:registerEventHandler( "elite_registration_ended", CoD.MainMenu.elite_registration_ended )
		f4_local0:registerEventHandler( "elite_registration_email_popup_requested", CoD.EliteRegistrationEmailPopup.EliteRegistrationEmailPopupRequested )
		f4_local0:registerEventHandler( "AutoFillPopup_Closed", CoD.EliteRegistrationEmailPopup.AutoFillPopup_Closed )
		f4_local0:registerEventHandler( "motd_popup_closed", CoD.MainMenu.Popup_Closed )
		f4_local0:registerEventHandler( "dlcpopup_closed", CoD.MainMenu.Popup_Closed )
		f4_local0:registerEventHandler( "voting_popup_closed", CoD.MainMenu.Popup_Closed )
		f4_local0:registerEventHandler( "spreminder_popup_closed", CoD.MainMenu.Popup_Closed )
		f4_local0:registerEventHandler( "dsppromotion_popup_closed", CoD.MainMenu.Popup_Closed )
	end
	f4_local0:addSelectButton()
	if not CoD.isPC then
		f4_local0:addBackButton( Engine.Localize( "MENU_MAIN_MENU" ) )
	end
	if UIExpression.AnySignedInToLive( f4_arg0 ) == 1 then
		f4_local0:addFriendsButton()
	end
	if CoD.isZombie == false then
		local self = LUI.UIImage.new()
		self:setLeftRight( false, false, -640, 640 )
		self:setTopBottom( false, false, -360, 360 )
		self:setImage( RegisterMaterial( "menu_mp_soldiers" ) )
		self:setPriority( -1 )
		f4_local0:addElement( self )
		local f4_local2 = LUI.UIImage.new()
		f4_local2:setLeftRight( false, false, -640, 640 )
		f4_local2:setTopBottom( false, false, 180, 360 )
		f4_local2:setImage( RegisterMaterial( "ui_smoke" ) )
		f4_local2:setAlpha( 0,1 )
		f4_local0:addElement( f4_local2 )
	end
	if CoD.isZombie then
		local self = 192
		local f4_local2 = self * 2
		local f4_local3 = 230
		local f4_local4 = LUI.UIImage.new()
		f4_local4:setLeftRight( true, false, 0, f4_local2 )
		f4_local4:setTopBottom( true, false, f4_local3 - self / 2, f4_local3 + self / 2 )
		f4_local4:setImage( RegisterMaterial( "menu_zm_title_screen" ) )
		f4_local0:addElement( f4_local4 )
		CoD.GameGlobeZombie.gameGlobe.currentMenu = f4_local0
	else
		local self = 48
		local f4_local2 = self * 8
		local f4_local3 = 210
		local f4_local4 = LUI.UIImage.new()
		f4_local4:setLeftRight( true, false, 0, f4_local2 )
		f4_local4:setTopBottom( true, false, f4_local3, f4_local3 + self )
		f4_local4:setImage( RegisterMaterial( "menu_mp_title_screen" ) )
		f4_local0:addElement( f4_local4 )
		local f4_local5 = Dvar.loc_language:get()
		if f4_local5 == CoD.LANGUAGE_ENGLISH or f4_local5 == CoD.LANGUAGE_BRITISH then
			local f4_local6 = 24
			local f4_local7 = f4_local6 * 16
			local f4_local8 = f4_local3 + self + 2
			local f4_local9 = LUI.UIImage.new()
			f4_local9:setLeftRight( true, false, 0, f4_local7 )
			f4_local9:setTopBottom( true, false, f4_local8, f4_local8 + f4_local6 )
			f4_local9:setImage( RegisterMaterial( "menu_mp_title_screen_mp" ) )
			f4_local0:addElement( f4_local9 )
		end
	end
	local self = 8
	if CoD.isWIIU then
		self = self + 1
	end
	local f4_local2 = 6
	local f4_local3 = CoD.CoD9Button.Height * self
	local f4_local4 = CoD.ButtonList.DefaultWidth
	local f4_local5 = -f4_local3 - CoD.ButtonPrompt.Height
	f4_local0.buttonList = CoD.ButtonList.new( {
		leftAnchor = true,
		rightAnchor = false,
		left = f4_local2,
		right = f4_local2 + f4_local4,
		topAnchor = false,
		bottomAnchor = true,
		top = f4_local5,
		bottom = -CoD.ButtonPrompt.Height,
		alpha = 1
	} )
	f4_local0.buttonList:setPriority( 10 )
	f4_local0.buttonList:registerAnimationState( "disabled", {
		alpha = 0,5
	} )
	f4_local0:addElement( f4_local0.buttonList )
	f4_local0.mainLobbyButton = f4_local0.buttonList:addButton( Engine.Localize( "PLATFORM_XBOXLIVE_INSTR" ), nil, 1 )
	f4_local0.mainLobbyButton:setActionEventName( "open_main_lobby_requested" )
	local f4_local7
	if not CoD.isPC or 0 < Dvar.developer:get() then
		f4_local7 = not Engine.IsBetaBuild()
	else
		f4_local7 = false
	end
	local f4_local8 = 120
	if f4_local7 then
		local f4_local9 = Engine.Localize( "PLATFORM_SYSTEM_LINK_CAPS" )
		local f4_local10 = {}
		f4_local10 = GetTextDimensions( f4_local9, CoD.CoD9Button.Font, CoD.CoD9Button.TextHeight )
		f4_local0.systemLinkButton = f4_local0.buttonList:addButton( f4_local9, nil, 2 )
		f4_local0.systemLinkButton:setActionEventName( "open_system_link_flyout" )
		f4_local8 = f4_local10[3] + 15
	end
	if not CoD.isPC and not Engine.IsBetaBuild() then
		if CoD.isWIIU then
			f4_local0.localButton = f4_local0.buttonList:addButton( Engine.Localize( CoD.MPZM( "MENU_LOCAL_CAPS", "PLATFORM_UI_LOCAL_CAPS" ) ), nil, 3 )
		else
			f4_local0.localButton = f4_local0.buttonList:addButton( Engine.Localize( CoD.MPZM( "MENU_LOCAL_CAPS", "ZMUI_LOCAL_CAPS" ) ), nil, 3 )
		end
		f4_local0.localButton:setActionEventName( "open_local_match_lobby" )
	end
	if CoD.isWIIU then
		f4_local0.controlsButton = f4_local0.buttonList:addButton( Engine.Localize( "MENU_CONTROLLER_SETTINGS_CAPS" ), nil, 4 )
		f4_local0.controlsButton:setActionEventName( "open_controls_menu" )
	end
	f4_local0.optionsButton = f4_local0.buttonList:addButton( Engine.Localize( "MENU_OPTIONS_CAPS" ), nil, 4 )
	f4_local0.optionsButton:setActionEventName( "open_options_menu" )
	if CoD.MainMenu.ShowStoreButton( f4_arg0 ) == true and f4_local0.ingameStoreButton == nil then
		CoD.MainMenu.AddStoreButton( f4_local0 )
	end
	if CoD.isPC then
		f4_local0.buttonList:addSpacer( CoD.CoD9Button.Height / 2, 5 )
		f4_local0.spButton = f4_local0.buttonList:addButton( Engine.Localize( "MENU_SINGLEPLAYER_CAPS" ), nil, 6 )
		f4_local0.spButton:setActionEventName( "open_sp_switch_popup" )
		if CoD.isZombie then
			f4_local0.mpButton = f4_local0.buttonList:addButton( Engine.Localize( "MENU_MULTIPLAYER_CAPS" ), nil, 7 )
			f4_local0.mpButton:setActionEventName( "open_mp_switch_popup" )
		else
			f4_local0.zombieButton = f4_local0.buttonList:addButton( Engine.Localize( "MENU_ZOMBIE_CAPS" ), nil, 7 )
			f4_local0.zombieButton:setActionEventName( "open_zm_switch_popup" )
		end
		f4_local0.buttonList:addSpacer( CoD.CoD9Button.Height / 2, 8 )
		f4_local0.quitButton = f4_local0.buttonList:addButton( Engine.Localize( "MENU_QUIT_CAPS" ), nil, 9 )
		f4_local0.quitButton:setActionEventName( "open_quit_popup" )
		f4_local0:addLeftButtonPrompt( CoD.ButtonPrompt.new( "secondary", "", f4_local0, "open_quit_popup", true ) )
		f4_local0.buttonList:setLeftRight( true, false, f4_local2, f4_local2 + 120 )
	end
	if f4_local7 then
		local f4_local9 = f4_local5 + CoD.CoD9Button.Height + 2
		f4_local9 = f4_local5 + CoD.CoD9Button.Height + 2
		local f4_local10 = CoD.CoD9Button.Height * 2 + 2
		local f4_local11 = Engine.Localize( "MENU_CREATE_GAME_CAPS" )
		local f4_local12 = {}
		f4_local12 = GetTextDimensions( f4_local11, CoD.CoD9Button.Font, CoD.CoD9Button.TextHeight )
		local f4_local13 = Engine.Localize( "MENU_JOIN_GAME_CAPS" )
		local f4_local14 = {}
		f4_local14 = GetTextDimensions( f4_local13, CoD.CoD9Button.Font, CoD.CoD9Button.TextHeight )
		local f4_local15 = f4_local12[3]
		if f4_local15 < f4_local14[3] then
			f4_local15 = f4_local14[3]
		end
		f4_local0.systemLinkFlyoutContainer = LUI.UIElement.new( {
			leftAnchor = true,
			rightAnchor = false,
			left = f4_local2 + f4_local8,
			right = f4_local2 + f4_local8 + f4_local15 + 12,
			topAnchor = false,
			bottomAnchor = true,
			top = f4_local9,
			bottom = f4_local9 + f4_local10,
			alpha = 0
		} )
		f4_local0.systemLinkFlyoutContainer:registerAnimationState( "show", {
			alpha = 1
		} )
		f4_local0:addElement( f4_local0.systemLinkFlyoutContainer )
		f4_local0.systemLinkFlyoutContainer:addElement( LUI.UIImage.new( {
			leftAnchor = true,
			rightAnchor = false,
			left = -f4_local8 - 4,
			right = 0,
			topAnchor = true,
			bottomAnchor = false,
			top = 0,
			bottom = CoD.CoD9Button.Height,
			red = 0,
			green = 0,
			blue = 0,
			alpha = 0,8
		} ) )
		f4_local0.systemLinkFlyoutContainer:addElement( LUI.UIImage.new( {
			leftAnchor = true,
			rightAnchor = true,
			left = 0,
			right = 0,
			topAnchor = true,
			bottomAnchor = true,
			top = 0,
			bottom = 0,
			red = 0,
			green = 0,
			blue = 0,
			alpha = 0,8
		} ) )
		f4_local0.systemLinkFlyoutContainer.buttonList = CoD.ButtonList.new( {
			leftAnchor = true,
			rightAnchor = true,
			left = 4,
			right = 0,
			topAnchor = true,
			bottomAnchor = true,
			top = 0,
			bottom = 0
		} )
		CoD.ButtonList.DisableInput( f4_local0.systemLinkFlyoutContainer.buttonList )
		f4_local0.systemLinkFlyoutContainer:addElement( f4_local0.systemLinkFlyoutContainer.buttonList )
		f4_local0.systemLinkFlyoutContainer.buttonList.hintText:close()
		f4_local0.systemLinkFlyoutContainer.buttonList.hintText = nil
		if CoD.useMouse then
			f4_local0.systemLinkFlyoutContainer.buttonList:setHandleMouseButton( true )
			f4_local0.systemLinkFlyoutContainer.buttonList:registerEventHandler( "leftmouseup_outside", CoD.MainMenu.FlyoutBack )
		end
		f4_local0.systemLinkFlyoutContainer.openSystemLinkButton = f4_local0.systemLinkFlyoutContainer.buttonList:addButton( f4_local11, nil, 1 )
		f4_local0.systemLinkFlyoutContainer.openSystemLinkButton:setActionEventName( "open_system_link_lobby" )
		f4_local0.systemLinkFlyoutContainer.openServerBrowserButton = f4_local0.systemLinkFlyoutContainer.buttonList:addButton( f4_local13, nil, 1 )
		f4_local0.systemLinkFlyoutContainer.openServerBrowserButton:setActionEventName( "open_server_browser" )
	end
	if not f4_local0.buttonList:restoreState() then
		f4_local0.buttonList:processEvent( {
			name = "gain_focus"
		} )
	elseif f4_local7 and f4_local0.systemLinkButton:isInFocus() then
		local f4_local9 = {
			controller = f4_arg0
		}
		if true == Engine.CheckNetConnection() and CoD.MainMenu.OfflinePlayAvailable( f4_local0, f4_local9, true ) == 1 then
			CoD.MainMenu.OpenSystemLinkFlyout( f4_local0, f4_local9 )
			if CoD.MainMenu.SystemLinkLastUsedButton == 1 then
				f4_local0.systemLinkFlyoutContainer.openSystemLinkButton:processEvent( {
					name = "lose_focus"
				} )
				f4_local0.systemLinkFlyoutContainer.openServerBrowserButton:processEvent( {
					name = "gain_focus"
				} )
			end
		end
	end
	HideGlobe()
	if CoD.isWIIU then
		Engine.ExecNow( 0, "setclientbeingused" )
	end
	if CoD.isPS3 then
		Engine.ExecNow( f4_arg0, "onetimeinstallcorruptioncheck" )
	end
	return f4_local0
end

CoD.MainMenu.CorruptInstall = function ( f5_arg0, f5_arg1 )
	local f5_local0 = f5_arg0:openPopup( "Error", f5_arg1.controller )
	f5_local0.anyControllerAllowed = true
	f5_local0:setMessage( Engine.Localize( "MENU_PS3_INSTALL_INCOMPLETE" ) )
end

CoD.MainMenu.OpenPopup_EliteRegistration = function ( f6_arg0, f6_arg1 )
	if Engine.IsCustomElementScrollLanguageOverrideActive() then
		local f6_local0 = f6_arg0:openPopup( "EliteRegistrationScrollingTOS", f6_arg1.controller )
	else
		local f6_local0 = f6_arg0:openPopup( "EliteRegistrationPopup", f6_arg1.controller )
	end
end

CoD.MainMenu.OpenPopup_EliteWelcome = function ( f7_arg0, f7_arg1 )
	if Engine.IsPlayerEliteFounder( f7_arg1.controller ) then
		local f7_local0 = f7_arg0:openPopup( "EliteWelcomeFounderPopup", f7_arg1.controller )
	else
		local f7_local0 = f7_arg0:openPopup( "EliteWelcomePopup", f7_arg1.controller )
	end
end

CoD.MainMenu.elite_registration_ended = function ( f8_arg0, f8_arg1 )
	CoD.MainMenu.OpenMainLobby( f8_arg0, f8_arg1 )
end

CoD.MainMenu.Popup_Closed = function ( f9_arg0, f9_arg1 )
	CoD.MainMenu.OpenMainLobbyRequested( f9_arg0, f9_arg1 )
end

CoD.MainMenu.IsGuestRestricted = function ( f10_arg0, f10_arg1 )
	if not (not CoD.isPS3 or f10_arg1.controller == 0) or CoD.isXBOX and UIExpression.IsGuest( f10_arg1.controller ) == 1 then
		local f10_local0 = f10_arg0:openPopup( "popup_guest_contentrestricted", f10_arg1.controller )
		f10_local0.anyControllerAllowed = true
		return true
	else
		return false
	end
end

CoD.MainMenu.ShowDLC0Popup = function ( f11_arg0 )
	if CoD.isXBOX == true and Engine.IsContentAvailableByPakName( "dlc0" ) == false and UIExpression.DvarBool( nil, "ui_isDLCPopupEnabled" ) == 1 and CoD.perController[f11_arg0].IsDLCPopupViewed == nil then
		return true
	else
		return false
	end
end

CoD.MainMenu.AnyDLCMissing = function ()
	local f12_local0 = Dvar.ui_totalDLCReleased:get()
	for f12_local1 = 1, f12_local0, 1 do
		if not Engine.IsContentAvailableByPakName( "dlc" .. f12_local1 ) then
			return true
		end
	end
	return false
end

CoD.MainMenu.ShowSPReminderPopup = function ( f13_arg0 )
	if CoD.isPC then
		return false
	elseif Engine.ShouldShowSPReminder( f13_arg0 ) == true and Engine.OwnSeasonPass( f13_arg0 ) == true and CoD.MainMenu.AnyDLCMissing() == true then
		return true
	else
		return false
	end
end

CoD.MainMenu.ShowDSPPromotionPopup = function ( f14_arg0 )
	if Engine.ShouldShowDSPPromotion( f14_arg0 ) == true and Engine.OwnSeasonPass( f14_arg0 ) == false and Engine.OwnDLC1Only( f14_arg0 ) == true then
		return true
	else
		return false
	end
end

CoD.MainMenu.OpenMainLobbyRequested = function ( f15_arg0, f15_arg1 )
	if CoD.isZombie then
		if Engine.IsFeatureBanned( CoD.FEATURE_BAN_LIVE_ZOMBIE ) then
			Engine.ExecNow( f15_arg1.controller, "banCheck " .. CoD.FEATURE_BAN_LIVE_ZOMBIE )
			return 
		end
	elseif Engine.IsFeatureBanned( CoD.FEATURE_BAN_LIVE_MP ) then
		Engine.ExecNow( f15_arg1.controller, "banCheck " .. CoD.FEATURE_BAN_LIVE_MP )
		return 
	end
	if CoD.MainMenu.IsGuestRestricted( f15_arg0, f15_arg1 ) == true then
		return 
	elseif Engine.CheckNetConnection() == false then
		local f15_local0 = f15_arg0:openPopup( "popup_net_connection", f15_arg1.controller )
		f15_local0.callingMenu = f15_arg0
		return 
	elseif CoD.isZombie == false then
		if CoD.MainLobby.OnlinePlayAvailable( f15_arg0, f15_arg1 ) == 1 then
			Engine.Exec( f15_arg1.controller, "setclientbeingusedandprimary" )
			if CoD.MainMenu.ShowDLC0Popup( f15_arg1.controller ) == true then
				local f15_local0 = Engine.GetDLC0PublisherOfferId( f15_arg1.controller )
				if f15_local0 ~= nil then
					CoD.perController[f15_arg1.controller].ContentPublisherOfferID = f15_local0
					CoD.perController[f15_arg1.controller].ContentType = "0"
					local f15_local1 = f15_arg0:openPopup( "DLCPopup", f15_arg1.controller )
					f15_local1.callingMenu = f15_arg0
				end
			elseif Engine.ShouldShowMOTD( f15_arg1.controller ) ~= nil and Engine.ShouldShowMOTD( f15_arg1.controller ) == true then
				local f15_local0 = f15_arg0:openPopup( "MOTD", f15_arg1.controller )
				f15_local0.callingMenu = f15_arg0
			elseif CoD.MainMenu.ShowSPReminderPopup( f15_arg1.controller ) then
				local f15_local0 = f15_arg0:openPopup( "SPReminderPopup", f15_arg1.controller )
				f15_local0.callingMenu = f15_arg0
			elseif CoD.MainMenu.ShowDSPPromotionPopup( f15_arg1.controller ) then
				local f15_local0 = f15_arg0:openPopup( "DSPPromotionPopup", f15_arg1.controller )
				f15_local0.callingMenu = f15_arg0
			elseif Engine.ShouldShowVoting( f15_arg1.controller ) == true then
				local f15_local0 = f15_arg0:openPopup( "VotingPopup", f15_arg1.controller )
				f15_local0.callingMenu = f15_arg0
			elseif Engine.ERegPopup_ShouldShow( f15_arg1.controller ) == 1 then
				CoD.MainMenu.OpenPopup_EliteRegistration( f15_arg0, f15_arg1 )
			elseif Engine.EWelcomePopup_ShouldShow( f15_arg1.controller ) == 1 then
				CoD.MainMenu.OpenPopup_EliteWelcome( f15_arg0, f15_arg1 )
			elseif Engine.EMarketingOptInPopup_ShouldShow( f15_arg1.controller ) == true then
				f15_arg0:openPopup( "EliteMarketingOptInPopup", f15_arg1.controller )
			elseif CoD.isPS3 and Engine.IsChatRestricted( f15_arg1.controller ) then
				local f15_local0 = f15_arg0:openPopup( "popup_chatrestricted", f15_arg1.controller )
				f15_local0.callingMenu = f15_arg0
			else
				CoD.perController[f15_arg1.controller].IsDLCPopupViewed = nil
				CoD.MainMenu.OpenMainLobby( f15_arg0, f15_arg1 )
			end
		end
	elseif CoD.MainLobby.OnlinePlayAvailable( f15_arg0, f15_arg1 ) == 1 then
		Engine.Exec( f15_arg1.controller, "setclientbeingusedandprimary" )
		if Engine.ShouldShowMOTD( f15_arg1.controller ) then
			local f15_local0 = f15_arg0:openPopup( "MOTD", f15_arg1.controller )
			f15_local0.callingMenu = f15_arg0
		elseif CoD.isPS3 and Engine.IsChatRestricted( f15_arg1.controller ) then
			local f15_local0 = f15_arg0:openPopup( "popup_chatrestricted", f15_arg1.controller )
			f15_local0.callingMenu = f15_arg0
		else
			CoD.MainMenu.OpenMainLobby( f15_arg0, f15_arg1 )
		end
	end
end

CoD.MainMenu.OpenMainLobby = function ( f16_arg0, f16_arg1 )
	if CoD.MainLobby.OnlinePlayAvailable( f16_arg0, f16_arg1 ) == 1 then
		if CoD.isZombie then
			if Engine.IsFeatureBanned( CoD.FEATURE_BAN_LIVE_ZOMBIE ) then
				Engine.ExecNow( f16_arg1.controller, "banCheck " .. CoD.FEATURE_BAN_LIVE_ZOMBIE )
				return 
			end
		elseif Engine.IsFeatureBanned( CoD.FEATURE_BAN_LIVE_MP ) then
			Engine.ExecNow( f16_arg1.controller, "banCheck " .. CoD.FEATURE_BAN_LIVE_MP )
			return 
		end
		f16_arg0.buttonList:saveState()
		Engine.SessionModeSetOnlineGame( true )
		Engine.Exec( f16_arg1.controller, "xstartprivateparty" )
		Engine.Exec( f16_arg1.controller, "party_statechanged" )
		CoD.MainMenu.InitializeLocalPlayers( f16_arg1.controller )
		local f16_local0 = f16_arg0:openMenu( "MainLobby", f16_arg1.controller )
		Engine.Exec( f16_arg1.controller, "session_rejoinsession " .. CoD.SESSION_REJOIN_CHECK_FOR_SESSION )
		if CoD.isZombie then
			CoD.GameGlobeZombie.gameGlobe.currentMenu = f16_local0
		end
		f16_arg0:close()
	end
end

CoD.MainMenu.OpenControlsMenu = function ( f17_arg0, f17_arg1 )
	if CoD.MainMenu.OfflinePlayAvailable( f17_arg0, f17_arg1 ) == 0 then
		return 
	else
		CoD.MainMenu.InitializeLocalPlayers( f17_arg1.controller )
		f17_arg0:openPopup( "WiiUControllerSettings", f17_arg1.controller, true )
		Engine.PlaySound( "cac_screen_fade" )
	end
end

CoD.MainMenu.OpenOptionsMenu = function ( f18_arg0, f18_arg1 )
	if CoD.MainMenu.OfflinePlayAvailable( f18_arg0, f18_arg1 ) == 0 then
		return 
	else
		CoD.MainMenu.InitializeLocalPlayers( f18_arg1.controller )
		f18_arg0:openPopup( "OptionsMenu", f18_arg1.controller )
		Engine.PlaySound( "cac_screen_fade" )
	end
end

CoD.MainMenu.OpenLocalMatchLobby = function ( f19_arg0, f19_arg1 )
	if CoD.MainMenu.IsGuestRestricted( f19_arg0, f19_arg1 ) == true then
		return 
	elseif CoD.MainMenu.OfflinePlayAvailable( f19_arg0, f19_arg1 ) == 0 then
		return 
	end
	f19_arg0.buttonList:saveState()
	CoD.MainMenu.InitializeLocalPlayers( f19_arg1.controller )
	CoD.SwitchToLocalLobby( f19_arg1.controller )
	if CoD.isZombie == true then
		f19_arg0:openMenu( "SelectMapZM", f19_arg1.controller )
		ShowGlobe()
	else
		f19_arg0:openMenu( "SplitscreenGameLobby", f19_arg1.controller )
	end
	f19_arg0:close()
end

CoD.MainMenu.OfflinePlayAvailable = function ( f20_arg0, f20_arg1, f20_arg2 )
	local f20_local0 = f20_arg1.controller
	if UIExpression.IsSignedIn( f20_local0 ) == 0 then
		if f20_arg2 ~= nil and f20_arg2 == true then
			return 0
		elseif CoD.isPS3 then
			if UIExpression.IsPrimaryLocalClient( f20_local0 ) == 1 then
				Engine.Exec( f20_local0, "xsigninlive" )
			else
				Engine.Exec( f20_local0, "signclientin" )
			end
		else
			Engine.Exec( f20_local0, "xsignin" )
			if CoD.isPC then
				return 1
			end
		end
		return 0
	else
		return 1
	end
end

CoD.MainMenu.StartZombies = function ( f21_arg0, f21_arg1 )
	Engine.Exec( f21_arg1.controller, "startZombies" )
end

CoD.MainMenu.StartMP = function ( f22_arg0, f22_arg1 )
	Engine.Exec( f22_arg1.controller, "startMultiplayer" )
end

CoD.MainMenu.StartSP = function ( f23_arg0, f23_arg1 )
	Engine.Exec( f23_arg1.controller, "startSingleplayer" )
end

CoD.MainMenu.OpenQuitPopup = function ( f24_arg0, f24_arg1 )
	f24_arg0:openPopup( "QuitPopup", f24_arg1.controller )
end

CoD.MainMenu.OpenConfirmSwitchToSP = function ( f25_arg0, f25_arg1 )
	f25_arg0:openPopup( "SwitchToSPPopup", f25_arg1.controller )
end

CoD.MainMenu.OpenConfirmSwitchToMP = function ( f26_arg0, f26_arg1 )
	f26_arg0:openPopup( "SwitchToMPPopup", f26_arg1.controller )
end

CoD.MainMenu.OpenConfirmSwitchToZM = function ( f27_arg0, f27_arg1 )
	f27_arg0:openPopup( "SwitchToZMPopup", f27_arg1.controller )
end

CoD.MainMenu.OpenSystemLinkFlyout = function ( f28_arg0, f28_arg1 )
	if CoD.MainMenu.IsGuestRestricted( f28_arg0, f28_arg1 ) == true then
		return 
	elseif Engine.CheckNetConnection() == false then
		local f28_local0 = f28_arg0:openPopup( "popup_net_connection", f28_arg1.controller )
		f28_local0.callingMenu = f28_arg0
		return 
	elseif CoD.MainMenu.OfflinePlayAvailable( f28_arg0, f28_arg1 ) == 0 then
		return 
	end
	f28_arg0.systemLinkFlyoutContainer:animateToState( "show" )
	CoD.ButtonList.DisableInput( f28_arg0.buttonList )
	f28_arg0.buttonList:animateToState( "disabled" )
	CoD.ButtonList.EnableInput( f28_arg0.systemLinkFlyoutContainer.buttonList )
	f28_arg0.systemLinkFlyoutContainer.openSystemLinkButton:processEvent( {
		name = "gain_focus"
	} )
	if f28_arg0.backButton ~= nil then
		f28_arg0.backButton:close()
	end
	f28_arg0:addBackButton()
	f28_arg0:registerEventHandler( "button_prompt_back", CoD.MainMenu.CloseSystemLinkFlyout )
end

CoD.MainMenu.CloseSystemLinkFlyout = function ( f29_arg0, f29_arg1 )
	f29_arg0.systemLinkFlyoutContainer:animateToState( "default" )
	CoD.ButtonList.EnableInput( f29_arg0.buttonList )
	f29_arg0.buttonList:animateToState( "default" )
	f29_arg0.systemLinkFlyoutContainer.openSystemLinkButton:processEvent( {
		name = "lose_focus"
	} )
	f29_arg0.systemLinkFlyoutContainer.openServerBrowserButton:processEvent( {
		name = "lose_focus"
	} )
	CoD.ButtonList.DisableInput( f29_arg0.systemLinkFlyoutContainer.buttonList )
	if f29_arg0.backButton ~= nil then
		f29_arg0.backButton:close()
	end
	Engine.PlaySound( "cac_cmn_backout" )
	f29_arg0:addBackButton( Engine.Localize( "MENU_MAIN_MENU" ) )
	f29_arg0:registerEventHandler( "button_prompt_back", CoD.MainMenu.Back )
end

CoD.MainMenu.FlyoutBack = function ( f30_arg0, f30_arg1 )
	if f30_arg0.m_backReady then
		f30_arg0:dispatchEventToParent( {
			name = "button_prompt_back",
			controller = f30_arg1.controller
		} )
		f30_arg0.m_backReady = nil
	else
		f30_arg0.m_backReady = true
	end
end

CoD.MainMenu.OpenSystemLinkLobby = function ( f31_arg0, f31_arg1 )
	if CoD.MainMenu.IsGuestRestricted( f31_arg0, f31_arg1 ) == true then
		return 
	elseif Engine.CheckNetConnection() == false then
		local f31_local0 = f31_arg0:openPopup( "popup_net_connection", f31_arg1.controller )
		f31_local0.callingMenu = f31_arg0
		return 
	elseif CoD.MainMenu.OfflinePlayAvailable( f31_arg0, f31_arg1 ) == 0 then
		return 
	end
	f31_arg0.buttonList:saveState()
	CoD.MainMenu.SystemLinkLastUsedButton = 0
	CoD.MainMenu.InitializeLocalPlayers( f31_arg1.controller )
	CoD.SwitchToSystemLinkLobby( f31_arg1.controller )
	local f31_local0 = UIExpression.DvarInt( f31_arg1.controller, "party_maxlocalplayers_privatematch" )
	if CoD.isZombie == true then
		f31_arg0:openMenu( "SelectMapZM", f31_arg1.controller )
		ShowGlobe()
	else
		f31_arg0:openMenu( "PrivateLocalGameLobby", f31_arg1.controller )
	end
	f31_arg0:close()
end

CoD.MainMenu.OpenServerBrowser = function ( f32_arg0, f32_arg1 )
	if CoD.MainMenu.IsGuestRestricted( f32_arg0, f32_arg1 ) == true then
		return 
	else
		Engine.Exec( controller, "loadcommonff" )
		if Engine.CheckNetConnection() == false then
			local f32_local0 = f32_arg0:openPopup( "popup_net_connection", f32_arg1.controller )
			f32_local0.callingMenu = f32_arg0
			return 
		elseif CoD.MainMenu.OfflinePlayAvailable( f32_arg0, f32_arg1 ) == 0 then
			return 
		else
			f32_arg0.buttonList:saveState()
			CoD.MainMenu.SystemLinkLastUsedButton = 1
			CoD.MainMenu.InitializeLocalPlayers( f32_arg1.controller )
			Engine.ServerListUpdateFilter( f32_arg1.controller )
			f32_arg0:openPopup( "ServerBrowser", f32_arg1.controller )
		end
	end
end

CoD.MainMenu.ReopenServerBrowser = function ( f33_arg0, f33_arg1 )
	CoD.resetGameModes()
	if f33_arg0.systemLinkButton:isInFocus() then
		return 
	else
		f33_arg0.buttonList:processEvent( {
			name = "lose_focus"
		} )
		f33_arg0.systemLinkButton:processEvent( {
			name = "gain_focus"
		} )
		CoD.MainMenu.OpenSystemLinkFlyout( f33_arg0, f33_arg1 )
		f33_arg0.systemLinkFlyoutContainer.openSystemLinkButton:processEvent( {
			name = "lose_focus"
		} )
		f33_arg0.systemLinkFlyoutContainer.openServerBrowserButton:processEvent( {
			name = "gain_focus"
		} )
		CoD.MainMenu.OpenServerBrowser( f33_arg0, f33_arg1 )
	end
end

CoD.MainMenu.Leave = function ( f34_arg0, f34_arg1 )
	Dvar.ui_changed_exe:set( 1 )
	Engine.Exec( f34_arg1.controller, "wait;wait;wait" )
	Engine.Exec( f34_arg1.controller, "startSingleplayer" )
end

CoD.MainMenu.Back = function ( f35_arg0, f35_arg1 )
	local f35_local0 = {
		params = {},
		titleText = Engine.Localize( "MENU_MAIN_MENU_CAPS" )
	}
	if not CoD.isZombie then
		table.insert( f35_local0.params, {
			leaveHandler = CoD.MainMenu.StartSP,
			leaveEvent = "start_sp",
			leaveText = Engine.Localize( "MENU_CAMPAIGN" )
		} )
		table.insert( f35_local0.params, {
			leaveHandler = CoD.MainMenu.StartZombies,
			leaveEvent = "start_zombies",
			leaveText = Engine.Localize( "MENU_ZOMBIE" )
		} )
	else
		table.insert( f35_local0.params, {
			leaveHandler = CoD.MainMenu.StartSP,
			leaveEvent = "start_sp",
			leaveText = Engine.Localize( "MENU_CAMPAIGN" )
		} )
		table.insert( f35_local0.params, {
			leaveHandler = CoD.MainMenu.StartMP,
			leaveEvent = "start_mp",
			leaveText = Engine.Localize( "MENU_MULTIPLAYER" )
		} )
	end
	local f35_local1 = f35_arg0:openPopup( "ConfirmLeave", f35_arg1.controller, f35_local0 )
	f35_local1.anyControllerAllowed = true
end

CoD.MainMenu.ButtonPromptFriendsMenu = function ( f36_arg0, f36_arg1 )
	if UIExpression.IsGuest( f36_arg1.controller ) == 1 then
		local f36_local0 = f36_arg0:openPopup( "popup_guest_contentrestricted", f36_arg1.controller )
		f36_local0.anyControllerAllowed = true
		f36_local0:setOwner( f36_arg1.controller )
		return 
	elseif UIExpression.IsSignedInToLive( controller ) == 0 then
		local f36_local0 = f36_arg0:openPopup( "Error", controller )
		f36_local0:setMessage( Engine.Localize( "XBOXLIVE_FRIENDS_UNAVAILABLE" ) )
		f36_local0.anyControllerAllowed = true
		return 
	elseif UIExpression.IsContentRatingAllowed( f36_arg1.controller ) == 0 or UIExpression.IsAnyControllerMPRestricted() == 1 or not Engine.HasMPPrivileges( f36_arg1.controller ) then
		local f36_local0 = f36_arg0:openPopup( "Error", controller )
		f36_local0:setMessage( Engine.Localize( "XBOXLIVE_MPNOTALLOWED" ) )
		f36_local0.anyControllerAllowed = true
		return 
	elseif UIExpression.AreStatsFetched( f36_arg1.controller ) == 0 then
		return 
	elseif not CoD.isPS3 or UIExpression.IsSubUser( f36_arg1.controller ) ~= 1 then
		local f36_local0 = f36_arg0:openPopup( "FriendsList", f36_arg1.controller )
		CoD.MainMenu.InitializeLocalPlayers( f36_arg1.controller )
		f36_local0:setOwner( f36_arg1.controller )
	end
end

CoD.MainMenu.SignedIntoLive = function ( f37_arg0, f37_arg1 )
	if f37_arg0.friendsButton == nil then
		f37_arg0:addFriendsButton()
	end
end

CoD.MainMenu.SignedOut = function ( f38_arg0, f38_arg1 )
	if f38_arg0.friendsButton ~= nil then
		f38_arg0.friendsButton:close()
		f38_arg0.friendsButton = nil
	end
end

CoD.MainMenu.InitializeLocalPlayers = function ( f39_arg0 )
	Engine.ExecNow( f39_arg0, "disableallclients" )
	Engine.ExecNow( f39_arg0, "setclientbeingusedandprimary" )
end

LUI.createMenu.VCS = function ( f40_arg0 )
	local f40_local0 = CoD.Menu.New( "VCS" )
	f40_local0.anyControllerAllowed = true
	f40_local0:addElement( LUI.UIImage.new( {
		left = 0,
		top = 0,
		right = 1080,
		bottom = 600,
		leftAnchor = true,
		topAnchor = true,
		rightAnchor = false,
		bottomAnchor = false,
		red = 1,
		green = 1,
		blue = 1,
		alpha = 1,
		material = RegisterMaterial( "vcs_0" )
	} ) )
	return f40_local0
end

