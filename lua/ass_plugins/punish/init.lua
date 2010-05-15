
PLUGIN.Name = "Punish/Reward"
PLUGIN.Clientside = true
PLUGIN.Serverside = true
PLUGIN.HideDisableOption = true

PLUGIN.PunishOptions = {}

if (SERVER) then

	function PLUGIN:Activate()
		ASS.Config.AddPermission("punish", "Punish/Reward", "admin")
		concommand.Add("ASS_PunishToggle", function(P,C,A) self:CC_PunishToggle(P,A) end )
		concommand.Add("ASS_PunishTimed", function(P,C,A) self:CC_PunishTimed(P,A) end )
		concommand.Add("ASS_PunishCustom", function(P,C,A) self:CC_PunishCustom(P,A) end )
	end
	
	function PLUGIN:Deactivate()
		concommand.Remove("ASS_PunishToggle" )
		concommand.Remove("ASS_PunishTimed" )
		concommand.Remove("ASS_PunishCustom" )
	end
	
	function PLUGIN:FindPunishment(MODE)
		local PUNISH = nil
		for k,v in pairs(self.PunishOptions) do
			if (v.Name == MODE) then
				PUNISH = v
				break
			end
		end
		return PUNISH
	end
	
	function PLUGIN:CC_PunishToggle(PLAYER, ARGS)
		
		if (ASS.Config.HasPermission(PLAYER, "punish")) then
		
			local MODE = ARGS[1]
			local ACTOR = ARGS[2]
			local ENABLE = tonumber(ARGS[3])
			
			if (!MODE || !PLAYER || !ENABLE) then
				return
			end
			
			ACTOR = ASS.Utils.FindPlayer(ACTOR)
			if (!ValidEntity(ACTOR)) then
				return
			end
			
			if ( ACTOR != PLAYER && ( ACTOR:ASS_HasLevel( PLAYER:ASS_GetLevel() ) || ACTOR:GetLevel() == PLAYER:ASS_GetLevel() ) ) then
				return
			end
			
			local PUNISH = self:FindPunishment(MODE)
			
			if (!PUNISH) then
				return
			end
			if (!PUNISH.AllowToggle) then
				return
			end
			
			if (ENABLE == 0) then
				if (PUNISH.fnOff) then
					PCallError( PUNISH.fnOff, ACTOR )
					timer.Remove( PUNISH.Name .. "_" .. ACTOR:UniqueID() )
					ASS.IO.Log("punish", PLAYER, "Disabled " .. PUNISH.Text .. " for " .. ASS.Utils.PlayerName(ACTOR) )
				end
			elseif (ENABLE == 1) then
				local err, ret = PCallError( PUNISH.fnOn, ACTOR )
				if (PUNISH.fnOff) then
					ASS.IO.Log("punish", PLAYER, "Enabled " .. PUNISH.Text .. " for " .. ASS.Utils.PlayerName(ACTOR) )
				else
					if (ret) then
						ASS.IO.Log("punish", PLAYER, "Punished " .. ASS.Utils.PlayerName(ACTOR) .. " action was \"" .. PUNISH.Text .. "\"" )
					else
						ASS.IO.Log("punish", PLAYER, ret )
					end
				end
			end
		
		end
		
	end

	function PLUGIN:CC_PunishCustom(PLAYER, ARGS)
		
		if (ASS.Config.HasPermission(PLAYER, "punish")) then
		
			local MODE = ARGS[1]
			local ACTOR = ARGS[2]
			local INFO = ARGS[3]
			
			if (!MODE || !PLAYER || !INFO) then
				return
			end
			
			ACTOR = ASS.Utils.FindPlayer(ACTOR)
			if (!ValidEntity(ACTOR)) then
				return
			end
			
			if ( ACTOR != PLAYER && ( ACTOR:ASS_HasLevel( PLAYER:ASS_GetLevel() ) || ACTOR:GetLevel() == PLAYER:ASS_GetLevel() ) ) then
				return
			end
			
			local PUNISH = self:FindPunishment(MODE)
			
			if (!PUNISH) then
				return
			end

			if (!PUNISH.fnCustom) then
				return
			end
			
			for k,v in pairs(PUNISH.CustomOptions) do
				if (INFO == v.data) then
					local err, ret = PCallError( PUNISH.fnCustom, ACTOR, v.data )
					
					if (!ret) then
						ASS.IO.Log("punish", PLAYER, "Punished " .. ASS.Utils.PlayerName(ACTOR) .. " action was \"" .. PUNISH.Text .. "\"" )
					else
						ASS.IO.Log("punish", PLAYER, ret )
					end
					return
				end
			end
		
		end
		
	end
	
	function PLUGIN:CC_PunishTimed(PLAYER, ARGS)
	
		if (ASS.Config.HasPermission(PLAYER, "punish")) then
		
			local MODE = ARGS[1]
			local ACTOR = ARGS[2]
			local TIME = tonumber(ARGS[3])
			
			if (!MODE || !PLAYER || !TIME) then
				return
			end
			
			ACTOR = ASS.Utils.FindPlayer(ACTOR)
			if (!ValidEntity(ACTOR)) then
				return
			end
			
			if ( ACTOR != PLAYER && ( ACTOR:ASS_HasLevel( PLAYER:ASS_GetLevel() ) || ACTOR:GetLevel() == PLAYER:ASS_GetLevel() ) ) then
				return
			end
			
			local PUNISH = self:FindPunishment(MODE)
			
			if (!PUNISH) then
				return
			end
			if (!PUNISH.AllowTimed) then
				return
			end

			ASS.IO.Log("punish", PLAYER, "Enabled " .. PUNISH.Text .. " for " .. ASS.Utils.PlayerName(ACTOR) .. " for " ..  TIME .. " seconds" )

			PCallError( PUNISH.fnOn, ACTOR )
			timer.Create( 
				PUNISH.Name .. "_" .. ACTOR:UniqueID(),
				TIME,
				1,
				function()
					if (ACTOR:IsValid()) then
						PCallError( PUNISH.fnOff, ACTOR )
					end
				end
			)

		end
		
	end

