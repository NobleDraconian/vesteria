-- Resources
-- Rocky28447
-- June 2, 2020



local Resources = {}

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedModules
local Network
local Thread


function Resources:DoEffect(node, effect)
	local nodeMetadata = node.Parent.Parent.Parent.Metadata
	local effectFolder = nodeMetadata.EffectsStorage:FindFirstChild(effect)
	
	if effectFolder then
		for _, effect in pairs (effectFolder:GetChildren()) do
			local effectClone = effect:Clone()
			effectClone.Parent = node.PrimaryPart
			
			if effectClone:IsA("Sound") then
				effectClone:Play()
			elseif effectClone:IsA("ParticleEmitter") then
				effectClone:Emit(effectClone.Rate)
			end
			
			Thread.Delay(10, function()
				effectClone:Destroy()
			end)
		end
	end
end


function Resources:Start()
	
	Network:connect("ResourceHarvested", "OnClientEvent", function(node, dropPoint)
		local nodeMetadata = require(node.Parent.Parent.Parent.Metadata)
		local onHarvest = nodeMetadata.Animations.OnHarvest
		
		if onHarvest and type(onHarvest) == "function" then
			onHarvest(node, dropPoint)
		else
			self:DoEffect(node, "Harvest")
		end
			
		if dropPoint then
			dropPoint.Transparency = 1
		end
	end)
	
	Network:connect("ResourceReplenished", "OnClientEvent", function(node)
		local nodeMetadata = require(node.Parent.Parent.Parent.Metadata)
		local onReplenish = nodeMetadata.Animations.OnReplenish
		
		if nodeMetadata.DestroyOnDeplete then
			for _, c in pairs (node:GetDescendants()) do
				if c:IsA("BasePart") then
					c.Transparency = 0
					c.CanCollide = true
				end
			end
		else
			if node:FindFirstChild("DropPoints") then
				for _, dropPoint in pairs (node.DropPoints:GetChildren()) do
					dropPoint.Value.Transparency = 0
				end
			end
		end
		
		if onReplenish and type(onReplenish) == "function" then
			onReplenish(node)
		else
			self:DoEffect(node, "Replenish")
		end
		
		CollectionService:AddTag(node.PrimaryPart, "attackable")
	end)
	
	Network:connect("ResourceDepleted", "OnClientEvent", function(node)
		local nodeMetadata = require(node.Parent.Parent.Parent.Metadata)
		local onDeplete = nodeMetadata.Animations.OnDeplete
		
		if nodeMetadata.DestroyOnDeplete then			
			for _, c in pairs (node:GetDescendants()) do
				if c:IsA("BasePart") then
					c.Transparency = 1
					c.CanCollide = false
				end
			end
			if not onDeplete or type(onDeplete) ~= "function" then
				self:DoEffect(node, "Deplete")
			end
		end
		if onDeplete and type(onDeplete) == "function" then
			onDeplete(node)
		end
		CollectionService:RemoveTag(node.PrimaryPart, "attackable")
	end)
	
end


function Resources:Init()
	
	SharedModules = require(ReplicatedStorage.modules)
	Network = SharedModules.load("network")
	Thread = SharedModules.load("Thread")
	
end


Resources:Init()
Resources:Start()

return Resources