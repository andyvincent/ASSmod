

ASS.Config = {}
ASS.Config.Values = {}
ASS.Config.Default = {}
if (CLIENT) then
	ASS.Config.ServerValues = {}
end

ASS.Config.String = 0
ASS.Config.Number = 1
ASS.Config.Boolean = 2
ASS.Config.Select = 3
ASS.Config.Group = 4
ASS.Config.RankSelect = 5
ASS.Config.Custom = 6

function ASS.Config.Filename()
	if (CLIENT) then
		return "ass3_config_client.txt"
	end
	if (SERVER) then
		return "ass3_config_server.txt"
	end
end

function ASS.Config.Read()
	
	ASS.Config.RestoreDefault()

	if (file.Exists(ASS.Config.Filename())) then
	
		local cc = file.Read(ASS.Config.Filename())
		local cfg = util.KeyValuesToTable(cc)	
		
		for k,v in pairs(ASS.Utils.FixTable(cfg) ) do
			if (type(v) == "table") then
				ASS.Config.Values[k] = table.Copy(v)
			else
				ASS.Config.Values[k] = v
			end
		end
	
	end

end

function ASS.Config.Write()
	local cfg = util.TableToKeyValues(ASS.Config.Values)	
	file.Write(ASS.Config.Filename(),cfg)
end

function ASS.Config.Set(name, value)
	if (type(name) == "string") then
		name = string.lower(name)
	end
	
	local oldValue = ASS.Config.Values[name]
	ASS.Config.Values[name] = value
	
	if (ASS.Config.Default[name]) then
	
		if (ASS.Config.Default[name].fnOnChange) then
			PCallError( ASS.Config.Default[name].fnOnChange, oldValue, value )
		end

		if (ASS.Config.Default[name].updateClient) then
			umsg.Start("ASS:ConfigVar")
				umsg.String( name )
				umsg.String( value )
			umsg.End()
		end
		
	end
end

function ASS.Config.Get(name, isservervar)
	if (type(name) == "string") then
		name = string.lower(name)
	end
	
	if (CLIENT) then

		if (isservervar) then
			if (ASS.Config.ServerValues[name]) then
				return ASS.Config.ServerValues[name]
			end
		else
			if (ASS.Config.Values[name]) then
				return ASS.Config.Values[name]
			end
		end

	end
	
	if (ASS.Config.Values[name]) then
		return ASS.Config.Values[name]
	end
	
	if (ASS.Config.Default[name]) then
		return ASS.Config.Default[name].value
	end
end

function ASS.Config.RestoreDefault()
	ASS.Config.Values = {}
end

function ASS.Config.Register(name, default, onchange, updateclient)
	if (type(name) == "string") then
		name = string.lower(name)
	end
	
	ASS.Config.Default[name] = { value = default, fnOnChange = onchange, updateClient = updateclient }
end

if (SERVER) then
	function ASS.Config.AddPermission(name, text, default)
		ASS.Config.Register("permission_" .. name, default, nil, true )
		ASS.Config.AddMenuItem("permission_" .. name, "Permissions|"..text, ASS.Config.RankSelect )
	end
end

function ASS.Config.HasPermission(ply, name)
	if (CLIENT) then
		if (name == nil) then
			name = ply
			ply = LocalPlayer()
		end
	end
	
	local reqd = ASS.Config.Get("permission_" .. name, true)
	
	return ply:ASS_HasLevel(reqd)
end

