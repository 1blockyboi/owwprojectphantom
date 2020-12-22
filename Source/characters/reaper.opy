#!mainFile "../main.opy"

#!include "character.opy"

/*
    These rules were created before importation and rework of player variables. To make things easier, variables are redefined here.
    Note: Since some variables are chased, they have to be a separate variable instead of an array.
*/
#!define isTeleporting survivorSpecificVariable[0]
#!define isRising survivorSpecificVariable[1]
#!define teleportDestination survivorSpecificVariable[2]
#!define theGround survivorSpecificVariable[3]
#!define underTheGround survivorSpecificVariable[4]
#!define positionDecoy survivorSpecificVariable[5]
#!define directionDecoy survivorSpecificVariable[6]
#!define directionReaper survivorSpecificVariable[7]
#!define currentTeleportPosition survivorSpecificVariable2
#!define decoyCD survivorSpecificVariable3
#!define decoySwapCD survivorSpecificVariable4
#!define orbPosition survivorSpecificVariable5

/*
    Monster: Reaper
    Abilities: Wraith, Teleport, Ghost Spawn, Ghost Swap, Melee
    Strategy: Being a Phantom, his whole kit is to catch the survivors off guard, baiting abilities and tricking their sense.
    Dummy Bots Needed: 1
*/

/*
    This rule is run for both player and dummy bot. Sets up the basics for regardless of state.
*/
rule "Reaper Setup":
    @Event eachPlayer
    @Team 1
    @Hero reaper
    
    eventPlayer.startModifyingVoicelinePitch(-20, true)
    getPlayers(Team.2).stopForcingOutlineFor(eventPlayer)
    getPlayers(Team.2).enableNameplatesFor(eventPlayer)
    eventPlayer.setAbility2Enabled(false)
    eventPlayer.setPrimaryFireEnabled(false)
    eventPlayer.startScalingSize(1.3, true)
    startDamageModification(eventPlayer, getPlayers(Team.2), 1, DamageReeval.RECEIVERS_DAMAGERS_AND_DMGPERCENT)
    eventPlayer.disableHeroHUD()
    eventPlayer.startHoT(eventPlayer, 9999, 1000)
    eventPlayer.survivorSpecificVariable5 = vect(0,0,0)
    #There is a position always tracked for the orb cursor. Since only the player needs to see it, this only runs for the player.
    if eventPlayer.isDummy() == false:
        createDummy(Hero.WIDOWMAKER, Team.1, 1, eventPlayer.getPosition(), vect(0,0,0))
    #!define lookPosition  updateEveryTick(raycast(getPlayersInSlot(0, Team.1).getEyePosition(), getPlayersInSlot(0, Team.1).getFacingDirection() * 1000 + getPlayersInSlot(0, Team.1).getEyePosition(), null, getAllPlayers(), false).getHitPosition())

