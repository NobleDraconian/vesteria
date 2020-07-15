
local c=require(game:GetService("ReplicatedStorage"):WaitForChild("modules"))local d=c.load("mapping")
return
{id=22,QUEST_VERSION=1,questLineName="The Lost Palace",questLineImage="",questLineDescription="Dr. Henry Bones' son, Mississippi Bones, has gone missing somewhere in The Whispering Dunes.",requireQuests={},repeatableData={value=false},objectives={{requireLevel=35,giverNpcName="Dr. Henry Bones",handerNpcName="Dr. Henry Bones",objectiveName="The Lost Palace",completedText="Deliver the bad news to Dr. Henry Bones.",completedNotes="I found Mississippi but a mysterious entity disintegrated him before I could save him from his madness. I'd best be on the lookout for Tal-rey in the future...",handingNotes="Quest completed!",level=35,expMulti=2,goldMulti=3,rewards={},steps={{triggerType="open-surface-door-temple",requirement={amount=1},isSequentialStep=true,overridingNote="Find the place Mississippi Bones mentioned in his journal."},{triggerType="find-mississippi",requirement={amount=1},isSequentialStep=true,overridingNote="Find Mississippi Bones in the palace."},{triggerType="expose-mississippi",requirement={amount=1},isSequentialStep=true,overridingNote="Mississippi's gone mad. Talk him out of it. Could a complete journal help convince him?"},{triggerType="place-vase",requirement={amount=1},isSequentialStep=true,overridingNote="Pass Tal-rey's test."}}}},dialogueData={responseButtonColor=Color3.fromRGB(255,207,66),dialogue_unassigned_1={{text="Hello there young chap. Say... what do you have there? An old tattered notebook... that looks quite familiar indeed! That... that looks like it belongs to my boy, Mississipi Bones! I'm... I'm afraid he's gone missing, and I haven't the idea where he's ran off to this time..."}},dialogue_active_1={{text="Have you found my son, yet?"}},dialogue_objectiveDone_1={{text="Oh, no... that's grave news, indeed. Well, thank you for telling me. As thanks, I will send word to the museum in the Whispering Dunes that you are allowed to purchase artifacts and equipment."}},options={{response_unassigned_accept_1="I'll find him!",response_unassigned_decline_1="Boooriiing...",dialogue_unassigned_accept_1={{text="Fantastic! That's a chap! Bravo! My boy and I set up out there in the Dunes to study its secrets. There might be some clues of where he's ran off to in his notebook you found. Keep it to aid in your search! Best of luck to you! I'm not sure I'd be any more of help to you, I've told you all I know."}},dialogue_unassigned_decline_1={{text="Be on your way then!"}}}}}}