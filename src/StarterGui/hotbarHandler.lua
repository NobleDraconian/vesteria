local httpService = game:GetService("HttpService")

local module = {}


module.xboxHotbarKeys = {
	{keyCode = Enum.KeyCode.ButtonX; image = "rbxassetid://2528905407"};
	{keyCode = Enum.KeyCode.ButtonY; image = "rbxassetid://2528905431"};
	{keyCode = Enum.KeyCode.ButtonB; image = "rbxassetid://2528905016"};
	{keyCode = Enum.KeyCode.ButtonL1; image = "rbxassetid://2528905196"};
	{keyCode = Enum.KeyCode.ButtonR1; image = "rbxassetid://2528905316"};
	{keyCode = Enum.KeyCode.DPadUp; image = "rbxassetid://2528905167"};
	{keyCode = Enum.KeyCode.DPadRight; image = "rbxassetid://2528905134"};
	{keyCode = Enum.KeyCode.DPadDown; image = "rbxassetid://2528905076"};
	{keyCode = Enum.KeyCode.DPadLeft; image = "rbxassetid://2528905102"};
	{keyCode = Enum.KeyCode.ButtonSelect; image = "rbxassetid://2528905387"};
}

local selected = false

module.captureFocus = function()
	warn("hotbarHandler.captureFocus not ready!")
end

module.releaseFocus = function()
	warn("hotbarHandler.releaseFocus not ready!")
end

