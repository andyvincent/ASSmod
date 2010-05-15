PLUGIN.Name = "Map Change"
PLUGIN.Clientside = true
PLUGIN.Serverside = true
PLUGIN.HideDisableOption = true

if (SERVER) then

	function PLUGIN:Activate()
		local maps = file.Find("../maps/*.bsp")

		self.MapList = {}
		for k,v in pairs(maps) do
			if (!file.IsDir("../maps/" .. v)) then
				local map = string.gsub( string.lower( v ), ".bsp", "")
				table.insert( self.MapList, map )
			end	
		end
		table.sort(self.MapList, function(a,b) return a < b end )

		self.Gamemodes = {}
		local gamemodes = file.Find("../gamemodes/*")
		for k,v in pairs(gamemodes) do
			if (file.IsDir("../gamemodes/" .. v)) then
				if (file.Exists( "../gamemodes/" .. v .. "/info.txt")) then

					local gamemode_info = util.KeyValuesToTable( file.Read(	"../gamemodes/" .. v .. "/info.txt") )			

					if (gamemode_info["hide"] != "1") then
					
						gamemode_info.folder = v
						
						table.insert( self.Gamemodes, gamemode_info )

					end

				end
			end
		end
		table.sort(self.Gamemodes, function(a,b) return a.folder < b.folder end )
		
		ASS.Config.AddPermission("change_map", "Change Map", "admin")
		
		concommand.Add("ASS_Map_Change", function(P,C,A) self:CC_ChangeMap(P,A) end )
		concommand.Add("ASS_Map_Abort", function(P,C,A) self:CC_ChangeMap(P,A) end )
		concommand.Add("ASS_Map_List", function(P,C,A) self:CC_SendMapList(P,A) end )
	end
	
	function PLUGIN:Deactivate()
		concommand.Remove("ASS_Map_Change" )
		concommand.Remove("ASS_Map_Abort" )
		concommand.Remove("ASS_Map_List")
	end

	function PLUGIN:SendMapList(PL)

		umsg.Start("ASS:MapChange.Start", PL)
			umsg.String( game.GetMap() )
			umsg.Long( #self.MapList )
			umsg.Long( table.Count(self.Gamemodes) )
		umsg.End()
		
		timediff = 0
		for k,v in pairs(self.MapList) do

			timer.Simple( timediff, 
				function()
					if (PL:IsValid()) then
						umsg.Start("ASS:MapChange.Map", PL)
							umsg.String( v )
						umsg.End()
					end
				end )

			timediff = timediff + 0.01

		end

		timediff = 0
		for k,v in pairs(self.Gamemodes) do

			timer.Simple( timediff, 
				function()
					if (PL:IsValid()) then
						umsg.Start("ASS:MapChange.GM", PL)
							umsg.String( v["folder"] )
							umsg.String( v["name"] )
						umsg.End()
					end
				end )

			timediff = timediff + 0.01

		end		

	end
	
	function PLUGIN:ActualDoChangeMap(MAP,GAMEMODE)

		if (!GAMEMODE || #GAMEMODE == 0) then
			ASS.Command("changelevel " .. MAP .. "\n")
		else
			ASS.Command("changegamemode " .. MAP .. " " .. GAMEMODE .. "\n")
		end

	end
	
	function PLUGIN:CC_ChangeMap(PLAYER, ARGS)
		
		if (ASS.Config.HasPermission(PLAYER, "change_map")) then
		
			PrintTable(ARGS)
		
			local MAP = ARGS[1]
			local TIME = tonumber(ARGS[2])
			local GAMEMODE = ARGS[3]
				
			if (!MAP || !TIME) then
				return
			end
		
			ASS.IO.Log( "map", PLAYER, "scheduled a map change to " .. MAP .. " in " .. TIME .. " seconds" )
			ASS.Countdown.InitAll( "MapChange", "Map change to " .. MAP, TIME )
			timer.Create( "ASS:MapChange", TIME, 1, function() self:ActualDoChangeMap( MAP, GAMEMODE ) end )
		
		end
	
	end

	function PLUGIN:CC_AbortChangeMap(PLAYER, ARGS)

		if (ASS.Config.HasPermission(PLAYER, "change_map")) then
		
			ASS.IO.Log( "map", PLAYER, "map change aborted" )
			ASS.Countdown.RemoveAll( "MapChange" )
			timer.Remove( "ASS:MapChange" )

		end

	end
	
	function PLUGIN:CC_SendMapList(PLAYER, ARGS)
	
		self:SendMapList(PLAYER)
	
	end

end

if (CLIENT) then

	local function defaultTimeList()
		return	{
						{	txt = "30 Seconds",		time = 30		},
						{	txt = "1 Minute",			time = 60		},
						{	txt = "3 Minutes",		time = 3*60		},
						{	txt = "5 Minutes",		time = 5*60		},
						{	txt = "10 Minutes",		time = 10*60	},
						{	txt = "15 Minutes",		time = 15*60	},
						{	txt = "20 Minutes",		time = 20*60	},
						{	txt = "30 Minutes",		time = 30*60	},
						{	txt = "1 Hour",			time = 60*60	},
						{	txt = "2 Hours",			time = 2*60*60	},
					}	
	end

	function PLUGIN:Activate()
		usermessage.Hook("ASS:MapChange.Start", function(UM) self:StartRecieveLists(UM) end )
		usermessage.Hook("ASS:MapChange.Map", function(UM) self:RecieveMap(UM) end )
		usermessage.Hook("ASS:MapChange.GM", function(UM) self:RecieveGamemode(UM) end )
		
		ASS.Config.Register("map_favourites", {} )
		ASS.Config.Register("map_timelist", defaultTimeList() )
		
		ASS.Command("ASS_Map_List")
	end

	function PLUGIN:StartRecieveLists(UM)

		self.CurrentMap = UM:ReadString()
		self.MapListCount = UM:ReadLong()
		self.GamemodeListCount = UM:ReadLong()

		self.MapList = {}
		self.GamemodeList = {}

		ASS.Progress.Init("MapChange.Map", "Recieving Map List", self.MapListCount )
		ASS.Progress.Init("MapChange.GM", "Recieving Gamemode List", self.GamemodeListCount )
	end

	function PLUGIN:RecieveMap(UM)
		table.insert( self.MapList, UM:ReadString() )
		ASS.Progress.Increment("MapChange.Map", 1 )
		if (#self.MapList == self.MapListCount) then
			self.MapListCount = nil
			ASS.Progress.Remove("MapChange.Map")
		end
	end

	function PLUGIN:RecieveGamemode(UM)
		table.insert( self.GamemodeList, { name = UM:ReadString(), text = UM:ReadString() } )
		ASS.Progress.Increment("MapChange.GM", 1 )
		if (#self.GamemodeList == self.GamemodeListCount) then
			self.GamemodeListCount = nil
			ASS.Progress.Remove("MapChange.GM")
		end
	end
	
	function PLUGIN:AddToFavourites(MAPNAME)
		local favList = ASS.Config.Get("map_favourites")
		if (type(favList) != "table") then
			favList = {}
		end
		
		local found = false
		for k,v in pairs(favList) do
			if (v.map == MAPNAME) then
				v.count = v.count + 1
				found = true
			end
		end
		if (#favList < 10 && !found) then
			table.insert(favList, {map=MAPNAME, count=1})
		end
		table.sort( favList, function(a,b) return (a.count > b.count) end )
		
		ASS.Config.Set("map_favourites", favList)
		ASS.Config.Write()
	end
	
	function PLUGIN:ChangeMap(TIME, MAPNAME, GAMEMODE)
	
		if (MAPNAME == ":custom:") then
			
				Derma_StringRequest( "Map...", 
					"Which map do you want to switch to?", 
					self.CurrentMap, 
					function( strTextOut ) 
						self:ChangeMap(TIME, strTextOut, GAMEMODE)
					end 
				)

			return
		end
	
		self:AddToFavourites(MAPNAME)
		if (GAMEMODE) then
			ASS.Command("ASS_Map_Change", MAPNAME, TIME, GAMEMODE)
		else
			ASS.Command("ASS_Map_Change", MAPNAME, TIME)
		end
	end

	function PLUGIN:TimeMenu(MENU, MAPNAME, GAMEMODE)
		
		local timeList = ASS.Config.Get("map_timelist")
		if (type(timeList) != "table" or #timeList == 0) then
			timeList = defaultTimeList()
			ASS.Config.Set("map_timelist", timeList)
			ASS.Config.Write()
		end
	
		MENU:AddOption( "Now", function() self:ChangeMap(0, MAPNAME, GAMEMODE) end )
		MENU:AddSpacer()
		for k,v in pairs(timeList) do
			MENU:AddOption( v.txt, function() self:ChangeMap(v.time, MAPNAME, GAMEMODE) end )
		end
		
	end
	
	function PLUGIN:FavouriteMenu(MENU, GAMEMODE)
	
		local favList = ASS.Config.Get("map_favourites")
		if (type(favList) != "table") then
			favList = {}
			ASS.Config.Set("map_favourites", favList)
			ASS.Config.Write()
		end
		
		for k,v in pairs(favList) do
			MENU:AddSubMenu( v.map,		nil,	function(SUBMENU) self:TimeMenu(SUBMENU, v.map, GAMEMODE) end )
		end
	end

	function PLUGIN:BuildMapMenu(MENU, GAMEMODE)
		if (self.MapListCount) then
			MENU:AddOption("Downloading Map List...", function() end )
			return
		end
		
		MENU:AddSubMenu("Current Map",		nil,	function(SUBMENU) self:TimeMenu(SUBMENU, self.CurrentMap, GAMEMODE) end )
		MENU:AddSubMenu("Custom Map...",		nil,	function(SUBMENU) self:TimeMenu(SUBMENU, ":custom:", GAMEMODE) end )
		MENU:AddSubMenu("Favourite",			nil,	function(SUBMENU) self:FavouriteMenu(SUBMENU, GAMEMODE) end )
		MENU:AddSpacer()
		for k,v in pairs(self.MapList) do
			MENU:AddSubMenu( v,					nil,	function(SUBMENU) self:TimeMenu(SUBMENU, v, GAMEMODE) end )
		end
		
	end

	function PLUGIN:BuildGamemodeListMenu(MENU)

		if (self.GamemodeListCount) then
			MENU:AddOption("Downloading Gamemode List...", function() end )
			return
		end

		for k,v in pairs(self.GamemodeList) do

			MENU:AddSubMenu( v.text, nil, 
				function(SUBMENU)
					self:BuildMapMenu( SUBMENU, v.name )
				end )

		end
	end

	function PLUGIN:BuildMainMenu(MENU)
		if (ASS.Config.HasPermission("change_map")) then
		
			MENU:AddSubMenu( "Change Map", nil,
				function(SUBMENU)
					self:BuildGamemodeListMenu(SUBMENU)
					SUBMENU:AddSpacer()
					self:BuildMapMenu(SUBMENU)
				end )
			MENU:AddOption( "Abort Change Map", function() ASS.Command("ASS_Map_Abort") end )
		
		end
	end

end