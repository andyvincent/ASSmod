PLUGIN.Name = "Sandbox Colors"
PLUGIN.Clientside = true
PLUGIN.Serverside = true
PLUGIN.DefaultEnable = false
PLUGIN.Gamemodes = {"sandbox"}

PLUGIN.Groups = {}

if (SERVER) then

	function PLUGIN:Activate()
		ASS.Config.AddPermission("sandbox_colors", "Sandbox|Group Color", "serverowner")
		
		ASS.Config.Register("sandbox_colors",
			{	user = Color(100, 150, 245),
				respected = Color(160,170,10),
				admin = Color(5,130,45),
				superadmin = Color(55,180,10),
				serverowner = Color(200,15,5)
			} )
			
		self.Groups = ASS.Config.Get( "sandbox_colors" )

		concommand.Add( "ASS_Group_Color_Send", function(P,C,A) self:SendColorInfo(P,A) end )
		concommand.Add( "ASS_Group_Color_Set", function(P,C,A) self:SetColorInfo(P,A) end )
	end

	function PLUGIN:Deactivate()
		concommand.Remove( "ASS_Group_Color_Send" )
		concommand.Remove( "ASS_Group_Color_Set" )
	end
	
	function PLUGIN:SendColorInfo(PLAYER, ARGS)
	
		for k,v in pairs(self.Groups) do
		
			umsg.Start("ASS:Sandbox.GroupColor", PLAYER) 
				umsg.String( k )
				umsg.Short( v.r )
				umsg.Short( v.g )
				umsg.Short( v.b )
			umsg.End()
		
		end
	
	end
	
	function PLUGIN:SaveToConfig()
		
		ASS.Config.Set( "sandbox_colors", self.Groups )
		ASS.Config.Write()
	
	end

	function PLUGIN:SetColorInfo(PLAYER, ARGS)
		local grp = ARGS[1]
		local r = tonumber(ARGS[2])
		local g = tonumber(ARGS[3])
		local b = tonumber(ARGS[4])

		if (!grp) then return end
		if (!r && !g && !b) then return end
		if (!ASS.Groups.IsValid(grp)) then return end
		
		if (ASS.Config.HasPermission(PLAYER, "sandbox_colors")) then
		
			self.Groups[grp] = Color( 
				math.Clamp(r,0,255),
				math.Clamp(g,0,255),
				math.Clamp(b,0,255) )
				
			self:SendColorInfo()
			
			self:SaveToConfig()
		
		end
		
	end
	
end

if (CLIENT) then

	local PLUGIN_Reference = PLUGIN
	
	function PLUGIN:RowPaint( panel )

		local color = Color( 100, 150, 245, 255 )

		if ( !ValidEntity( panel.Player ) ) then return end
		
		local lvl = panel.Player:ASS_GetLevel()
		if (self.Groups[ lvl ]) then
			color = Color( self.Groups[ lvl ].r, self.Groups[ lvl ].g, self.Groups[ lvl ].b, self.Groups[ lvl ].a )
		end

		if ( panel.Player == LocalPlayer() ) then

			local offset = math.sin( CurTime() * 8 ) * 10
			
			color.r = math.Clamp(color.r + offset, 0, 255)
			color.g = math.Clamp(color.g + offset, 0, 255)
			color.b = math.Clamp(color.b + offset, 0, 255)

		end

		if ( panel.Open || panel.Size != panel.TargetSize ) then

			draw.RoundedBox( 4, 0, 16, panel:GetWide(), panel:GetTall() - 16, color )
			draw.RoundedBox( 4, 2, 16, panel:GetWide()-4, panel:GetTall() - 16 - 2, Color( 250, 250, 245, 255 ) )

			surface.SetTexture( texGradient )
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawTexturedRect( 2, 16, panel:GetWide()-4, panel:GetTall() - 16 - 2 ) 

		end

		draw.RoundedBox( 4, 0, 0, panel:GetWide(), 36, color )

		surface.SetTexture( texGradient )
		surface.SetDrawColor( 255, 255, 255, 50 )
		surface.DrawTexturedRect( 0, 0, panel:GetWide(), 36 ) 

		// This should be an image panel!
		surface.SetTexture( panel.texRating )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( panel:GetWide() - 16 - 8, 36 / 2 - 8, 16, 16 ) 	

		return true
	
	end
	
	local color_plugin_active = false
	
	local old_vgui_Create = vgui.Create
	vgui.Create = function(classname, parent, name, ...)
	
		local ctrl = old_vgui_Create(classname, parent, name, ...)
		if (ctrl && classname == "ScorePlayerRow") then
		
			ctrl.ASS_Original_Paint = ctrl.Paint
			ctrl.Paint = 
				function (self)
					if (PLUGIN_Reference.Active) then
						return PLUGIN_Reference:RowPaint(self)
					else
						return self:ASS_Original_Paint()
					end
				end
		
		end
		return ctrl
		
	end
	
	function PLUGIN:RecieveGroupColor(UM)
		local nm = UM:ReadString()
		local r = UM:ReadShort()
		local g = UM:ReadShort()
		local b = UM:ReadShort()
		
		self.Groups[nm] = Color(r,g,b,255)
	end
	
	function PLUGIN:Configure()
		
		local TE = vgui.Create("DChangeGroupColorFrame")
		for _, info in pairs(ASS.Groups.LevelsOrdered) do
			TE:AddGroup( info.text, info.name, self.Groups[info.name] or Color(100, 150, 245, 255) )
		end
		TE:SetBackgroundBlur( true )
		TE:SetDrawOnTop( true )
		TE:SetTitle("Change Colors...")
		TE:SetWide(250)
		TE:PerformLayout()
		TE:Center()
		TE:MakePopup()	
		
	end
	
	function PLUGIN:BuildGamemodeMenu(MENU)
	
		if (ASS.Config.HasPermission("sandbox_colors")) then
	
			MENU:AddOption( "Set Group Colors", function() self:Configure() end )
		
		end
	
	end

	function PLUGIN:Activate()
	
		self.Active = true
	
		usermessage.Hook( "ASS:Sandbox.GroupColor", function(UM) self:RecieveGroupColor(UM) end )
		ASS.Command("ASS_Group_Color_Send")
				
	end
	
	function PLUGIN:Deactivate()
	
		self.Active = false

	end