/*
        Creates the HUD and effects for Reaper. Since Reaper is the only monster, and only one player plays as the Reaper, these are created globally and are hardcoded for players in slot 0.
*/
rule "Reaper HUD and Effects":
    createInWorldText([player for player in getPlayers(Team.1) if entityExists(getPlayersInSlot(2, Team.1)) == true], stringGhost, getPlayersInSlot(2, Team.1), 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.PURPLE, SpecVisibility.DEFAULT)
    hudHeader(getPlayersInSlot(0, Team.1), "{0}: {1} {2}".format(abilityIconString(Hero.REAPER, Button.ABILITY_1), ceil(getPlayersInSlot(0, Team.1).getAbilityCooldown(Button.ABILITY_1)), stringSec), HudPosition.LEFT, 1, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(getPlayersInSlot(0, Team.1), "{0}: {1} {2}".format(abilityIconString(Hero.REAPER, Button.ABILITY_2), ceil(getPlayersInSlot(0, Team.1).getAbilityCooldown(Button.ABILITY_2)), stringSec), HudPosition.LEFT, 1.1, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(getPlayersInSlot(0, Team.1), "{0}: ∞".format(abilityIconString(Hero.REAPER, Button.MELEE)), HudPosition.LEFT, 1.6, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(getPlayersInSlot(0, Team.1), "{0}: {1} {2}".format(abilityIconString(Hero.ECHO, Button.ULTIMATE), ceil(getPlayersInSlot(0, Team.1).decoyCD), stringSec), HudPosition.LEFT, 1.3, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(getPlayersInSlot(0, Team.1), "{0}: {1} {2}".format(iconString(Icon.RECYCLE), ceil(getPlayersInSlot(0, Team.1).decoySwapCD), stringSec), HudPosition.LEFT, 1.4, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    createEffect([i for i in getPlayersInSlot(0, Team.1) if getPlayersInSlot(0, Team.1).isRising == false], Effect.ORB, Color.GRAY, lookPosition, 2, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
    createInWorldText([i for i in getPlayersInSlot(0, Team.1) if getPlayersInSlot(0, Team.1).isTeleporting == false], buttonString(Button.SECONDARY_FIRE), lookPosition, 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    createInWorldText([i for i in getPlayersInSlot(0, Team.1) if getPlayersInSlot(0, Team.1).isRising == false and getPlayersInSlot(0, Team.1).isTeleporting == true], "{0} {1} | {2}".format(stringReaperTeleport, buttonString(Button.PRIMARY_FIRE), "{0} {1}".format(buttonString(Button.SECONDARY_FIRE), stringReaperTeleportGhost)), lookPosition, 1, Clip.NONE, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    hudSubtext([i for i in getPlayersInSlot(0, Team.1) if getPlayersInSlot(0, Team.1).hideInfo == false], " \n{0}\n\n{1}".format(stringReaperTitle, "{0}\n{1}".format("{0} {1}: {2}".format(abilityIconString(Hero.REAPER, Button.ABILITY_1), buttonString(Button.ABILITY_1), stringReaperAbility1), "{0} {1}: {2}".format(abilityIconString(Hero.REAPER, Button.ABILITY_2), buttonString(Button.ABILITY_2), stringReaperAbility2))), HudPosition.LEFT, 1.8, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([i for i in getPlayersInSlot(0, Team.1) if getPlayersInSlot(0, Team.1).hideInfo == false], "{0}\n{1}".format("{0} {1}: {2}".format(abilityIconString(Hero.ECHO, Button.ULTIMATE), buttonString(Button.SECONDARY_FIRE), stringReaperAbility3), "{0} {1}: {2}".format(iconString(Icon.RECYCLE), buttonString(Button.ULTIMATE), stringReaperAbility4)), HudPosition.LEFT, 1.81, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([i for i in getPlayersInSlot(0, Team.1) if getPlayersInSlot(0, Team.1).hideInfo == false], "{0} {1}: {2}".format(abilityIconString(Hero.REAPER, Button.MELEE), buttonString(Button.MELEE), stringReaperAbility5), HudPosition.LEFT, 1.82, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)


/*
    Since the set up for Reaper is handled in a separate rule, this spawn rule just makes sure some variables and cooldowns are properly adjusted.
*/
rule "Reaper Spawn":
    @Condition isGameInProgress() == true or isWaitingForPlayers() == true
    @Condition getPlayersInSlot(0, Team.1).isAlive() == true
    @Condition getPlayersInSlot(0, Team.1).hasSpawned() == true
    @Condition getPlayersInSlot(0, Team.1).hasSpawned == false
    
    wait(0.5)
    getPlayersOnHero(Hero.REAPER, Team.ALL).setAbilityCooldown(Button.ABILITY_1, 0)
    if isGameInProgress() == true:
        getPlayersInSlot(0, Team.1).hasSpawned = true

/*
    This makes sure Reaper does not get stuck in a state while messing around during Waiting for Game...
*/
rule "Reaper Cleanup Before Game Start":
    @Condition isAssemblingHeroes() == true
    
    #This cleans up the dummy bots Reaper was using before the match and teleportation variables.
    destroyDummy(Team.1, 1)
    destroyDummy(Team.1, 2)
    #This teleport clean up is specifically for the pre-match.
    getPlayersInSlot(0, Team.1).isTeleporting = false
    getPlayersInSlot(0, Team.1).isRising = false
    enableEnvironmentCollision(getPlayersInSlot(0, Team.1))
    getPlayersInSlot(0, Team.1).clearStatusEffect(Status.PHASED_OUT)
    stopChasingVariable(getPlayersInSlot(0, Team.1).currentTeleportPosition)
    getPlayersInSlot(0, Team.1).stopForcingPosition()
    getPlayersInSlot(0, Team.1).setAbility1Enabled(true)
    getPlayersInSlot(0, Team.1).setMeleeEnabled(true)
    getPlayersInSlot(0, Team.1).setAbilityCooldown(Button.ABILITY_2, 7)
    getPlayersInSlot(0, Team.1).setInvisibility(Invis.NONE)

/*
    The first rule for teleport. This is executed by the player only.
*/
rule "Teleport (Start Teleport)":
    @Event eachPlayer
    @Team 1
    @Hero reaper
    @Condition eventPlayer.isHoldingButton(Button.ABILITY_2) == true
    @Condition eventPlayer.isTeleporting == false
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_2) == 0
    @Condition eventPlayer.hasStatusEffect(Status.HACKED) == false
    @Condition eventPlayer.hasStatusEffect(Status.FROZEN) == false
    @Condition eventPlayer.hasStatusEffect(Status.STUNNED) == false
    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) == false
    @Condition eventPlayer.hasStatusEffect(Status.ASLEEP) == false
    @Condition eventPlayer.isRising == false
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == false
    
    #The beginning of Reaper's unique teleport.
    eventPlayer.setAbilityCooldown(Button.ABILITY_2, 2)
    wait(0.1)
    playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.BLACK, eventPlayer.getPosition(), 3)
    eventPlayer.setAbility1Enabled(false)
    eventPlayer.setMeleeEnabled(false)
    eventPlayer.setInvisibility(Invis.ALL)
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)
    eventPlayer.disableEnvironmentCollision(true)
    eventPlayer.startForcingPosition(eventPlayer.currentTeleportPosition, true)
    eventPlayer.isTeleporting = true
    eventPlayer.currentTeleportPosition = eventPlayer.getPosition()
    eventPlayer.teleportDestination = eventPlayer.getPosition()
    chase(eventPlayer.currentTeleportPosition, updateEveryTick(eventPlayer.teleportDestination), rate=5*distance(eventPlayer.teleportDestination, eventPlayer.currentTeleportPosition), ChaseReeval.DESTINATION_AND_RATE)

/*
    Second part of the teleport. This animation is also used for dummy bot spawn (which has another rule executed to set up the rule properly)
*/
rule "Teleport (Rise from Ground)":
    @Event eachPlayer
    @Team 1
    @Hero reaper
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    @Condition eventPlayer.isTeleporting == true
    @Condition eventPlayer.isRising == false
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_2) == 0
    
    #Now the teleport actually begins. It teleports him to the spot and prepares Reaper for the rising phase.
    #eventPlayer.theGround = raycast(eventPlayer.getEyePosition(), eventPlayer.getFacingDirection() * 1000 + eventPlayer.getEyePosition(), null, eventPlayer, false).getHitPosition()
    #This check is applied due to an exploit on Eichenwalde.
    eventPlayer.theGround = raycast(eventPlayer.getEyePosition(), eventPlayer.getFacingDirection() * 1000 + eventPlayer.getEyePosition(), null, eventPlayer, false).getHitPosition()
    eventPlayer.disableEnvironmentCollision(true)
    eventPlayer.underTheGround = eventPlayer.theGround + vect(0, -4, 0)
    eventPlayer.currentTeleportPosition = eventPlayer.underTheGround
    chase(eventPlayer.currentTeleportPosition, eventPlayer.theGround, rate=2, ChaseReeval.DESTINATION_AND_RATE)
    eventPlayer.isRising = true
    wait(0.25)
    eventPlayer.setInvisibility(Invis.NONE)
    #This message serves as a warning for survivors that he is teleporting nearby.
    smallMessage([player for player in getAllPlayers() if distance(eventPlayer, player) <= 15], "{0} {2}: {1}".format(heroIcon(Hero.REAPER), stringReaperTeleportSpawn, eventPlayer))

/*
    The teleport is now complete, but status effects, variables, etc. still have to be reverted.
*/
rule "Teleport (Clean up Teleport)":
    @Event eachPlayer
    @Team 1
    @Hero reaper
    @Condition eventPlayer.currentTeleportPosition == eventPlayer.theGround
    @Condition eventPlayer.isRising == true
    
    #Once he has finished rising, this subroutine will clean up the variables and other adjustments made.
    eventPlayer.isTeleporting = false
    eventPlayer.isRising = false
    enableEnvironmentCollision(eventPlayer)
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    stopChasingVariable(eventPlayer.currentTeleportPosition)
    eventPlayer.stopForcingPosition()
    eventPlayer.setAbility1Enabled(true)
    eventPlayer.setMeleeEnabled(true)
    eventPlayer.setAbilityCooldown(Button.ABILITY_2, 7)
    #This is to prevent out of bounds teleports. The game waits 0.2 sec to ensure that the out of bounds is really out of bounds.
    wait(1)
    if distance(nearestWalkablePosition(eventPlayer.getPosition()), eventPlayer.getPosition()) >= 5 and eventPlayer.isDummy() == false:
        eventPlayer.teleport(nearestWalkablePosition(eventPlayer.getPosition()))
        playEffect(getAllPlayers(), DynamicEffect.BAD_EXPLOSION, Color.BLACK, eventPlayer.getPosition(), 3)
        eventPlayer.setStatusEffect(null, Status.STUNNED, 2)
        smallMessage(eventPlayer, stringInvalidPosition)

/*
    When teleporting, this rule loops while movement keys are being pressed. This ensures smooth movement.
*/
rule "Move Player During Teleport":
        @Event eachPlayer
        @Team 1
        @Hero reaper
        @Condition eventPlayer.isTeleporting == true
        @Condition eventPlayer.isRising == false
        
        if eventPlayer.getThrottle().x != 0 or eventPlayer.getThrottle().z != 0:
            eventPlayer.teleportDestination += angleToDirection(horizontalAngleFromDirection(eventPlayer.getThrottle()) + eventPlayer.getHorizontalFacingAngle(),0) * sqrt((eventPlayer.getThrottle().x * eventPlayer.getThrottle().x) + (eventPlayer.getThrottle().z * eventPlayer.getThrottle().z))
        if eventPlayer.isHoldingButton(Button.JUMP) == true:
            eventPlayer.teleportDestination += vect(0, 0.7, 0)
        if eventPlayer.isHoldingButton(Button.CROUCH) == true:
            eventPlayer.teleportDestination += vect(0, -0.7, 0)
        wait(0.05)
        if RULE_CONDITION:
            goto RULE_START


/*
    Begins the modified wraith ability. It can no-clip through walls.
*/
rule "Wraith (Setup No Clip)":
    @Event eachPlayer
    @Team 1
    @Hero reaper
    @Condition eventPlayer.isUsingAbility1() == true
    
    #With wraith form Reaper can no clip through walls.
    eventPlayer.disableEnvironmentCollision(false)
    eventPlayer.setMeleeEnabled(false)
    eventPlayer.setMoveSpeed(80)

/*
    When wraith is over, ability cooldown is manually set in case of balancing patches. Collision with walls is enabled.
*/
rule "Wraith (Disable Clipping)":
    @Event eachPlayer
    @Team 1
    @Hero reaper
    @Condition eventPlayer.isUsingAbility1() == false
    
    enableEnvironmentCollision(eventPlayer)
    eventPlayer.setMoveSpeed(100)
    wait(0.1)
    eventPlayer.setAbilityCooldown(Button.ABILITY_1, 12)
    #This is to fix wraith abuse. A technique used is to wraith to get the speed-boost, then while reverting, the player is given a window of opportunity to melee while still be invincible.
    #This wait prevents that.
    wait(0.3)
    eventPlayer.setMeleeEnabled(true)
    
/*
    Spawn a ghost. This can be done whether in teleport or not, unlike other abilities.
*/
rule "Spawn Ghost (Create Dummy Bot)":
    @Event eachPlayer
    @Team 1
    @Hero reaper
    @Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE) == true
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.decoyCD == 0
    @Condition eventPlayer.isRising == false
    
    createDummy(Hero.REAPER, Team.1, 2, vect(0,-4,0) + raycast(eventPlayer.getEyePosition(), eventPlayer.getFacingDirection() * 1000 + eventPlayer.getEyePosition(), null, eventPlayer, false).getHitPosition(), angleToDirection(eventPlayer.getHorizontalFacingAngle(), 0))
    eventPlayer.decoyCD = 10
    chase(eventPlayer.decoyCD, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)
    smallMessage([player for player in getAllPlayers() if distance(raycast(eventPlayer.getEyePosition(), eventPlayer.getFacingDirection() * 1000 + eventPlayer.getEyePosition(), null, eventPlayer, false).getHitPosition(), player) <= 15], "{0} {2}: {1}".format(heroIcon(Hero.REAPER), stringReaperTeleportSpawn, eventPlayer))

/*
    Ghost Variable and status setup. This rule is only ran by the dummy bot.
*/
rule "Ghost Setup (Dummy Bot Setup)":
    @Event eachPlayer
    @Team 1
    @Hero reaper
    @Condition eventPlayer.getSlot() == 2
    @Condition eventPlayer.isDummy() == true
    
    #This dummy bot is a setup and forget thing. Once it spawns it will automatically run forwards, sometimes changing direction and wraithing if a survivor is within view.
    eventPlayer.isTeleporting = true
    eventPlayer.startForcingThrottle(1, 1, 0, 1, 0, 1)
    #The following rules are to get it read for the Rise from Ground rule.
    eventPlayer.disableEnvironmentCollision(true)
    eventPlayer.currentTeleportPosition = eventPlayer.getPosition()
    eventPlayer.theGround = eventPlayer.getPosition() + vect(0, 4, 0)
    eventPlayer.startForcingPosition(eventPlayer.currentTeleportPosition, true)
    wait(1)
    eventPlayer.startForcingOutlineFor(getPlayers(Team.2), false, Color.WHITE)
    eventPlayer.disableNameplatesFor(getAllPlayers())
    chase(eventPlayer.currentTeleportPosition, eventPlayer.theGround, rate=2, ChaseReeval.DESTINATION_AND_RATE)
    eventPlayer.isRising = true
    #Before the ghost fully emerges and is fully spawned, effects are set up.
    wait(0.5)
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)
    eventPlayer.disableEnvironmentCollision(false)
    eventPlayer.startForcingOutlineFor(getPlayers(Team.1), true, Color.PURPLE)
    eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)

/*
    If the ghost manages to die, it is deleted so it doesn't pop out of nowhere somewhere unknown. Only for dummy bot.
*/
rule "Ghost Died (Destroy Bot if dead)":
    @Event playerDied
    @Team 1
    @Slot 2
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.getCurrentHero() == Hero.REAPER
    
    #If the dummy bot somehow dies, it is deleted so it doesn't just respawn randomly.
    destroyDummy(Team.1, 2)

/*
    The ghost cooldown is managed my a player variable instead of using an existing cooldown (since those are already taken up).
*/
rule "Ghost Spawn CD Reset":
    @Event eachPlayer
    @Team 1
    @Hero reaper
    @Condition eventPlayer.decoyCD == 0
    
    stopChasingVariable(eventPlayer.decoyCD)

/*
    Ghost teleports to the NWP when it starts falling. This is to prevent it from dying to a pit. Only for dummy bot.
*/
rule "Ghost Teleport":
    @Event eachPlayer
    @Team 1
    @Hero reaper
    @Condition eventPlayer.isInAir() == true
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.isTeleporting == false
    @Condition eventPlayer.isRising == false
    
    #The dummy bot tries to prevent suicide. If it starts falling it is assumed that it will die (whether that is true or not), so it teleports to the closest area and continues it's path.
    wait(0.5, Wait.ABORT_WHEN_FALSE)
    eventPlayer.teleport(nearestWalkablePosition(eventPlayer.getPosition()))
    eventPlayer.setFacing(vect(random.uniform(-1, -0.1), 0, random.uniform(-1, -0.1)), Relativity.TO_PLAYER)

/*
    In order to make it seem more real, it will lock onto a player's position and chase it with Wraith form. Only for dummy bot.
*/
rule "Ghost Chase":
    @Event eachPlayer
    @Team 1
    @Hero reaper
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.isTeleporting == false
    @Condition eventPlayer.isRising == false
    @Condition any([isInLoS(eventPlayer.getEyePosition(), player.getEyePosition(), BarrierLos.PASS_THROUGH_BARRIERS) == true for player in eventPlayer.getPlayersInViewAngle(Team.2, 30)]) == true
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_1) == 0
    @Condition eventPlayer.getCurrentHero() == Hero.REAPER
    
    #This is here to scare the player into reacting.
    eventPlayer.startForcingButton(Button.ABILITY_1)
    wait()
    eventPlayer.stopForcingButton(Button.ABILITY_1)
    eventPlayer.setFacing(directionTowards(eventPlayer, eventPlayer.getPlayerClosestToReticle(Team.2)), Relativity.TO_WORLD)
    #This is here to provide info for decoy swap. If the decoy sees a player and starts chasing, the Reaper may want to swap position and confuse the survivor, or take advantage of them not reacting.
    smallMessage(getPlayersInSlot(0, Team.1), "{0} {1}: {2}".format(heroIcon(Hero.REAPER), stringGhost, stringChase))

/*
    When it fully rises, the rule rids of any no-clip. Since the bot relies on it, it is restored in this dummy bot exclusive rule.
*/
rule "Restore No-Clip after Rising":
    @Event eachPlayer
    @Team 1
    @Hero reaper
    @Condition eventPlayer.isDummy() == true
    @Condition eventPlayer.isTeleporting == false
    @Condition eventPlayer.isRising == false
    @Condition eventPlayer.isUsingAbility1() == false
    
    #The decoy is always no clipped. It is both easier for it to roam and also a sign for survivors to note.
    eventPlayer.disableEnvironmentCollision(false)
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)

