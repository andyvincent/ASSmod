
ASS = {}

include("ass_shared/init.lua")
if (CLIENT) then	include("ass_client/init.lua")	end
if (SERVER) then	include("ass_server/init.lua")	end