if (CLIENT) then
	
	ASS.Config.GUI = {}
	
	function ASS.Config.UMSG_AddMenuItem(UM)
		local name = UM:ReadString()
		local text = UM:ReadString()
		local mode = UM:ReadChar()
		local data = UM:ReadString()
		
		ASS.Config.AddMenuItem( name, text, mode, string.Explode("|", data), true )
	end
	usermessage.Hook("ASS:AddMenuItem", ASS.Config.UMSG_AddMenuItem )
	
	function ASS.Config.BuildMenu(MENU, LIST)
	
		for key, info in ASS.Utils.SortedPairs(LIST or ASS.Config.GUI) do
		
			if (info.mode == ASS.Config.String) then
			
				MENU:AddOption( info.text, 
						function()

							Derma_StringRequest( "Enter " .. info.text .. "...", 
								info.data[1], 
								ASS.Config.Get(info.name, info.isserver) or "", 
								function( NEWCONFIG ) 
									if (info.isserver) then
										RunConsoleCommand( "ASS_Config_SvVar", info.name, NEWCONFIG )
									else
										RunConsoleCommand( "ASS_Config_ClVar", info.name, NEWCONFIG )
									end
								end 
							)

						end
					)
					
			elseif (info.mode == ASS.Config.Number) then
			
				MENU:AddOption( info.text, 
						function()

							Derma_StringRequest( "Enter " .. info.text .. "...", 
								info.data[1], 
								ASS.Config.Get(info.name, info.isserver) or "", 
								function( NEWCONFIG ) 

									NEWCONFIG = tonumber(NEWCONFIG)
									if (!NEWCONFIG) then
										Derma_Message("Please enter a valid number!",	"Configuration Error!")
										return
									end
									
									if (tonumber(info.data[2]) && NEWCONFIG < tonumber(info.data[2])) then
										Derma_Message("Please enter a number higher then " .. info.data[2],	"Configuration Error!")
										return
									end
									
									if (tonumber(info.data[3]) && NEWCONFIG > tonumber(info.data[3])) then
										Derma_Message("Please enter a number lower then " .. info.data[3],	"Configuration Error!")
										return
									end

									if (info.isserver) then
										RunConsoleCommand( "ASS_Config_SvVar", info.name, NEWCONFIG )
									else
										RunConsoleCommand( "ASS_Config_ClVar", info.name, NEWCONFIG )
									end
								end 
							)
						end
					)
			
			elseif (info.mode == ASS.Config.Boolean) then
				
				MENU:AddSubMenu( info.text, 
						nil,
						function(NEWMENU)
							local ITEMS = {}
							ITEMS[info.data[2] or "1"] = NEWMENU:AddOption( info.data[1] or "Yes",
								function()
									if (info.isserver) then
										RunConsoleCommand( "ASS_Config_SvVar", info.name, info.data[2] or "1" )
									else
										RunConsoleCommand( "ASS_Config_ClVar", info.name, info.data[2] or "1" )
									end
								end )
							ITEMS[info.data[4] or "0"] = NEWMENU:AddOption( info.data[3] or "No",
								function()
									if (info.isserver) then
										RunConsoleCommand( "ASS_Config_SvVar", info.name, info.data[4] or "0" )
									else
										RunConsoleCommand( "ASS_Config_ClVar", info.name, info.data[4] or "0" )
									end
								end )
							local val = ASS.Config.Get(info.name, info.isserver) or ""
							if (ITEMS[val]) then
								ITEMS[val]:SetImage("gui/silkicons/check_on_s")
							end
						end
					)
					
			elseif (info.mode == ASS.Config.Select) then
				MENU:AddSubMenu( info.text, 
						nil,
						function(NEWMENU)
							local ITEMS = {}
							for i=1,#info.data,2 do
								local k = info.data[i]
								local v = info.data[i+1]
								ITEMS[k] = NEWMENU:AddOption( v,
								function()
									if (info.isserver) then
										RunConsoleCommand( "ASS_Config_SvVar", info.name, k )
									else
										RunConsoleCommand( "ASS_Config_ClVar", info.name, k )
									end
								end )
							end
							local val = ASS.Config.Get(info.name, info.isserver) or ""
							if (ITEMS[val]) then
								ITEMS[val]:SetImage("gui/silkicons/check_on_s")
							end
						end
					)
			elseif (info.mode == ASS.Config.RankSelect) then
				MENU:AddSubMenu( info.text, 
						nil,
						function(NEWMENU)
							local ITEMS = {}
							for k,v in pairs(ASS.Groups.LevelsOrdered) do
								ITEMS[v.name] = NEWMENU:AddOption( v.text,
								function()
									if (info.isserver) then
										RunConsoleCommand( "ASS_Config_SvVar", info.name, v.name )
									else
										RunConsoleCommand( "ASS_Config_ClVar", info.name, v.name )
									end
								end )
							end
							local val = ASS.Config.Get(info.name, info.isserver) or ""
							if (ITEMS[val]) then
								ITEMS[val]:SetImage("gui/silkicons/check_on_s")
							end
						end
					)
			elseif (info.mode == ASS.Config.Group) then
				
				MENU:AddSubMenu( info.text, 
						nil,
						function(NEWMENU)
							ASS.Config.BuildMenu(NEWMENU, info.data)
						end
					)
				
			elseif (info.mode == ASS.Config.Custom) then
				
				MENU:AddOption( info.text, function() PCallError( info.data ) end)

			end
		end
	
	end
	
end

