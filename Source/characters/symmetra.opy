#!mainFile "../main.opy"

#!include "character.opy"

/*
    Survivor: Symmetra
    Ablities: Turret, Teleport
    Passive: None
    Team Synergy: A secure anchor/escort. Makes is harder for Reaper to approach the position, and gives teammates and fast and guaranteed way to traveling a far distance from the attack. Unlike Wrecking Ball, she usually
                    shifting her position.
*/

/*
    Spawns Symmetra. commonSpawnConditions and startProcess macro imported from character.opy.
*/
rule "Symmetra Spawn":
    @Event eachPlayer
    @Team 2
    @Hero symmetra
    commonSpawnConditions
    
    startProcess
            hudHeader(eventPlayer, "{0}\n{1}".format("{0}: {2}".format(abilityIconString(Hero.SYMMETRA, Button.ABILITY_1), null, "{0} {1}".format(ceil(eventPlayer.getAbilityCharge(Button.ABILITY_1)), stringCharges)), "{0}: {2}".format(abilityIconString(Hero.SYMMETRA, Button.ABILITY_2), null, "{0} {1}".format(ceil(eventPlayer.getAbilityCooldown(Button.ABILITY_2)), stringSec))), HudPosition.LEFT, 0, Color.SKY_BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
            hudIDs[eventPlayer.getSlot()].append(getLastCreatedText())
            eventPlayer.setMaxHealth(20 / eventPlayer.getMaxHealth() * 100)
            eventPlayer.addHealthPool(Health.NORMAL, 180, true, true)
            commonSub()

/*
    Teleporter Ability cooldown is reset.
*/
rule "Teleporter Ability Cooldown":
    @Event eachPlayer
    @Team 2
    @Hero symmetra
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_2) > 0

    eventPlayer.setAbilityCooldown(Button.ABILITY_2, 30)
    #Playtests have shown that if Reaper takes out her tele, she is much more vulnerable. While this should be a thing, she needs a little more survivability during her cooldown.
    #So, her charges get set to 3 regardless of their previous charge. This allows her to set up somewhere more proper while she runs from Reaper. This is useful
    #because her turret cooldown is still pretty high, and instead of introducing a spam turret meta, we just give her some room to prepare a new defense.
    eventPlayer.setAbilityCharge(Button.ABILITY_1, 3)