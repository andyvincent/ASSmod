
PLUGIN.Name = "Test"
PLUGIN.Clientside = true
PLUGIN.Serverside = true

function PLUGIN:Activate()

	Msg("TEST ACTIVATE\n")

	if (SERVER) then
		ASS.Config.Register("server_var_1", "text")
		ASS.Config.Register("server_var_2", "0")
		ASS.Config.Register("server_var_3", "yes")
		ASS.Config.Register("server_var_4", "sel1")

		ASS.Config.AddMenuItem("server_var_1", "Server Var 1", ASS.Config.String, {"Enter Variable 1:"})
		ASS.Config.AddMenuItem("server_var_2", "Server Var 2", ASS.Config.Number, {"Enter Variable 2:", 0, 10})
		ASS.Config.AddMenuItem("server_var_3", "Server Var 3", ASS.Config.Boolean)
		ASS.Config.AddMenuItem("server_var_4", "Server Var 4", ASS.Config.Select, {"sel1","Item1","sel2","Item2","sel3","Item3"})


		ASS.Config.AddMenuItem("server_var_2", "SubTest|Server Var 2", ASS.Config.String, {"Enter Variable 2:"})
		ASS.Config.AddMenuItem("server_var_4", "SubTest|Server Var 4", ASS.Config.String, {"Enter Variable 4:"})

		ASS.Config.AddMenuItem("server_var_4", "Level|Server Var 4", ASS.Config.RankSelect)
	end

	if (CLIENT) then
		ASS.Config.Register("client_var_1", "text")
		ASS.Config.Register("client_var_2", "0")
		ASS.Config.Register("client_var_3", "yes")
		ASS.Config.Register("client_var_4", "sel1")

		ASS.Config.AddMenuItem("client_var_1", "Client Var 1", ASS.Config.String, {"Enter Variable 1:"})
		ASS.Config.AddMenuItem("client_var_2", "Client Var 2", ASS.Config.Number, {"Enter Variable 2:", 0, 10})
		ASS.Config.AddMenuItem("client_var_3", "Client Var 3", ASS.Config.Boolean)
		ASS.Config.AddMenuItem("client_var_4", "Client Var 4", ASS.Config.Select, {"sel1","Item1","sel2","Item2","sel3","Item3"})
	end

end

function PLUGIN:BuildPluginMenu( MENU )

	MENU:AddOption("Item Test", function() print("plugin test") end )
	MENU:AddSubMenu("Player Test 1", nil, 
		function(NEWMENU) 
			ASS.Menu.PlayerMenu(NEWMENU,
				function(PLAYERLIST)
					print("player test:")
					for _,pl in pairs(PLAYERLIST) do
						print(pl)
					end
					print("/end")
				end)
		end)
					

end

function PLUGIN:BuildGamemodeMenu( MENU )

	MENU:AddOption("Item Test", function() print("gamemode test") end )

end

function PLUGIN:BuildMainMenu( MENU )

	MENU:AddOption("Item Test", function() print("main test") end )

end