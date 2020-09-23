#!include "character.opy"

/*
    Survivor: Brigitte
    Abilities: Flail, Shield Bash
    Passive: None
    Team Synergy: Is a character at the front lines, and can duel with Reaper if done right. Can support teamamtes by fighting Reaper, giving them time to run.
*/

/*
    Spawn Brigitte. Uses commonSpawnConditions and startProcess from character.opy
*/
rule "Brigitte Spawn":
    @Event eachPlayer
    @Team 2
    @Hero brigitte
    commonSpawnConditions

    startProcess
            hudHeader(eventPlayer, "{0}\n{1}".format("{0} : {2}".format(abilityIconString(Hero.BRIGITTE, Button.ABILITY_1), buttonString(Button.ABILITY_1), "{0} {1}".format(ceil(eventPlayer.getAbilityCooldown(Button.ABILITY_1)), stringSec)), "{0}: {2}".format(abilityIconString(Hero.BRIGITTE, Button.SECONDARY_FIRE), buttonString(Button.PRIMARY_FIRE), "{0} {1}".format(ceil(eventPlayer.getAbilityCooldown(Button.PRIMARY_FIRE)), stringSec))), HudPosition.LEFT, 0, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
            hudIDs[eventPlayer.getSlot()].append(getLastCreatedText())
            eventPlayer.setMaxHealth(20 / eventPlayer.getMaxHealth() * 100)
            eventPlayer.addHealthPool(Health.NORMAL, 180, true, true)
            commonSub()
            eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)

/*
    Manually set Shield Bash cooldown.
*/
rule "Using Shield Bash":
    @Event eachPlayer
    @Team 2
    @Hero brigitte
    @Condition eventPlayer.getAbilityCooldown(Button.PRIMARY_FIRE) > 0

    #To counter balancing patches.
    eventPlayer.setAbilityCooldown(Button.PRIMARY_FIRE, 7.0)

/*
    Manually set Flail cooldown
*/
rule "Using Flail":
    @Event eachPlayer
    @Team 2
    @Hero brigitte
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.hasSpawned == true

    #To counter balancing patches.
    eventPlayer.setAbilityCooldown(Button.ABILITY_1, 4.0)