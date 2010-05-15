
ASS.Groups = {}
ASS.Groups.Levels = {}

function ASS.Groups.IsValid( name )
	if (!ASS.Groups.Levels[name]) then
		return false
	else
		return true
	end
end

function ASS.Groups.LevelMeetsRequired( current, required )

	if (!ASS.Groups.Levels[current]) then
		return false
	end
	if (!ASS.Groups.Levels[required]) then
		return false
	end
	
	return (ASS.Groups.Levels[current].level >= ASS.Groups.Levels[required].level)

end

if (SERVER) then

	function ASS.Groups.Register(name, display, level)

		ASS.Groups.Levels[name] = {text = display, level = level}
		
		ASS.Utils.DoNowAndOnConnect( 
			function(pl)
				umsg.Start("ASS:GroupRegister", pl)
					umsg.String(name)
					umsg.String(display)
					umsg.Long(level)
				umsg.End()
			end )

	end
	
	ASS.Utils.DoOnInit( 
		function()
			ASS.IO.RegisterPlayerInfoPart(
					"rank",
					function( PLY, VALUE )
						if (!VALUE) then
							PLY:ASS_InitLevel()
						else
							PLY:ASS_SetLevel( VALUE or "user" )		
						end
					end,
					function( PLY)		
						return PLY:GetNetworkedString( "UserGroup" )
					end
				)
		end )
	
end

if (CLIENT) then

	ASS.Groups.LevelsOrdered = {}

	usermessage.Hook("ASS:GroupRegister", 
		function(UM)
			local name = UM:ReadString()
			local display = UM:ReadString()
			local level = UM:ReadLong()
			ASS.Groups.Levels[name] = {name = name, text = display, level = level}
			table.insert(ASS.Groups.LevelsOrdered, ASS.Groups.Levels[name] )
			table.sort(ASS.Groups.LevelsOrdered, function(a,b) return a.level > b.level end )
		end )

end

if (SERVER) then

	ASS.Groups.Register("serverowner",	"Server Owner", 10000)
	ASS.Groups.Register("superadmin",	"Super Admin",	1000)
	ASS.Groups.Register("admin",		"Admin",	100)
	ASS.Groups.Register("respected",	"Respected",	10)
	ASS.Groups.Register("user",		"User",		0)
	
	ASS.Utils.DoOnConnect(	function (PLY)
										PLY:SetNetworkedString( "ASS_ID", PLY:ASS_UniqueId() )
										PLY:ASS_InitLevel()
										ASS.IO.LoadPlayerInfo(PLY)
									end )

end

local PLAYER_META = FindMetaTable("Player")

function PLAYER_META:IsSuperAdmin()	return self:ASS_HasLevel("superadmin") 	end
function PLAYER_META:IsAdmin()		return self:ASS_HasLevel("admin") 	end
function PLAYER_META:ASS_HasLevel(lvl)	
	if ( !self:IsValid() ) then return false end 
 	local group = self:GetNetworkedString( "UserGroup" )
 	return ASS.Groups.LevelMeetsRequired( group, lvl)
end

if (SERVER) then
function PLAYER_META:ASS_SetLevel(lvl)	
	if ( !self:IsValid() ) then return end 
 	self:SetNetworkedString( "UserGroup", lvl )
 	ASS.IO.SavePlayerInfo(self)
end
end

function PLAYER_META:ASS_GetLevel()	
	if ( !self:IsValid() ) then return "" end 
 	local group = self:GetNetworkedString( "UserGroup" )
 	return group
end
function PLAYER_META:ASS_UniqueId()		

	if (SERVER) then
		if (ASS.Utils.IsLan()) then	return self:IPAddress()
		else									return self:SteamID()
		end
	else
		return self:GetNetworkedString( "ASS_ID" )
	end

end
function PLAYER_META:ASS_CleanUniqueId()		

	local id = "ASS_"
	
	if (ASS.Utils.IsLan()) then
	
		id = "IP_" .. self:ASS_UniqueId()
	
	else
	
		id = "ID_" .. self:ASS_UniqueId()
	
	end
	
	id = string.gsub(id, "STEAM_", "")
	id = string.gsub(id, ":", "_")
	id = string.gsub(id, ".", "_")
	
	return id
end
function PLAYER_META:ASS_InitLevel()

	if (SinglePlayer() || self:IsListenServerHost()) then
		
		self:ASS_SetLevel( "serverowner" )
		
	else
	
		self:ASS_SetLevel( "user" )
	
	end

end
