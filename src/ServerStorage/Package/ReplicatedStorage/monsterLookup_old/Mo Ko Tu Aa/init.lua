
local b={attackRange=20,baseSpeed=0,attackSpeed=1,baseHealth=700,baseDamage=2,aggressionRange=30,monsterBookPage=4,baseEXP=10,bonusXPMulti=1000,level=35,baseMoney=0,boss=true,portrait="rbxassetid://4333918780",monsterSpawnRegions={[script.Name]=1,[script.Name.."2"]=1,[script.Name.."3"]=1},animationDamageEnd=1,dontScale=true,damageHitboxCollection={},goldMulti=25,monsterBookPage=99,bonusLootMulti=30,lootDrops={{id=1,spawnChance=0.5},{itemName="mogomelon",spawnChance=0.8},{itemName="mighty sub",spawnChance=0.1,stacks=5},{itemName="mana potion 3",spawnChance=0.1,stacks=5},{itemName="moko club",spawnChance=0.01},{itemName="moko dagger",spawnChance=0.01},{itemName="moko maul",spawnChance=0.01},{itemName="tuaa bow",spawnChance=0.01},{itemName="tuaa shield",spawnChance=0.01},{itemName="tuaa staff",spawnChance=0.01},{id="ancient weapon attack scroll vit",spawnChance=0.03},{itemName="60% cursed weapon attack scroll",spawnChance=0.015},{itemName="60% cursed armor defense scroll",spawnChance=0.015},{itemName="skill reset tome",spawnChance=0.015,soulbound=false},{itemName="stat reset tome",spawnChance=0.015,soulbound=false}},module=script,id="monster"}
b.maxHealth=b.baseHealth*
require(game.ReplicatedStorage.modules.levels).getMonsterHealthForLevel(b.level)
b.damage=b.baseDamage*
require(game.ReplicatedStorage.modules.levels).getMonsterDamageForLevel(b.level)return b