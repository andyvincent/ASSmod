
ASS.Utils.AddCSLuaDir("ass_client")
ASS.Utils.AddCSLuaDir("ass_client/vgui")

include("ass_server/io.lua")

ASS.Utils.DoOnConnect( function(PL) PL:SetNetworkedString( "ASS_UniqueID", PL:UniqueID() ) end )

ASS.Resource.SendMaterialDir( "materials/gui/silkicons" )
