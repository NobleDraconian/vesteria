
local b={baseEXP=10,level=23,baseMoney=10,baseHealth=0.65,baseDamage=1.5,attackRange=3.5,baseSpeed=26,attackSpeed=2,flies=true,floats=true,aggressionRange=50,targetingYOffsetMulti=0.2,hitboxDilution=1,monsterSpawnRegions={[script.Name]=1,[script.Name.."2"]=1,[script.Name.."3"]=1},damageHitboxCollection={{partName="RightFoot",castType="box",hitboxSizeMultiplier=Vector3.new(1.5,1.65,1.5),originOffset=CFrame.new()},{partName="LeftFoot",castType="box",hitboxSizeMultiplier=Vector3.new(1.5,1.65,1.5),originOffset=CFrame.new()}},monsterBookPage=3,lootDrops={{id=1,spawnChance=0.8},{itemName="batty wing",spawnChance=0.8},{itemName="dexterity potion",spawnChance=0.001,idols=5},{itemName="ancient weapon attack scroll",spawnChance=0.0008,idols=8},{itemName="banana",spawnChance=0.0005,idols=10},{itemName="batty dagger",spawnChance=0.00025}},renderOffset=CFrame.new(0,1,0),module=script,monsterEvents={}}
b.maxHealth=b.baseHealth*
require(game.ReplicatedStorage.modules.levels).getMonsterHealthForLevel(b.level)
b.damage=b.baseDamage*
require(game.ReplicatedStorage.modules.levels).getMonsterDamageForLevel(b.level)return b