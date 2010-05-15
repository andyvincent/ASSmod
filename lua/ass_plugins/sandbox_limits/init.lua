PLUGIN.Name = "Sandbox Cleanup"
PLUGIN.Clientside = true
PLUGIN.Serverside = true
PLUGIN.DefaultEnable = true
PLUGIN.Gamemodes = {"sandbox"}

if (SERVER) then

	function PLUGIN:Activate()
		ASS.Config.AddPermission("sandbox_limits", "Sandbox|Limits", "admin")
		
		concommand.Add("ASS_Sandbox_Limits_Send", function(P,C,A) self:CC_SendLimits(P,A) end )
		concommand.Add("ASS_Sandbox_Limits_Set", function(P,C,A) self:CC_SetLimit(P,A) end )
		
		if (!self.Limits) then
			self.Limits = {}
			
			local category = { name = "#Sandbox", list = {} }
			table.insert( category.list, 		{	text = "#SBoxMaxProps",							var = "sbox_maxprops"						} )
			table.insert( category.list, 		{	text = "#SBoxMaxRagdolls",						var = "sbox_maxragdolls"					} )
			table.insert( category.list, 		{	text = "#SBoxMaxVehicles",						var = "sbox_maxvehicles"					} )
			table.insert( category.list, 		{	text = "#SBoxMaxEffects",						var = "sbox_maxeffects"						} )
			table.insert( category.list, 		{	text = "#SBoxMaxBalloons",						var = "sbox_maxballoons"					} )
			table.insert( category.list, 		{	text = "#SBoxMaxNPCs",							var = "sbox_maxnpcs"							} )
			table.insert( category.list, 		{	text = "#SBoxMaxSENTs",							var = "sbox_maxsents"						} )
			table.insert( category.list, 		{	text = "#SBoxMaxDynamite",						var = "sbox_maxdynamite"					} )
			table.insert( category.list, 		{	text = "#SBoxMaxLamps",							var = "sbox_maxlamps"						} )
			table.insert( category.list, 		{	text = "#SBoxMaxWheels",						var = "sbox_maxwheels"						} )
			table.insert( category.list, 		{	text = "#SBoxMaxThrusters",					var = "sbox_maxthrusters"					} )
			table.insert( category.list, 		{	text = "#SBoxMaxHoverBalls",					var = "sbox_maxhoverballs"					} )
			table.insert( category.list, 		{	text = "#SBoxMaxButtons",						var = "sbox_maxbuttons"						} )
			table.insert( category.list, 		{	text = "#SBoxMaxEmitters",						var = "sbox_maxemitters"					} )
			table.insert( category.list, 		{	text = "#SBoxMaxSpawners",						var = "sbox_maxspawners"					} )
			table.insert( category.list, 		{	text = "#SBoxMaxTurrets",						var = "sbox_maxturrets"						} )
			table.insert( self.Limits, category )

			if (WireLib) then
				local category = { name = "#Wire", list = {} }
				table.insert( category.list,	{ text = "#Max Wiremod Wheels",					var = "sbox_maxwire_wheels"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Waypoints",				var = "sbox_maxwire_waypoints"			} )
				table.insert( category.list,	{ text = "#Max Wiremod Values",					var = "sbox_maxwire_values"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Two-way Radios",		var = "sbox_maxwire_twoway_radioes"		} )
				table.insert( category.list,	{ text = "#Max Wiremod Turrets",					var = "sbox_maxwire_turrets"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Thrusters",				var = "sbox_maxwire_thrusters"			} )
				table.insert( category.list,	{ text = "#Max Wiremod Target Finders",		var = "sbox_maxwire_target_finders"		} )
				table.insert( category.list,	{ text = "#Max Wiremod Speedometers",			var = "sbox_maxwire_speedometers"		} )
				table.insert( category.list,	{ text = "#Max Wiremod Spawners",				var = "sbox_maxwire_spawners"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Emitters",				var = "sbox_maxwire_emitters"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Simple Explosives",	var = "sbox_maxwire_simple_explosive"	} )
				table.insert( category.list,	{ text = "#Max Wiremod Sensors",					var = "sbox_maxwire_sensors"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Screens",					var = "sbox_maxwire_screens"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Relays",					var = "sbox_maxwire_relays"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Rangers",					var = "sbox_maxwire_rangers"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Radios",					var = "sbox_maxwire_radioes"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Pods",						var = "sbox_maxwire_pods"					} )
				table.insert( category.list,	{ text = "#Max Wiremod Sockets",					var = "sbox_maxwire_sockets"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Plugs",					var = "sbox_maxwire_plugs"					} )
				table.insert( category.list,	{ text = "#Max Wiremod Pixels",					var = "sbox_maxwire_pixels"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Panels",					var = "sbox_maxwire_panels"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Outputs",					var = "sbox_maxwire_outputs"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Oscilloscopes",			var = "sbox_maxwire_oscilloscopes"		} )
				table.insert( category.list,	{ text = "#Max Wiremod Numpads",					var = "sbox_maxwire_numpads"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Nailers",					var = "sbox_maxwire_nailers"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Locators",				var = "sbox_maxwire_locators"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Lights",					var = "sbox_maxwire_lights"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Lamps",					var = "sbox_maxwire_lamps"					} )
				table.insert( category.list,	{ text = "#Max Wiremod Inputs",					var = "sbox_maxwire_inputs"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Indicators",				var = "sbox_maxwire_indicators"			} )
				table.insert( category.list,	{ text = "#Max Wiremod Hoverballs",				var = "sbox_maxwire_hoverballs"			} )
				table.insert( category.list,	{ text = "#Max Wiremod Gyroscopes",				var = "sbox_maxwire_gyroscopes"			} )
				table.insert( category.list,	{ text = "#Max Wiremod GPSes",					var = "sbox_maxwire_gpss"					} )
				table.insert( category.list,	{ text = "#Max Wiremod Gates - Trig",			var = "sbox_maxwire_gate_trigs"			} )
				table.insert( category.list,	{ text = "#Max Wiremod Gates - Time",			var = "sbox_maxwire_gate_times"			} )
				table.insert( category.list,	{ text = "#Max Wiremod Gates - Selection",	var = "sbox_maxwire_gate_selections"	} )
				table.insert( category.list,	{ text = "#Max Wiremod Gates - Memory",		var = "sbox_maxwire_gate_memorys"		} )
				table.insert( category.list,	{ text = "#Max Wiremod Gates - Logic",			var = "sbox_maxwire_gate_logics"			} )
				table.insert( category.list,	{ text = "#Max Wiremod Gates - Comparison",	var = "sbox_maxwire_gate_logics"			} )
				table.insert( category.list,	{ text = "#Max Wiremod Gates",					var = "sbox_maxwire_gates"					} )
				table.insert( category.list,	{ text = "#Max Wiremod Forcers",					var = "sbox_maxwire_forcers"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Explosives",				var = "sbox_maxwire_explosive"			} )
				table.insert( category.list,	{ text = "#Max Wiremod Dual Inputs",			var = "sbox_maxwire_dual_inputs"			} )
				table.insert( category.list,	{ text = "#Max Wiremod Digital-Sceens",		var = "sbox_maxwire_digitalscreens"		} )
				table.insert( category.list,	{ text = "#Max Wiremod Detonators",				var = "sbox_maxwire_detonators"			} )
				table.insert( category.list,	{ text = "#Max Wiremod CPUs",						var = "sbox_maxwire_cpus"					} )
				table.insert( category.list,	{ text = "#Max Wiremod Buttons",					var = "sbox_maxwire_buttons"				} )
				table.insert( category.list,	{ text = "#Max Wiremod Adv. Inputs",			var = "sbox_maxwire_adv_inputs"			} )
				table.insert( self.Limits, category )
			end
			if (StarGate) then
			
				local category = { name = "#Stargate", list = {} }
				table.insert( category.list,	{ text = "#Max Mobile DHD",						var = "sbox_maxmobile_dhd"					} )
				table.insert( category.list,	{ text = "#Max Cloak Generator",					var = "sbox_maxcloaking_generator"		} )
				table.insert( category.list,	{ text = "#Max Mobile DHD",						var = "sbox_maxmobile_dhd"					} )
				table.insert( category.list,	{ text = "#Max Iris",								var = "sbox_maxstargate_iris"				} )
				table.insert( category.list,	{ text = "#Max Shields",							var = "sbox_maxshield_generator"			} )
				table.insert( category.list,	{ text = "#Max Zero Point Modules",				var = "sbox_maxZero_Point_Module"		} )
				table.insert( category.list,	{ text = "#Max Drones",								var = "sbox_maxdrone_launcher"			} )
				table.insert( category.list,	{ text = "#Max Staff Weapons",					var = "sbox_maxstaff_weapon_glider"		} )
				table.insert( self.Limits, category )

			end
			
			category = { name = "#Misc", list = {} }
			table.insert( category.list,			{ text = "#Max Bridges",							var = "sbox_maxbridge"						} )
			table.insert( category.list,			{ text = "#Max Hoverboards",							var = "sbox_hoverboards"					} )
			table.insert( self.Limits, category )

			for cidx,cat in pairs(self.Limits) do
				
				for iidx, item in pairs(cat.list) do
					if (!ConVarExists(item.var)) then
						table.remove(cat.list, iidx)
					else
						umsg.PoolString(item.text)
						umsg.PoolString(item.var)
					end
				end
				
				if (#cat.list == 0) then
					table.remove(self.Limits, cidx)
				else
					umsg.PoolString(cat.name)
				end
					
			end
		end
	end
	
	function PLUGIN:Deactivate()
		concommand.Remove("ASS_Sandbox_Limits_Send" )
		concommand.Remove("ASS_Sandbox_Limits_Set" )
	end

	function PLUGIN:CC_SendLimits(PLAYER, ARGS)

		local cnt = 0
		for _,cat in pairs(self.Limits) do
			cnt = cnt + #cat.list
		end

		umsg.Start( "ASS:SandBox.Limit.Init", PLAYER )
			umsg.Long( cnt )
		umsg.End()
		
		local timediff = 0
		for _,cat in pairs(self.Limits) do
			for k,v in pairs(cat.list) do
			
				timer.Simple( timediff,
					function()
						if (!ValidEntity(PLAYER)) then return end
						umsg.Start( "ASS:SandBox.Limit.Info", PLAYER )
							umsg.String(	cat.name			)
							umsg.String(	v.text			)
							umsg.String(	v.var				)
							umsg.String(	GetConVarString(v.var)	)
						umsg.End()
					end )
				timediff = timediff + 0.01
			end
		end

		timer.Simple( timediff,
			function()
				if (!ValidEntity(PLAYER)) then return end
				umsg.Start( "ASS:SandBox.Limit.GUI", PLAYER )
				umsg.End()
			end )
	
	end

	function PLUGIN:CC_SetLimit(PLAYER, ARGS)
		
		if (ASS.Config.HasPermission(PLAYER, "sandbox_limits")) then
		
			if (!ARGS[1] || !ARGS[2]) then return end
		
			for k,v in pairs(SandboxVars) do
				if (v.var == ARGS[1]) then
					ASS.Command( ARGS[1], ARGS[2] )		
					return
				end
			end
		
		end
	
	end

end

if (CLIENT) then

	function PLUGIN:Activate()
		usermessage.Hook( "ASS:SandBox.Limit.Init", function(UM) self:InitLimitInfo(UM) end )
		usermessage.Hook( "ASS:SandBox.Limit.Info", function(UM) self:RecieveLimitInfo(UM) end )
		usermessage.Hook( "ASS:SandBox.Limit.GUI", function(UM) self:ShowLimitGUI(UM) end )
		self.Info = {}
		self.Cats = {}
	end
	
	function PLUGIN:InitLimitInfo(UM)
		self.Info = {}
		self.Cats = {}
		local count = UM:ReadLong()
		
		ASS.Progress.Init( "ASS_Sandbox_Limits", "Downloading limit information...", count )
	end
	
	function PLUGIN:RecieveLimitInfo(UM)
		local cat = UM:ReadString()
		local text = UM:ReadString()
		local var = UM:ReadString()
		local value = UM:ReadString()
		
		if (!self.Cats[cat]) then
			self.Cats[cat] = { name=cat, list = {} }
			table.insert(self.Info, self.Cats[cat])
		end
		
		table.insert(self.Cats[cat].list, { text=text, var=var, value=value } )

		ASS.Progress.Increment( "ASS_Sandbox_Limits", 1 )
	end

	function PLUGIN:ShowLimitGUI(UM)
		
		ASS.Progress.Remove( "ASS_Sandbox_Limits" )
		
		local TE = vgui.Create("DChangeLimitsFrame")
		for cidx,cat in pairs(self.Info) do
			TE:AddCategory( cat.name, cidx==1 )
			for k,v in pairs(cat.list) do
				TE:AddVar( v.text, v.var, v.value )
			end
		end
		TE:SetBackgroundBlur( true )
		TE:SetDrawOnTop( true )
		TE:SetTitle("Change Limits...")
		TE:SetWide(250)
		TE:PerformLayout()
		TE:Center()
		TE:MakePopup()	

	end

	function PLUGIN:BuildGamemodeMenu(MENU)
		if (ASS.Config.HasPermission("sandbox_limits")) then
		
			MENU:AddOption( "Change Limits",
				function()
					self.Info = {}
					self.Cats = {}
					ASS.Command("ASS_Sandbox_Limits_Send")
				end )
		
		end
	end

////////////////////////////////////////////////////////////////////////////////////
// DConVarEditLine
////////////////////////////////////////////////////////////////////////////////////

	PANEL = {}

	function PANEL:Init()

		self.Label = vgui.Create("DLabel", self)
		self.Value = vgui.Create("DTextEntry", self)

	end

	function PANEL:Setup( text, cmd, val )
	
		self.Label:SetText(text)
		self.Value:SetText(val)
		self.InitialValue = val
		self.Command = cmd
	
	end
	
	function PANEL:PerformLayout()

		derma.SkinHook( "Layout", "Panel", self )	
		
		self.Label:SizeToContents()
		self.Label:SetPos( self:GetWide() - 50 - 4 -self.Label:GetWide() - 4, 4)
		
		self.Value:SetWide(50)
		self.Value:SetPos(self:GetWide() - 50 - 4, 4)
		
	end

	derma.DefineControl( "DConVarEditLine", "Convar edit line", PANEL, "Panel" )
	
////////////////////////////////////////////////////////////////////////////////////
// DChangeLimitsFrame
////////////////////////////////////////////////////////////////////////////////////

	PANEL = {}

	function PANEL:Init()

		self.List = vgui.Create("DPanelList", self)
		self.List:EnableVerticalScrollbar()

		self.ApplyButton = vgui.Create("DButton", self)
		self.ApplyButton:SetText("Apply")
		self.ApplyButton.DoClick = function(BTN) self:ApplySettings() end

		self.CancelButton = vgui.Create("DButton", self)
		self.CancelButton:SetText("Cancel")
		self.CancelButton.DoClick = function(BTN) self:Close() end
		
		self.Items = {}
		self.CurrentCategoryList = nil
		
	end
	
	function PANEL:AddCategory( name, expand )
		
		local Category = vgui.Create("DCollapsibleCategory")
		Category:SetLabel( name ) 
		self.List:AddItem(Category)
		
		local CategoryContent = vgui.Create( "DPanelList" ) 
			CategoryContent:SetAutoSize( true ) 
			CategoryContent:SetDrawBackground( false ) 
			CategoryContent:SetSpacing( 0 ) 
			CategoryContent:SetPadding( 5 ) 

		Category:SetExpanded( expand )
		Category:SetContents( CategoryContent ) 
		
		self.CurrentCategoryList = CategoryContent
		
	end

	function PANEL:AddVar( text, cmd, val )
	
		if (!self.CurrentCategoryList) then return end
		
		local Item = vgui.Create("DConVarEditLine")
			Item:Setup( text, cmd, val )

		self.CurrentCategoryList:AddItem(Item)
		table.insert(self.Items, Item)
	
	end
	
	function PANEL:ApplySettings()
		for k,v in pairs(self.Items) do
			local newValue = v.Value:GetValue()
			if (newValue != v.InitialValue) then
				ASS.Command("ASS_Sandbox_Limits_Set", v.Command, newValue )
				v.InitialValue = newValue
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

	derma.DefineControl( "DChangeLimitsFrame", "Frame to change sandbox limits", PANEL, "DFrame" )

end