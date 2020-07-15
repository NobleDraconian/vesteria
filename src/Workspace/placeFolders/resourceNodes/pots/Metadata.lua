-- Node Metadata
-- Rocky28447
-- July 2, 2020



local RNG = Random.new()
local EffectsStorage = script.EffectsStorage

return {
	
	DestroyOnDeplete = true;
	Durability = 0;
	Harvests = 1;
	IsGlobal = true;
	Replenish = 20;
	
	LootTable = {
		Drops = 4;
		Items = {
			[1] = {
				ID = 1;
				Chance = 1;
				Amount = function()
					return RNG:NextInteger(2, 4)
				end;
				Modifiers = function()
					return {
						value = RNG:NextInteger(3, 6)
					}
				end
			};
		}
	};
	
	-- Used to define weapons that will deal MORE than 1 damage
	Effectiveness = {
		
	};
	
	Animations = {
--		OnHarvest = function(node, dropPoint)
--		end;
--		
--		OnDeplete = function(node)
--		end;
--		
--		OnReplenish = function(node)
--		end;
	}
}