////////////////////////////////////////////////////////////////////////////////////
// DChangeGroupColor
////////////////////////////////////////////////////////////////////////////////////

	PANEL = {}

	function PANEL:Init()
		
		self.Items = {}

		self.List = vgui.Create("DPanelList", self)
		self.List:EnableVerticalScrollbar()

		self.ApplyButton = vgui.Create("DButton", self)
		self.ApplyButton:SetText("Apply")
		self.ApplyButton.DoClick = function(BTN) self:ApplySettings() end

		self.CancelButton = vgui.Create("DButton", self)
		self.CancelButton:SetText("Cancel")
		self.CancelButton.DoClick = function(BTN) self:Close() end
		
	end
	
	function PANEL:AddGroup( text, name, color )
		
		local Category = vgui.Create("DCollapsibleCategory")
		Category:SetLabel( text ) 
		self.List:AddItem(Category)

		local Picker = vgui.Create("DColorMixer")
		Picker.Group = name
		Picker.InitialColor = Color( color.r, color.g, color.b )
		Picker:SetTall(100)
		Picker:SetColor( color )
		
		Category:SetContents( Picker ) 
		Category:SetExpanded( false )
		
		self.Items[name] = Picker
		
	end

	function PANEL:ApplySettings()
		for k,v in pairs(self.Items) do
			local newValue = v:GetColor()
			
			if (newValue.r != v.InitialColor.r || newValue.g != v.InitialColor.g || newValue.b != v.InitialColor.b) then
				ASS.Command("ASS_Group_Color_Set", v.Group, newValue.r, newValue.g, newValue.b )
				v.InitialColor = Color( newValue.r, newValue.g, newValue.b )
			end
		end
	end

	function PANEL:PerformLayout()

		derma.SkinHook( "Layout", "Frame", self )

		self.List:SetTall(300)

		self.CancelButton:SizeToContents()
		self.ApplyButton:SizeToContents()
		
		local btnWid = self.CancelButton:GetWide()
		if (self.ApplyButton:GetWide() > btnWid) then
			btnWid = self.ApplyButton:GetWide()
		end
		btnWid = btnWid + 16

		local btnHei = self.CancelButton:GetTall()
		if (self.ApplyButton:GetTall() > btnHei) then
			btnHei = self.ApplyButton:GetTall()
		end
		btnHei = btnHei + 8
		
		self.CancelButton:SetWide(btnWid)
		self.CancelButton:SetTall(btnHei)

		self.ApplyButton:SetWide(btnWid)
		self.ApplyButton:SetTall(btnHei)

		local height = 32

			height = height + self.List:GetTall()
			height = height + 8
			height = height + btnHei
			height = height + 8

		self:SetTall(height)

		local width = self:GetWide()

		self.List:SetPos( 8, 32 )
		self.List:SetWide( width - 16 )

		local btnY = 32 + self.List:GetTall() + 8
		self.CancelButton:SetPos( width - 8 - btnWid, btnY )
		self.ApplyButton:SetPos( width - 8 - btnWid - 8 - btnWid, btnY )
	end

	derma.DefineControl( "DChangeGroupColorFrame", "Frame to change sandbox colors", PANEL, "DFrame" )

end