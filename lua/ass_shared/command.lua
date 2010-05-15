
function ASS.Command( CMD, ... )

	local FullCmd = CMD
	local Args = {...}
	if (#Args > 0) then
		for k,v in pairs(Args) do
			FullCmd = FullCmd .. string.format(" %q", v)
		end
	end
	ASS.Debug("Command", FullCmd )

	if (SERVER) then
		game.ConsoleCommand( FullCmd )
	end
	if (CLIENT) then
		RunConsoleCommand( CMD, ... )
	end
end