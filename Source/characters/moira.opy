#!include "character.opy"

/*
    Survivor: Moira
    Abilities: Fade, Heal
    Passive: Can see teammates health status in fog. Respawns at 100 seconds if dead.
    Team Synergy: Can heal important members stalling the monster, at the cost of potentially dying sooner. If done right, Moira will sacrifice herself putting health into the MVP of the team.
*/

/*
    Spawn Moira. Imports commonSpawnConditions and startProcess from character.opy
*/
rule "Moira Spawn":
    @Event eachPlayer
    @Team 2
    @Hero moira
    commonSpawnConditions

    startProcess
            hudHeader(eventPlayer, "{0}\n{1}".format("{0}: {2}".format(abilityIconString(Hero.MOIRA, Button.ABILITY_1), buttonString(Button.ABILITY_1), "{0} {1}".format(ceil(eventPlayer.getAbilityCooldown(Button.ABILITY_1)), stringSec)), "{0}: {2}".format(abilityIconString(Hero.ZENYATTA, Button.ABILITY_1), buttonString(Button.INTERACT), "{0} {1}".format(ceil(eventPlayer.getAbilityCooldown(Button.ABILITY_2)), stringSec))), HudPosition.LEFT, 0, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
            hudIDs[eventPlayer.getSlot()].append(getLastCreatedText())
            eventPlayer.setMaxHealth(200 / eventPlayer.getMaxHealth() * 100)
            commonSub()
            eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)
            createIcon([i for i in eventPlayer if isInLoS(eventPlayer, eventPlayer.getPlayerClosestToReticle(Team.2), BarrierLos.PASS_THROUGH_BARRIERS) == true and eventPlayer.isInViewAngle(eventPlayer.getPlayerClosestToReticle(Team.2), 20) == true and eventPlayer.getPlayerClosestToReticle(Team.2).getHealth() < eventPlayer.getPlayerClosestToReticle(Team.2).getMaxHealth() and eventPlayer.getPlayerClosestToReticle(Team.2).isAlive() == true], eventPlayer.getPlayerClosestToReticle(Team.2), Icon.HEART, IconReeval.VISIBILITY_AND_POSITION, Color.GREEN, false)
            eventPlayer.survivorSpecificVariable2 = getLastCreatedEntity()
            effectIDs[eventPlayer.getSlot()].append(getLastCreatedEntity())

/*
    Moira can no-clip through walls during Fade.
*/
rule "Moira Clipping I":
    @Event eachPlayer
    @Team 2
    @Hero moira
    @Condition eventPlayer.isUsingAbility1() == true
    
    #Like Reaper, Moira can no clip too, but to prevent exploits she is also teleported to NWP when she is done, to prevent hiding outside the map or in the environment.
    disableEnvironmentCollision(eventPlayer, false)

/*
    Clipping is restored after Fade ends, and teleports to NWP to prevent exploits.
*/
rule "Moira Clipping II":
    @Event eachPlayer
    @Team 2
    @Hero moira
    @Condition eventPlayer.isUsingAbility1() == false
    
    enableEnvironmentCollision(eventPlayer)
    eventPlayer.teleport(nearestWalkablePosition(eventPlayer.getPosition()))
    #Cooldown is manually set to counter balancing patches.
    eventPlayer.setAbilityCooldown(Button.ABILITY_1, 9)

/*
    Moira can heal nearby teammates at the cost of her health.
*/
rule "Moira Healing":
    @Event eachPlayer
    @Team 2
    @Hero moira
    @Condition isInLoS(eventPlayer, eventPlayer.getPlayerClosestToReticle(Team.2), BarrierLos.PASS_THROUGH_BARRIERS) == true
    @Condition eventPlayer.isInViewAngle(eventPlayer.getPlayerClosestToReticle(Team.2), 20) == true
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true
    @Condition eventPlayer.getPlayerClosestToReticle(Team.2).getHealth() < eventPlayer.getPlayerClosestToReticle(Team.2).getMaxHealth()
    @Condition eventPlayer.getPlayerClosestToReticle(Team.2).isAlive() == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_2) == 0
    
    #Moira's healing is unique. She takes a chunk of her health pool to heal someone else. However, she can die during this process.
    eventPlayer.survivorSpecificVariable = eventPlayer.getPlayerClosestToReticle(Team.2)
    heal(eventPlayer.survivorSpecificVariable, eventPlayer, 150)
    smallMessage(eventPlayer.survivorSpecificVariable, "{0} {1}: {2}".format(heroIcon(Hero.MOIRA), eventPlayer, stringMoiraHeal))
    if eventPlayer.survivorSpecificVariable != null:
        playEffect(getAllPlayers(), DynamicEffect.GOOD_EXPLOSION, Color.GREEN, eventPlayer.survivorSpecificVariable, 2)
        eventPlayer.setAbilityCooldown(Button.ABILITY_2, 60)