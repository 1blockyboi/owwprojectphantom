#!mainFile "../main.opy"

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
            eventPlayer.survivorSpecificVariable3 = []
            hudHeader(eventPlayer, "{0}\n{1}".format("{0}: {2}".format(abilityIconString(Hero.WINSTON, Button.ABILITY_1), buttonString(Button.ABILITY_1), "{0} {1}".format(ceil(eventPlayer.getAbilityCooldown(Button.JUMP)), stringSec)), "{0}: {2}".format(abilityIconString(Hero.HANZO, Button.JUMP), buttonString(Button.JUMP), "{0} {1}".format(ceil(eventPlayer.getAbilityCooldown(Button.ABILITY_2)), stringSec))), HudPosition.LEFT, 0, Color.BLUE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
            hudIDs[eventPlayer.getSlot()].append(getLastCreatedText())
            createIcon([i for i in getPlayers(Team.2) if entityExists(getPlayersInSlot(0, Team.1)) and isInLoS(eventPlayer, getPlayersInSlot(0, Team.1), BarrierLos.PASS_THROUGH_BARRIERS) and eventPlayer.isInViewAngle(getPlayersInSlot(0, Team.1), 105) and distance(eventPlayer, getPlayersInSlot(0, Team.1)) <= fogDistance + 10 and eventPlayer.isAlive() and getPlayersInSlot(0, Team.1).isAlive() and getPlayersInSlot(0, Team.1).survivorSpecificVariable[0] == false],getPlayersInSlot(0, Team.1), Icon.EYE, IconReeval.VISIBILITY_AND_POSITION, Color.RED, true)
            iconIDs[eventPlayer.getSlot()].append(getLastCreatedEntity())
            createIcon([i for i in getPlayers(Team.2) if entityExists(getPlayersInSlot(2, Team.1)) and isInLoS(eventPlayer, getPlayersInSlot(2, Team.1), BarrierLos.PASS_THROUGH_BARRIERS) and eventPlayer.isInViewAngle(getPlayersInSlot(2, Team.1), 105) and distance(eventPlayer, getPlayersInSlot(2, Team.1)) <= fogDistance + 10 and eventPlayer.isAlive() and getPlayersInSlot(2, Team.1).isAlive() and getPlayersInSlot(2, Team.1).survivorSpecificVariable[0] == false],getPlayersInSlot(2, Team.1), Icon.EYE, IconReeval.VISIBILITY_AND_POSITION, Color.RED, true)
            iconIDs[eventPlayer.getSlot()].append(getLastCreatedEntity())
            eventPlayer.setMaxHealth(200 / eventPlayer.getMaxHealth() * 100)
            fogCreate(fogDistance + 10)
            fogCreate(fogDistance + 11)
            fogCreate(fogDistance + 12)
            fogCreate((fogDistance + 10) * -1)
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
    Hanzo Leap Cooldown is manually set
*/
rule "Hanzo Leap Cooldown":
    @Event eachPlayer
    @Team 2
    @Hero hanzo
    @Condition eventPlayer.getAbilityCooldown(Button.JUMP) > 0
    #To counter balancing patches.
    eventPlayer.setAbilityCooldown(Button.JUMP, 5)