end

if (CLIENT) then

	local TimeList = {
						{	txt = "10 Seconds",		time = 10		},
						{	txt = "30 Seconds",		time = 30		},
						{	txt = "1 Minute",			time = 60		},
						{	txt = "2 Minutes",		time = 2*60		},
						{	txt = "5 Minutes",		time = 5*60		},
						{	txt = "10 Minutes",		time = 10*60	},
					}	

	function PLUGIN:Activate()
	end
	
	function PLUGIN:DoToggle(PLAYER_LIST, OPTIONS, ENABLE)
		for _, PLAYER in pairs(PLAYER_LIST) do
			ASS.Command("ASS_PunishToggle", OPTIONS.Name, PLAYER:UniqueID(), ENABLE )
		end
	end
	
	function PLUGIN:DoTimed(PLAYER_LIST, OPTIONS, TIME)
		for _, PLAYER in pairs(PLAYER_LIST) do
			ASS.Command("ASS_PunishTimed", OPTIONS.Name, PLAYER:UniqueID(), TIME )
		end
	end

	function PLUGIN:DoCustom(PLAYER_LIST, OPTIONS, INFO)
		for _, PLAYER in pairs(PLAYER_LIST) do
			ASS.Command("ASS_PunishCustom", OPTIONS.Name, PLAYER:UniqueID(), INFO )
		end
	end

	function PLUGIN:TimeToggleMenu(MENU, PLAYER_LIST, OPTIONS)
	
		if (OPTIONS.AllowToggle) then
		
			if OPTIONS.CustomOptions[1] && OPTIONS.CustomOptions[2] then
				local X1 = MENU:AddOption( OPTIONS.CustomOptions[1].txt,	function()	self:DoToggle(PLAYER_LIST, OPTIONS, OPTIONS.CustomOptions[1].data)		end )
				local X2 = MENU:AddOption( OPTIONS.CustomOptions[2].txt,	function()	self:DoToggle(PLAYER_LIST, OPTIONS, OPTIONS.CustomOptions[2].data)		end )
				
				if (OPTIONS.CustomOptions[1].icon && #OPTIONS.CustomOptions[1].icon > 0) then X1:SetImage( OPTIONS.CustomOptions[1].icon ) end
				if (OPTIONS.CustomOptions[2].icon && #OPTIONS.CustomOptions[2].icon > 0) then X2:SetImage( OPTIONS.CustomOptions[2].icon ) end
			else
				MENU:AddOption( "Enable",			function()	self:DoToggle(PLAYER_LIST, OPTIONS, 1)		end )
				MENU:AddOption( "Disable",			function()	self:DoToggle(PLAYER_LIST, OPTIONS, 0)		end )
			end
		
		end
		
		if (MENU:HasPanels() && OPTIONS.AllowTimed) then
			MENU:AddSpacer()
		end
	
		if (OPTIONS.AllowTimed) then
		
			for k,v in pairs(TimeList) do
				MENU:AddOption( v.txt,		function()	self:DoTimed(PLAYER_LIST, OPTIONS, v.time)		end )
			end
			
		end

		if (MENU:HasPanels() && #OPTIONS.CustomOptions > 0 && OPTIONS.fnCustom) then
			MENU:AddSpacer()
		end

		if (OPTIONS.fnCustom) then
			for k,v in pairs(OPTIONS.CustomOptions) do
				local ITEM = MENU:AddOption( v.txt,		function()	self:DoCustom(PLAYER_LIST, OPTIONS, v.data)		end )
				if (v.icon && #v.icon > 0) then
					ITEM:SetImage( v.icon )
				end
			end
		end
	end
	
	function PLUGIN:PunishMenu(MENU, PLAYER_LIST)
	
		for _, opt in pairs(self.PunishOptions) do
		
			if (opt.Text == "-") then
				MENU:AddSpacer()
			else
				local ITEM
				if (opt.fnOff == nil && opt.fnCustom == nil) then
					ITEM = MENU:AddOption( opt.Text, function()	self:DoToggle(PLAYER_LIST, opt, 1) end )
				else
					ITEM = MENU:AddSubMenu( opt.Text, nil, function(SUBMENU)	self:TimeToggleMenu(SUBMENU,PLAYER_LIST,opt) end )
				end
				if (opt.icon && #opt.icon > 0) then
					ITEM:SetImage(opt.icon)
				end
			end
		
		end
	
	end

	function PLUGIN:BuildMainMenu(MENU)
		if (ASS.Config.HasPermission("punish")) then
		
			MENU:AddSubMenu( "Punish/Reward", nil,
				function(SUBMENU)
					ASS.Menu.PlayerMenu( SUBMENU, function(SUBMENU,PLAYER) self:PunishMenu(SUBMENU,PLAYER) end, { ASS.Menu.HasSubMenu } )
				end )
		
		end
	end

end

local function AddPunishOption(Name, Text, fnOn, fnOff, fnCustom, AllowTimed, AllowToggle, CustomOptions, Icon )
	table.insert(PLUGIN.PunishOptions, { Name = Name, Text = Text, fnOn = fnOn, fnOff = fnOff, fnCustom = fnCustom, AllowTimed = AllowTimed, AllowToggle= AllowToggle, CustomOptions=CustomOptions or {}, Icon=Icon } )
end

AddPunishOption(
	"god",
	"God Mode",
	function(PL)	PL:GodEnable()		end,
	function (PL)	PL:GodDisable()	end,
	nil,
	true,
	true,
	nil,
	"")
	
AddPunishOption(
	"kill",
	"Kill",
	function(PL)	PL:Kill()		end,
	nil,
	nil,
	false,
	false,
	nil,
	"gui/silkicons/bomb" )
	
AddPunishOption(
	"freeze",
	"Freeze",
	function(PL)	PL:Freeze(true)		end,
	function (PL)	PL:Freeze(false)	end,
	nil,
	true,
	true,
	{ 
		{ txt = "Freeze",	data = 1, icon="gui/silkicons/status_offline"	},
		{ txt = "UnFreeze",	data = 0, icon="gui/silkicons/user"		}
	},
	"gui/silkicons/status_offline"  )
	
AddPunishOption(
	"slap",
	"Slap",
	nil,
	nil,
	function(TO_SLAP,POWER)
		local SLAP_SOUNDS = {
			"physics/body/body_medium_impact_hard1.wav",
			"physics/body/body_medium_impact_hard2.wav",
			"physics/body/body_medium_impact_hard3.wav",
			"physics/body/body_medium_impact_hard5.wav",
			"physics/body/body_medium_impact_hard6.wav",
			"physics/body/body_medium_impact_soft5.wav",
			"physics/body/body_medium_impact_soft6.wav",
			"physics/body/body_medium_impact_soft7.wav"
		}
		local POWER_TABLE = {
			{	VelocityMax = 1000, 	Damage = 75,	LogText = "with deadly force"	},
			{	VelocityMax = 10000,	Damage = 5,		LogText = "hard but fast"		},
			{	VelocityMax = 500, 	Damage = 25,	LogText = "hard"					},
			{	VelocityMax = 200, 	Damage = 5,		LogText = "lightly"				},
		}
		POWER = tonumber(POWER) or 1

		local PT = POWER_TABLE[POWER] or POWER_TABLE[1]
		local RandomVelocity = Vector( math.random(PT.VelocityMax) - (PT.VelocityMax / 2 ), math.random(PT.VelocityMax) - (PT.VelocityMax / 2 ), math.random(PT.VelocityMax) - (PT.VelocityMax / 4 ) )
		local RandomSound = SLAP_SOUNDS[ math.random(#SLAP_SOUNDS) ]

		TO_SLAP:EmitSound( RandomSound )
		TO_SLAP:SetVelocity( RandomVelocity )
		ASS.Utils.HurtPlayer(TO_SLAP, PT.Damage)
			
		return "Slapped " .. ASS.Utils.PlayerName(TO_SLAP) .. " " .. PT.LogText

	end,
	false,
	false,
	{
		{txt = "Deadly", data = "1"},
		{txt = "Super", data = "2"},
		{txt = "Hard", data = "3"},
		{txt = "Light", data = "4"},
	},
	""
	)
	
AddPunishOption("-", "-")
	
AddPunishOption(
	"add_health",
	"Give Health",
	nil,
	nil,
	function(PL,HEALTH)
		if (PL:Health() + HEALTH > 9999) then
			HEALTH = 9999 - PL:Health()
			if (HEALTH <= 0) then
				return
			end
		end
		
		PL:SetHealth( PL:Health() + HEALTH )
		return "Gave " .. HEALTH .. " health to " .. ASS.Utils.PlayerName(PL)
	end,
	false,
	false,
	{
		{ txt = "10", data = 10 },{ txt = "20", data = 20 },{ txt = "30", data = 30 },{ txt = "40", data = 40 },{ txt = "50", data = 50 },
		{ txt = "60", data = 60 },{ txt = "70", data = 70 },{ txt = "80", data = 80 },{ txt = "90", data = 90 },{ txt = "100", data = 100 }
	},
	"gui/silkicons/heart"
)
	
AddPunishOption(
	"take_health",
	"Take Health",
	nil,
	nil,
	function(PL,HEALTH)
		ASS.Utils.HurtPlayer(PL, HEALTH)
		return "Took " .. HEALTH .. " health from " .. ASS.Utils.PlayerName(PL)
	end,
	false,
	false,
	{
		{ txt = "10", data = 10 },{ txt = "20", data = 20 },{ txt = "30", data = 30 },{ txt = "40", data = 40 },{ txt = "50", data = 50 },
		{ txt = "60", data = 60 },{ txt = "70", data = 70 },{ txt = "80", data = 80 },{ txt = "90", data = 90 },{ txt = "100", data = 100 }
	},
	"gui/silkicons/pill"
	)
	
	
