
local c=require(game:GetService("ReplicatedStorage"):WaitForChild("modules"))local d=c.load("mapping")
return
{id=18,QUEST_VERSION=1,questLineName="Spider Fighter",questLineImage="",questLineDescription="The Spider vs. Goblin conflict rages on. I guess I'll help the Goblins.",questEndedNote="I can complete this quest everyday.",requireQuests={},repeatableData={value=true,timeInterval=
8 *60 *60},requireClass=nil,objectives={{requireLevel=14,giverNpcName="Spider guy",handerNpcName="Spider guy",objectiveName="Spider Fighter",completedText="Return to spider guy",completedNotes="Now that I have slayed the Spiders I should return to spider guy.",handingNotes="Quest completed!",level=14,expMulti=1,goldMulti=1,rewards={},steps={{triggerType="monster-killed",requirement={monsterName="Spider",amount=25}}}}},dialogueData={responseButtonColor=Color3.fromRGB(255,207,66),dialogue_unassigned_1={{text="Hey, hey you de humanling. You know how I got des scar? De Spidos. Humanling, I need you to join de good fight against de Spiders."}},dialogue_active_1={{text="You fight de Spiders, yes?"}},dialogue_objectiveDone_1={{text="You showed the Spiders who is de boss. Come back later to show de Spidos who is de boss, again. GOBLINS RULE!"}},options={{response_unassigned_accept_1="Bye bye Spiders",response_unassigned_decline_1="I don't trust Goblins",dialogue_unassigned_accept_1={{text="Goblins are de best, Spiders not de good ones. Get rid of 25 of dem."}},dialogue_unassigned_decline_1={{text="We have a lover of de Spiders over here! GET OUT OF ME SIGHT!"}}}}}}