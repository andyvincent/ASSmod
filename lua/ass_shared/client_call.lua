
local UMSG_CC_STRING_SPLIT = 198
local UMSG_CC_LIMIT = 200

ASS.ClientCall = {}

ASS.ClientCall.Functions = {}
ASS.ClientCall.OptCallNow = "callnow"
ASS.ClientCall.OptCallNowPerPlayer = "callperplayer"
ASS.ClientCall.OptCallNowWithPlayerList = "callplayerlist"

if (SERVER) then
	function ASS.ClientCall.Dispatch(PLAYERS, FUNCTION_NAME, PARAMETER_FORMAT, PARAMETERS)

		local messages = {}

		local current_message = {}
		local current_message_size = 1
		for key, parameter_cfg in pairs(PARAMETER_FORMAT) do

			local value = PARAMETERS[key] or parameter_cfg.default_value
			local sendfn = nil
			local bc = 0

			if (!value) then

				ASS.Debug("ClientCall.Dispatch", "function " .. tostring(function_name) .. " call aborted: missing parameter " .. key)
				return

			end

			if (parameter_cfg.type == "string") then				value = tostring(value)		sendfn = umsg.String		bc = #value
			elseif (parameter_cfg.type == "number") then			value = tonumber(value)		sendfn = umsg.Float		bc = 4
			elseif (parameter_cfg.type == "byte") then			value = tonumber(value)		sendfn = umsg.Char		bc = 1
			elseif (parameter_cfg.type == "short") then			value = tonumber(value)		sendfn = umsg.Short		bc = 2
			elseif (parameter_cfg.type == "long") then			value = tonumber(value)		sendfn = umsg.Long		bc = 4
			elseif (parameter_cfg.type == "bool") then			value = tobool(value)		sendfn = umsg.Bool		bc = 1
			elseif (parameter_cfg.type == "entity") then												sendfn = umsg.Entity		bc = 4
			else
				ASS.Debug("ClientCall.Dispatch", "function " .. tostring(function_name) .. " call aborted: invalid parameter type " .. key)
				return
			end

			if (value == nil) then
				ASS.Debug("ClientCall.Dispatch", "function " .. tostring(function_name) .. " call aborted: missing parameter " .. key)
				return
			end

			if (type(value) == "string") then

				while (#value > 0) do

					local bc = math.min( #value, UMSG_CC_STRING_SPLIT ) + 2
					if (bc+1+current_message_size > UMSG_CC_LIMIT) then
						bc = UMSG_CC_LIMIT - current_message_size
						if (bc <= 5) then
							bc = math.min( #value, UMSG_CC_STRING_SPLIT ) + 2
						end
					end

					local info = { num = key, value = string.sub(value, 1, UMSG_CC_STRING_SPLIT), func = umsg.String }

					if (current_message_size + (bc + 1) > UMSG_CC_LIMIT) then
						table.insert(messages, current_message)
						current_message = {}
						current_message_size = 1
					end

					table.insert(current_message, info )

					value = string.sub(value, UMSG_CC_STRING_SPLIT+1)

				end

			else
				local info = { num = key, value = value, func = sendfn }

				if (current_message_size + (bc + 1) > UMSG_CC_LIMIT) then
					table.insert(messages, current_message)

					current_message = {}
					current_message_size = 1
				end

				table.insert(current_message, info )
			end

		end

		if (#current_message > 0) then
				table.insert(messages, current_message)
		end

		local send_messages = function(pl)
			if (type(pl) != "Player" && pl != nil) then
				ASS.Debug("ClientCall.Dispatch", "function " .. tostring(function_name) .. " call aborted: invalid destination")
				return
			end
			
			umsg.Start("ASS:ClientCall", pl)
				umsg.String(FUNCTION_NAME)
				umsg.Long(#messages)
			umsg.End()
			for _, parts in pairs(messages) do

				umsg.Start("ASS:ClientParam", pl)
					umsg.Char( #parts )
					for _, data in pairs(parts) do
						umsg.Char( data.num )
						data.func( data.value )
					end
				umsg.End()

			end
		end
		
		if (type(PLAYERS) == "table") then
			for k,v in pairs(PLAYERS) do
				send_messages(v)
			end
		else
			if (players == nil) then
				send_messages()
			else
				send_messages(PLAYERS)
			end
		end
	end
end

if (CLIENT) then

	ASS.ClientCall.Current = nil
	
	function ASS.ClientCall.UMSG_ClientCall(UM)
		
		if (ASS.ClientCall.Current) then
			ASS.Debug("ClientCall.UMSG_ClientCall", "function " .. tostring(ASS.ClientCall.Current.function_name) .. " call aborted: new message")
			ASS.ClientCall.Current = nil
		end
		
		local function_name = UM:ReadString()
		
		if (!ASS.ClientCall.Functions[function_name]) then
			ASS.Debug("ClientCall.UMSG_ClientCall", "function " .. tostring(function_name) .. " call aborted: not registered")
			ASS.ClientCall.Current = nil
			return
		end
		
		ASS.ClientCall.Current = {}
		ASS.ClientCall.Current.function_name = function_name
		ASS.ClientCall.Current.num_messages = UM:ReadLong()
		ASS.ClientCall.Current.func_info = ASS.ClientCall.Functions[function_name].Format or {}
		ASS.ClientCall.Current.func_opts = ASS.ClientCall.Functions[function_name].Options or {}
		ASS.ClientCall.Current.func = ASS.ClientCall.Functions[function_name].Pointer or function() end
		ASS.ClientCall.Current.parameters = {}

		if (ASS.ClientCall.Current.num_messages == 0) then
			ASS.ClientCall.Current.func()
			ASS.ClientCall.Current = nil
		end
	end
	usermessage.Hook("ASS:ClientCall", ASS.ClientCall.UMSG_ClientCall )
	
	function ASS.ClientCall.UMSG_ClientParam(UM)

		if (!ASS.ClientCall.Current) then
			return
		end
		
		local numparts = UM:ReadChar()
		for p = 1, numparts do
			local paramnum = UM:ReadChar()
			local paramtype = nil
			if (ASS.ClientCall.Current.func_info[paramnum]) then
				paramtype = ASS.ClientCall.Current.func_info[paramnum].type
			end
			local data = nil
			
			if (paramtype == "string") then		data = UM:ReadString()
			elseif (paramtype == "number") then	data = UM:ReadFloat()
			elseif (paramtype == "long") then	data = UM:ReadLong()
			elseif (paramtype == "short") then	data = UM:ReadShort()
			elseif (paramtype == "char") then	data = UM:ReadChar()
			elseif (paramtype == "bool") then	data = UM:ReadBool()
			elseif (paramtype == "entity") then	data = UM:ReadEntity()
			else
				ASS.Debug("ClientCall.UMSG_ClientParam", "function " .. tostring(ASS.ClientCall.Current.function_name) .. " call aborted: unknown parameter type " .. tostring(paramtype) .. " for parameter " .. paramnum)
				ASS.ClientCall.Current = nil
				return
			end
			
			if (paramtype == "string") then
				ASS.ClientCall.Current.parameters[paramnum] = (ASS.ClientCall.Current.parameters[paramnum] or "") .. data
			else
				ASS.ClientCall.Current.parameters[paramnum] = data
			end
		end
		
		ASS.ClientCall.Current.num_messages = ASS.ClientCall.Current.num_messages - 1
		if (ASS.ClientCall.Current.num_messages == 0) then
			if (table.HasValue(ASS.ClientCall.Current.func_opts, ASS.ClientCall.OptCallNowPerPlayer)) then
				ASS.ClientCall.Current.func( LocalPlayer(), unpack(ASS.ClientCall.Current.parameters) )
			elseif (table.HasValue(ASS.ClientCall.Current.func_opts, ASS.ClientCall.OptCallNowWithPlayerList)) then
				ASS.ClientCall.Current.func( {LocalPlayer()}, unpack(ASS.ClientCall.Current.parameters) )
			else
				ASS.ClientCall.Current.func( unpack(ASS.ClientCall.Current.parameters) )
			end
			
			ASS.ClientCall.Current = nil
		end
	end
	usermessage.Hook("ASS:ClientParam", ASS.ClientCall.UMSG_ClientParam )

end

function ASS.ClientCall.Register(FUNC_NAME, POINTER, PARAM_FORMAT, OPTIONS)

	if (!POINTER) then

		ASS.Debug("ClientCall.Register", "function " .. tostring(FUNC_NAME) .. " not found")
		return

	end

	if (ASS.ClientCall.Functions[FUNC_NAME]) then

		ASS.Debug("ClientCall.Register", "function " .. tostring(FUNC_NAME) .. " already defined")
		return

	end

	ASS.ClientCall.Functions[FUNC_NAME] = {}
	ASS.ClientCall.Functions[FUNC_NAME].Pointer = POINTER
	ASS.ClientCall.Functions[FUNC_NAME].Format = PARAM_FORMAT or {}
	ASS.ClientCall.Functions[FUNC_NAME].Options = OPTIONS

	if (CLIENT) then
	
		if (table.HasValue(OPTIONS, ASS.ClientCall.OptCallNowPerPlayer)) then
			return function(...)	POINTER(LocalPlayer(), ...)	end, nil
		elseif (table.HasValue(OPTIONS, ASS.ClientCall.OptCallNowWithPlayerList)) then
			return function(...)	POINTER({LocalPlayer()}, ...)	end, nil
		else
			return function(...)	POINTER(...)	end, nil
		end
	
	end
	
	if (SERVER) then
	
		if (table.HasValue(OPTIONS, ASS.ClientCall.OptCallNowPerPlayer)) then
			return
				function(PLAYERS, ...)
					if (type(PLAYERS) == "table" || PLAYERS == nil) then
						for _, PL in pairs(PLAYERS or player.GetAll()) do
							POINTER(PL, ...)
						end
					elseif (type(PLAYERS) == "Player") then
						POINTER(PLAYERS, ...)
					end
					ASS.ClientCall.Dispatch( PLAYERS, FUNC_NAME, PARAM_FORMAT or {}, {...} )
				end,
				function(...)
					POINTER(nil, ...)
					ASS.ClientCall.Dispatch( nil, FUNC_NAME, PARAM_FORMAT or {}, {...} )
				end
		elseif (table.HasValue(OPTIONS, ASS.ClientCall.OptCallNowWithPlayerList)) then
		
			return
				function(PLAYERS, ...)
					POINTER(PLAYERS, ...)
					ASS.ClientCall.Dispatch( PLAYERS, FUNC_NAME, PARAM_FORMAT or {}, {...} )
				end,
				function(...)
					POINTER(nil, ...)
					ASS.ClientCall.Dispatch( nil, FUNC_NAME, PARAM_FORMAT or {}, {...} )
				end
				
		elseif (table.HasValue(OPTIONS, ASS.ClientCall.OptCallNow)) then
		
			return
				function(PLAYERS, ...)
					POINTER(...)
					ASS.ClientCall.Dispatch( PLAYERS, FUNC_NAME, PARAM_FORMAT or {}, {...} )
				end,
				function(...)
					POINTER(...)
					ASS.ClientCall.Dispatch( nil, FUNC_NAME, PARAM_FORMAT or {}, {...} )
				end

		else
			return
				function(PLAYERS, ...)
					ASS.ClientCall.Dispatch( PLAYERS, FUNC_NAME, PARAM_FORMAT or {}, {...} )
				end,
				function(...)
					ASS.ClientCall.Dispatch( nil, FUNC_NAME, PARAM_FORMAT or {}, {...} )
				end
		end
				
	end
		
end