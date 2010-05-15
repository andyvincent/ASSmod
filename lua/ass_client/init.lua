
local PLAYER = FindMetaTable("Player")
function PLAYER:UniqueID()	return self:GetNetworkedString("ASS_UniqueID")	end
PLAYER = nil

include("ass_client/menu.lua")