/*
    This rule swaps the positions and directions of the player and the dummy bot. Executed by player.
*/
rule "Ghost Swap (Dummy Bot Swap Positions)":
    @Event eachPlayer
    @Team 1
    @Hero reaper
    @Condition eventPlayer.isHoldingButton(Button.ULTIMATE) == true
    @Condition eventPlayer.isTeleporting == false
    @Condition entityExists(getPlayersInSlot(2, Team.1)) == true
    @Condition eventPlayer.decoySwapCD == 0
    @Condition eventPlayer.isUsingAbility1() == false
    @Condition eventPlayer.hasStatusEffect(Status.HACKED) == false
    @Condition eventPlayer.hasStatusEffect(Status.FROZEN) == false
    @Condition eventPlayer.hasStatusEffect(Status.STUNNED) == false
    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN) == false
    @Condition eventPlayer.hasStatusEffect(Status.ASLEEP) == false
    
    #Ghost swap ensures that, if done right, it is unnoticeable to the survivor. This means that the change has to be instant (so position variables have to be stored) and they are facing the same direction (another variable stored)
    eventPlayer.positionDecoy = getPlayersInSlot(2, Team.1).getPosition()
    eventPlayer.directionDecoy = getPlayersInSlot(2, Team.1).getFacingDirection()
    getPlayersInSlot(2, Team.1).teleport(eventPlayer)
    getPlayersInSlot(2, Team.1).setFacing(eventPlayer.getFacingDirection(), Relativity.TO_WORLD)
    wait(0.1)
    #In case the swap was in mid air, the decoy will retreat to NWP.
    eventPlayer.teleport(nearestWalkablePosition(eventPlayer.positionDecoy))
    eventPlayer.setFacing(eventPlayer.directionDecoy, Relativity.TO_WORLD)
    eventPlayer.decoySwapCD = 20
    chase(eventPlayer.decoySwapCD, 0, rate=1, ChaseReeval.DESTINATION_AND_RATE)

