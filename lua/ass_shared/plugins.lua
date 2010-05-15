
ASS.Plugins = {}
ASS.Plugins.List = {}

function ASS.Plugins.Run( plugin, fnName, ...)

	if (type(plugin[fnName]) == "function") then
	
		local err, ret = PCallError( plugin[fnName], plugin, ... )

		return ret
		
	end

end


function ASS.Plugins.Hook( fnName, defaultResult, ...)

	return ASS.Plugins.HookFiltered(fnName, nil, defaultResult, ...)

end

function ASS.Plugins.GetList( fnFilter )

	local list = {}
	
	for _, info in pairs(ASS.Plugins.List) do
	
		if (fnFilter) then
		
			local err, ret = PCallError( fnFilter, info.plugin )
			if (ret) then
			
				table.insert(list, info.plugin)
			
			end
			
		else
		
			table.insert(list, info.plugin)
		
		end
		
	end

	return list
	
end

function ASS.Plugins.HookSingle( plgnName, fnName, defaultResult, ...)

	for _, info in pairs(ASS.Plugins.List) do
		
		if (info.plugin.Folder == plgnName) then
		
			if (type(info.plugin[fnName]) == "function") then

				local err, ret = PCallError( info.plugin[fnName], info.plugin, ... )

				if (ret != nil) then
					return ret
				end

				return defaultResult
			
			end
			
		end
		
	end	
	
	return defaultResult

end

function ASS.Plugins.HookFiltered( fnName, fnFilter, defaultResult, ...)

	for _, info in pairs(ASS.Plugins.List) do
	
		if (info.enabled) then
		
			if (type(info.plugin[fnName]) == "function") then
			
				local call = true
				if (fnFilter) then
					
					local err, result = PCallError( fnFilter, info.plugin )
					
					if (err || !result) then
						call = false
					end
					
				end
			
				if (call) then
					
					local err, ret = PCallError( info.plugin[fnName], info.plugin, ... )

					if (ret != nil) then

						return ret

					end
					
				end
			
			end
		
		end
	
	end
	
	return defaultResult

end

function ASS.Plugins.CheckGamemode( LIST )

	if (LIST == nil || #LIST == 0) then
		return true
	end

	for k,v in pairs(LIST) do
		local lv = string.lower(v)
		local gm = gmod.GetGamemode()
	
		while (gm) do
			if (string.lower(gm.Name) == lv) then
				return true
			end
		
			gm = gm.BaseClass
		end
	end
	
	return false

end

function ASS.Plugins.Register( NAME, PLUGIN )

	if (!ASS.Plugins.CheckGamemode(PLUGIN.Gamemodes)) then
	
		ASS.Debug("Plugins.Register", "Plugin " .. PLUGIN.Folder .. " not registered: gamemode check failed!")
		return
		
	end

	local info = { enabled = false, plugin = PLUGIN }
	
	ASS.Plugins.List[NAME] = info
	
	ASS.Debug("Plugins.Register", "Plugin " .. PLUGIN.Folder .. " registered!")

	if (SERVER) then
		
		if (PLUGIN.HideDisableOption) then	
			info.enabled = true	
			ASS.Plugins.Run( PLUGIN, "Activate" )
		else
			local default = "0"
			if (PLUGIN.DefaultEnable) then
				default = "1"
			end

			ASS.Config.Register( "plugin_enabled_" .. PLUGIN.Folder, default, 
				function(oldValue, newValue)	
					if (newValue == "1" && !info.enabled) then
						ASS.Plugins.Run( PLUGIN, "Activate" )
					elseif (newValue ~= "1" && info.enabled) then
						ASS.Plugins.Run( PLUGIN, "Deactivate" )
					end
					info.enabled = (newValue == "1")

					umsg.Start("ASS:PluginEnable")
						umsg.String( PLUGIN.Folder )
						umsg.Bool( newValue == "1" )
					umsg.End()
				end )

			ASS.Config.AddMenuItem( "plugin_enabled_" .. PLUGIN.Folder, "Plugins|"..PLUGIN.Name, ASS.Config.Boolean, {"Enabled",1,"Disabled",0} )
		end	
	end

end

function ASS.Plugins.Load()
	
	ASS.Debug("Plugins.Load", "Searching for plugins...")

	for _, folder in pairs( file.FindInLua("ass_plugins/*") ) do
	
		ASS.Debug("Plugins.Load", "Checking " .. folder)
		
		if (folder != "." and folder != ".." and file.IsDir( "../lua/ass_plugins/" .. folder )) then

			ASS.Debug("Plugins.Load", "Plugin " .. folder .. " loaded!")

			PLUGIN_FOLDERNAME = folder
			PLUGIN_FILENAME = "ass_plugins/" .. PLUGIN_FOLDERNAME .. "/init.lua"

			PLUGIN = {}
			PLUGIN.Filename = PLUGIN_FILENAME
			PLUGIN.Folder = folder
			PLUGIN.Name = folder
			PLUGIN.Activate = function() end
			PLUGIN.Deactivate = function() end
			
			include(PLUGIN_FILENAME)
			if (SERVER && PLUGIN.Clientside) then
				AddCSLuaFile(PLUGIN_FILENAME)
			end
			if ((CLIENT && PLUGIN.Clientside) || (SERVER && PLUGIN.Serverside)) then
				ASS.Plugins.Register(folder, PLUGIN)
			end
			PLUGIN = nil
		
		end
	
	end

	if (SERVER) then	
		ASS.IO.PostPluginLoad()
	end

end

ASS.Utils.DoOnInit( ASS.Plugins.Load )

if (SERVER) then

	function ASS.Plugins.LoadFromConfig()
	
		for _, info in pairs(ASS.Plugins.List) do

			if (!info.plugin.HideDisableOption) then
			
				info.enabled = tostring(ASS.Config.Get( "plugin_enabled_" .. info.plugin.Folder )) == "1"
				
				if (info.enabled) then

					ASS.Plugins.Run( info.plugin, "Activate" )

				end
				
			end
			
		end

	end
	ASS.Utils.DoOnInit( ASS.Plugins.LoadFromConfig )
	
	function ASS.Plugins.TellPlayerWhatEnabled( pl )
		
		for _, info in pairs(ASS.Plugins.List) do
		
			umsg.Start("ASS:PluginEnable", pl)
				umsg.String( info.plugin.Folder )
				umsg.Bool( info.enabled )
			umsg.End()
		
		end
	
	end
	
	ASS.Utils.DoOnConnect( ASS.Plugins.TellPlayerWhatEnabled )
	
end

if (CLIENT) then

	function ASS.Plugins.EnableDisablePlugin( UM )
		
		local name = UM:ReadString()
		local en = UM:ReadBool()
		
		if (ASS.Plugins.List[name]) then
		
			ASS.Debug("Plugins.EnableDisablePlugin", "Plugin " .. name .. " set to " .. tostring(en) )

			if (!ASS.Plugins.List[name].enabled && en) then
			
				ASS.Plugins.Run( ASS.Plugins.List[name].plugin, "Activate" )
			
			elseif (ASS.Plugins.List[name].enabled && !en) then
			
				ASS.Plugins.Run( ASS.Plugins.List[name].plugin, "Deactivate" )

			end

			ASS.Plugins.List[name].enabled = en
	
		else
		
			ASS.Debug("Plugins.EnableDisablePlugin", "Plugin " .. name .. " not found [possibly not clientside]" )
		
		end
	
	end
	usermessage.Hook("ASS:PluginEnable", ASS.Plugins.EnableDisablePlugin)
	
end