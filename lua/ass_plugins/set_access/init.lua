
PLUGIN.Name = "Set Access"
PLUGIN.Clientside = true
PLUGIN.Serverside = true

PLUGIN.HideDisableOption = true

if (SERVER) then

//////////////////////////////////////////////////////////////////////
////////////SERVER SIDE///////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

function PLUGIN:Activate()

	ASS.Config.AddPermission("player_promote_demote", "Promte/Demote", "serverowner")
	concommand.Add("ASS_SetAccess",		function(PLY, CMD, ARGS) self:CC_SetAccess(PLY,ARGS) end )
	concommand.Add("ASS_SetAccessManual",	function(PLY, CMD, ARGS) self:CC_SetAccess(PLY,ARGS) end )

end

function PLUGIN:Deactivate()
	concommand.Remove("ASS_SetAccess")
	concommand.Remove("ASS_SetAccessManual")
end

function PLUGIN:CC_SetAccess(ACTIVATOR, ARGS)

	if (ASS.Config.HasPermission(ACTIVATOR, "player_promote_demote")) then
		
		local LEVEL = ARGS[2]

		local TO_CHANGE = ASS.Utils.FindPlayer( ARGS[1] )
		if (!ValidEntity(TO_CHANGE)) then
			ASS.Print.Action(ACTIVATOR, "Player not found!" )
			return	
		end

		if (!ASS.Groups.Levels[LEVEL]) then
			ASS.Print.Action(ACTIVATOR, "Invalid rank!" )
			return
		end

		if (TO_CHANGE:ASS_HasLevel(ACTIVATOR:ASS_GetLevel()) || TO_CHANGE:ASS_GetLevel() == ACTIVATOR:ASS_GetLevel()) then
			ASS.Print.Action(ACTIVATOR, "Access denied (player has higher or equal access)" )
			return
		end

		TO_CHANGE:ASS_SetLevel( LEVEL )
		ASS.Print.Action(ACTIVATOR, "Changed " .. ASS.Utils.PlayerName(TO_CHANGE) .. " to " .. ASS.Groups.Levels[LEVEL].text, "rank_change" )
	
	end
	
end

function PLUGIN:CC_SetAccessManual(ACTIVATOR, ARGS)

	if (ASS.Config.HasPermission(ACTIVATOR, "player_promote_demote")) then
	
		local LEVEL = ARGS[2]

		local TO_CHANGE = ASS.Utils.FindPlayer( ARGS[1] )
		if (ValidEntity(TO_CHANGE)) then
			ASS.Print.Action(ACTIVATOR, "Player found, can't manually change level!" )
			return	
		end

		if (!ASS.Groups.Levels[LEVEL]) then
			ASS.Print.Action(ACTIVATOR, "Invalid rank!" )
			return
		end

		local info = ASS.IO.RetrievePlayerInfo( ARGS[1] ) or {}
		info.rank = LEVEL
		ASS.IO.StorePlayerInfo( ARGS[1], info )

	end

end


end

if (CLIENT) then

//////////////////////////////////////////////////////////////////////
////////////CLIENT SIDE///////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

function PLUGIN:RankMenu( MENU, PLAYERLIST )

	local ITEMS = {}
	
	for k,v in pairs(ASS.Groups.LevelsOrdered) do
		ITEMS[v.name] = MENU:AddOption(
			v.text,
			function()
				for _, pl in pairs(PLAYERLIST) do
					RunConsoleCommand( "ASS_SetAccess", pl:UniqueID(), v.name )
				end
			end )
	end
	
	if (#PLAYERLIST == 1) then
		
		local lvl = PLAYERLIST[1]:ASS_GetLevel()
		if (ITEMS[ lvl ]) then
			ITEMS[lvl]:SetImage("gui/silkicons/check_on_s")
		end
	
	end
	
end

function PLUGIN:PlayerAddManual()
end

function PLUGIN:SetAccessMenu(MENU)

	MENU:AddOption( "Add Manually...",
		function()
			self:PlayerAddManual()
		end )
	
	ASS.Menu.PlayerMenu(MENU, 
			function(SUBMENU, PLAYERLIST)
				self:RankMenu(SUBMENU, PLAYERLIST)
			end,
			{ ASS.Menu.HasSubMenu, ASS.Menu.ExcludeSelf, ASS.Menu.ExcludeAll, ASS.Menu.ExcludeLevels } )

end


function PLUGIN:BuildMainMenu(MENU, PLAYER)

	if (ASS.Config.HasPermission("player_promote_demote")) then

		MENU:AddSubMenu("Set Access", nil, function(SUBMENU) self:SetAccessMenu(SUBMENU) end ):SetImage( "gui/silkicons/key" )

	end

end

end
