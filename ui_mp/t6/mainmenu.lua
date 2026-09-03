require("T6.MainMenuOG")

LUI.createMenu.MainMenu = function ( localClientNumber )
	local self = CoD.Menu.New( "MainMenu" )

	self.anyControllerAllowed = true
	self:registerEventHandler( "open_main_lobby_requested", CoD.MainMenu.OpenMainLobbyRequested )
	self:registerEventHandler( "open_system_link_flyout", CoD.MainMenu.OpenSystemLinkFlyout )
	self:registerEventHandler( "open_system_link_lobby", CoD.MainMenu.OpenSystemLinkLobby )
	self:registerEventHandler( "open_server_browser", CoD.MainMenu.OpenServerBrowser )
	self:registerEventHandler( "open_local_match_lobby", CoD.MainMenu.OpenLocalMatchLobby )

	if CoD.isWIIU then
		self:registerEventHandler( "open_controls_menu", CoD.MainMenu.OpenControlsMenu )
	end

	self:registerEventHandler( "open_options_menu", CoD.MainMenu.OpenOptionsMenu )
	self:registerEventHandler( "start_zombies", CoD.MainMenu.StartZombies )
	self:registerEventHandler( "start_mp", CoD.MainMenu.StartMP )
	self:registerEventHandler( "start_sp", CoD.MainMenu.StartSP )
	self:registerEventHandler( "button_prompt_back", CoD.MainMenu.Back )
	self:registerEventHandler( "first_signed_in", CoD.MainMenu.SignedIntoLive )
	self:registerEventHandler( "last_signed_out", CoD.MainMenu.SignedOut )
	self:registerEventHandler( "open_menu", CoD.Lobby.OpenMenu )
	self:registerEventHandler( "reopen_serverbrowser", CoD.MainMenu.ReopenServerBrowser )
	self:registerEventHandler( "invite_accepted", CoD.inviteAccepted )
	self:registerEventHandler( "button_prompt_friends", CoD.MainMenu.ButtonPromptFriendsMenu )
	self:registerEventHandler( "open_store", CoD.MainLobby.OpenStore )
	self:registerEventHandler( "showstorebutton", CoD.MainMenu.ShowStoreButtonEvent )

	if CoD.isPS3 then
		self:registerEventHandler( "corrupt_install", CoD.MainMenu.CorruptInstall )
	end

	if CoD.isPC then
		self:registerEventHandler( "open_quit_popup", CoD.MainMenu.OpenQuitPopup )
		self:registerEventHandler( "open_sp_switch_popup", CoD.MainMenu.OpenConfirmSwitchToSP )
		self:registerEventHandler( "open_mp_switch_popup", CoD.MainMenu.OpenConfirmSwitchToMP )
		self:registerEventHandler( "open_zm_switch_popup", CoD.MainMenu.OpenConfirmSwitchToZM )
	end

	if CoD.isZombie == false then
		self:registerEventHandler( "elite_registration_ended", CoD.MainMenu.elite_registration_ended )
		self:registerEventHandler( "elite_registration_email_popup_requested", CoD.EliteRegistrationEmailPopup.EliteRegistrationEmailPopupRequested )
		self:registerEventHandler( "AutoFillPopup_Closed", CoD.EliteRegistrationEmailPopup.AutoFillPopup_Closed )
		self:registerEventHandler( "motd_popup_closed", CoD.MainMenu.Popup_Closed )
		self:registerEventHandler( "dlcpopup_closed", CoD.MainMenu.Popup_Closed )
		self:registerEventHandler( "voting_popup_closed", CoD.MainMenu.Popup_Closed )
		self:registerEventHandler( "spreminder_popup_closed", CoD.MainMenu.Popup_Closed )
		self:registerEventHandler( "dsppromotion_popup_closed", CoD.MainMenu.Popup_Closed )
		self:registerEventHandler( "ghostupsell_popup_closed", CoD.MainMenu.Popup_Closed )
	end

	self:addSelectButton()
	if not CoD.isPC then
		self:addBackButton( Engine.Localize( "MENU_MAIN_MENU" ) )
	end

	if UIExpression.AnySignedInToLive( localClientNumber ) == 1 then
		self:addFriendsButton()
	end

	if CoD.isZombie == false then
		local someImage = LUI.UIImage.new()
		someImage:setLeftRight( false, false, -640, 640 )
		someImage:setTopBottom( false, false, -360, 360 )
		someImage:setImage( RegisterMaterial( "menu_mp_soldiers" ) )
		someImage:setPriority( -1 )
		self:addElement( someImage )

		local anotherImage = LUI.UIImage.new()
		anotherImage:setLeftRight( false, false, -640, 640 )
		anotherImage:setTopBottom( false, false, 180, 360 )
		anotherImage:setImage( RegisterMaterial( "ui_smoke" ) )
		anotherImage:setAlpha( 0.1 )
		self:addElement( anotherImage )
	end
	
	if CoD.isZombie then
		local someOffset = 192
		local f4_local2 = someOffset * 2
		local f4_local3 = 230
		local f4_local4 = LUI.UIImage.new()
		f4_local4:setLeftRight( true, false, 0, f4_local2 )
		f4_local4:setTopBottom( true, false, f4_local3 - someOffset / 2, f4_local3 + someOffset / 2 )
		f4_local4:setImage( RegisterMaterial( "menu_zm_title_screen" ) )
		self:addElement( f4_local4 )

		CoD.GameGlobeZombie.gameGlobe.currentMenu = self
	else
		local someOffset = 48
		local f4_local2 = someOffset * 8
		local f4_local3 = 210
		local f4_local4 = LUI.UIImage.new()
		f4_local4:setLeftRight( true, false, 0, f4_local2 )
		f4_local4:setTopBottom( true, false, f4_local3, f4_local3 + someOffset )
		f4_local4:setImage( RegisterMaterial( "menu_mp_title_screen" ) )
		self:addElement( f4_local4 )

		local f4_local5 = Dvar.loc_language:get()
		if f4_local5 == CoD.LANGUAGE_ENGLISH or f4_local5 == CoD.LANGUAGE_BRITISH then
			local f4_local6 = 24
			local f4_local7 = f4_local6 * 16
			local f4_local8 = f4_local3 + someOffset + 2
			local f4_local9 = LUI.UIImage.new()
			f4_local9:setLeftRight( true, false, 0, f4_local7 )
			f4_local9:setTopBottom( true, false, f4_local8, f4_local8 + f4_local6 )
			f4_local9:setImage( RegisterMaterial( "menu_mp_title_screen_mp" ) )
			self:addElement( f4_local9 )
		end
	end

	local someHeight = 8
	if CoD.isWIIU then
		someHeight = someHeight + 1
	end

	local f4_local2 = 6
	local f4_local3 = CoD.CoD9Button.Height * someHeight
	local f4_local4 = CoD.ButtonList.DefaultWidth
	local f4_local5 = -f4_local3 - CoD.ButtonPrompt.Height

	self.buttonList = CoD.ButtonList.new( {
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

	self.buttonList:setPriority( 10 )
	self.buttonList:registerAnimationState( "disabled", {
		alpha = 0.5
	} )

	self:addElement( self.buttonList )
	self.mainLobbyButton = self.buttonList:addButton( Engine.Localize( "PLATFORM_XBOXLIVE_INSTR" ), nil, 1 )
	self.mainLobbyButton:setActionEventName( "open_main_lobby_requested" )

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
		local f4_local10_f1, f4_local10_f2, f4_local10_f3, f4_local10_f4 = GetTextDimensions( f4_local9, CoD.CoD9Button.Font, CoD.CoD9Button.TextHeight )
		f4_local10[1] = f4_local10_f1
		f4_local10[2] = f4_local10_f2
		f4_local10[3] = f4_local10_f3
		f4_local10[4] = f4_local10_f4
		self.systemLinkButton = self.buttonList:addButton( f4_local9, nil, 2 )
		self.systemLinkButton:setActionEventName( "open_system_link_flyout" )
		f4_local8 = f4_local10[3] + 15
	end

	if not CoD.isPC and not Engine.IsBetaBuild() then
		if CoD.isWIIU then
			self.localButton = self.buttonList:addButton( Engine.Localize( CoD.MPZM( "MENU_LOCAL_CAPS", "PLATFORM_UI_LOCAL_CAPS" ) ), nil, 3 )
		else
			self.localButton = self.buttonList:addButton( Engine.Localize( CoD.MPZM( "MENU_LOCAL_CAPS", "ZMUI_LOCAL_CAPS" ) ), nil, 3 )
		end
		
		self.localButton:setActionEventName( "open_local_match_lobby" )
	end

	if CoD.isWIIU then
		self.controlsButton = self.buttonList:addButton( Engine.Localize( "MENU_CONTROLLER_SETTINGS_CAPS" ), nil, 4 )
		self.controlsButton:setActionEventName( "open_controls_menu" )
	end

	self.optionsButton = self.buttonList:addButton( Engine.Localize( "MENU_OPTIONS_CAPS" ), nil, 4 )
	self.optionsButton:setActionEventName( "open_options_menu" )

	if CoD.MainMenu.ShowStoreButton( localClientNumber ) == true and self.ingameStoreButton == nil then
		CoD.MainMenu.AddStoreButton( self )
	end

	if CoD.isPC then
		if not CoD.isPC then -- pluto patch
			self.buttonList:addSpacer( CoD.CoD9Button.Height / 2, 5 )
			self.spButton = self.buttonList:addButton( Engine.Localize( "MENU_SINGLEPLAYER_CAPS" ), nil, 6 )
			self.spButton:setActionEventName( "open_sp_switch_popup" )

			if CoD.isZombie then
				self.mpButton = self.buttonList:addButton( Engine.Localize( "MENU_MULTIPLAYER_CAPS" ), nil, 7 )
				self.mpButton:setActionEventName( "open_mp_switch_popup" )
			else
				self.zombieButton = self.buttonList:addButton( Engine.Localize( "MENU_ZOMBIE_CAPS" ), nil, 7 )
				self.zombieButton:setActionEventName( "open_zm_switch_popup" )
			end
		end -- pluto patch
		self.buttonList:addSpacer( CoD.CoD9Button.Height / 2, 8 )
		self.quitButton = self.buttonList:addButton( Engine.Localize( "MENU_QUIT_CAPS" ), nil, 9 )
		self.quitButton:setActionEventName( "open_quit_popup" )
		self:addLeftButtonPrompt( CoD.ButtonPrompt.new( "secondary", "", self, "open_quit_popup", true ) )
		self.buttonList:setLeftRight( true, false, f4_local2, f4_local2 + 120 )
	end

	if f4_local7 then
		local f4_local9 = f4_local5 + CoD.CoD9Button.Height + 2
		f4_local9 = f4_local5 + CoD.CoD9Button.Height + 2
		local f4_local10 = CoD.CoD9Button.Height * 2 + 2
		local f4_local11 = Engine.Localize( "MENU_CREATE_GAME_CAPS" )
		local f4_local12 = {}
		local f4_local12_1, f4_local12_2, f4_local12_3, f4_local12_4 = GetTextDimensions( f4_local11, CoD.CoD9Button.Font, CoD.CoD9Button.TextHeight )
		f4_local12[1] = f4_local12_1
		f4_local12[2] = f4_local12_2
		f4_local12[3] = f4_local12_3
		f4_local12[4] = f4_local12_4
		local f4_local13 = Engine.Localize( "MENU_JOIN_GAME_CAPS" )
		local f4_local14 = {}
		local f4_local14_1, f4_local14_2, f4_local14_3, f4_local14_4 = GetTextDimensions( f4_local13, CoD.CoD9Button.Font, CoD.CoD9Button.TextHeight )
		f4_local14[1] = f4_local14_1
		f4_local14[2] = f4_local14_2
		f4_local14[3] = f4_local14_3
		f4_local14[4] = f4_local14_4

		local f4_local15 = f4_local12[3]
		if f4_local15 < f4_local14[3] then
			f4_local15 = f4_local14[3]
		end

		self.systemLinkFlyoutContainer = LUI.UIElement.new( {
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

		self.systemLinkFlyoutContainer:registerAnimationState( "show", {
			alpha = 1
		} )

		self:addElement( self.systemLinkFlyoutContainer )
		self.systemLinkFlyoutContainer:addElement( LUI.UIImage.new( {
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
			alpha = 0.8
		} ) )

		self.systemLinkFlyoutContainer:addElement( LUI.UIImage.new( {
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
			alpha = 0.8
		} ) )

		self.systemLinkFlyoutContainer.buttonList = CoD.ButtonList.new( {
			leftAnchor = true,
			rightAnchor = true,
			left = 4,
			right = 0,
			topAnchor = true,
			bottomAnchor = true,
			top = 0,
			bottom = 0
		} )

		CoD.ButtonList.DisableInput( self.systemLinkFlyoutContainer.buttonList )
		self.systemLinkFlyoutContainer:addElement( self.systemLinkFlyoutContainer.buttonList )
		self.systemLinkFlyoutContainer.buttonList.hintText:close()
		self.systemLinkFlyoutContainer.buttonList.hintText = nil

		if CoD.useMouse then
			self.systemLinkFlyoutContainer.buttonList:setHandleMouseButton( true )
			self.systemLinkFlyoutContainer.buttonList:registerEventHandler( "leftmouseup_outside", CoD.MainMenu.FlyoutBack )
		end

		self.systemLinkFlyoutContainer.openSystemLinkButton = self.systemLinkFlyoutContainer.buttonList:addButton( f4_local11, nil, 1 )
		self.systemLinkFlyoutContainer.openSystemLinkButton:setActionEventName( "open_system_link_lobby" )
		self.systemLinkFlyoutContainer.openServerBrowserButton = self.systemLinkFlyoutContainer.buttonList:addButton( f4_local13, nil, 1 )
		self.systemLinkFlyoutContainer.openServerBrowserButton:setActionEventName( "open_server_browser" )
	end

	if not self.buttonList:restoreState() then
		self.buttonList:processEvent( {
			name = "gain_focus"
		} )
	elseif f4_local7 and self.systemLinkButton:isInFocus() then
		local f4_local9 = {
			controller = localClientNumber
		}
		if true == Engine.CheckNetConnection() and CoD.MainMenu.OfflinePlayAvailable( self, f4_local9, true ) == 1 then
			CoD.MainMenu.OpenSystemLinkFlyout( self, f4_local9 )
			if CoD.MainMenu.SystemLinkLastUsedButton == 1 then
				self.systemLinkFlyoutContainer.openSystemLinkButton:processEvent( {
					name = "lose_focus"
				} )
				self.systemLinkFlyoutContainer.openServerBrowserButton:processEvent( {
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
		Engine.ExecNow( localClientNumber, "onetimeinstallcorruptioncheck" )
	end

	return self
end
