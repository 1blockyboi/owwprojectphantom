#!include "character.opy"

/*
    Survivor: Winston
    Abilities: Leap, Carry/Throw
    Passive: None
    Team Synergy: Can carry teammates and throw them a certain distance. Can be useful for dispersal and mobility.
*/

/*
    Spawn Winston. Uses commonSpawnConditions and startProcess from character.opy
*/
rule "Winston Spawn":
    @Event eachPlayer
    @Team 2
    @Hero winston
    commonSpawnConditions

    startProcess
            hudHeader(eventPlayer, "{0}\n{1}".format("{0} : {2}".format(abilityIconString(Hero.WINSTON, Button.ABILITY_1), buttonString(Button.ABILITY_1), "{0} {1}".format(ceil(eventPlayer.getAbilityCooldown(Button.ABILITY_1)), stringSec)), "{0}: {2}".format(abilityIconString(Hero.MERCY, Button.ABILITY_2), null, "{0} {1}".format(ceil(eventPlayer.getAbilityCooldown(Button.ABILITY_2)), stringSec))), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
            hudIDs[eventPlayer.getSlot()].append(getLastCreatedText())
            createEffect(eventPlayer, Effect.RING, Color.WHITE, eventPlayer.getPosition(), 6, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            effectIDs[eventPlayer.getSlot()].append(getLastCreatedEntity())
            eventPlayer.setMaxHealth(20 / eventPlayer.getMaxHealth() * 100)
            eventPlayer.addHealthPool(Health.NORMAL, 180, true, true)
            commonSub()
            eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)

/*
    Picks up a player.
*/
rule "Winston Grab":
    @Event eachPlayer
    @Team 2
    @Hero winston
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.survivorSpecificVariable == null
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_2) == 0
    @Condition eventPlayer.getPlayerClosestToReticle(Team.2).isAlive() == true
    @Condition eventPlayer.getPlayerClosestToReticle(Team.2).getCurrentHero() != Hero.WINSTON
    @Condition eventPlayer.getPlayerClosestToReticle(Team.2).winstonGrab == false
    @Condition isInLoS(eventPlayer, eventPlayer.getPlayerClosestToReticle(Team.2), BarrierLos.PASS_THROUGH_BARRIERS) == true
    @Condition eventPlayer.isInViewAngle(eventPlayer.getPlayerClosestToReticle(Team.2), 20) == true
    @Condition distance(eventPlayer, eventPlayer.getPlayerClosestToReticle(Team.2)) <= 6
    
    #Winston's grab is very picky, but once done will make sure the player is on top of him, and hacked to prevent weird ability glitches (or exploits).
    eventPlayer.setAbilityCooldown(Button.ABILITY_2, 3)
    if (eventPlayer.getAbilityCooldown(Button.ABILITY_1) < 2):
        eventPlayer.setAbilityCooldown(Button.ABILITY_1, 2)
    eventPlayer.survivorSpecificVariable = eventPlayer.getPlayerClosestToReticle(Team.2)
    wait(0.1)
    eventPlayer.survivorSpecificVariable.attachTo(eventPlayer, vect(0, 2, 0))
    eventPlayer.survivorSpecificVariable.winstonGrab = true
    eventPlayer.survivorSpecificVariable.setStatusEffect(null, Status.HACKED, 9999)
    smallMessage(eventPlayer.survivorSpecificVariable, "{0} {1}: {2}".format(heroIcon(Hero.WINSTON), eventPlayer, stringWinstonGrab))

/*
    Throws the carried player in the facing direction of Winston.
*/
rule "Winston Throw":
    @Event eachPlayer
    @Team 2
    @Hero winston
    @Condition eventPlayer.survivorSpecificVariable != null
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_2) == 0
    @Condition eventPlayer.survivorSpecificVariable.winstonGrab == true
    
    eventPlayer.setAbilityCooldown(Button.ABILITY_2, 5)
    wait(0.1)
    eventPlayer.survivorSpecificVariable.throwingPlayer = eventPlayer
    eventPlayer.survivorSpecificVariable.detach()
    eventPlayer.survivorSpecificVariable.winstonGrab = false
    eventPlayer.survivorSpecificVariable.clearStatusEffect(Status.HACKED)
    eventPlayer.survivorSpecificVariable.applyImpulse(eventPlayer.getFacingDirection(), 40, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    eventPlayer.survivorSpecificVariable = null

/*
    If something external happens, this rule will clear up any inconsistencies with his grab.
*/
rule "Winston Grab Clear Up":
    @Event eachPlayer
    @Team 2
    @Hero winston
    @Condition eventPlayer.survivorSpecificVariable != null
    @Condition (entityExists(eventPlayer.survivorSpecificVariable) == false or eventPlayer.survivorSpecificVariable.isAlive() == false) == true
    
    #In case something weird happens, this rule exists to clear up the variables so the ability doesn't get soft locked.
    eventPlayer.survivorSpecificVariable.detach()
    eventPlayer.survivorSpecificVariable.winstonGrab = false
    eventPlayer.survivorSpecificVariable.clearStatusEffect(Status.HACKED)
    eventPlayer.survivorSpecificVariable = null

/*
    If the player does not want to be carried, they can jump off. This rule is executed by the Winston.
*/
rule "Winston Player Escape":
    @Event eachPlayer
    @Team 2
    @Hero winston
    @Condition eventPlayer.survivorSpecificVariable != null
    @Condition entityExists(eventPlayer.survivorSpecificVariable) == true
    @Condition eventPlayer.survivorSpecificVariable.isAlive() == true
    @Condition eventPlayer.survivorSpecificVariable.isHoldingButton(Button.JUMP) == true
    
    #Not everyone wants to be captive to Winston, or trolled. This exists to allow them to escape. Since there is a cooldown for the grab, this should be enough for them to get away from a troll.
    eventPlayer.survivorSpecificVariable.detach()
    eventPlayer.survivorSpecificVariable.winstonGrab = false
    eventPlayer.survivorSpecificVariable.clearStatusEffect(Status.HACKED)
    eventPlayer.survivorSpecificVariable = null

/*
    Manually set the Winston Leep cooldown.
*/
rule "Set Winston Leap Cooldown":
    @Event eachPlayer
    @Team 2
    @Hero winston
    @Condition eventPlayer.isUsingAbility1() == false

    #To counter balancing patches.
    eventPlayer.setAbilityCooldown(Button.ABILITY_1, 9)