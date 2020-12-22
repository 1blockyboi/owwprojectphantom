#!suppressWarnings w_already_imported
#!include "characters/brigitte.opy"
#!include "characters/moira.opy"
#!include "characters/winston.opy"
#!include "characters/tracer.opy"
#!include "characters/hammond.opy"
#!include "characters/hanzo.opy"
#!include "characters/symmetra.opy"
#!include "characters/reaper.opy"
#!include "characters/widow.opy"
#!include "settings.opy"


#Global variables
globalvar gracePeriod 
globalvar matchTimeMin 
globalvar matchTimeSec
globalvar constantMatchTime
globalvar debugMode 
globalvar tipsEnabled
globalvar dynMatchTime

#Subroutine names
subroutine debugMode
subroutine nameTagCreate

/*
    Global setup at the beginning.
*/
rule "Initial Setup (Global Setup)":
    disableMusic()
    disableAnnouncer()
    disableGamemodeCompletion()
    disableScoring()
    nameTagCreate()
    gracePeriod = 30
    tipsEnabled = createWorkshopSetting(bool, "General", "Info Displayed by Default", true)
    matchTimeMin = createWorkshopSetting(int<1:20>, "Time", "Minutes", 4)
    matchTimeSec = createWorkshopSetting(int<0:59>, "Time", "Seconds", 30)
    debugMode = createWorkshopSetting(bool, "Debug Mode", "Enabled", false)
    constantMatchTime = createWorkshopSetting(bool, "Time", "Dynamic Match Time", true)
    #If debug mode is disabled, recording is also disabled to save server resources.
    hudIDs = []
    effectIDs = []
    inWorldTextIDs = []
    if debugMode:
        hudText(hostPlayer, getAverageServerLoad(), l"Server Load Average", null, HudPosition.RIGHT, 10, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    else:
        disableInspector()

/*
    Initial Setup for each player.
*/
rule "Initial Setup (Per Player Setup)":
    @Event eachPlayer
    @Hero all
    @Condition (isWaitingForPlayers() or isGameInProgress()) == true
    
    eventPlayer.disableHeroHUD()
    eventPlayer.disableGamemodeHud()
    eventPlayer.enableDeathSpectateTargetHud()
    eventPlayer.prevHero = null
    eventPlayer.setRespawnTime(5)
    if eventPlayer.getTeam() == Team.2:
        eventPlayer.disableScoreboard()
        eventPlayer.disableKillFeed()
        eventPlayer.hasSpawned = false
    if tipsEnabled == false:
        eventPlayer.hideInfo = true

/*
    Global HUD setup
*/
rule "Pre-Match HUD & In-world Effect Creation":
    #Global HUD setup
    hudHeader([player for player in getAllPlayers() if isGameInProgress() == true], "{1}: {0}".format(ceil(getMatchTime()), stringTimeRemaining), HudPosition.TOP, 0, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getPlayers(Team.2) if isGameInProgress() == true], stringObjectiveSurvivors, HudPosition.TOP, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getPlayers(Team.1) if isGameInProgress() == true], stringObjectiveReaper, HudPosition.TOP, -1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader(getAllPlayers(), "Project: Phantom", HudPosition.RIGHT, -5, Color.PURPLE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText(getAllPlayers(), null, stringCreatorVersion, " ", HudPosition.RIGHT, -4, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), stringDiscord, HudPosition.RIGHT, -3, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), stringProject, HudPosition.RIGHT, -2, Color.ORANGE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), stringCode, HudPosition.RIGHT, -1, Color.AQUA, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudHeader([player for player in getPlayers(Team.2) if player.winstonGrab == true], "{0}: {1}".format(buttonString(Button.JUMP), stringWinstonRide), HudPosition.TOP, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getPlayers(Team.2), stringTip, HudPosition.LEFT, 3, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getPlayers(Team.1), stringTip2, HudPosition.LEFT, 4, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), " \n{0}".format(stringGH), HudPosition.RIGHT, -0.92, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext(getAllPlayers(), stringGHDiscord, HudPosition.RIGHT, -0.91, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    #Late Join HUD Setup
    hudHeader([player for player in getPlayers(Team.2) if player.lateJoin == true], stringLateJoin, HudPosition.TOP, 2, Color.YELLOW, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    #Show/hide info setup
    hudSubtext([player for player in getAllPlayers() if player.hideInfo == true], " \n{0} + {2}: {1}".format(buttonString(Button.INTERACT), stringShowInfo, buttonString(Button.CROUCH)), HudPosition.LEFT, 2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getAllPlayers() if player.hideInfo == false], " \n{0} + {2}: {1}".format(buttonString(Button.INTERACT), stringHideInfo, buttonString(Button.CROUCH)), HudPosition.LEFT, 2, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudText([player for player in getPlayers(Team.ALL) if isWaitingForPlayers() == true], null, null, "{0} ({1})".format(stringWaitingGame, hostPlayer), HudPosition.TOP, -1, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_SORT_ORDER_AND_STRING, SpecVisibility.DEFAULT)
   
    #Survivor Info HUD Setup
    hudSubtext([player for player in getPlayers(Team.2) if player.getCurrentHero() == Hero.MOIRA and player.hideInfo == false], " \n{0}\n\n{1}".format(stringMoiraTitle, "{0}\n{1}\n{2}".format("{0} {1}: {2}".format(abilityIconString(Hero.MOIRA, Button.ABILITY_1), buttonString(Button.ABILITY_1), stringMoiraAbility1), "{0} {1}: {2}".format(abilityIconString(Hero.ZENYATTA, Button.ABILITY_1), buttonString(Button.ABILITY_2), stringMoiraAbility2), stringMoiraPassive)), HudPosition.LEFT, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getPlayers(Team.2) if player.getCurrentHero() == Hero.HANZO and player.hideInfo == false], " \n{0}\n\n{1}".format(stringHanzoTitle, "{0}\n{1}\n{2}".format("{0} {1}: {2}".format(abilityIconString(Hero.WINSTON, Button.ABILITY_1), buttonString(Button.JUMP), stringHanzoAbility1), "{0} {1}: {2}".format(abilityIconString(Hero.HANZO, Button.JUMP), buttonString(Button.JUMP), stringHanzoAbility2), stringHanzoPassive)), HudPosition.LEFT, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getPlayers(Team.2) if player.getCurrentHero() == Hero.BRIGITTE and player.hideInfo == false], " \n{0}\n\n{1}".format(stringBrigTitle, "{0}\n{1}".format("{0} {1}: {2}".format(abilityIconString(Hero.BRIGITTE, Button.ABILITY_1), buttonString(Button.ABILITY_1), stringBrigAbility1), "{0} {1}: {2}".format(abilityIconString(Hero.BRIGITTE, Button.SECONDARY_FIRE), buttonString(Button.SECONDARY_FIRE), stringBrigAbility2))), HudPosition.LEFT, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getPlayers(Team.2) if player.getCurrentHero() == Hero.HAMMOND and player.hideInfo == false], " \n{0}\n\n{1}".format(stringWBTitle, "{0}\n{1}".format("{0} {1}: {2}".format(abilityIconString(Hero.HAMMOND, Button.ABILITY_2), buttonString(Button.ABILITY_2), stringWBAbility1), "{0} {1}: {2}".format(abilityIconString(Hero.HAMMOND, Button.ULTIMATE), buttonString(Button.ULTIMATE), stringWBAbility2))), HudPosition.LEFT, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getPlayers(Team.2) if player.getCurrentHero() == Hero.SYMMETRA and player.hideInfo == false], " \n{0}\n\n{1}".format(stringSymTitle, "{0}\n{1}".format("{0} {1}: {2}".format(abilityIconString(Hero.SYMMETRA, Button.ABILITY_1), buttonString(Button.ABILITY_1), stringSymAbility1), "{0} {1}: {2}".format(abilityIconString(Hero.SYMMETRA, Button.ABILITY_2), buttonString(Button.ABILITY_2), stringSymAbility2))), HudPosition.LEFT, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getPlayers(Team.2) if player.getCurrentHero() == Hero.TRACER and player.hideInfo == false], " \n{0}\n\n{1}".format(stringTracerTitle, "{0}\n{1}\n{2}".format("{0} {1}: {2}".format(abilityIconString(Hero.TRACER, Button.ABILITY_1), buttonString(Button.ABILITY_1), stringTracerAbility1), "{0} {1}: {2}".format(abilityIconString(Hero.TRACER, Button.ABILITY_2), buttonString(Button.ABILITY_2), stringTracerAbility2), stringTracerPassive)), HudPosition.LEFT, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
    hudSubtext([player for player in getPlayers(Team.2) if player.getCurrentHero() == Hero.WINSTON and player.hideInfo == false], " \n{0}\n\n{1}".format(stringWinstonTitle, "{0}\n{1}".format("{0} {1}: {2}".format(abilityIconString(Hero.WINSTON, Button.ABILITY_1), buttonString(Button.ABILITY_1), stringWinstonAbility1), "{0} {1}: {2}".format(abilityIconString(Hero.MERCY, Button.ABILITY_2), buttonString(Button.SECONDARY_FIRE), stringWinstonAbility2))), HudPosition.LEFT, 1, Color.WHITE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)

