
ASS.Menu = {}

function ASS.Menu.OverrideHooks( MENU )

	// Call the callback when we need to build the menu
	// If we're creating the menu now, also register our
	// hacked functions with it, so this hack propagates
	// virus like among any DMenus spawned from this 
	// parent DMenu.. muhaha
 	function DMenuOption_OnCursorEntered(self) 
 	
 		local m = self.SubMenu
 		if (self.BuildFunction) then
 	 		m = DermaMenu( self ) 
	 		ASS.Menu.OverrideHooks(m)
 			m:SetVisible( false ) 
 			m:SetParent( self:GetParent() ) 
 			PCallError( self.BuildFunction, m)
 			if (!m:HasPanels()) then
 				m:AddOption( "(none)", function() end )
 			end
		end
		
		self:GetParent():OpenSubMenu( self, m )	 
 	 
	end 	
	
	// Menu item images!
	function DMenuOption_SetImage(self, img)
	
		self.Image = ASS.Resource.LoadImage(img)
	
	end
	
	// Change the released hook so that if the click function
	// returns a non-nil or non-false value then the menus
	// get closed (this way menus can stay opened and be clicked
	// several time).
	function DMenuOption_OnMouseReleased( self, mousecode ) 

		DButton.OnMouseReleased( self, mousecode ) 

		if ( self.m_MenuClicking ) then 

			self.m_MenuClicking = false 
			
			if (!self.ClickReturn) then
				CloseDermaMenus() 
			end

		end 

	end 
	
	// Make sure we draw the image, should be done in the skin
	// but this is a total hack, so meh.
	function DMenuOption_Paint(self)
	
		derma.SkinHook( "Paint", "MenuOption", self )
		
		if (self.Image) then
	 		surface.SetTexture( self.Image ) 
 			surface.SetDrawColor( 255, 255, 255, 255 ) 
 			surface.DrawTexturedRect( 2, (self:GetTall() - 16) * 0.5, 16, 16)
 		end
		
		return false
	
	end
	
	local function DMenu_HasPanels( self )
		return #self.Panels > 0
	end

 	// Make DMenuOptions implement our new functions above.
	// Returns the new DMenuOption created.
	local function DMenu_AddOption( self, strText, funcFunction )

 		local pnl = vgui.Create( "DMenuOption", self ) 
 		pnl.OnCursorEntered = DMenuOption_OnCursorEntered
		pnl.OnMouseReleased = DMenuOption_OnMouseReleased
 		pnl.Paint = DMenuOption_Paint
 		pnl.SetImage = DMenuOption_SetImage
  		pnl:SetText( strText ) 
 		if ( funcFunction ) then 
 			pnl.DoClick = function(self) 
 					self.ClickReturn = funcFunction(pnl) 
 				end
 		end
 	 
 		self:AddPanel( pnl ) 
 	 
 		return pnl 
 
 	end	

	// Make DMenuOptions implement our new functions above.
	// If we're creating the menu now, also register our
	// hacked functions with it, so this hack propagates
	// virus like among any DMenus spawned from this 
	// parent DMenu.. muhaha
	// Returns the new DMenu (if it exists), and the DMenuOption
	// created.
	local function DMenu_AddSubMenu( self, strText, funcFunction, openFunction ) 

	 	local SubMenu = nil
	 	if (!openFunction) then
	 		SubMenu = DermaMenu( self ) 
	 		ASS.Menu.OverrideHooks(SubMenu)
 			SubMenu:SetVisible( false ) 
 			SubMenu:SetParent( self ) 
 		end
 	
 		local pnl = vgui.Create( "DMenuOption", self ) 
 		pnl.OnCursorEntered = DMenuOption_OnCursorEntered
  		pnl.OnMouseReleased = DMenuOption_OnMouseReleased
		pnl.Paint = DMenuOption_Paint
 		pnl.SetImage = DMenuOption_SetImage
		pnl.BuildFunction = openFunction
		pnl:SetSubMenu( SubMenu ) 
		pnl:SetText( strText ) 
		if ( funcFunction ) then 
			pnl.DoClick = function() pnl.ClickReturn = funcFunction(pnl) end
		else 
			pnl.DoClick = function() pnl.ClickReturn = true end
		end

		self:AddPanel( pnl ) 

		if (SubMenu) then
			return SubMenu, pnl
		else
			return pnl
		end

	end 
	
	function UP_Scroll(self)
		local menu = self.menu_owner
		menu.yOffset = menu.yOffset - 1  
		if (menu.yOffset < 0) then 
			menu.yOffset = 0
		end
		menu:InvalidateLayout( true ) 
	end
	
	function DOWN_Scroll(self)
		local menu = self.menu_owner
		menu.yOffset = menu.yOffset + 1 
		if (menu.yOffset > menu.max_yOffset) then 
			menu.yOffset = menu.max_yOffset
		end
		menu:InvalidateLayout( true ) 
	end
	
	function REPEAT_Scroll(self)
		DMenuOption_Paint(self)
		
		if (self.Hovered) then
			if ((not self.NextScrollTime) || (CurTime() > self.NextScrollTime)) then
				if (self.Depressed) then
					self.NextScrollTime = CurTime() + 0.005
				else
					self.NextScrollTime = CurTime() + 0.10
				end
				self:DoScroll()
			end
		end
	end

	function DMENU_Init(menu, w)
	
		if (not menu.UpArrowBtn) then

			local pnl = vgui.Create( "DMenuOption", menu ) 
			pnl.menu_owner = menu
			pnl.DoScroll = UP_Scroll
			pnl.Paint = REPEAT_Scroll
			pnl.SetImage = DMenuOption_SetImage
			pnl:SetText( "** UP **" ) 
			pnl.OnMouseReleased = function(self) self.Depressed = false 	self:MouseCapture( false )	end
			pnl.DoClick = function() end
			pnl:SetWide( w )
			pnl:InvalidateLayout( true )

			menu.UpArrowBtn = pnl
		end

		if (not menu.DownArrowBtn) then

			local pnl = vgui.Create( "DMenuOption", menu ) 
			pnl.menu_owner = menu
			pnl.DoScroll = DOWN_Scroll
			pnl.Paint = REPEAT_Scroll
			pnl.SetImage = DMenuOption_SetImage
			pnl:SetText( "** DOWN **" ) 
			pnl.OnMouseReleased = function(self) self.Depressed = false	self:MouseCapture( false )	end
			pnl.DoClick = function() end
			pnl:SetWide( w )
			pnl:InvalidateLayout( true )

			menu.DownArrowBtn = pnl

		end
		
	end
	
	function DMENU_LayoutMenu( self )

		if ( self.animOpen.Running ) then return end
		
		local w = self:GetMinimumWidth()

		// Find the widest one
		for k, pnl in pairs( self.Panels ) do

			pnl:PerformLayout()
			w = math.max( w, pnl:GetWide() )

		end

		DMENU_Init(self, w)

		self:SetWide( w )
		
		self.yOffset = self.yOffset or 0
		
		local h = 0
		local HighY = ScrH() - self.UpArrowBtn:GetTall() - self.DownArrowBtn:GetTall()
		
		self.max_yOffset = 0

		for k, pnl in pairs( self.Panels ) do

			pnl:SetWide( w )
			pnl:InvalidateLayout( true )

			h = h + pnl:GetTall()
			
			if (h > HighY) then
			
				self.max_yOffset = self.max_yOffset + 1
				
			end

		end

		local y = 0
		local yMax = ScrH()
		if (self.max_yOffset > 0) then
		
			self.UpArrowBtn:SetDisabled( self.yOffset == 0 )
			self.DownArrowBtn:SetDisabled( self.yOffset >= self.max_yOffset )
		
			self.UpArrowBtn:SetVisible(true)
			self.DownArrowBtn:SetVisible(true)
			y = self.UpArrowBtn:GetTall()
			yMax = yMax - self.DownArrowBtn:GetTall()
			
		else
		
			self.UpArrowBtn:SetVisible(false)
			self.DownArrowBtn:SetVisible(false)

		end

		for k, pnl in pairs( self.Panels ) do
			
			local incY = false
			if (self.max_yOffset > 0) then

				if (k < self.yOffset ) then
					pnl:SetVisible(false)
				elseif ((y + pnl:GetTall()) > yMax) then
					pnl:SetVisible(false)
				else
					pnl:SetVisible(true)
					incY = true
				end
				
			else
			
				pnl:SetVisible(true)
				incY = true

			end
			
			pnl:SetPos( 0, y )
			if (incY) then
				y = y + pnl:GetTall()
			end

		end
		
		if (self.max_yOffset > 0) then
			self.DownArrowBtn:SetPos(0, y)
			self:SetTall( y + self.DownArrowBtn:GetTall() )
		else
			self:SetTall( y )
		end
		
	end

	// Register our new hacked function. muhahah
	MENU.AddOption = DMenu_AddOption
	MENU.AddSubMenu = DMenu_AddSubMenu
	MENU.HasPanels = DMenu_HasPanels
	MENU.PerformLayout = DMENU_LayoutMenu