function ASS.Config.AddMenuItem(name, text, mode, data, isserver)
	if (CLIENT) then
		if (mode == ASS.Config.Custom) then 
			if (type(data) != "function") then
				ASS.Debug("Config.AddMenuItem","ASS.Config.Custom must be provided with a function to call")
				return
			end
		end
		data = data or {}
		if (type(data) == "table") then
			for k,v in pairs(data) do
				if (type(v) == "string" && #v == 0) then
					data[k] = nil
				end
			end
		end
		
		local split = string.Explode("|", text)
		
		local root = ASS.Config.GUI
		for k,v in pairs(split) do
			if (k == #split) then
				root[v] = { name=name, text=v, mode=mode, data=data, isserver=isserver	}
			else
				root[v] = root[v] or { name=k, text=v, mode=ASS.Config.Group, data={}, isserver=isserver }
				root = root[v].data
			end
		end
	else
		if (mode == ASS.Config.Custom) then ASS.Debug("Config.AddMenuItem","ASS.Config.Custom can only be used clientside") return end
		ASS.Utils.DoNowAndOnConnect(
				function(pl)
					umsg.Start("ASS:AddMenuItem", pl)
						umsg.String( name )
						umsg.String( text )
						umsg.Char( mode )
						umsg.String( table.concat(data or {}, "|") )
					umsg.End()
				end )
		if (ASS.Config.Default[name]) then
			ASS.Config.Default[name].updateClient = true
		end
	end
end

function ASS.Config.ConsoleConfig(PLAYER, COMMAND, ARGS)

	if (SERVER) then
		if (!PLAYER:ASS_HasLevel( ASS.Config.Get("config_change_level") ) ) then
			ASS.Print.Action(PLAYER, "Insufficient access!" )
			return
		end
	end

	local name = string.lower(ARGS[1])
	local data = ARGS[2]
	local dataDef = nil
	local parts = string.Explode(".", name)	
	local write = false

	local defaultRoot = ASS.Config.Default
	local valueRoot = ASS.Config.Values
	local changeFn = nil
	local oldValue = nil
	local updateClient = false

	for k,v in pairs(parts) do
		if (tostring(tonumber(v)) == v) then
			v = tonumber(v)
		end

		local r1isTable = false
		if (defaultRoot == ASS.Config.Default) then
			r1isTable = defaultRoot[v] && type(defaultRoot[v].value) == "table"
			changeFn = defaultRoot[v].fnOnChange
			updateClient = defaultRoot[v].updateClient
		else
			r1isTable = type(defaultRoot[v]) == "table"
		end
		local r2isTable = type(valueRoot[v]) == "table"

		if (r1isTable && r2isTable) then
			defaultRoot = defaultRoot[v].value										
			valueRoot = valueRoot[v]
		elseif (!r1isTable && !r2isTable) then
			if (data) then
				oldValue = valueRoot[v]
				valueRoot[v] = data
				write = true
			else
				data = valueRoot[v]
				dataDef = defaultRoot[v].value
			end
			break
		end

	end

	if (write) then
		ASS.Config.Write()

		if (changeFn) then
			PCallError( changeFn, oldValue, data )
		end

		if (SERVER) then
			ASS.IO.Log( "config", PLAYER, name .. " changed to " .. tostring(data) )
			
			if (updateClient) then
				umsg.Start("ASS:ConfigVar")
					umsg.String( name )
					umsg.String( tostring(data) )
				umsg.End()
			end
		end
		ASS.Print.Action(PLAYER, name .. " changed to " .. tostring(data) )
	else
		ASS.Print.Console(PLAYER, name .. " is set to " .. tostring(data) .. " (default: " .. tostring(dataDef) .. ")" )
	end

end

if (SERVER) then
	concommand.Add("ASS_Config_SvVar", ASS.Config.ConsoleConfig)
	
	ASS.Config.Register("config_change_level", "serverowner", nil, true )
		
	ASS.Utils.DoOnConnect( 
		function(pl)
			for name,cfg in pairs(ASS.Config.Default) do
				if (cfg.updateClient) then
					umsg.Start("ASS:ConfigVar", pl)
						umsg.String( name )
						umsg.String( ASS.Config.Get(name) )
					umsg.End()
				end
			end
		end )
end
if (CLIENT) then
	concommand.Add("ASS_Config_ClVar", ASS.Config.ConsoleConfig)
	
	usermessage.Hook( "ASS:ConfigVar", 
		function(UM)
			local name = UM:ReadString()
			local val = UM:ReadString()
			
			ASS.Config.ServerValues[name] = val
		end )

	ASS.Config.AddMenuItem("config_change_level", "Config Alter",		ASS.Config.RankSelect,		{},	true)
end

ASS.Utils.DoOnInit( ASS.Config.Read )