/*
    Subroutine creates name tags for Team 2.
*/
def nameTagCreate():
    @Name "Nametag In World Text Setup Subroutine"
    
    #Nametags are disabled for Team 2 by default, so I created an alternate name tag system. Basically, when one player of team 2 is close to another team 2 player, they get to see each other's nametags.
    createInWorldText([player for player in getLivingPlayers(Team.2) if distance(getPlayersInSlot(0, Team.2), player) <= 8 and isInLoS(getPlayersInSlot(0, Team.2), player, BarrierLos.PASS_THROUGH_BARRIERS) == true and entityExists(getPlayersInSlot(0, Team.2)) == true and player != getPlayersInSlot(0, Team.2)], getPlayersInSlot(0, Team.2), getPlayersInSlot(0, Team.2), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.YELLOW, SpecVisibility.DEFAULT)
    createInWorldText([player for player in getLivingPlayers(Team.2) if distance(getPlayersInSlot(1, Team.2), player) <= 8 and isInLoS(getPlayersInSlot(1, Team.2), player, BarrierLos.PASS_THROUGH_BARRIERS) == true and entityExists(getPlayersInSlot(1, Team.2)) == true and player != getPlayersInSlot(1, Team.2)], getPlayersInSlot(1, Team.2), getPlayersInSlot(1, Team.2), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.YELLOW, SpecVisibility.DEFAULT)
    createInWorldText([player for player in getLivingPlayers(Team.2) if distance(getPlayersInSlot(2, Team.2), player) <= 8 and isInLoS(getPlayersInSlot(2, Team.2), player, BarrierLos.PASS_THROUGH_BARRIERS) == true and entityExists(getPlayersInSlot(2, Team.2)) == true and player != getPlayersInSlot(2, Team.2)], getPlayersInSlot(2, Team.2), getPlayersInSlot(2, Team.2), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.YELLOW, SpecVisibility.DEFAULT)
    createInWorldText([player for player in getLivingPlayers(Team.2) if distance(getPlayersInSlot(3, Team.2), player) <= 8 and isInLoS(getPlayersInSlot(3, Team.2), player, BarrierLos.PASS_THROUGH_BARRIERS) == true and entityExists(getPlayersInSlot(3, Team.2)) == true and player != getPlayersInSlot(3, Team.2)], getPlayersInSlot(3, Team.2), getPlayersInSlot(3, Team.2), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.YELLOW, SpecVisibility.DEFAULT)
    createInWorldText([player for player in getLivingPlayers(Team.2) if distance(getPlayersInSlot(4, Team.2), player) <= 8 and isInLoS(getPlayersInSlot(4, Team.2), player, BarrierLos.PASS_THROUGH_BARRIERS) == true and entityExists(getPlayersInSlot(4, Team.2)) == true and player != getPlayersInSlot(4, Team.2)], getPlayersInSlot(4, Team.2), getPlayersInSlot(4, Team.2), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.YELLOW, SpecVisibility.DEFAULT)
    createInWorldText([player for player in getLivingPlayers(Team.2) if distance(getPlayersInSlot(5, Team.2), player) <= 8 and isInLoS(getPlayersInSlot(5, Team.2), player, BarrierLos.PASS_THROUGH_BARRIERS) == true and entityExists(getPlayersInSlot(5, Team.2)) == true and player != getPlayersInSlot(5, Team.2)], getPlayersInSlot(5, Team.2), getPlayersInSlot(5, Team.2), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.YELLOW, SpecVisibility.DEFAULT)
    createInWorldText([player for player in getLivingPlayers(Team.2) if distance(getPlayersInSlot(6, Team.2), player) <= 8 and isInLoS(getPlayersInSlot(6, Team.2), player, BarrierLos.PASS_THROUGH_BARRIERS) == true and entityExists(getPlayersInSlot(6, Team.2)) == true and player != getPlayersInSlot(6, Team.2)], getPlayersInSlot(6, Team.2), getPlayersInSlot(6, Team.2), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.YELLOW, SpecVisibility.DEFAULT)
    createInWorldText([player for player in getLivingPlayers(Team.2) if distance(getPlayersInSlot(7, Team.2), player) <= 8 and isInLoS(getPlayersInSlot(7, Team.2), player, BarrierLos.PASS_THROUGH_BARRIERS) == true and entityExists(getPlayersInSlot(7, Team.2)) == true and player != getPlayersInSlot(7, Team.2)], getPlayersInSlot(7, Team.2), getPlayersInSlot(7, Team.2), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.YELLOW, SpecVisibility.DEFAULT)
    createInWorldText([player for player in getLivingPlayers(Team.2) if distance(getPlayersInSlot(8, Team.2), player) <= 8 and isInLoS(getPlayersInSlot(8, Team.2), player, BarrierLos.PASS_THROUGH_BARRIERS) == true and entityExists(getPlayersInSlot(8, Team.2)) == true and player != getPlayersInSlot(8, Team.2)], getPlayersInSlot(8, Team.2), getPlayersInSlot(8, Team.2), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.YELLOW, SpecVisibility.DEFAULT)
    createInWorldText([player for player in getLivingPlayers(Team.2) if distance(getPlayersInSlot(9, Team.2), player) <= 8 and isInLoS(getPlayersInSlot(9, Team.2), player, BarrierLos.PASS_THROUGH_BARRIERS) == true and entityExists(getPlayersInSlot(9, Team.2)) == true and player != getPlayersInSlot(9, Team.2)], getPlayersInSlot(9, Team.2), getPlayersInSlot(9, Team.2), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.YELLOW, SpecVisibility.DEFAULT)
    createInWorldText([player for player in getLivingPlayers(Team.2) if distance(getPlayersInSlot(10, Team.2), player) <= 8 and isInLoS(getPlayersInSlot(10, Team.2), player, BarrierLos.PASS_THROUGH_BARRIERS) == true and entityExists(getPlayersInSlot(10, Team.2)) == true and player != getPlayersInSlot(10, Team.2)], getPlayersInSlot(10, Team.2), getPlayersInSlot(10, Team.2), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.YELLOW, SpecVisibility.DEFAULT)
    createInWorldText([player for player in getLivingPlayers(Team.2) if distance(getPlayersInSlot(11, Team.2), player) <= 8 and isInLoS(getPlayersInSlot(11, Team.2), player, BarrierLos.PASS_THROUGH_BARRIERS) == true and entityExists(getPlayersInSlot(11, Team.2)) == true and player != getPlayersInSlot(11, Team.2)], getPlayersInSlot(11, Team.2), getPlayersInSlot(11, Team.2), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.YELLOW, SpecVisibility.DEFAULT)