end

function ASS.Menu.PluginsMenu(MENU, PLAYER)
	ASS.Plugins.Hook("BuildPluginMenu", nil, MENU, PLAYER)
end

function ASS.Menu.GamemodeMenu(MENU, PLAYER)
	ASS.Plugins.Hook("BuildGamemodeMenu", nil,MENU, PLAYER)
end

local function InternalRankMenu(MENU, FUNCTION, OPTIONS, CHECKFN)
	
	local excludeSelf = table.HasValue( OPTIONS, ASS.Menu.ExcludeSelf )
	local hasSubMenu = table.HasValue( OPTIONS, ASS.Menu.HasSubMenu )

	for _, group in pairs(ASS.Groups.LevelsOrdered) do

		local list = {}
		for _,pl in pairs(player.GetAll()) do
			local err, meetsLevelRequirements = PCallError( CHECKFN, pl, group.name )
						
			if ((!excludeSelf || pl != LocalPlayer()) && meetsLevelRequirements) then
				table.insert(list, pl) 							
			end
		end
		
		if (LocalPlayer():ASS_HasLevel(group.name) && hasSubMenu && #list > 0) then	
			MENU:AddSubMenu( group.text,	nil,	function(NEWMENU)		FUNCTION(NEWMENU, list)		end )
		else
			MENU:AddOption( group.text, 			function()				FUNCTION(list)					end )
		end
	
	end
	
end

ASS.Menu.ExcludeSelf = "excludeself"
ASS.Menu.ExcludeLevels = "excludelevels"
ASS.Menu.ExcludeAll = "excludeall"
ASS.Menu.HasSubMenu = "hassubmenu"

function ASS.Menu.PlayerMenu( MENU, FUNCTION, OPTIONS )
	
	OPTIONS = OPTIONS or {}
	
	local excludeSelf = table.HasValue( OPTIONS, ASS.Menu.ExcludeSelf )
	local excludeLevels = table.HasValue( OPTIONS, ASS.Menu.ExcludeLevels )
	local excludeAll = table.HasValue( OPTIONS, ASS.Menu.ExcludeAll )
	local hasSubMenu = table.HasValue( OPTIONS, ASS.Menu.HasSubMenu )
	
	if (!excludeAll) then

		if (MENU:HasPanels()) then
			MENU:AddSpacer()
		end

		local list = {}
		for _, pl in pairs(player.GetAll()) do
			if (!excludeSelf || pl != LocalPlayer()) then
				table.insert(list, pl)
			end
		end
		
		if (hasSubMenu) then
			MENU:AddSubMenu( "All", nil,	function(NEWMENU)		FUNCTION( NEWMENU, list )		end )
		else
			MENU:AddOption( "All",			function()				FUNCTION( list )					end )
		end
	
	end
	
	if (!excludeLevels) then
	
		MENU:AddSubMenu( "Based on rank", nil,
			function(NEWMENU)
				NEWMENU:AddSubMenu( "Above or same", nil, function(NEWMENU2) InternalRankMenu(NEWMENU2, FUNCTION, OPTIONS, function(pl, group)	return pl:ASS_HasLevel(group)					end) end )
				NEWMENU:AddSubMenu( "Exact", nil, function(NEWMENU2) InternalRankMenu(NEWMENU2, FUNCTION, OPTIONS, function(pl, group)	return pl:ASS_GetLevel() == group				end) end )
				NEWMENU:AddSubMenu( "Below or same", nil, function(NEWMENU2) InternalRankMenu(NEWMENU2, FUNCTION, OPTIONS, function(pl, group)	return !pl:ASS_HasLevel(group) || pl:ASS_GetLevel() == group	end) end )
			end )
	
	end
	
	if (MENU:HasPanels()) then
		MENU:AddSpacer()
	end
	
	if (!excludeSelf) then
		if (hasSubMenu) then
			MENU:AddSubMenu( LocalPlayer():Nick(), nil, function(NEWMENU) FUNCTION( NEWMENU, {LocalPlayer()} ) end )
		else
			MENU:AddOption( LocalPlayer():Nick(), function() FUNCTION( {LocalPlayer()} ) end )
		end
	end

	local plylist = player.GetAll()

	if (MENU:HasPanels() && #plylist > 1) then
		MENU:AddSpacer()
	end
	
	for _, pl in pairs(plylist) do
		if (pl != LocalPlayer()) then
			if (hasSubMenu) then
				MENU:AddSubMenu( pl:Nick(), nil, function(NEWMENU) FUNCTION( NEWMENU, {pl} ) end )
			else
				MENU:AddOption( pl:Nick(), function() FUNCTION( {pl} ) end )
			end
		end
	end

end

function ASS.Menu.Show( PLAYER )

	local MENU = DermaMenu()
	
	ASS.Menu.OverrideHooks(MENU)
	
	ASS.Plugins.Hook("BuildMainMenu", nil, MENU, PLAYER)
	if (MENU:HasPanels()) then
		MENU:AddSpacer()
	end
	MENU:AddSubMenu( GAMEMODE.Name, nil, function(NEWMENU) ASS.Menu.GamemodeMenu(NEWMENU, PLAYER) end )
	MENU:AddSubMenu("Plugins", nil, function(NEWMENU) ASS.Menu.PluginsMenu(NEWMENU, PLAYER) end )
	
	if ( PLAYER:ASS_HasLevel( ASS.Config.Get("config_change_level", true) ) ) then
		MENU:AddSpacer()
		MENU:AddSubMenu("Configuration", nil, ASS.Config.BuildMenu )
	end
	
	MENU:Open( 100, 100 )	
	timer.Simple( 0, gui.SetMousePos, 110, 110 )
	
	ASS.Debug( "Menu.Show", "Menu Opened")
	
end

function ASS.Menu.Hide()

	CloseDermaMenus()
	ASS.Debug( "Menu.Hide", "Menu Closed")

end

concommand.Add("+ASS_Menu", ASS.Menu.Show)
concommand.Add("-ASS_Menu", ASS.Menu.Hide)