function module.postInit(Modules)

	local function updateAmbient()
		local amb = game.Lighting.OutdoorAmbient
		local r, g, b = (amb.r ^ 2.4) * 4, (amb.g ^ 2.4) * 4, (amb.b ^ 2.4) * 4
		local col = Color3.new(r, g, b) 
		
		script.Parent.Frame.ImageLabel.ImageColor3 = col
		script.Parent.Parent.money.ImageColor3 = Color3.fromRGB(85 * r, 93 * g, 104 * b)
	end
	
	updateAmbient()
	
	game.Lighting:GetPropertyChangedSignal("OutdoorAmbient"):connect(updateAmbient)
	
	local network = Modules.network
	local utilities = Modules.utilities
	local mapping = Modules.mapping
	local uiCreator = Modules.uiCreator
	local tween = Modules.tween
	local projectile = Modules.projectile
	
	local placeSetup = Modules.placeSetup
	local entitiesFolder = placeSetup.awaitPlaceFolder("entities")

	
	-- the whild ber, in a 3 am frenzy, decides this is the best course of action to fix that one goddamn bug
	--spawn(function()
	
	local replicatedStorage = game.ReplicatedStorage
	
	local itemData = require(replicatedStorage.itemData)
	local abilityLookup = require(replicatedStorage.abilityLookup)
	
	local player = game.Players.LocalPlayer
	
	local tweenService = game:GetService("TweenService")
	
	-- equipment, consumable, miscellaneous
	local lastHotbarDataReceived = nil
	local lastInventoryDataReceived = nil
	local hotbarSlotPairing = {}
	
	for i,child in pairs(script.Parent.content:GetChildren()) do
		if child:IsA("ImageButton") then
			child:Destroy()
		end
	end
	
	local function getInventoryCountLookupTableByItemId()
		local lookupTable = {}
		
		for i, inventorySlotData in pairs(lastInventoryDataReceived) do
			if lookupTable[inventorySlotData.id] then
				lookupTable[inventorySlotData.id] = lookupTable[inventorySlotData.id] + (inventorySlotData.stacks or 1)
			else
				lookupTable[inventorySlotData.id] = inventorySlotData.stacks or 1
			end
		end
		
		return lookupTable
	end
	
	local function abilityLevelFromAbilityData(abilityData, abilityId)
		for i,ability in pairs(abilityData) do
			if ability.id == abilityId then
				return ability.rank
			end
		end	
	end
	
	local hotbarButtonClicked = Instance.new("BindableEvent")
	
	-- none of this should be in hotbarHandler
	-- but here it is anyways, this is the price of victory
	-- Davidii
	local function doAbilityTargetingImpl(abilityId, initialKeyCode)
		-- we only do this if we're on a touch screen
		
		-- todo: local setting
		if not game:GetService("UserInputService").TouchEnabled then return true end
		if not abilityId then return false end
		
		local playerData = network:invoke("getLocalPlayerDataCache")
		local abilityData = abilityLookup[abilityId](playerData)
		if not abilityData then return false end
		
		local player = game.Players.LocalPlayer
		if not player then return false end
		
		local char = player.Character
		if not char then return false end
		
		local manifest = char.PrimaryPart
		if not manifest then return false end
		
		local entityContainer = network:invoke("getMyClientCharacterContainer")
		if not entityContainer then return false end
		
		local abilityRank = abilityLevelFromAbilityData(network:invoke("getCacheValueByNameTag", "abilities"), abilityId)
		local statistics = Modules.ability_utilities.getAbilityStatisticsForRank(abilityData, abilityRank)
		
		-- targeting data tells us what to do
		-- if we don't have any, just say we targeted successfully
		local targetingData = abilityData.targetingData
		if not targetingData then
			return true
		end
		
		-- some stuff can cancel targeting, this bool helps us handle that
		local canceled = false
		
		local function getTargetingValue(key)
			local value = targetingData[key]
			
			if typeof(value) == "string" then
				if statistics[value] then
					value = statistics[value]
				elseif abilityData[value] then
					value = abilityData[value]
				end
			
			elseif typeof(value) == "function" then
				value = value(network:invoke("getAbilityExecutionData", abilityId))
			end
			
			return value
		end
		
		local function waitForTargetingConfirmation(updateFunction)
			local cas = game:GetService("ContextActionService")
			local heartbeat = game:GetService("RunService").Heartbeat
			local waiting = true
			
			local hotbarKeyCodes = {} do
				for _, keyCode in pairs(network:invoke("getHotbarKeyCodes")) do
					if keyCode ~= initialKeyCode then
						table.insert(hotbarKeyCodes, keyCode)
					end
				end
			end
			
			-- sink all hotbar keys, mouse, and touch
			cas:BindAction(
				"confirmTargeting",
				
				function(name, state, input)
					if state ~= Enum.UserInputState.Begin then return end
					
					waiting = false
				end,
				
				false,
				
				Enum.UserInputType.MouseButton1,
				Enum.UserInputType.Touch,
				unpack(hotbarKeyCodes)
			)
			
			cas:BindAction(
				"cancelTargeting",
				
				function(name, state, input)
					if state ~= Enum.UserInputState.Begin then return end
					
					canceled = true
					waiting = false
				end,
				
				false,
				
				-- default to a non-existent keycode if we don't have one
				initialKeyCode or Enum.KeyCode.Unknown
			)
			
			local hotbarButtonClickedConn
			hotbarButtonClickedConn = hotbarButtonClicked.Event:Connect(function()
				canceled = true
				waiting = false
				hotbarButtonClickedConn:Disconnect()
			end)
			
			while waiting do
				updateFunction(network:invoke("getAbilityExecutionData", abilityId))
				heartbeat:Wait()
			end
			
			cas:UnbindAction("confirmTargeting")
			cas:UnbindAction("cancelTargeting")
			hotbarButtonClickedConn:Disconnect()
		end
		
		local function createTargetingPart()
			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.TopSurface = Enum.SurfaceType.Smooth
			part.BottomSurface = Enum.SurfaceType.Smooth
			part.Material = Enum.Material.ForceField
			part.Color = Color3.new(0.75, 0.75, 0.75)
			part.Transparency = 0.5
			part.CastShadow = false
			return part
		end
		
		local customFunctionData, customFunctionGuid
		if targetingData.onStarted then
			customFunctionGuid = httpService:GenerateGUID()
			local abilityExecutionData = network:invoke("getAbilityExecutionData", abilityId)
			
			customFunctionData = targetingData.onStarted(
				entityContainer,
				abilityExecutionData
			)
			
			network:fireServer("abilityTargetingSequenceStarted", abilityId, customFunctionGuid, manifest, abilityExecutionData)
		end
		
		----
		-- direct sphere
		-- a sphere of radius radius at maximum range range
		-- no projectile involved
		----
		if targetingData.targetingType == "directSphere" then
			local range = getTargetingValue("range")
			
			local sphere = createTargetingPart()
			sphere.Shape = Enum.PartType.Ball
			sphere.Size = Vector3.new(2, 2, 2) * getTargetingValue("radius")
			sphere.Parent = entitiesFolder
			
			waitForTargetingConfirmation(function(executionData)
				local there = executionData["mouse-target-position"]
				local here = manifest.Position
				local delta = there - here
				local distance = delta.Magnitude
				if distance > range then
					there = here + (delta / distance) * range
				end
				sphere.Position = there
			end)
			
			sphere:Destroy()
		
		----
		-- direct cylinder
		-- like sphere except we show a cylinder instead
		-- revolutionary i know
		----
		elseif targetingData.targetingType == "directCylinder" then
			local range = getTargetingValue("range")
			
			local cylinder = createTargetingPart()
			cylinder.Shape = Enum.PartType.Cylinder
			cylinder.Size = Vector3.new(2, 2, 2) * getTargetingValue("radius")
			cylinder.Parent = entitiesFolder
			
			waitForTargetingConfirmation(function(executionData)
				local there = executionData["mouse-target-position"]
				local here = manifest.Position
				local delta = there - here
				local distance = delta.Magnitude
				if distance > range then
					there = here + (delta / distance) * range
				end
				cylinder.CFrame = CFrame.new(there) * CFrame.Angles(0, 0, math.pi / 2)
			end)
			
			cylinder:Destroy()
		
		----
		-- line
		-- an area of a certain length and width
		-- issues forth from the character
		-- kinda specific? but hey
		----
		elseif targetingData.targetingType == "line" then
			local width = getTargetingValue("width")
			local length = getTargetingValue("length")
			
			local box = createTargetingPart()
			box.Size = Vector3.new(width, width, length)
			box.Parent = entitiesFolder
			
			waitForTargetingConfirmation(function(executionData)
				local here = manifest.Position
				local there = executionData["mouse-target-position"]
				local delta = (there - here) * Vector3.new(1, 0, 1)
				box.CFrame = CFrame.new(here, here + delta) * CFrame.new(0, 0, -length / 2)
			end)
			
			
			
			box:Destroy()
		
		----
		-- projectile
		-- a projectile with a certain gravity and speed
		-- single target, no area of effect
		----
		elseif targetingData.targetingType == "projectile" then
			local entity = entityContainer:FindFirstChild("entity")
			if not entity then return false end
			
			local projectionPart =
				(customFunctionData and customFunctionData.projectionPart) or
				entity:FindFirstChild("RightHand")
			if not projectionPart then return false end
			
			local speed = getTargetingValue("projectileSpeed")
			local gravity = getTargetingValue("projectileGravity")
			
			local function getPosition()
				if projectionPart:IsA("Attachment") then
					return projectionPart.WorldPosition
				else
					return projectionPart.Position
				end
			end
			
			local function getDirection(targetPosition)
				return projectile.getUnitVelocityToImpact_predictive(getPosition(), speed, targetPosition, Vector3.new(), gravity)
			end
			
			local beam, attach0, attach1 = projectile.showProjectilePath(getPosition(), Vector3.new(), 3, gravity)
			
			waitForTargetingConfirmation(function(executionData)
				local direction = getDirection(executionData["mouse-target-position"])
				if direction then
					projectile.updateProjectilePath(beam, attach0, attach1, getPosition(), direction * speed, 3, gravity)
				end
			end)
			
			beam:Destroy()
			attach0:Destroy()
			attach1:Destroy()
		end
		
		if targetingData.onEnded then
			local abilityExecutionData = network:invoke("getAbilityExecutionData", abilityId)
			
			targetingData.onEnded(
				entityContainer,
				abilityExecutionData,
				customFunctionData
			)
			
			network:fireServer("abilityTargetingSequenceEnded", abilityId, customFunctionGuid, manifest, abilityExecutionData)
		end
		
		if canceled then
			return false
		end
		
		return true
	end

	local abilityTargetingActive = false
	local function doAbilityTargeting(...)
		if abilityTargetingActive then return false end
		-- swap the above line for this for behavior that
		-- simply ensures thread safety instead of cancelling
		-- superfluous requests:
		-- while abilityTargetingActive do wait() end
		abilityTargetingActive = true
		local retVals = {doAbilityTargetingImpl(...)}
		abilityTargetingActive = false
		return unpack(retVals)
	end
	
	-- capture the events of other targeting sequences... this still shouldn't be here, but it was here,
	-- so this is where it's going to stay. i'm sorry, dad, i know i disappoint you
	local targetingSequenceDataByGuid = {}
--	network:connect("abilityTargetingSequenceStarted", "OnClientEvent", function(abilityId, guid, manifest, executionData)
--		local renderContainer = network:invoke("getPlayerRenderFromManifest", manifest)
--		if not renderContainer then return end
--		
--		local abilityData = abilityLookup[abilityId](nil, executionData)
--		if not abilityData then return end
--		
--		local targetingData = abilityData.targetingData
--		if not targetingData then return end
--		
--		local onStarted = targetingData.onStarted
--		if not onStarted then return end
--		
--		targetingSequenceDataByGuid[guid] = onStarted(renderContainer, executionData)
--	end)
--	network:connect("abilityTargetingSequenceEnded", "OnClientEvent", function(abilityId, guid, manifest, executionData)
--		local renderContainer = network:invoke("getPlayerRenderFromManifest", manifest)
--		if not renderContainer then return end
--		
--		local abilityData = abilityLookup[abilityId](nil, executionData)
--		if not abilityData then return end
--		
--		local targetingData = abilityData.targetingData
--		if not targetingData then return end
--		
--		local onEnded = targetingData.onEnded
--		if not onEnded then return end
--		
--		onEnded(renderContainer, executionData, targetingSequenceDataByGuid[guid])
--	end)
	
	local hotbarButtonDebounce = true
	local function onHotbarButtonDoubleClicked(hotbarButtonItem, ...)
		if not hotbarButtonDebounce then return end
		hotbarButtonDebounce = false
		delay(0.05, function()
			hotbarButtonDebounce = true
		end)
		
		-- let other parts of the code know that another button's been clicked
		hotbarButtonClicked:Fire()
		
		local hotbarSlotData = hotbarSlotPairing[hotbarButtonItem]
		
		if hotbarSlotData then
			local hotbarSlotData = hotbarSlotPairing[hotbarButtonItem]
			
			if hotbarSlotData.dataType == mapping.dataType.item then
				local inventorySlotData = network:invoke("getInventorySlotDataWithItemId", hotbarSlotData.id)
				
				local correspondingBG = script.Parent.decor:FindFirstChild(hotbarButtonItem.Name:gsub("hotbarButton",""))
				if correspondingBG then
					correspondingBG.ImageColor3 = Color3.fromRGB(0, 255, 255)
					tween(correspondingBG,{"ImageColor3"},Color3.fromRGB(72, 72, 76),0.5)
				end				
				
				if inventorySlotData then
					network:invoke("activateItemRequestLocal", inventorySlotData)
				end
			elseif hotbarSlotData.dataType == mapping.dataType.ability then
				local correspondingBG = script.Parent.decor:FindFirstChild(hotbarButtonItem.Name:gsub("hotbarButton",""))
				if correspondingBG then
					correspondingBG.ImageColor3 = Color3.fromRGB(0, 255, 255)
				end
				
				local canActivate, problem = network:invoke("canActivateAbility", hotbarSlotData.id, hotbarButtonItem, ...)
				
				if canActivate then
					local targetingComplete = doAbilityTargeting(hotbarSlotData.id, hotbarSlotData.keyCode)
					
					if targetingComplete then
						local success, err = network:invoke("activateAbilityRequest", hotbarSlotData.id, hotbarButtonItem, ...)
					end
				else
					utilities.playSound("error")
					if correspondingBG then
						correspondingBG.ImageColor3 = Color3.fromRGB(255, 0, 0)
					end
					if problem == "missing-mana" then
						Modules.statusBars.manaWarning()
					end
				end
				
				if correspondingBG then
					tween(correspondingBG,{"ImageColor3"},Color3.fromRGB(72, 72, 76),0.5)
				end
			end
		end
	end
		
		
	local cooldownEndTime	
	local function showConsumableCooldown(duration)
		local durationEndTime = tick() + duration
		cooldownEndTime = durationEndTime
		for hotbarButtonItem, hotbarSlotData in pairs(hotbarSlotPairing) do
			if hotbarSlotData and hotbarSlotData.dataType == mapping.dataType.item then
				if hotbarButtonItem:FindFirstChild("cooldown") then
					hotbarButtonItem.cooldown.Visible = true
				end
			end
		end
		spawn(function()
			wait(duration)
			if cooldownEndTime == durationEndTime then
				for hotbarButtonItem, hotbarSlotData in pairs(hotbarSlotPairing) do
					if hotbarSlotData and hotbarSlotData.dataType == mapping.dataType.item then
						if hotbarButtonItem:FindFirstChild("cooldown") then
							hotbarButtonItem.cooldown.Visible = false
						end									
					end
				end
			end
		end)
	end
	
	network:create("showConsumableCooldown", "BindableFunction", "OnInvoke", showConsumableCooldown)		
	
	local inputShortcuts = {
		One = "1"; KeypadOne = "1";
		Two = "2"; KeypadTwo = "2";
		Three = "3"; KeypadThree = "3";
		Four = "4"; KeypadFour = "4";
		Five = "5"; KeypadFive = "5";
		Six = "6"; KeypadSix = "6";
		Seven = "7"; KeypadSeven = "7";
		Eight = "8"; KeypadEight = "8";
		Nine = "9"; KeypadNine = "9";
		Zero = "0"; KeypadZero = "0";
	}
	
	local buttons = {}
	local RunService = game:GetService("RunService")
	
	local primedAbilityId
	local targetingType = "slow"
	
	local function getHotbarDataByHotbarKey()
		
	end
	
	local function getItemIdFromInventory()
		
	end
	
	local function onGetHotbarSlotDataByHotbarSlotUI(hotbarSlotUI)
		if hotbarSlotUI then
			return hotbarSlotPairing[hotbarSlotUI]
		end
		
		return nil
	end
	
	script.Parent.xboxBinding.Visible = false
	script.Parent.xboxBindPrompt.Visible = false
	
	local function getHotbarSlotDataByHotbarSlotPosition(hotbarSlotPosition)
		if not lastHotbarDataReceived then return end
		
		for i, hotbarSlotData in pairs(lastHotbarDataReceived) do
			if hotbarSlotData.position == hotbarSlotPosition then
				return hotbarSlotData
			end
		end
		
		return nil
	end
	
	local valueCache = {}
	
	-- function to set a property, remembering the original value of the property
	-- if called with nil value, restores to default value
	local function setValue(object, property, value)
		valueCache[object] = valueCache[object] or {}
		if valueCache[object][property] == nil then
			valueCache[object][property] = object[property]
		end
		if value then
			object[property] = value
		else
			object[property] = valueCache[object][property]
		end
	end
	local function setValues(valueTable)
		for i, entry in pairs(valueTable) do
			setValue(entry[1], entry[2], entry[3])
		end
	end
	
	local function inputUpdate()
		
		script.Parent.selectedDecor.Visible = Modules.input.mode.Value == "xbox"
		
		if Modules.input.mode.Value == "mobile" then
			setValues({
				{script.Parent.Parent.statusBars, "Position", UDim2.new(0.25,0,1,-70)};
				{script.Parent.Parent.Parent.statusEffects, "Position", UDim2.new(0,5,1,-110)};
				{script.Parent.content, "Position", UDim2.new(1,-220,1,-216)};
				{script.Parent.content, "Size", UDim2.new(0,200,0,190)};
				{script.Parent.decor, "Position", UDim2.new(1,-220,1,-220)};
				{script.Parent.decor, "Size", UDim2.new(0,200,0,200)};
				{script.Parent, "Size", UDim2.new(1.2,0,0,60)};
				{script.Parent.decor.UIGridLayout, "StartCorner", "BottomRight"};
				{script.Parent.content.UIGridLayout, "StartCorner", "BottomRight"};
			})
		else
			setValues({
				{script.Parent.Parent.statusBars, "Position"};
				{script.Parent.Parent.Parent.statusEffects, "Position"};
				{script.Parent.content, "Position"};
				{script.Parent.content, "Size"};
				{script.Parent.decor, "Position"};
				{script.Parent.decor, "Size"};
				{script.Parent, "Size"};
				{script.Parent.decor.UIGridLayout, "StartCorner"};
				{script.Parent.content.UIGridLayout, "StartCorner"};				
			})
		end	
		
	end	
	
	Modules.input.mode.changed:connect(inputUpdate)
	inputUpdate()
	
	script.Parent.selectedDecor.ImageTransparency = 1
	for i,decor in pairs(script.Parent.selectedDecor:GetChildren()) do
		decor.ImageTransparency = 1
	end
	
	module.focused = false
	
	local lastButtonFrom
	
	local promptButtonFrom
	
	function module.showSelectionPrompt(buttonFrom)
		promptButtonFrom = buttonFrom
		script.Parent.xboxBindPrompt.contents.itemIcon.Image = buttonFrom.Image
		script.Parent.xboxBindPrompt.Visible = true
	end
	
	function module.hideSelectionPrompt(buttonFrom)
		if promptButtonFrom == buttonFrom then
			script.Parent.xboxBindPrompt.Visible = false
		end
	end
	
	local lastFocus
	
	module.captureFocus = function()
		if not module.focused then
			module.focused = true
			
			script.Parent.xboxBinding.Visible = false
			
			for i,hotbarButton in pairs(script.Parent.content:GetChildren()) do
				if hotbarButton:FindFirstChild("xboxPrompt") then
					hotbarButton.xboxPrompt.Visible = true
				end
			end
			
			local selectedObject = game.GuiService.SelectedObject
			if selectedObject and selectedObject:FindFirstChild("bindable") then
				lastButtonFrom = selectedObject
				script.Parent.xboxBinding.contents.curveBG.itemIcon.Image = selectedObject.Image
				script.Parent.xboxBinding.Visible = true
				
				lastFocus = Modules.focus.focused
				game.GuiService.GuiNavigationEnabled = false
				
				for i,hotbarButton in pairs(script.Parent.content:GetChildren()) do
					if hotbarButton:FindFirstChild("xboxPrompt") then
						hotbarButton.xboxPrompt.Visible = true
					end
				end	
			else
				lastButtonFrom = nil
				tween(script.Parent.selectedDecor,{"ImageTransparency"},0,0.3)
				for i,decor in pairs(script.Parent.selectedDecor:GetChildren()) do
					local val = tonumber(decor.Name)
					if val then
						tween(decor,{"ImageTransparency"},val,1-val)
					end
				end								
			end
			
			--script.Parent.gamepadPrompt.close.Visible = true
			--script.Parent.gamepadPrompt.open.Visible = false
		end
	end
	
	-- modules.uiCreator.processSwap(buttonFrom, buttonTo, isRightClickTrigger)
	
	
	--[[
	module.promptNewBinding = function(buttonFrom)
		if not module.focused then
			module.focused = true
			lastButtonFrom = buttonFrom
			script.Parent.xboxBinding.Visible = true
			
			for i,hotbarButton in pairs(script.Parent.content:GetChildren()) do
				if hotbarButton:FindFirstChild("xboxPrompt") then
					hotbarButton.xboxPrompt.Visible = true
				end
			end			
		end
	end
	]]
	
	module.releaseFocus = function(input)
		local endFocus = input == nil or input.KeyCode == Enum.KeyCode.ButtonL2

		if input then
			for i,hotbarButton in pairs(script.Parent.content:GetChildren()) do
				if hotbarButton:FindFirstChild("xboxKeyCode") then
					if input.KeyCode.Name == hotbarButton.xboxKeyCode.Value then
						if script.Parent.xboxBinding.Visible and lastButtonFrom then
							Modules.uiCreator.processSwap(lastButtonFrom, hotbarButton, false)
							endFocus = true
						else
							onHotbarButtonDoubleClicked(hotbarButton)	
						end					
					end
				end
			end
		end			
  
		if endFocus then
			script.Parent.xboxBinding.Visible = false
			
			if lastFocus == Modules.focus.focused or game.GuiService.GuiNavigationEnabled == lastButtonFrom then
				game.GuiService.GuiNavigationEnabled = true
			end
		
			for i,hotbarButton in pairs(script.Parent.content:GetChildren()) do
				if hotbarButton:FindFirstChild("xboxPrompt") then
					hotbarButton.xboxPrompt.Visible = false
				end
			end		
			
			if module.focused then
				tween(script.Parent.selectedDecor,{"ImageTransparency"},1,0.3)
				for i,decor in pairs(script.Parent.selectedDecor:GetChildren()) do
					local val = tonumber(decor.Name)
					if val then
						tween(decor,{"ImageTransparency"},1,1-val)
					end
				end
			end
			--script.Parent.gamepadPrompt.close.Visible = false
			--script.Parent.gamepadPrompt.open.Visible = true		
			
			module.focused = false
		end
	end
		
	network:create("getHotbarSlotPairing", "BindableFunction", "OnInvoke", function()
		local pairing = {}
		
		for i=1,10 do
			local button = script.Parent.content:FindFirstChild("hotbarButton"..i)
			if button then		
				table.insert(pairing, {button = button; data = hotbarSlotPairing[button]})
			end
		end
		
		return pairing
	end)

	local hotbarButtonConnections = {}
	
	local function updateButtonItem(hotbarButtonItem, i, flareEffect)
		local trans_i = i % 10
		
		if hotbarButtonConnections[i] then
			for name, connection in pairs(hotbarButtonConnections[i]) do
				connection:Disconnect()
			end
		else
			hotbarButtonConnections[i] = {}
		end

		local buttonConnections = hotbarButtonConnections[i]
		
		local hotbarSlotData = getHotbarSlotDataByHotbarSlotPosition(trans_i)
		hotbarButtonItem.LayoutOrder = i
		hotbarButtonItem.Name = "hotbarButton"..i
		hotbarButtonItem.ImageTransparency = 1
		hotbarButtonItem.Image = ""
		
		-- xbox juiciness
		local xboxInput = module.xboxHotbarKeys[i]
		hotbarButtonItem.xboxPrompt.key.Image = xboxInput.image
		hotbarButtonItem.xboxKeyCode.Value = xboxInput.keyCode.Name
		hotbarButtonItem.duplicateCount.Visible = false
		hotbarButtonItem.level.Visible = false
		local inventoryCountLookupTable = getInventoryCountLookupTableByItemId()
		
		for i,child in pairs(hotbarButtonItem:GetChildren()) do
			if child:FindFirstChild("keyCode") then
				child.ImageTransparency = 0
				child.backdrop.ImageTransparency = 0
				child.keyCode.TextTransparency = 0
				child.keyCode.TextStrokeTransparency = 0
	--			child.shadow.ImageTransparency = 0
			end
		end		
		
		if hotbarSlotData then
			hotbarSlotPairing[hotbarButtonItem] = hotbarSlotData

			local correspondingBG = script.Parent.decor:FindFirstChild(hotbarButtonItem.Name:gsub("hotbarButton",""))
			if correspondingBG then
				correspondingBG.ImageTransparency = 0
			--	if correspondingBG:FindFirstChild("UIGradient") == nil then
			--		local UIGradient = script.UIGradient:Clone()
			--		UIGradient.Parent = correspondingBG
			--	end
--				correspondingBG.shadow.ImageTransparency = 0
			end	

			if hotbarSlotData.dataType == mapping.dataType.item then
				hotbarButtonItem.duplicateCount.Text = tostring(inventoryCountLookupTable[hotbarSlotData.id] or 0)
				
				local itemBaseData = itemData[hotbarSlotData.id]			
				if itemBaseData then
					hotbarButtonItem.Image = itemBaseData.image
					hotbarButtonItem.inputKey.Text = "[" .. tostring(hotbarSlotData.keyCode or trans_i) .. "]"
					hotbarButtonItem.keyCode.Value = tostring(hotbarSlotData.keyCode or trans_i)
					
					uiCreator.setIsDoubleClickFrame(hotbarButtonItem, 0.2, onHotbarButtonDoubleClicked)
					-- add item tooltip

					buttonConnections.hovered = hotbarButtonItem.MouseEnter:connect(function()
						network:invoke("populateItemHoverFrame", itemBaseData, "equipment", hotbarSlotData)
					end)

					buttonConnections.unhovered = hotbarButtonItem.MouseLeave:connect(function()
						network:invoke("populateItemHoverFrame")
					end)

					table.insert(buttons, hotbarButtonItem)
				end
				hotbarButtonItem.duplicateCount.Visible = true
				hotbarButtonItem.ImageTransparency 	= 0
			elseif hotbarSlotData.dataType == mapping.dataType.ability then
				--JAYY LOOK HERE ABILIT STUFF
				local abilityData = network:invoke("getCacheValueByNameTag", "abilities")
				local level = abilityLevelFromAbilityData(abilityData, hotbarSlotData.id)
				
				local playerData = network:invoke("getLocalPlayerDataCache")
				local abilityBaseData = abilityLookup[hotbarSlotData.id](playerData, nil)
				local statistics = Modules.ability_utilities.getAbilityStatisticsForRank(abilityBaseData, level)
				
				if abilityBaseData and statistics then
					local textSize = game.TextService:GetTextSize(hotbarButtonItem.level.Text, hotbarButtonItem.level.TextSize, hotbarButtonItem.level.Font, Vector2.new())
					hotbarButtonItem.level.Size = UDim2.new(0, textSize.X + 2, 0, textSize.Y - 2)
--					hotbarButtonItem.level.Visible = true
					
					hotbarButtonItem.level.Text = utilities.romanNumerals[level]
					local tier = statistics.tier or 1
					hotbarButtonItem.level.TextColor3 = Modules.itemAcquistion.tierColors[tier]
				
					hotbarButtonItem.Image = abilityBaseData.image
					hotbarButtonItem.inputKey.Text = "[" .. tostring(hotbarSlotData.keyCode or trans_i) .. "]"
					hotbarButtonItem.keyCode.Value = tostring(hotbarSlotData.keyCode or trans_i)

					uiCreator.setIsDoubleClickFrame(hotbarButtonItem, 0.2, onHotbarButtonDoubleClicked)
					
					table.insert(buttons, hotbarButtonItem)
				end
				
				hotbarButtonItem.duplicateCount.Visible = false
				hotbarButtonItem.ImageTransparency 	= 0
			else
				
			end
		else
			for i,child in pairs(hotbarButtonItem:GetChildren()) do
				if child:FindFirstChild("keyCode") then
					child.ImageTransparency = 1
					child.backdrop.ImageTransparency = 1
					child.keyCode.TextTransparency = 1
					child.keyCode.TextStrokeTransparency = 1
		--			child.shadow.ImageTransparency = 1
				end
			end	

			local correspondingBG = script.Parent.decor:FindFirstChild(hotbarButtonItem.Name:gsub("hotbarButton",""))
			if correspondingBG then
				correspondingBG.ImageTransparency = 0.5
		--		if correspondingBG:FindFirstChild("UIGradient") then 
		--			correspondingBG.UIGradient:Destroy()
		--		end
		--		correspondingBG.shadow.ImageTransparency = 0.5
			end						
		end	
	end
	
	local function updateHotbar(updateHotbarData)
		if updateHotbarData then
			lastHotbarDataReceived = updateHotbarData
		end
		
		if lastHotbarDataReceived then
			hotbarSlotPairing = {}		
			
			for i = 1, 10 do
			--	local hotbarButtonItem = script.hotbarButton:Clone()
				local hotbarButtonItem = script.Parent.content:FindFirstChild("hotbarButton"..i) or script.hotbarButton:Clone()
				hotbarButtonItem.Name = "hotbarButton"..i
				hotbarButtonItem.Parent = script.Parent.content
				updateButtonItem(hotbarButtonItem, i)
				uiCreator.drag.setIsDragDropFrame(hotbarButtonItem)
			end
		end
	end

	local fx = Modules.fx
	local Rand = Random.new()
	local oldxp = 0

	local function setup()
		local value = network:invoke("getCacheValueByNameTag", "exp")
		local level = network:invoke("getCacheValueByNameTag", "level")
		
		local xp = value
		local needed = math.floor(Modules.levels.getEXPToNextLevel(level))	
		oldxp = value
		script.Parent.Frame.xp.title.Text = "XP: " .. utilities.formatNumber(xp) .. "/" .. utilities.formatNumber(needed)
		script.Parent.Frame.xp.value.Size = UDim2.new(xp/needed,0,1,0)
		script.Parent.Frame.xp.instant.Size = script.Parent.Frame.xp.value.Size
		--[[
		local gold = network:invoke("getCacheValueByNameTag", "gold")
		script.Parent.header.gold.Text = "$"..gold
		]]
	end	
	setup()
	
	script.Parent.Frame.xp.MouseEnter:connect(function()
		script.Parent.Frame.xp.title.Visible = true
		selected = true
	end)
	
	script.Parent.Frame.xp.MouseLeave:connect(function()
		script.Parent.Frame.xp.title.Visible = false
		selected = false
	end)	
	
	local lastStats
	
	local function onPropogationRequestToSelf(propogationNameTag, propogationData)
		if propogationNameTag == "hotbar" then
			updateHotbar(propogationData)
		elseif propogationNameTag == "inventory" then
			lastInventoryDataReceived = propogationData
			updateHotbar()
		elseif propogationNameTag == "abilities" then
			updateHotbar()
		elseif propogationNameTag == "nonSerializeData" then
			local stats = propogationData.statistics_final
			if lastStats == nil then
				lastStats = stats
				updateHotbar()
			else
				for stat, value in pairs(lastStats) do
					if stats[stat] ~= value then
						lastStats = stats
						updateHotbar()
						break
					end
				end	
			end
			
		elseif propogationNameTag == "exp" then
			local key = propogationNameTag
			local value = propogationData
			
			local level = network:invoke("getCacheValueByNameTag", "level")
		
			local xp = value
			local needed = math.floor(Modules.levels.getEXPToNextLevel(level))
			script.Parent.Frame.xp.title.Text = "XP: " .. utilities.formatNumber(xp) .. "/" .. utilities.formatNumber(needed)
		
			-- ahh crying internally
			
			local change = xp - oldxp

			local notice = script.Parent.Frame.noticeTemplate:Clone()
			notice.Name = "Notice"
			notice.TextTransparency = 1
			notice.TextStrokeTransparency = 1
			notice.Parent = script.Parent.Frame
			notice.Visible = true
			notice.Text = "+"..utilities.formatNumber(change).." EXP"	
			notice.Position = UDim2.new(0.5,Rand:NextInteger(-50,50),0,Rand:NextInteger(-30,40))
			Modules.tween(notice,{"Position"},notice.Position + UDim2.new(0,0,0,-100),3)
			Modules.tween(notice,{"TextTransparency","TextStrokeTransparency"},{0,0.7},1.5)
			game.Debris:AddItem(notice, 10)
			local sampleParticle = script.Parent.Frame.xp.value.value.tip.sample
			
			for i=1,6 do
				local particle = sampleParticle:Clone()
				particle.Rotation = math.random(1,90)
				particle.Parent = sampleParticle.Parent
				particle.Visible = true
				tween(particle,{"Rotation", "Position", "Size", "BackgroundTransparency"},
				{particle.Rotation + math.random(100,200), UDim2.new(0, math.random(3,25),0.5,math.random(-20,20)), UDim2.new(0,16,0,16), 1},math.random(60,130)/100)
				game.Debris:AddItem(particle,1.5)
			end
			
			if xp < oldxp then
				Modules.tween(script.Parent.Frame.xp.value,{"Size"},{UDim2.new(1,0,1,0)},0.5)
				script.Parent.Frame.xp.instant.Size = UDim2.new(1,0,1,0)
				spawn(function()
					wait(0.25)
					script.Parent.Frame.xp.value.Size = UDim2.new(1,0,0,0)
					local goal = UDim2.new(xp/needed,0,1,0)
					Modules.tween(script.Parent.Frame.xp.value,{"Size"},{goal},0.5)
					script.Parent.Frame.xp.instant.Size = goal
				end)
			else
				Modules.tween(script.Parent.Frame.xp.value,{"Size"},{UDim2.new(xp/needed,0,1,0)},1)
				script.Parent.Frame.xp.instant.Size = UDim2.new(xp/needed,0,1,0)
			end
			
			script.Parent.Frame.xp.Visible = true
			oldxp = value
			
			spawn(function()
				wait(0.5)
				Modules.tween(notice,{"TextTransparency","TextStrokeTransparency"},{1,1},1.5)
				wait(3)
				if oldxp == value and not selected then
				--	script.Parent.Frame.xp.Visible = false
				end
			end)
		end
	end
	
	local function main()
		lastInventoryDataReceived = network:invoke("getCacheValueByNameTag", "inventory")

		local hotbarBinds = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"}
		-- setup input
		for i=1,10 do
			local ei = i % 10
			network:invoke("addInputAction","hotbarButton"..i,function(inputObject)
				local button = script.Parent.content:FindFirstChild("hotbarButton"..i)
				if button then
					local hotbarSlotData = hotbarSlotPairing[button]
					if hotbarSlotData then
						hotbarSlotData.keyCode = inputObject.KeyCode
					end
					
					onHotbarButtonDoubleClicked(button)
				end
			end, hotbarBinds[i],10)
		end

		updateHotbar(network:invoke("getCacheValueByNameTag", "hotbar"))
		network:connect("propogationRequestToSelf", "Event", onPropogationRequestToSelf)
		network:create("getHotbarSlotDataByHotbarSlotUI", "BindableFunction", "OnInvoke", onGetHotbarSlotDataByHotbarSlotUI)
	end
	
	main()
	module.releaseFocus()	
--	end)
end

return module
