
ASS.Progress = {}

ASS.Progress.ListAll = {}
ASS.Progress.ListPP = {}

if (SERVER) then

	function ASS.Progress.SendActive(PL)
		for name, info in pairs(ASS.Progress.ListAll) do
			ASS.Progress.Init(PL, name, info.text, (info.starttime + info.time) - CurTime(), true, info.progress )
		end
	end
	ASS.Utils.DoOnConnect(ASS.Progress.SendActive)

end

if (CLIENT) then

end

ASS.Progress.Init, ASS.Progress.InitAll = 
		ASS.ClientCall.Register( 
				"ASS.Progress.Init", 
				function(PLAYER, NAME, TEXT, MAX, DONTADD, PRESET)
					
					-- DONTADD & PRESET parameter is only used on the server (ASS.Progress.SendActive)
					if (!DONTADD || CLIENT) then
						if (PLAYER == nil) then
							ASS.Progress.ListAll[NAME] = { text = TEXT, max = MAX, progress = PRESET or 0, starttime = CurTime() }
						else
							ASS.Progress.ListPP[PLAYER] = ASS.Progress.ListPP[PLAYER] or {}
							ASS.Progress.ListPP[PLAYER][NAME] = { text = TEXT, max = MAX, progress = PRESET or 0, starttime = CurTime() }
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
				
ASS.Progress.Increment, ASS.Progress.IncrementAll = 
		ASS.ClientCall.Register( 
				"ASS.Progress.Increment", 
				function(PLAYER, NAME, VALUE)
				
					if (PLAYER == nil) then
						if (ASS.Progress.ListAll[NAME] == nil) then
							ASS.Debug("Progress.Increment", "Progress " .. NAME .. " not found!")
							return
						end
						
						ASS.Progress.ListAll[NAME].progress = ASS.Progress.ListAll[NAME].progress + VALUE
						
						if (ASS.Progress.ListAll[NAME].progress > ASS.Progress.ListAll[NAME].max) then
							-- TODO: Remove from VGUI
							ASS.Progress.ListAll[NAME] = nil
							return
						end
					else
						ASS.Progress.ListPP[PLAYER] = ASS.Progress.ListPP[PLAYER] or {}
						if (ASS.Progress.ListPP[PLAYER][NAME] == nil) then
							ASS.Debug("Progress.Increment", "Progress " .. NAME .. " not found!")
							return
						end
						ASS.Progress.ListPP[PLAYER][NAME].progress = ASS.Progress.ListPP[PLAYER][NAME].progress + VALUE
						
						if (ASS.Progress.ListPP[PLAYER][NAME].progress > ASS.Progress.ListPP[PLAYER][NAME].max) then
							-- TODO: Remove from VGUI
							ASS.Progress.ListPP[PLAYER][NAME] = nil
							return
						end
					end

					if (CLIENT) then
						-- TODO: Update VGUI
					end
					
				end,
				{ 
					{type="string"},
					{type="number"}
				},
				{ ASS.ClientCall.OptCallNowPerPlayer } )
				
ASS.Progress.SetMax, ASS.Progress.SetMaxAll = 
		ASS.ClientCall.Register( 
				"ASS.Progress.SetMax", 
				function(PLAYER, NAME, VALUE)
					
					if (PLAYER == nil) then
						if (ASS.Progress.ListAll[NAME] == nil) then
							ASS.Debug("Progress.SetMax", "Progress " .. NAME .. " not found!")
							return
						end
						
						ASS.Progress.ListAll[NAME].max = VALUE
					else
						ASS.Progress.ListPP[PLAYER] = ASS.Progress.ListPP[PLAYER] or {}
						if (ASS.Progress.ListPP[PLAYER][NAME] == nil) then
							ASS.Debug("Progress.SetMax", "Progress " .. NAME .. " not found!")
							return
						end
						ASS.Progress.ListPP[PLAYER][NAME].max = VALUE
					end

					if (SERVER) then
					end
					
					if (CLIENT) then
						-- TODO: Update VGUI
					end
					
				end,
				{ 
					{type="string"},
					{type="number"}
				},
				{ ASS.ClientCall.OptCallNowPerPlayer } )
			
ASS.Progress.SetText, ASS.Progress.SetTextAll = 
		ASS.ClientCall.Register( 
				"ASS.Progress.SetText", 
				function(PLAYER, NAME, VALUE)
					
					if (PLAYER == nil) then
						if (ASS.Progress.ListAll[NAME] == nil) then
							ASS.Debug("Progress.SetText", "Progress " .. NAME .. " not found!")
							return
						end
						
						ASS.Progress.ListAll[NAME].text = VALUE
					else
						ASS.Progress.ListPP[PLAYER] = ASS.Progress.ListPP[PLAYER] or {}
						if (ASS.Progress.ListPP[PLAYER][NAME] == nil) then
							ASS.Debug("Progress.SetText", "Progress " .. NAME .. " not found!")
							return
						end
						ASS.Progress.ListPP[PLAYER][NAME].text = VALUE
					end

					if (SERVER) then
					end
					
					if (CLIENT) then
						-- TODO: Update VGUI
					end
					
				end,
				{ 
					{type="string"},
					{type="string"}
				},
				{ ASS.ClientCall.OptCallNowPerPlayer } )

ASS.Progress.Remove, ASS.Progress.RemoveAll = 
		ASS.ClientCall.Register( 
				"ASS.Progress.Remove", 
				function(PLAYER, NAME)
				
					if (PLAYER == nil) then
						ASS.Progress.ListAll[NAME] = nil
						for pl, list in pairs(ASS.Progress.ListPP) do
							list[NAME] = nil
						end
					else
						ASS.Progress.ListAll[NAME] = nil
						ASS.Progress.ListPP[PLAYER] = ASS.Progress.ListPP[PLAYER] or {}
						ASS.Progress.ListPP[PLAYER][NAME] = nil
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
				{ ASS.ClientCall.OptCallNowPerPlayer } )