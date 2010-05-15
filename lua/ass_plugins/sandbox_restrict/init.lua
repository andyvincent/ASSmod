
PLUGIN.Name = "Restrict Tools/SWEPs/SENTs"
PLUGIN.Clientside = true
PLUGIN.Serverside = true
PLUGIN.HideDisableOption = true
PLUGIN.Gamemodes = {"sandbox"}

if (SERVER) then

	local function FillToolList(list)

		local toolgun = weapons.GetStored("gmod_tool")
		
		if (!toolgun || !toolgun.Tool) then
			return false
		end
		
		for toolname, tool in pairs(toolgun.Tool) do
			
			local Info = {}
			Info.DisplayName = tool.Name || "#"..toolname
			Info.InternalName = string.lower(toolname)
			Info.LowestAllowedLevel = "user"
			Info.Category = tool.Category || "#Other"
			Info.DefaultLowestAllowedLevel = Info.LowestAllowedLevel
			table.insert( list, Info )
			
			umsg.PoolString(Info.DisplayName)
			umsg.PoolString(Info.InternalName)
			umsg.PoolString(Info.LowestAllowedLevel)
			umsg.PoolString(Info.Category)
		end
		
		return true

	end

	local function FillSwepList(list)

		local sweps = weapons.GetList() 
		
		for _,wep in pairs(sweps) do
			
			if (wep.Spawnable || wep.AdminSpawnable) then
				
				local Info = {}
				Info.DisplayName = wep.PrintName || wep.ClassName
				Info.InternalName = wep.ClassName
				Info.Category = wep.Category || "#Other"
				if (!wep.Spawnable && wep.AdminSpawnable) then
					Info.LowestAllowedLevel = "admin"
				else
					Info.LowestAllowedLevel = "user"
				end
				Info.DefaultLowestAllowedLevel = Info.LowestAllowedLevel
				table.insert( list, Info )

				umsg.PoolString(Info.DisplayName)
				umsg.PoolString(Info.InternalName)
				umsg.PoolString(Info.LowestAllowedLevel)
				umsg.PoolString(Info.Category)
			
			end
			
		end
		
		return true

	end
	
	local function FillSentList(list)

		local sents = scripted_ents.GetSpawnable()
		
		for _,sent in pairs(sents) do
			
			if (sent.Spawnable || sent.AdminSpawnable) then
				local Info = {}
				Info.DisplayName = sent.PrintName || sent.ClassName
				Info.InternalName = sent.ClassName
				Info.Category = sent.Category || "Other"
				if (!sent.Spawnable && sent.AdminSpawnable) then
					Info.LowestAllowedLevel = "admin"
				else
					Info.LowestAllowedLevel = "user"
				end
				Info.DefaultLowestAllowedLevel = Info.LowestAllowedLevel
				table.insert( list, Info )

				umsg.PoolString(Info.DisplayName)
				umsg.PoolString(Info.InternalName)
				umsg.PoolString(Info.InternalName)
				umsg.PoolString(Info.Category)
			end
			
		end
		
		return true

	end
	
	function PLUGIN:InitList( name, text, fnFill )
	
		ASS.Config.Register("restrict_"..name, {} )
		ASS.Config.AddPermission("sandbox_restrict_" .. name, "Sandbox|Restrict|" .. text,		"admin")
		
		umsg.PoolString(name)
		
		local items = {}
		if (fnFill(items)) then
			self.Lists[name] = {}
			self.Lists[name].Text = text
			self.Lists[name].Items = items
			return true
		end
		
		return false
	
	end
	
	function PLUGIN:ReadFromConfig()
		for name, info in pairs(self.Lists) do
			local cfg = ASS.Config.Get("restrict_" .. name) or {}
			if (type(cfg) != "table") then cfg = {} end
			
			for item,level in pairs(cfg) do
				self:SetListAllowed(name, item, level)
			end
		end
	end
	
	function PLUGIN:WriteToConfig()
		for name, info in pairs(self.Lists) do
			local cfg = {}
			
			for _, item in pairs(info.Items) do
				if (item.DefaultLowestAllowedLevel != item.LowestAllowedLevel) then
					cfg[ item.InternalName ] = item.LowestAllowedLevel
				end
			end
			
			ASS.Config.Set("restrict_" .. name, cfg)
		end
		
		ASS.Config.Write()
	end
	
	function PLUGIN:Activate()
		
		ASS.Config.AddPermission("sandbox_sweplimit", "Sandbox|Restrict|Weapons",	"admin")
		ASS.Config.AddPermission("sandbox_sentlimit", "Sandbox|Restrict|Entities",	"admin")
		
		concommand.Add( "ASS_Sandbox_Restrict_GetList", function(P,C,A) self:CC_GetList(P,A) end )
		concommand.Add( "ASS_Sandbox_Restrict_SetItem", function(P,C,A) self:CC_SetItem(P,A) end )

		if (!self.Lists) then
		
			self.Lists = {}
			
			self:InitList( "tools", "Tools",		FillToolList )
			self:InitList( "sweps", "Weapons",	FillSwepList )
			self:InitList( "send",	"Entities", FillSentList )
			
			self:ReadFromConfig()
		
		end
		
	end

	function PLUGIN:SetListAllowed(TYPE, NAME, LEVEL)
	
		if (!self.Lists[TYPE]) then return end
	
		for _,info in pairs(self.Lists[TYPE]) do
			if (info.InternalName == NAME) then
				info.LowestAllowedLevel = LEVEL
				break
			end
		end
	
	end

	function PLUGIN:GetListLevel(TYPE, NAME)
		if (!self.Lists[TYPE]) then return end
	
		for _,info in pairs(self.Lists[TYPE]) do
			if (info.InternalName == NAME) then
				return info.LowestAllowedLevel || "guest"
			end
		end
		
		return "guest"
		
	end

	function PLUGIN:SendListToPlayer(PLAYER,TYPE)
		if (!self.Lists[TYPE]) then return end

		umsg.Start( "ASS:SandBox.Restrict.Init", PLAYER )
			umsg.Long( #self.Lists[TYPE].Items )
			umsg.String( TYPE )
			umsg.String( self.Lists[TYPE].Text )
		umsg.End()
		
		local timediff = 0
		for _,info in pairs(self.Lists[TYPE].Items) do
			timer.Simple( timediff, 
				function()
					if (!PLAYER:IsValid()) then return end
					umsg.Start( "ASS:SandBox.Restrict.Item", PLAYER )
						umsg.String( TYPE )
						umsg.String( info.DisplayName )
						umsg.String( info.InternalName )
						umsg.String( info.Category )
						umsg.String( info.LowestAllowedLevel )
					umsg.End()
				end )
			timediff = timediff + 0.01
		end		
				
		timer.Simple( timediff, 
			function()
				if (!ValidEntity(PLAYER)) then return end
				umsg.Start( "ASS:SandBox.Restrict.GUI", PLAYER )
					umsg.String( TYPE )
				umsg.End()
			end )
	end
	
	function PLUGIN:CC_SetItem(PLAYER, ARGS)
		
		local TYPE = ARGS[1]
		local NAME = ARGS[2]
		local LEVEL = ARGS[3]

		if (!TYPE || !NAME || !LEVEL) then
			return
		end
		
		if (!ASS.Groups.IsValid(LEVEL)) then
			return
		end
			
		if (ASS.Config.HasPermission(PLAYER, "sandbox_restrict_" .. TYPE)) then
		
			self:SetListAllowed(TYPE, NAME, LEVEL)
			self:WriteToConfig()
		
		end

	end
	
	function PLUGIN:CC_GetList(PLAYER, ARGS)

		local TYPE = ARGS[1]
		self:SendListToPlayer(PLAYER, TYPE)
		
	end
	
	-- TODO: Actually stop tools/sweps/sents being used,
	
end

if (CLIENT) then

	function PLUGIN:Activate()
		usermessage.Hook("ASS:SandBox.Restrict.Init", function(UM) self:RecieveInitMsg(UM) end )
		usermessage.Hook("ASS:SandBox.Restrict.Item", function(UM) self:RecieveItemMsg(UM) end )
		usermessage.Hook("ASS:SandBox.Restrict.GUI", function(UM) self:RecieveGUIMsg(UM) end )
		self.Items = {}
	end
	
	function PLUGIN:RecieveInitMsg(UM)
		local Count = UM:ReadLong()
		local Type = UM:ReadString()
		local Text = UM:ReadString()
		
		self.Items[Type] = {}
		self.Items[Type].Type = Type
		self.Items[Type].Expected = Count
		self.Items[Type].Text = Text
		self.Items[Type].Items = {}

		ASS.Progress.Init("RestrictList_" .. Type, "Downloading " .. Text .. " list...", Count)
	end

	function PLUGIN:RecieveItemMsg(UM)
		local Type = UM:ReadString()
		
		local Display = UM:ReadString()
		local Internal = UM:ReadString()
		local Category = UM:ReadString()
		local Level = UM:ReadString()
		
		local Item = { DisplayName = Display, InternalName = Internal, Category = Category, LowestAllowedLevel = Level }
		table.insert( self.Items[Type].Items, Item )

		if (Type == "sweps") then
			local wep = weapons.GetStored(Item.InternalName)
			if (wep && wep.PrintName) then
				Item.DisplayName = wep.PrintName
			end
		end

		ASS.Progress.Increment("RestrictList_" .. Type, 1)
	end

	function PLUGIN:RecieveGUIMsg(UM)
		local Type = UM:ReadString()

		ASS.Progress.Remove("RestrictList_" .. Type)
		
		self:ShowRestrictGUI( self.Items[Type] )
	end
	
	function PLUGIN:BuildGamemodeMenu(MENU)
		if (ASS.Config.HasPermission("sandbox_limits")) then
		
			MENU:AddSubMenu( "Restrict", nil,
					function(SUBMENU)
						SUBMENU:AddOption("Tools",		function() ASS.Command("ASS_Sandbox_Restrict_GetList","tools") end )
						SUBMENU:AddOption("Weapons",	function() ASS.Command("ASS_Sandbox_Restrict_GetList","sweps") end )
						SUBMENU:AddOption("Entities",	function() ASS.Command("ASS_Sandbox_Restrict_GetList","sents") end )
					end )
		
		end
	end
	
	function PLUGIN:ShowRestrictGUI(INFO)

		local TE = vgui.Create("DToolRestrictFrame")
		TE:SetBackgroundBlur( true )
		TE:SetDrawOnTop( true )
		TE:SetTitle("Restrict " .. INFO.Text .. "...")
		TE:SetMode(INFO.Type)

		local category = nil
		for k,v in pairs(INFO.Items) do
			TE:AddItem( v.Category, v.DisplayName, v.InternalName, v.LowestAllowedLevel )
		end

		TE:SetVisible( true )
		TE:SetWide(300)
		TE:PerformLayout()
		TE:Center()
		TE:MakePopup()	

	end


////////////////////////////////////////////////////////////////////////////////////
// DToolRestrictLine
////////////////////////////////////////////////////////////////////////////////////

	PANEL = {}

	function PANEL:Init()

		self.AdminItems = {}
		self.Label = vgui.Create("DLabel", self)
		self.Value = vgui.Create("DMultiChoice", self)
		self.Value:SetEditable(false)
		self.Value.OnSelect = function(self, index, value, data) self.Selected = data end
		
		for n, v in pairs(ASS.Groups.LevelsOrdered) do
			self.AdminItems[ v.name ] = self.Value:AddChoice( v.text, v.name )
		end

	end

	function PANEL:Setup( DisplayName, InternalName, AllowedLevel )
	
		self.InternalName = InternalName
		self.InitialValue = AllowedLevel
		
		self.Label:SetText(DisplayName)
		self.Value.Selected = AllowedLevel
		if (ASS.Groups.Levels[AllowedLevel]) then
			self.Value:ChooseOption( ASS.Groups.Levels[AllowedLevel].text, self.AdminItems[AllowedLevel] )
		end
	
	end
	
	function PANEL:PerformLayout()

		derma.SkinHook( "Layout", "Panel", self )	
		
		self.Label:SizeToContents()
		self.Label:SetPos( self:GetWide() - 100 - 4 -self.Label:GetWide() - 4, 4)
		
		self.Value:SetWide(100)
		self.Value:SetPos(self:GetWide() - 100 - 4, 4)
		
	end

	derma.DefineControl( "DToolRestrictLine", "Tool restrict line", PANEL, "Panel" )
	
////////////////////////////////////////////////////////////////////////////////////
// DToolRestrictFrame
////////////////////////////////////////////////////////////////////////////////////

	PANEL = {}

	function PANEL:Init()

		self.Categories = {}
		self.Items = {}
		
		self.List = vgui.Create("DPanelList", self)
		self.List:EnableVerticalScrollbar()

		self.ApplyButton = vgui.Create("DButton", self)
		self.ApplyButton:SetText("Apply")
		self.ApplyButton.DoClick = function(BTN) self:ApplySettings() end

		self.CancelButton = vgui.Create("DButton", self)
		self.CancelButton:SetText("Cancel")
		self.CancelButton.DoClick = function(BTN) self:Close() end
	end
	
	function PANEL:SetMode( m )
		self.Mode = m
	end

	function PANEL:AddItem( Category, DisplayName, InternalName, LowestLevel )
	
		if (!self.Categories[Category]) then

			local CategoryPanel = vgui.Create("DCollapsibleCategory")
			CategoryPanel:SetLabel( "#" .. Category ) 
			self.List:AddItem(CategoryPanel)
		
			local CategoryContent = vgui.Create( "DPanelList" ) 
				CategoryContent:SetAutoSize( true ) 
				CategoryContent:SetDrawBackground( false ) 
				CategoryContent:SetSpacing( 0 ) 
				CategoryContent:SetPadding( 4 ) 

			CategoryPanel:SetExpanded( expand )
			CategoryPanel:SetContents( CategoryContent ) 

			self.Categories[Category] = CategoryContent
		
		end
		
		local item = vgui.Create("DToolRestrictLine")
		item:Setup( DisplayName, InternalName, LowestLevel )

		self.Categories[Category]:AddItem(item)
		table.insert(self.Items, item)
	
	end
	
	function PANEL:ApplySettings()
		for k,v in pairs(self.Items) do
			local NewValue = v.Value.Selected
			
			if (NewValue != v.InitialValue) then
				RunConsoleCommand("ASS_Sandbox_Restrict_SetItem", self.Mode, v.InternalName, NewValue )
				v.InitialValue = NewValue
			end
		end
	end

	function PANEL:PerformLayout()

		derma.SkinHook( "Layout", "Frame", self )

		self.List:SetTall(300)

		self.CancelButton:SizeToContents()
		self.ApplyButton:SizeToContents()
		
		local btnWid = self.CancelButton:GetWide()
		if (self.ApplyButton:GetWide() > btnWid) then
			btnWid = self.ApplyButton:GetWide()
		end
		btnWid = btnWid + 16

		local btnHei = self.CancelButton:GetTall()
		if (self.ApplyButton:GetTall() > btnHei) then
			btnHei = self.ApplyButton:GetTall()
		end
		btnHei = btnHei + 8
		
		self.CancelButton:SetWide(btnWid)
		self.CancelButton:SetTall(btnHei)

		self.ApplyButton:SetWide(btnWid)
		self.ApplyButton:SetTall(btnHei)

		local height = 32

			height = height + self.List:GetTall()
			height = height + 8
			height = height + btnHei
			height = height + 8

		self:SetTall(height)

		local width = self:GetWide()

		self.List:SetPos( 8, 32 )
		self.List:SetWide( width - 16 )

		local btnY = 32 + self.List:GetTall() + 8
		self.CancelButton:SetPos( width - 8 - btnWid, btnY )
		self.ApplyButton:SetPos( width - 8 - btnWid - 8 - btnWid, btnY )
	end
	derma.DefineControl( "DToolRestrictFrame", "Frame to restrict tools", PANEL, "DFrame" )

end

