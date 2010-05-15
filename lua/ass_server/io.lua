
ASS.IO = {}
ASS.IO.InfoParts = {}

function ASS.IO.Log(LEVEL, ACTOR, TEXT)

	ASS.Plugins.HookSingle( ASS.Config.Get("log_output"), "Log", LEVEL, ACTOR, TEXT )

end

function ASS.IO.RegisterPlayerInfoPart(NAME, fnSET, fnGET)
	
	ASS.IO.InfoParts[ NAME ] = { set = fnSET, get = fnGET }
	
end

function ASS.IO.RetrievePlayerInfo( ID )
	return ASS.Plugins.HookSingle( ASS.Config.Get("player_info_io"), "OpenPlayerInfo", {}, ID )
end
function ASS.IO.StorePlayerInfo( ID, TAB )
	ASS.Plugins.HookSingle( ASS.Config.Get("player_info_io"), "SavePlayerInfo", nil, ID, TAB )
end

function ASS.IO.LoadPlayerInfo(PLY)

	local tab = ASS.IO.RetrievePlayerInfo( PLY:ASS_CleanUniqueId() )
	
	if (type(tab) != "table") then tab = {} end

	for key, fns in pairs(ASS.IO.InfoParts) do
		fns.set(PLY, tab[key])
	end

end

function ASS.IO.SavePlayerInfo(PLY)

	local tab = {}
	for key, fns in pairs(ASS.IO.InfoParts) do
		tab[key] = fns.get(PLY)
	end

	ASS.IO.StorePlayerInfo( PLY:ASS_CleanUniqueId(), tab )

end

function ASS.IO.PostPluginLoad()
	
	local io_plugins = ASS.Plugins.GetList( function(plgn)
							return (plgn.OpenPlayerInfo && plgn.SavePlayerInfo) || plgn.LogInfo
						end )

	local loadsave_options = {}
	local log_options = {}
	for _, plgin in pairs(io_plugins) do
		if (plgin.OpenPlayerInfo && plgin.SavePlayerInfo) then
			table.insert(loadsave_options, plgin.Folder)
			table.insert(loadsave_options, plgin.Name)
		end
		if (plgin.LogInfo) then
			table.insert(log_options, plgin.Folder)
			table.insert(log_options, plgin.Name)
		end
	end
	
	ASS.Config.AddMenuItem("player_info_io",	"Load/Save",	ASS.Config.Select, loadsave_options,	true)
	ASS.Config.AddMenuItem("log_output",		"Logging",		ASS.Config.Select, log_options,		true)

end

ASS.Config.Register("player_info_io", "text_io")
ASS.Config.Register("log_output", "text_io")

hook.Add("PlayerInitialSpawn", "ASS.IO.LoadPlayerInfo", ASS.IO.LoadPlayerInfo)