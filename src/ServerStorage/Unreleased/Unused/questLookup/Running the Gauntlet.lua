return {
	id = 24,
	QUEST_VERSION = 1,
	
	questLineName = "Running the Gauntlet",
	questLineImage = "",
	questLineDescription = "The bridge to the Whispering Dunes has been taken over by bandits. If I want to go there, I'll have to defeat them.",
	
	requireQuests = {},
	repeatableData = {value = false},
	
	objectives = {
		[1] = {
			requireLevel = 40,
			giverNpcName = "Hunter Lieutenant Jin",
			handerNpcName = "Hunter Lieutenant Jin",
			
			objectiveName = "Running the Gauntlet",
			completedText = "Report your success.",
			
			completedNotes = "I've successfully cleared the gauntlet of the bandits. I should report my success.",
			handingNotes = "Quest completed!",
			
			level = 40,
			expMulti = 1,
			goldMulti = 1,
			rewards = {},
			
			steps = {
				[1] = {
					triggerType = "gauntlet-completed",
					requirement = {
						amount = 1,
					},
				}	
			}
		}	
	},
	
	dialogueData = {
		responseButtonColor = Color3.fromRGB(255, 207, 66),
		
		dialogue_unassigned_1 = {{text = "Sorry, if you're heading to the Whispering Dunes, we've closed the way due to safety concerns. There's bloodthirsty bandits on the bridge."}},
		dialogue_active_1 = {{text = "Let me know when you've defeated those bandits."}},
		dialogue_objectiveDone_1 = {{text = "Thanks again for running the gauntlet. I'm sure it was no easy feat, and the Hunters are grateful for your help."}},
		
		options = {
			response_unassigned_accept_1 = "I can clear the way.",
			dialogue_unassigned_accept_1 = {{text = "If you say so. Go right ahead."}},
			
			response_unassigned_decline_1 = "Sounds scary.",
			dialogue_unassigned_decline_1 = {{text = "Yep, just going to have to wait until they get bored or we decide to do something about them."}},
		}
	}
}