/*
    When the Ghost Swap Cooldown is 0, it is no longer chased to save on resources.
*/
rule "Ghost Swap Cooldown Reset":
    @Event eachPlayer
    @Team 1
    @Hero reaper
    @Condition eventPlayer.decoySwapCD == 0
    
    stopChasingVariable(eventPlayer.decoySwapCD)

/*
    If it feels more natural, the player can use primary fire to melee instead of the melee keybind.
*/
rule "Reaper Melee on Primary Fire":
    @Event eachPlayer
    @Team 1
    @Hero reaper
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE) == true
    @Condition eventPlayer.isTeleporting == false
    
    #As a community request, the melee can also be done on primary fire (though the game will still refer for the melee button in the info).
    eventPlayer.startForcingButton(Button.MELEE)
    wait()
    eventPlayer.stopForcingButton(Button.MELEE)

/*
    If Reaper lands a hit, he is stunned. This is to give time for the survivor to reposition.
*/
rule "Reaper Melee Stun":
    @Event playerDealtDamage
    @Team 1
    @Hero reaper
    @Condition eventPlayer.isMeleeing() == true
    
    #If Reaper lands a hit, he is stunned to give the victim time to reposition.
    eventPlayer.setStatusEffect(null, Status.STUNNED, 3)
    smallMessage(eventPlayer, stringReaperHit)

rule "Reaper died":
    @Event playerDied
    @Team 1
    @Hero reaper
    
    playEffect(getAllPlayers, DynamicEffect.BAD_EXPLOSION, Color.BLACK, eventPlayer.getPosition(), 3)