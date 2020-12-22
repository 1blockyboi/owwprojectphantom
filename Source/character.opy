#!mainFile "main.opy"
#!include "language.opy"

#!define commonSpawnConditions @Condition eventPlayer.isAlive() == true\
    @Condition isGameInProgress() == true or isWaitingForPlayers() == true\
    @Condition eventPlayer.hasSpawned() == true\
    @Condition eventPlayer.lateJoin == false\

#NOTE: If used, make sure that the actions included are tabbed twice relative to the positioning of this macro.
#!define startProcess \
    wait(0.5, Wait.ABORT_WHEN_FALSE)\
    if eventPlayer.getCurrentHero() != eventPlayer.prevHero or eventPlayer.prevHero == null:\
        playerReset()\
        wait(0.1)

globalvar hudIDs
globalvar effectIDs
globalvar inWorldTextIDs
globalvar iconIDs
globalvar i
globalvar j
globalvar fogDistance

#Player variables
playervar survivorSpecificVariable3
playervar survivorSpecificVariable4
playervar winstonGrab
playervar lateJoin
playervar survivorSpecificVariable
playervar throwingPlayer
playervar survivorSpecificVariable2
playervar wasOnWall
playervar hasSpawned
playervar hideInfo
playervar survivorSpecificVariable5
playervar prevHero
playervar k

#Subroutine names
subroutine commonSub
subroutine playerReset
subroutine fogCreation

/*
    Workshop Player Variables.
*/
rule "Player Workshop Setting Variables":

   fogDistance = createWorkshopSetting(int<5:30>, "General", "Fog Distance", 14)

/*
    Setup for Team 2 players.
*/
rule "Team 2 Game Start Setup":
    @Event eachPlayer
    @Team 2
    @Hero all
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.isAlive() == true
    
    wait(0.5, Wait.ABORT_WHEN_FALSE)
    
    #Unique fog messages for each map.
    if getCurrentMap() == Map.ECOPOINT_ANTARCTICA:
        smallMessage(eventPlayer, stringArrayFog[1])
    elif getCurrentMap() == Map.NECROPOLIS:
        smallMessage(eventPlayer, stringArrayFog[2])
    else:
        smallMessage(eventPlayer, stringArrayFog[0])
    #Team 2 players cannot see where they are.
    getPlayersInSlot(0,Team.1).startForcingOutlineFor(getPlayers(Team.2), false, Color.WHITE)
    getPlayersInSlot(0,Team.1).disableNameplatesFor(getAllPlayers())
    getPlayersInSlot(2,Team.1).startForcingOutlineFor(getPlayers(Team.2), false, Color.WHITE)
    getPlayersInSlot(2,Team.1).disableNameplatesFor(getAllPlayers())
    eventPlayer.startForcingOutlineFor(getPlayers(Team.2), false, Color.WHITE)
    eventPlayer.disableNameplatesFor(getPlayers(Team.2))
    eventPlayer.startScalingSize(0.9, true)
    eventPlayer.startScalingBarriers(0.9, true)
    if isGameInProgress() == true:
        eventPlayer.disableRespawn()
        bigMessage(eventPlayer, stringObjectiveSurvivors)

#!define fogCreate(distance)    createEffect(eventPlayer, Effect.BAD_AURA, Color.BLACK, updateEveryTick(eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * (distance)), 1000, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)\
effectIDs[eventPlayer.getSlot()].append(getLastCreatedEntity())

/*
    commonSub used by Team 2 Survivors.
*/
def commonSub():
    @Name "Common Subroutine"
    
    #This fog is unique to the player, that way they always see fogDistance meters ahead of them.
    if (eventPlayer.getCurrentHero() != Hero.HANZO):
        fogCreation()
    wait(0.5)
    heal(eventPlayer, null, 1000)
    wait(1)
    eventPlayer.setHealingDealt(0)
    eventPlayer.prevHero = eventPlayer.getCurrentHero()
    getPlayersInSlot(0,Team.1).startForcingOutlineFor(eventPlayer, false, Color.WHITE)
    getPlayersInSlot(0,Team.1).disableNameplatesFor(getAllPlayers())
    getPlayersInSlot(2,Team.1).startForcingOutlineFor(eventPlayer, false, Color.WHITE)
    getPlayersInSlot(2,Team.1).disableNameplatesFor(getAllPlayers())
    eventPlayer.startForcingOutlineFor(getPlayers(Team.2), false, Color.WHITE)
    eventPlayer.disableNameplatesFor(getPlayers(Team.2))


def fogCreation():
    @Name "Fog Creation Subroutine"

    fogCreate(fogDistance)
    fogCreate(fogDistance + 1)
    fogCreate(fogDistance + 2)
    fogCreate(fogDistance * -1)

