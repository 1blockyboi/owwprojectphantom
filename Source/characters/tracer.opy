#!include "character.opy"

/*
    Survivor: Tracer
    Abilities: Blink, Rewind
    Passive: Fragile (One-hit)
    Team Synergy: Can be a distraction; can teleport teammates nearby when rewinding.addHealthPool
*/

/*
    Spawn Tracer. Imports commonSpawnConditions and startProcess macro from character.opy.
*/
rule "Tracer Spawn":
    @Event eachPlayer
    @Team 2
    @Hero tracer
    commonSpawnConditions

    startProcess
            hudHeader(eventPlayer, "{0}\n{1}".format("{0}: {2}".format(abilityIconString(Hero.TRACER, Button.ABILITY_1), null, "{0} {1}".format(ceil(eventPlayer.getAbilityCharge(Button.ABILITY_1)), stringCharges)), "{0}: {2}".format(abilityIconString(Hero.TRACER, Button.ABILITY_2), null, "{0} {1}".format(ceil(eventPlayer.getAbilityCooldown(Button.ABILITY_2)), stringSec))), HudPosition.LEFT, 0, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
            hudIDs[eventPlayer.getSlot()].append(getLastCreatedText())
            createEffect(eventPlayer, Effect.RING, Color.ORANGE, eventPlayer.getPosition(), 6, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
            effectIDs[eventPlayer.getSlot()].append(getLastCreatedEntity())
            eventPlayer.setMaxHealth(100 / eventPlayer.getMaxHealth() * 100)
            commonSub()
            eventPlayer.setAbilityCooldown(Button.ABILITY_2, 0)

/*
    First rule executed to rewind Tracer and teleport nearby teammates.
*/
rule "Tracer Team Warp":
    @Event eachPlayer
    @Team 2
    @Hero tracer
    @Condition eventPlayer.isUsingAbility2() == true
    
    #Tracer can teleport people with her when she jukes Reaper out. She doesn't teleport people held by Winston since they will be teleported when he is.
    eventPlayer.survivorSpecificVariable = [player for player in getPlayers(Team.2) if distance(eventPlayer, player) <= 6 and isInLoS(eventPlayer, player, BarrierLos.PASS_THROUGH_BARRIERS) == true and player != eventPlayer and player.winstonGrab == false]
    wait(0.1)
    if len(eventPlayer.survivorSpecificVariable) > 0 and eventPlayer.survivorSpecificVariable2 < 0 or len(eventPlayer.survivorSpecificVariable) <= 0 and eventPlayer.survivorSpecificVariable2 > 0:
        eventPlayer.survivorSpecificVariable[eventPlayer.survivorSpecificVariable2].setStatusEffect(null, Status.BURNING, 4)

/*
    Second rule executed for rewind. Teammates are teleported one by one in a for loop.
*/
rule "Tracer Team Warp II":
    @Event eachPlayer
    @Team 2
    @Hero tracer
    @Condition eventPlayer.isUsingAbility2() == false
    
    for eventPlayer.survivorSpecificVariable2 in range(len(eventPlayer.survivorSpecificVariable)):
        eventPlayer.survivorSpecificVariable[eventPlayer.survivorSpecificVariable2].throwingPlayer = eventPlayer
        playEffect(getAllPlayers(), DynamicEffect.GOOD_EXPLOSION, Color.ORANGE, eventPlayer.survivorSpecificVariable[eventPlayer.survivorSpecificVariable2], 2)
        #This wait ensures that the orange puff affect above plays in the location prior to teleport.
        wait(0.1)
        eventPlayer.survivorSpecificVariable[eventPlayer.survivorSpecificVariable2].teleport(eventPlayer)
        eventPlayer.survivorSpecificVariable[eventPlayer.survivorSpecificVariable2].clearStatusEffect(Status.BURNING)
        smallMessage(eventPlayer.survivorSpecificVariable[eventPlayer.survivorSpecificVariable2], "{0} {1}: {2}".format(heroIcon(Hero.TRACER), eventPlayer, stringTracerTeleportMessage))
    #This makes sure that the cooldown is always 28 despite Overwatch balance updates.
    eventPlayer.setAbilityCooldown(Button.ABILITY_2, 28)