/*
    Subroutine that adds debug mode.
*/
def debugMode():
    @Name "Debug Mode"
    
    #A dummy bot for Reaper and Ana is created so that you can test certain stuff. They both occupy slot 0 of each team, so if you don't want them to spawn in, make sure a player is in each of those slots.
    createDummy(Hero.REAPER, Team.1, 0, nearestWalkablePosition(vect(0, 0, 0)), vect(0, 0, 0))
    createDummy(Hero.HANZO, Team.2, 0, nearestWalkablePosition(vect(1000, 0, 0)), vect(0, 0, 0))
    wait(2)
    damage(getLastCreatedEntity(), null, 150)

/*
    This sets up some stuff when the game starts.
*/
rule "Gamemode Setup":
    @Condition isGameInProgress() == true
    
    if (constantMatchTime):
        if (len(getPlayers(Team.2)) <= 2):
            dynMatchTime = 70
        else:
            dynMatchTime = len(getPlayers(Team.2)) * 35
    else:
        dynMatchTime = matchTimeMin * 60 + matchTimeSec
    setMatchTime(dynMatchTime)
    bigMessage(getPlayers(Team.2), stringObjectiveSurvivors)
    bigMessage(getPlayers(Team.1), stringObjectiveReaper)
    if debugMode == true:
        debugMode()

