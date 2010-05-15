
ASS.Print = {}

function ASS.Print.Console(PLAYER, TEXT)

	if (PLAYER == NULL) then
		print(TEXT)
	else
		PLAYER:PrintMessage(HUD_PRINTCONSOLE, TEXT .. "\n")
	end

end

function ASS.Print.Action(PLAYER, TEXT, LVL)

	if (CLIENT or PLAYER:IsListenServerHost()) then
		PLAYER:PrintMessage(HUD_PRINTCONSOLE, TEXT .. "\n")
	else
		print(ASS.Utils.PlayerName(PLAYER) .. " " .. TEXT )
		PLAYER:PrintMessage(HUD_PRINTCONSOLE, TEXT .. "\n")
		
		if (LVL) then
			ASS.IO.Log(PLAYER, LVL, TEXT)
		end
	end

end