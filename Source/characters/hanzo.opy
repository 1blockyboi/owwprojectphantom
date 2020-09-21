#!include "character.opy"

#This was written before the player variables were reworked.
#!define wasOnWall survivorSpecificVariable

/*
    Survivor: Hanzo
    Abilities: Sonic Arrow, Wall Climb
    Passive: See monster outline in the fog.
    Team Synergy: Can use enhanced vision to spot Reaper, and he can use sonic dart to warn teammates of the monster's approach.
*/

/*
    Spawn Hanzo. Uses commonSpawnConditions and startProcess macros from character.opy
*/
rule "Hanzo Spawn":
    @Event eachPlayer
    @Team 2
    @Hero hanzo
    commonSpawnConditions 

    startProcess
        getPlayersInSlot(0, Team.1).startForcingOutlineFor(eventPlayer, true, Color.RED)
        hudHeader(eventPlayer, "{0}\n{1}".format("{0}: {2}".format(abilityIconString(Hero.HANZO, Button.ABILITY_1), buttonString(Button.ABILITY_1), "{0} {1}".format(ceil(eventPlayer.getAbilityCooldown(Button.ABILITY_1)), stringSec)), "{0}: {2}".format(abilityIconString(Hero.HANZO, Button.JUMP), buttonString(Button.JUMP), "{0} {1}".format(ceil(eventPlayer.getAbilityCooldown(Button.ABILITY_2)), stringSec))), HudPosition.LEFT, 0, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        hudIDs[eventPlayer.getSlot()].append(getLastCreatedText())
        eventPlayer.setMaxHealth(200 / eventPlayer.getMaxHealth() * 100)
        commonSub()

/*
    Keeps track when Hanzo is wall climbing while the ability is off cooldown.
*/
rule "Hanzo Wall Climbing":
    @Event eachPlayer
    @Team 2
    @Hero hanzo
    @Condition eventPlayer.isOnWall() == true
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_2) == 0
    @Condition eventPlayer.wasOnWall == false
    
    eventPlayer.wasOnWall = true

/*
    When the wall climb ends, cooldown is reset.
*/
rule "Hanzo Wall Climb End":
    @Event eachPlayer
    @Team 2
    @Hero hanzo
    @Condition eventPlayer.isOnWall() == false
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_2) == 0
    @Condition eventPlayer.wasOnWall == true
    
    #Hanzo's wall climb is put on a cooldown. These rules check and correct any wall climbing during cooldown.
    eventPlayer.setAbilityCooldown(Button.ABILITY_2, 10)
    eventPlayer.wasOnWall = false

/*
    If Hanzo tries to wallclimb while on cooldown, he is hacked for a split second.
*/
rule "Hanzo Wall Climb Prevention":
    @Event eachPlayer
    @Team 2
    @Hero hanzo
    @Condition eventPlayer.isOnWall() == true
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_2) > 0
    
    eventPlayer.setStatusEffect(null, Status.HACKED, 0.2)

/*
    Every time Reaper spawns a ghost, it's outline is fixed so Hanzo can see it too.
*/
rule "Hanzo Reaper Ghost Outline Refresh":
    @Event eachPlayer
    @Team 2
    @Hero hanzo
    @Condition getPlayersInSlot(2, Team.1).survivorSpecificVariable[1] == true

    getPlayersInSlot(2, Team.1).startForcingOutlineFor(eventPlayer, true, Color.RED)

/*
    Hanzo Sonic Arrow Cooldown is manually set
*/
rule "Hanzo Sonic Arrow Cooldown":
    @Event eachPlayer
    @Team 2
    @Hero hanzo
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_1) > 0

    #To counter balancing patches.
    eventPlayer.setAbilityCooldown(Button.ABILITY_1, 9)
