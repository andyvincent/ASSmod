PLUGIN.Name = "Sandbox Cleanup"
PLUGIN.Clientside = true
PLUGIN.Serverside = true
PLUGIN.DefaultEnable = true
PLUGIN.Gamemodes = {"sandbox"}

if (SERVER) then

	function PLUGIN:Activate()
		ASS.Config.AddPermission("sandbox_cleanup", "Sandbox|Cleanup", "admin")
		
		concommand.Add("ASS_Sandbox_Cleanup", function(P,C,A) self:CC_Cleanup(P,A) end )
	end
	
	function PLUGIN:Deactivate()
		concommand.Remove("ASS_Sandbox_Cleanup" )
	end

	function PLUGIN:CC_Cleanup(PLAYER, ARGS)
		
		if (ASS.Config.HasPermission(PLAYER, "sandbox_cleanup")) then
		
			if (ARGS[1]) then
			
				local TO_CLEAN = ASS.Utils.FindPlayer( ARGS[1] )

				if (PLAYER:ASS_HasLevel(TO_CLEAN)) then

					cleanup.CC_Cleanup(TO_CLEAN, "", {} )

				end

			else
			
				cleanup.CC_AdminCleanup(PLAYER, "", {} )
			
			end
		
		end
	
	end

end

if (CLIENT) then

	function PLUGIN:Activate()
	end

	function PLUGIN:CleanupServer()
		RunConsoleCommand( "ASS_Sandbox_Cleanup" )
	end

	function PLUGIN:CleanupPlayers(PLAYERLIST)
		for _, pl in pairs(PLAYERLIST) do
			RunConsoleCommand( "ASS_Sandbox_Cleanup", pl:UniqueID() )
		end
	end

	function PLUGIN:BuildGamemodeMenu(MENU)
		if (ASS.Config.HasPermission("sandbox_cleanup")) then
		
			MENU:AddSubMenu( "Cleanup", nil,		
				function(SUBMENU)		
					SUBMENU:AddOption("Entire Server", function() self:CleanupServer() end )
					ASS.Menu.PlayerMenu( SUBMENU, 
						function(PLAYERLIST) 
							self:CleanupPlayers(PLAYERLIST) 
						end,
						{ ASS.Menu.ExcludeAll }
					)
				end
			)
		
		end
	end

end