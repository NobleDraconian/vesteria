
local c=require(game:GetService("ReplicatedStorage"):WaitForChild("modules"))local d=c.load("mapping")
return
{id=3,QUEST_VERSION=1,questLineName="No More Crabbies!",questLineImage="",questLineDescription="The Crabbies are disturbing Fisherman Gary's fishin'! He needs me to slay them and collect their claws.",questLineRequirements="I must be level 7 to start this quest.",questEndedNote="If I return to Fisherman Gary he will trade me Fresh Fish for Crabby Claws.",requireQuests={},repeatableData={value=false,timeInterval=0},requireClass=
nil,objectives={{requireLevel=8,giverNpcName="Fisherman Gary",handerNpcName="Fisherman Gary",objectiveName="No More Crabbies!",completedText="Return to Fisherman Gary.",completedNotes="Return to Fisherman Gary",handingNotes="Quest completed!",level=8,expMulti=1,goldMulti=1,rewards={{id=30,stacks=20}},steps={{triggerType="item-collected",requirement={id=18,amount=30}}}}},dialogueData={responseButtonColor=Color3.fromRGB(255,207,66),dialogue_unassigned_1={{text="These gosh darn Crabbys waltzing 'round here like they own the place. They be scarin' away all me fish! I say, you take care of 'em for me and I'll give you something fresh."}},dialogue_active_1={{text="I'm tryin' to catch me some fish! Come back when you've got my"},{text="30 Crabby Claws!",font=Enum.Font.SourceSansBold}},dialogue_objectiveDone_1={{text="Perfecto! Those Crabbys won't be getting in my way any more. Here be a fresh reward as promised. Visit me again if you like 'em. You keep killin' these darn Crabbys and I'll keep you fed!"}},options={{response_unassigned_accept_1="Crabby Cakes coming up!",response_unassigned_decline_1="I'm not messing with no Crabby.",dialogue_unassigned_accept_1={{text="Aw yea! Destroy those nabby Crabbys and bring me 30 Crabby Claws."}},dialogue_unassigned_decline_1={{text="Pshh *spits* I knew you were too yellow for these Crabbys."}}}}}}