/*
    Team Kill Setup
*/
rule "Player Dies due to teammate":
    @Event playerDied
    @Team 2
    @Hero all
    @Condition eventPlayer.throwingPlayer != null
    @Condition attacker != getPlayersInSlot(0, Team.1)
    
    #If a troll was successful, this makes sure that the player trolled is not punished, but instead the troll. This only works with Winston and Tracer.
    kill(eventPlayer.throwingPlayer, eventPlayer)
    smallMessage(eventPlayer.throwingPlayer, stringTeamKill)
    eventPlayer.throwingPlayer = null
    wait(0.2)
    eventPlayer.respawn()

/*
    Reset Player status after being moved by a teammate.
*/
rule "Reset Player Throw Status":
    @Event eachPlayer
    @Team 2
    @Hero all
    @Condition eventPlayer.isOnGround() == true
    @Condition eventPlayer.throwingPlayer != null
    
    wait(0.5, Wait.ABORT_WHEN_FALSE)
    eventPlayer.throwingPlayer = null

/*
    Hide and show info HUD.
*/
rule "Hide Info HUD":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.isHoldingButton(Button.INTERACT) == true
    @Condition eventPlayer.isHoldingButton(Button.CROUCH) == true
        
    if eventPlayer.hideInfo == false:
        eventPlayer.hideInfo = true
    else:
        eventPlayer.hideInfo = false

/*
    Cleans up player IDs after they leave.
*/
rule "Player Clean-up Team 2":
    @Event playerLeft

    for i in range(0,8,1):
        if entityExists(getPlayersInSlot(i, Team.2)) == false:
            for j in range(len(hudIDs[i])):
                destroyHudText(hudIDs[i][j])
                hudIDs[i] = []
            for j in range(len(effectIDs[i])):
                destroyEffect(effectIDs[i][j])
                effectIDs[i] = []
            for j in range(len(inWorldTextIDs[i])):
                destroyInWorldText(inWorldTextIDs[i][j])
                inWorldTextIDs[i] = []
            for j in range(len(iconIDs[i])):
                destroyInWorldText(iconIDs[i][j])
                iconIDs[i] = []

/*
    Cleans up Team 2 IDs when game is starting.
*/
rule "Assembly Players Team 2 Clean-Up":
    for i in range(0,8,1):
            for j in range(len(hudIDs[i])):
                destroyHudText(hudIDs[i][j])
            hudIDs[i] = []
            for j in range(len(effectIDs[i])):
                destroyEffect(effectIDs[i][j])
            effectIDs[i] = []
            for j in range(len(inWorldTextIDs[i])):
                destroyInWorldText(inWorldTextIDs[i][j])
            inWorldTextIDs[i] = []
            for j in range(len(iconIDs[i])):
                destroyInWorldText(iconIDs[i][j])
            iconIDs[i] = []
            getPlayersInSlot(i, Team.2).removeAllHealthPools()

/*
    Reset Player IDs subroutine.
*/
def playerReset():
    @Name "Player Reset"
    
    for eventPlayer.k in range(len(hudIDs[eventPlayer.getSlot()])):
        destroyHudText(hudIDs[eventPlayer.getSlot()][eventPlayer.k])
    hudIDs[eventPlayer.getSlot()] = []
    for eventPlayer.k in range(len(effectIDs[eventPlayer.getSlot()])):
        destroyEffect(effectIDs[eventPlayer.getSlot()][eventPlayer.k])
    effectIDs[eventPlayer.getSlot()] = []
    for eventPlayer.k in range(len(inWorldTextIDs[eventPlayer.getSlot()])):
        destroyInWorldText(inWorldTextIDs[eventPlayer.getSlot()][eventPlayer.k])
    inWorldTextIDs[eventPlayer.getSlot()] = []
    for eventPlayer.k in range(len(iconIDs[eventPlayer.getSlot()])):
        destroyIcon(iconIDs[eventPlayer.getSlot()][eventPlayer.k])
    iconIDs[eventPlayer.getSlot()] = []
    eventPlayer.removeAllHealthPools()
    eventPlayer.setGravity(100)
    wait()
    eventPlayer.setMaxHealth(100)
    hudText(eventPlayer, "{0}: {1}".format(iconString(Icon.HEART), ceil(eventPlayer.getHealth()/150)), stringOneHit if eventPlayer.getHealth() <= 150 else "", null, HudPosition.TOP, 0.5, Color.GREEN if eventPlayer.getHealth() > 150 else Color.RED, Color.WHITE, null, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
    hudIDs[eventPlayer.getSlot()].append(getLastCreatedText())
    #hudText([player for player in eventPlayer if eventPlayer.getHealth() <= 150], "{0}: {1}".format(iconString(Icon.HEART), ceil(eventPlayer.getHealth()/150)), stringOneHit, null, HudPosition.TOP, 0.5, Color.RED, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    #hudIDs[eventPlayer.getSlot()].append(getLastCreatedText())

rule "Winston Grab Reset":
    @Event playerLeft
    @Team 2
    @Condition entityExists(eventPlayer.throwingPlayer) == false and eventPlayer.winstonGrab

    eventPlayer.detach()
    eventPlayer.winstonGrab = false
    eventPlayer.clearStatusEffect(Status.HACKED)