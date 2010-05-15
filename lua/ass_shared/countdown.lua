
ASS.Countdown = {}

ASS.Countdown.ListAll = {}
ASS.Countdown.ListPP = {}

if (SERVER) then
	function ASS.Countdown.SendActive(PL)
		for name, info in pairs(ASS.Countdown.ListAll) do
			ASS.Countdown.Init(PL, name, info.text, (info.starttime + info.time) - CurTime(), true )
		end
	end
	ASS.Utils.DoOnConnect(ASS.Countdown.SendActive)

	function ASS.Countdown.Think()
		for name, info in pairs(ASS.Countdown.ListAll) do
			if (CurTime() >= info.starttime + info.time) then
				ASS.Countdown.ListAll[name] = nil
			end
		end
		for pl, list in pairs(ASS.Countdown.ListPP) do
			if (!pl:IsValid()) then
				ASS.Countdown.ListPP[pl] = nil
			else
				for name, info in pairs(list) do
					if (CurTime() >= info.starttime + info.time) then
						list[name] = nil
					end
				end
			end
		end
	end
	ASS.Utils.DoOnThink(ASS.Countdown.Think)
	
end

if (CLIENT) then

	function ASS.Countdown.Think()
		for name, info in pairs(ASS.Countdown.ListAll) do
			if (CurTime() >= info.starttime + info.time) then
				ASS.Countdown.ListAll[name] = nil
				-- TODO: Remove from VGUI
			end
		end
		for pl, list in pairs(ASS.Countdown.ListPP) do
			if (!pl:IsValid()) then
				ASS.Countdown.ListPP[pl] = nil
			else
				for name, info in pairs(list) do
					if (CurTime() >= info.starttime + info.time) then
						-- TODO: Remove from VGUI
						list[name] = nil
					end
				end
			end
		end
	end
	ASS.Utils.DoOnThink(ASS.Countdown.Think)

end

ASS.Countdown.Init, ASS.Countdown.InitAll = 
		ASS.ClientCall.Register( 
				"ASS.Countdown.Init", 
				function(PLAYER, NAME, TEXT, TIME, DONTADD)
					
					-- DONTADD parameter is only used on the server (ASS.Countdown.SendActive)
					if (!DONTADD || CLIENT) then
						if (PLAYER == nil) then
							ASS.Countdown.ListAll[NAME] = { text = TEXT, time = TIME, starttime = CurTime() }
						else
							ASS.Countdown.ListPP[PLAYER] = ASS.Countdown.ListPP[PLAYER] or {}
							ASS.Countdown.ListPP[PLAYER][NAME] = { text = TEXT, time = TIME, starttime = CurTime() }
						end
					end

					if (SERVER) then
					end
					
					if (CLIENT) then
						-- TODO: Add to VGUI
					end
					
				end,
				{ 
					{type="string"},
					{type="string"},
					{type="number"}
				},
				{ ASS.ClientCall.OptCallNowPerPlayer } )
			
ASS.Countdown.Remove, ASS.Countdown.RemoveAll = 
		ASS.ClientCall.Register( 
				"ASS.Countdown.Remove", 
				function(PLAYER, NAME)
				
					if (PLAYER == nil) then
						ASS.Countdown.ListAll[NAME] = nil
						for pl, list in pairs(ASS.Countdown.ListPP) do
							list[NAME] = nil
						end
					else
						ASS.Countdown.ListAll[NAME] = nil
						ASS.Countdown.ListPP[PLAYER] = ASS.Countdown.ListPP[PLAYER] or {}
						ASS.Countdown.ListPP[PLAYER][NAME] = nil
					end

					if (SERVER) then
					end
					
					if (CLIENT) then
						-- TODO: Remove from VGUI
					end

				end,
				{ 
					{type="string"},
				},
				{ ASS.ClientCall.OptCallNowPerPlayer } 	)