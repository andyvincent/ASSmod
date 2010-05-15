PLUGIN.Name = "Sandbox Cleanup"
PLUGIN.Clientside = true
PLUGIN.Serverside = true
PLUGIN.DefaultEnable = true
PLUGIN.Gamemodes = {"sandbox"}

if (SERVER) then

	local function PLAYER_CheckLimit( self, str )

		if (GetConVarNumber( "sbox_admin_nolimits" ) == 1) then
			if (self:IsTempAdmin())	then 
				return true
			end
		end

		return self:ASS_Backup_CheckLimit(str)
	end

	local function PLAYER_GetCount( self, str, minus )

		if (GetConVarNumber( "sbox_admin_nolimits" ) == 1) then
			if (self:IsTempAdmin())	then 
				if (minus) then
					return 1
				else 
					return -1
				end
			end
		end

		return self:ASS_Backup_GetCount(str, minus)

	end
	
	local function SendConVarValue( PLAYER, NAME, VALUE )
		
		umsg.Start( "ASS:SandBox.Option", PLAYER )
			umsg.String( NAME	)
			umsg.Short(	tonumber(VALUE) 	)
		umsg.End()

	end
	local function SendConVarValueChange( name, oldvalue, newvalue )
		SendConVarValue( nil, name, newvalue )
	end
	
	function PLUGIN:Activate()
		ASS.Config.AddPermission("sandbox_options", "Sandbox|Options", "admin")
		
		// !!! Fix Gmod bug !!!
		if (!ConVarExists("sbox_weapons")) then
			CreateConVar( "sbox_weapons", "1", FCVAR_NOTIFY )
		end

		// !!! Add functionality !!!
		if (!ConVarExists("sbox_admin_nolimits")) then
			CreateConVar( "sbox_admin_nolimits", "0", FCVAR_NOTIFY )
		end

		concommand.Add("ASS_Sandbox_Options_Send", function(P,C,A) self:CC_SendOptions(P,A) end )
		concommand.Add("ASS_Sandbox_Options_Set", function(P,C,A) self:CC_SetOption(P,A) end )
		
		if (!self.Options) then
			self.Options = {}
			
			table.insert( self.Options, 		"sbox_godmode"				 )
			table.insert( self.Options, 		"sbox_plpldamage"			 )
			table.insert( self.Options, 		"sbox_weapons"				 )
			table.insert( self.Options, 		"sbox_noclip"				 )
			table.insert( self.Options, 		"sbox_admin_nolimits"	 )
		
			for _,opt in pairs(self.Options) do
				umsg.PoolString(opt)
				cvars.AddChangeCallback(opt, SendConVarValueChange )
			end
		end

		local META = FindMetaTable("Player")
		if (!META.ASS_Backup_CheckLimit) then		META.ASS_Backup_CheckLimit = META.CheckLimit	end
		if (!META.ASS_Backup_GetCount) then			META.ASS_Backup_GetCount = META.GetCount		end
		META.CheckLimit = PLAYER_CheckLimit
		META.GetCount = PLAYER_GetCount
	end
	
	function PLUGIN:Deactivate()
		concommand.Remove("ASS_Sandbox_Options_Send" )
		concommand.Remove("ASS_Sandbox_Options_Set" )

		local META = FindMetaTable("Player")
		if (META.ASS_Backup_CheckLimit) then		META.CheckLimit = META.ASS_Backup_CheckLimit	end
		if (META.ASS_Backup_GetCount) then			META.GetCount = META.ASS_Backup_GetCount		end
	end

	function PLUGIN:CC_SendOptions(PLAYER, ARGS)

		for k,v in pairs(self.Options) do
			SendConVarValue( PLAYER, v, GetConVarNumber(v) )
		end
	
	end

	function PLUGIN:CC_SetOption(PLAYER, ARGS)
		
		if (ASS.Config.HasPermission(PLAYER, "sandbox_options")) then
		
			if (!ARGS[1] || !ARGS[2]) then return end
		
			for k,v in pairs(self.Options) do
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
		usermessage.Hook( "ASS:SandBox.Option", function(UM) self:RecieveOptionInfo(UM) end )
		self.Info = {}
     	ASS.Command("ASS_Sandbox_Options_Send")	
	end
	
	function PLUGIN:RecieveOptionInfo(UM)
		local var = UM:ReadString()
		self.Info[var] = UM:ReadShort()
	end
	
	function PLUGIN.ChangeOption(CMD, VAL)

		ASS.Command("ASS_Sandbox_Options_Set", CMD, VAL)

	end
	
	function PLUGIN:OnOffMenu(MENU, CMD, ON_VAL, OFF_VAL, ON_TXT, OFF_TXT)
	
		local Items = {}

		Items[ON_VAL] = MENU:AddOption( 	ON_TXT or "Yes",	function() PLUGIN:ChangeOption(CMD, tostring(ON_VAL)) end 	)
		Items[OFF_VAL] = MENU:AddOption(	OFF_TXT or "No",	function() PLUGIN:ChangeOption(CMD, tostring(OFF_VAL)) end	)

		if (self.Info[CMD] && Items[ self.Info[CMD] ]) then
			Items[ self.Info[CMD] ]:SetImage("gui/silkicons/check_on_s")
		end
		
	end

	
	function PLUGIN:BuildGamemodeMenu(MENU)

		MENU:AddSubMenu( "Give weapons", 			nil, function(SUBMENU) self:OnOffMenu(SUBMENU, "sbox_weapons", 			1, 0 ) end )
		MENU:AddSubMenu( "Allow Player damage",	nil, function(SUBMENU) self:OnOffMenu(SUBMENU, "sbox_godmode", 			0, 1 ) end )
		MENU:AddSubMenu( "Allow PvP Damage",		nil, function(SUBMENU) self:OnOffMenu(SUBMENU, "sbox_plpldamage", 		0, 1 ) end )
		MENU:AddSubMenu( "Allow Noclip",				nil, function(SUBMENU) self:OnOffMenu(SUBMENU, "sbox_noclip", 				1, 0 ) end )
		MENU:AddSubMenu( "Admin has no limits",	nil, function(SUBMENU) self:OnOffMenu(SUBMENU, "sbox_admin_nolimits",	1, 0 ) end )

	end

end