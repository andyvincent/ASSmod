
ASS.Utils = {}

/////////////// Plugable Connect Functions ///////////////

ASS.Utils.DoOnConnectList = {}

function ASS.Utils.DoOnConnect( func )
	table.insert(ASS.Utils.DoOnConnectList, func)
end

function ASS.Utils.DoNowAndOnConnect( func )
	func(nil)
	ASS.Utils.DoOnConnect( func )
end

function ASS.Utils.RunDoNowAndOnConnect( pl )
	for _, func in pairs(ASS.Utils.DoOnConnectList) do
		func( pl )
	end
end
hook.Add( "PlayerInitialSpawn", "ASS:DoNowAndOnConnect", ASS.Utils.RunDoNowAndOnConnect )

/////////////// Plugable Think Functions ///////////////

ASS.Utils.DoOnThinkList = {}

function ASS.Utils.DoOnThink( func )
	table.insert(ASS.Utils.DoOnThinkList, func)
end

function ASS.Utils.RunDoOnThink()
	for _, func in pairs(ASS.Utils.DoOnThinkList) do
		func()
	end
end
hook.Add( "Think", "ASS:DoOnThink", ASS.Utils.RunDoOnThink )

/////////////// Plugable Init Functions ///////////////

ASS.Utils.DoOnInitList = {}

function ASS.Utils.DoOnInit( func )
	table.insert(ASS.Utils.DoOnInitList, func)
end

function ASS.Utils.RunDoOnInit()
	for _, func in pairs(ASS.Utils.DoOnInitList) do
		func()
	end
end
hook.Add( "Initialize", "ASS:DoOnInitialize", ASS.Utils.RunDoOnInit )

///////////////////////////////////////////////////////

function ASS.Utils.AddCSLuaDir( f )
	for k,v in pairs( file.FindInLua(f .. "/*.lua") ) do
		if (!file.IsDir(f .. "/" .. v)) then
			AddCSLuaFile( f .. "/" .. v )
		end
	end
end

function ASS.Utils.FixTable( t )

	local new = {}
	for k,v in pairs(t) do
		
		local newv = v
		if (type(v) == "table") then
			newv = ASS.Utils.FixTable(v)
		end

		if (tostring(tonumber(k)) == k) then
			new[tonumber(k)] = newv
		else
			new[k] = newv
		end
		
	end
	return new

end

if (SERVER) then
function ASS.Utils.FindPlayer( whatever )

	if (!whatever) then return NULL end
	
	local pl_list = player.GetAll()
	
	for _, pl in pairs(pl_list) do
		
		if (	pl:UniqueID() == whatever		||
			pl:ASS_UniqueId() == whatever		||
			pl:ASS_CleanUniqueId() == whatever	||
			pl:SteamID() == whatever		||
			pl:IPAddress() == whatever		||
			pl:UserID() == whatever			||
			string.lower(pl:Nick()) == string.lower(whatever)) then
			
			return pl
			
		end
		
	end
	
	return NULL

end
	
function ASS.Utils.HurtPlayer( PLAYER, DAMAGE )
	if (DAMAGE <= 0) then return end
	if (!ValidEntity(PLAYER)) then return end
	
	local newHealth = PLAYER:Health() - DAMAGE

	if (newHealth <= 0) then
		PLAYER:SetHealth(0)
		PLAYER:Kill()
	else
		PLAYER:SetHealth(newHealth)
	end
end
end

local function fnPairsSorted( pTable, Index ) 
   
 	if ( Index == nil ) then 
 	 
 		Index = 1 
 	 
 	else 
 	 
 		for k, v in pairs( pTable.__SortedIndex ) do 
 			if ( v == Index ) then 
 				Index = k + 1 
 				break 
 			end 
 		end 
 		 
 	end 
 	 
 	local Key = pTable.__SortedIndex[ Index ] 
 	if ( !Key ) then 
 		pTable.__SortedIndex = nil 
 		return 
 	end 
 	 
 	Index = Index + 1 
 	 
 	return Key, pTable[ Key ] 
   
 end 


function ASS.Utils.SortedPairs( pTable ) 

	pTable = table.Copy( pTable ) 

	local SortedIndex = {} 
	for k, v in pairs( pTable ) do 
		table.insert( SortedIndex, k ) 
	end 

	table.sort( SortedIndex ) 
	pTable.__SortedIndex = SortedIndex 

	return fnPairsSorted, pTable, nil 

end 

function ASS.Utils.PlayerName(PLAYER)
	if (PLAYER == nil or PLAYER == NULL or !PLAYER:IsValid() or !PLAYER:IsPlayer()) then
		return "Console"
	end
	
	return PLAYER:Nick() .. " (" .. PLAYER:SteamID() .. " | " .. PLAYER:IPAddress() .. ")"
end

if (CLIENT) then
	
	local isLan = false
	function ASS.Utils.IsLan()
		return isLan
	end
	
	usermessage.Hook("ASS:SetIsLan",function(UM)	isLan = UM:ReadBool() end )

else
	function ASS.Utils.IsLan()

		if (SinglePlayer()) then
			return false
		else
			return (GetConVarNumber("sv_lan") == 1)
		end
	end


	ASS.Utils.DoOnConnect( 
		function(pl)
			umsg.Start("ASS:SetIsLan", pl)
				umsg.Bool( ASS.Utils.IsLan() )
			umsg.End()
		end)
end