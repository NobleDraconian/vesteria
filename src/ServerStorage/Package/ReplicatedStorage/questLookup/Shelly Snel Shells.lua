
local c=require(game:GetService("ReplicatedStorage"):WaitForChild("modules"))local d=c.load("mapping")
return
{id=16,QUEST_VERSION=1,questLineName="Shelly's Snel Shells",questLineImage="",questLineDescription="Shelly sells Snel Shells by the sea shore, but she's sold out of shells.",questEndedNote="If I bring Shelly more Snel Shells she will trade me for them.",requireQuests={},repeatableData={value=false,timeInterval=0},requireClass=
nil,objectives={{requireLevel=17,giverNpcName="Shelly",handerNpcName="Shelly",objectiveName="Shelly's Snel Shells",completedText="Return to Shelly.",completedNotes="Now that I have the Snel Shells I should return to Shelly by the sea shore.",handingNotes="Quest completed!",level=19,expMulti=1,goldMulti=1,rewards={{id=150,stacks=1}},steps={{triggerType="item-collected",requirement={id=168,amount=1}},{triggerType="item-collected",requirement={id=169,amount=1}},{triggerType="item-collected",requirement={id=170,amount=1}},{triggerType="item-collected",requirement={id=171,amount=1}}},localOnFinish=function(_a)
if
workspace:FindFirstChild("SnelShopDisplay")then
for aa,ba in
pairs(workspace:FindFirstChild("SnelShopDisplay"):GetChildren())do ba.Transparency=0;ba.CanCollide=true end end end}},dialogueData={responseButtonColor=Color3.fromRGB(255,207,66),dialogue_unassigned_1={{text="Hello! My name is Shelly and I sell Snel Shells. But I have a problem... I'm sold out of shells! Would you help me out and get me some more?"}},dialogue_active_1={{text="Did you get those Snel Shells yet?"}},dialogue_objectiveDone_1={{text="Yay, my shells! Thanks friend. Hey... I have an idea. These shells sell faster then you can say \"Shelly sells Snel Shells by the sea shore\"! I'll always need more Snel Shells, and if you bring them to me I'll trade you for them!"}},options={{response_unassigned_accept_1="Sure",response_unassigned_decline_1="Sorry, no",dialogue_unassigned_accept_1={{text="Great! The shells I sell are rare and only found in Shiprock Bottom. If you bring me some I'll have my Snel Shell stand up and running again!"}},dialogue_unassigned_decline_1={{text="Aw shucks."}}}}}}