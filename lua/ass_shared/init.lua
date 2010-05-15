
function ASS.IncludeShared(fn)
	include(fn)
	if (SERVER) then
		AddCSLuaFile(fn)
	end
end

ASS.IncludeShared("ass_shared/utils.lua")
ASS.IncludeShared("ass_shared/command.lua")
ASS.IncludeShared("ass_shared/debug.lua")
ASS.IncludeShared("ass_shared/resource.lua")
ASS.IncludeShared("ass_shared/print.lua")
ASS.IncludeShared("ass_shared/config.lua")
ASS.IncludeShared("ass_shared/groups.lua")
ASS.IncludeShared("ass_shared/plugins.lua")
ASS.IncludeShared("ass_shared/client_call.lua")
ASS.IncludeShared("ass_shared/countdown.lua")
ASS.IncludeShared("ass_shared/progress.lua")