/*
    The setup when time runs out.
*/
rule "Winning Setup (Time Runs Out)":
    @Condition isGameInProgress() == true
    @Condition getMatchTime() == 0
    
    wait(0.1, Wait.ABORT_WHEN_FALSE)
    #If some living players are still alive for team 2 (that also have spawned in) when time runs out, they win, else Reaper wins. (This else statement solely exists for backup. Practically this will never be executed).
    if len([player for player in getLivingPlayers(Team.2) if player.hasSpawned() == true]) > 0:
        declareTeamVictory(Team.2)
    else:
        declareTeamVictory(Team.1)
    destroyAllDummies()

/*
    The winning setup when the monster kills everyone that spawned in on time.
*/
rule "Winning Setup (Reaper Kills Everyone that spawned on time)":
    @Condition isGameInProgress() == true
    @Condition len([player for player in getLivingPlayers(Team.2) if player.hasSpawned() == true]) == 0
    @Condition getMatchTime() < dynMatchTime - gracePeriod
    @Condition getPlayersInSlot(0, Team.1).hasSpawned() == true
    
    #If everyone is dead, Reaper wins.
    wait(0.1, Wait.ABORT_WHEN_FALSE)
    declareTeamVictory(Team.1)
    destroyAllDummies()

/*
    Rare winning setup if the monster hasn't spawned.
*/
rule "Winning Setup (Survivors win if Reaper does not exist)":
    @Condition isGameInProgress() == true
    @Condition entityExists(getPlayersInSlot(0, Team.1)) == false
    @Condition getMatchTime() < dynMatchTime - gracePeriod
    
    #Backup win condition if Reaper did not spawn in or he disconnected.
    wait(0.1)
    declareTeamVictory(Team.2)
    destroyAllDummies()

/*
    The player setup if a player takes too long to select a character or joins late.
*/
rule "Late Join Setup":
    @Event eachPlayer
    @Team 2
    @Hero all
    @Condition eventPlayer.hasSpawned() == false
    @Condition isGameInProgress() == true
    #If a player joins or did not select a character before the grace period (default match time - grace period), then he is considered a late joining player. The game does not consider him to be alive, and when he spawns he is killed immediately.
    @Condition getMatchTime() < dynMatchTime - gracePeriod
    
    wait(0.1, Wait.ABORT_WHEN_FALSE)
    eventPlayer.lateJoin = true
    eventPlayer.disableRespawn()

/*
    When the late player spawns, they are killed immediately.
*/
rule "Late Join Kill":
    @Event eachPlayer
    @Team 2
    @Hero all
    @Condition isGameInProgress() == true
    @Condition eventPlayer.isAlive() == true
    @Condition eventPlayer.hasSpawned() == true
    @Condition eventPlayer.lateJoin == true
    
    kill(eventPlayer, null)