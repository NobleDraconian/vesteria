
local _a=require(game:GetService("ReplicatedStorage"):WaitForChild("modules"))local aa=_a.load("mapping")local ba=_a.load("network")
local ca=_a.load("utilities")
return
{id=8,QUEST_VERSION=3,questLineName="Whale Tale",questLineimage="",questLineDescription="Richard's brother Mobeus has gone missing, and he needs me to find him.",questLineRequirements="I must be level 8 to start this quest.",questEndedNote="Mobeus gave me his pocketwatch to return to Richard.",requireQuests={},repeatableData={value=false,timeInterval=0},requireClass=
nil,objectives={{requireLevel=9,giverNpcName="Richard",handerNpcName="One-Eye Chuck",objectiveName="Whale Tale",completedText="Talk to One-Eye Chuck.",completedNotes="One-Eye Chuck, who is upstairs of the bar in Port Fidelio, knows about Mobeus.",handingNotes="One-Eye Chuck will give me information about Mobeus.",level=10,expMulti=0.5,goldMulti=0,rewards={{id=71,stacks=8}},steps={{triggerType="talk-to-davey",requirement={amount=1},isSequentialStep=true,overridingNote="Mobeus ran off to somewhere in Port Fidelio. I should ask the people of the city about what happened to him."}}},{requireLevel=9,giverNpcName="One-Eye Chuck",handerNpcName="Mobeus",objectiveName="Whale Tale Part 2",completedText="Find Mobeus.",completedNotes="The Evil Scientist turned Mobeus into a whale! I need to find him in the Port!",handingNotes="Quest completed!",level=10,expMulti=1,goldMulti=2,rewards={{id=125},{id=57,stacks=1}},steps={{triggerType="pickpocket-scientist",requirement={amount=1},overridingNote="There's a scientist in Port Fidelio who Mobeus was last seen with. He's on the beach in the fancy part of town."},{triggerType="read-evil-book",requirement={amount=1},isSequentialStep=true,overridingNote="I've stolen the Evil Scientist's lair key. I wonder what it opens..."}},localOnFinish=function(da)
end}},dialogueData={responseButtonColor=Color3.fromRGB(255,207,66),dialogue_unassigned_1={{text="Stranger, I need your help! My brother Mobeus has gone! The fool ran off weeks ago following his crazy dream of becoming a \"Whale Hunter\" and hasn't been seen since. Will you help find him? Please, I'm desperate!"}},dialogue_active_1={{text="Ayyee, I know what happened to this Mobeus fella, but I ain't answering no questions to no stranger until me gets me muffin!"}},dialogue_objectiveDone_1={{text="Davey sent ye? Ah yes, Mobeus. I know about this Mobeus fellow..."}},dialogue_unassigned_2={{text="I have seen the lad Mobeus wander into town. If ye wish to find him now, ye'll have to deal with that strange scientist fellow- he be the last soul I saw Mobeus with. A real strange fella that scientist, he strikes me as no good since he's been here. I sees him lounging on the beach in the fancy part of town."}},dialogue_active_2={{text="Ye can find the scientist out at the beach in the fancy district, me laddy. I have the feelin' he be responsible for the dissapearing of Mobeus."}},dialogue_objectiveDone_2={{text="WOOOOOOOOOAAAAAAOOOOOO",font=Enum.Font.SourceSansBold},{text="The crazy scientist, he tricked me! I should have known what the Whale Hunters actually were!"},{text="Pfuussshhhhhh!",font=Enum.Font.SourceSansBold},{text="Please, return to my brother and tell him of my fate. And also, bring him my pocketwatch- it belonged to my father and is very valuable."}},options={{response_unassigned_accept_1="I'll help",response_unassigned_decline_1="Sounds like a whale of a problem",dialogue_unassigned_accept_1={{text="There's got to be someone in Port Fidelio who knows something, but I've had no luck so far. Please, ask around in the city about Mobeus!"}},dialogue_unassigned_decline_1={{text="I'm tired of all the puns! I just want to find my brother!"}},response_unassigned_accept_2="I'll find him",response_unassigned_decline_2="I don't mess with scientists",dialogue_unassigned_accept_2={{text="I spots him setting his post out across the bay if ye wish to approach to him."}},dialogue_unassigned_decline_2={{text="Not a bad inclination to have, me laddy."}}}}}}