local melee_manager = {}

function melee_manager.PlayAnimation(animationSequenceName,...)
    if
        animationSequenceName == "staffAnimations" or
        animationSequenceName == "swordAnimations" or
        animationSequenceName == "daggerAnimations" or
        animationSequenceName == "greatswordAnimations" or
        animationSequenceName == "dualAnimations" or
        animationSequenceName == "swordAndShieldAnimations"
        then
            local atkspd = (extraData and extraData.attackSpeed) or 0
        
            CharacterEntityAnimationTracks[animationSequenceName][animationName]:Play(0.1, 1, (1 + atkspd))
        else
            if typeof(characterEntityAnimationTracks[animationSequenceName][animationName]) == "Instance" then
                characterEntityAnimationTracks[animationSequenceName][animationName]:Play()
            elseif typeof(characterEntityAnimationTracks[animationSequenceName][animationName]) == "table" then
                animationToBePlayed = animationToBePlayed[1]
            
            for i, obj in pairs(characterEntityAnimationTracks[animationSequenceName][animationName]) do
                obj:Play()
            end
        end
    end
end


return melee_manager