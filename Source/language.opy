#!mainFile "main.opy"

#Global variables

globalvar stringVersion 
globalvar stringCreator 
globalvar stringProject 
globalvar stringProjectLink 
globalvar stringCreatorVersion
globalvar stringCodeLink
globalvar stringCode
globalvar stringSec
globalvar stringHP 
globalvar stringMoiraTitle 
globalvar stringMoiraAbility1 
globalvar stringMoiraAbility2
globalvar stringMoiraPassive
globalvar stringMoiraHeal 
globalvar stringMoiraSacrifice
globalvar stringHideInfo 
globalvar stringShowInfo 
globalvar stringHanzoTitle 
globalvar stringHanzoAbility1 
globalvar stringHanzoAbility2 
globalvar stringHanzoPassive
globalvar stringBrigTitle 
globalvar stringBrigAbility1 
globalvar stringBrigAbility2 
globalvar stringWBTitle 
globalvar stringWBAbility1 
globalvar stringWBAbility2 
globalvar stringCharges 
globalvar stringSymTitle 
globalvar stringSymAbility1 
globalvar stringSymAbility2 
globalvar stringTracerTitle 
globalvar stringTracerAbility1 
globalvar stringTracerAbility2 
globalvar stringReaperTitle 
globalvar stringReaperAbility1 
globalvar stringReaperAbility2 
globalvar stringReaperAbility3 
globalvar stringReaperAbility4 
globalvar stringReaperAbility5 
globalvar stringTracerPassive 
globalvar stringWinstonTitle 
globalvar stringWinstonAbility1 
globalvar stringWinstonAbility2
globalvar stringTracerTeleportMessage 
globalvar stringTeamKill 
globalvar stringWinstonGrab 
globalvar stringTimeRemaining 
globalvar stringObjectiveSurvivors 
globalvar stringObjectiveReaper 
globalvar stringReaperTeleport 
globalvar stringReaperTeleportGhost 
globalvar stringLateJoin 
globalvar stringChase 
globalvar stringTip 
globalvar stringReaperTeleportSpawn 
globalvar stringArrayFog 
globalvar stringGhost 
globalvar stringWinstonRide
globalvar stringOneHit
globalvar stringWaitingGame
globalvar stringGH
globalvar stringGHDiscord 
globalvar stringGHDiscordLink
globalvar stringReaperHit
globalvar stringTip2
globalvar stringInvalidPosition

#Subroutine names

subroutine english

rule "Constant Strings":
    stringCodeLink = "8MM16"
    stringProjectLink = "workshop.codes/8MM16"
    stringVersion = "1.2.1"
    stringCreator = "Block#12425"
    stringGHDiscordLink = "grandeurhammers.com/discord"

rule "Determine Language (English)":
    #By default all strings are set to English. If it is a different language then the strings will be set to that, with any untranslated strings remaining in English.
    #All strings (that will be translated if they are) for the game.
    stringProject =  "Link: {0}".format(stringProjectLink)
    stringCreatorVersion = "Created by: {0}. Version: {1}".format(stringCreator, stringVersion)
    stringCode = "Code: {0}".format(stringCodeLink)
    stringSec = "CD"
    stringHP = "HP"
    stringMoiraTitle = "Moira, the phasing support."
    stringMoiraAbility1 = "Fade out and go through walls to escape."
    stringMoiraAbility2 = "Heal an injured teammate for 1 HP. Does not work on Tracer."
    stringHideInfo = "Hide Info."
    stringShowInfo = "Show info"
    stringHanzoTitle = "Hanzo, the eagle-eye."
    stringHanzoAbility1 = "Leap in the air."
    stringHanzoAbility2 = "Climb up walls."
    stringHanzoPassive = "Passive: Less Fog. Pings the Phantom and tracks it when he sees it."
    stringBrigTitle = "Brigitte, the frontline resistance."
    stringBrigAbility1 = "Use flail to throw the Phantom back."
    stringBrigAbility2 = "Bash and stun with the shield! Requires primary fire to use.\nDoes not block damage."
    stringWBTitle = "Wrecking Ball, the area denier"
    stringWBAbility1 = "Create a force field that repels the Phantom,\neven in when he is in Wraith form."
    stringWBAbility2 = "Place a mine field that lasts infinitely (and can be destroyed).\n The Phantom will be stunned and knocked back if he hits one."
    stringCharges = "Charges"
    stringTracerTitle = "Tracer, the quick-save speedster."
    stringTracerAbility1 = "Cover a chunk of distance in your current velocity instantly."
    stringTracerAbility2 = "Rewind to your position 3 seconds ago. Any teammates within\nthe ring when used will also be warped to your position."
    stringReaperTitle = "Reaper, the monstrous spirit."
    stringReaperAbility1 = "Go into wraith form to go faster and go through walls."
    stringReaperAbility2 = "Enter teleport mode, able to fly and spawn back (you or your ghost) anywhere."
    stringReaperAbility3 = "Spawn a ghost, that appears just like you and roams the map."
    stringReaperAbility4 = "Swap positions with your ghost, perfectly in the same direction as each other."
    stringReaperAbility5 = "Punch survivors close enough to deal damage. Targets are usually\ntwo hits, unless buffed by Moira."
    stringSymTitle = "Symmetra, the team escort."
    stringSymAbility1 = "Place a turret that slows down the Phantom. Can be destroyed. Max 3."
    stringSymAbility2 = "Create a teleporter for teammates to use. Use same button to destroy.\nWhen destroyed, restores charges of turrets."
    stringTracerPassive = "Passive: Fragile. (1 hit only)"
    stringWinstonTitle = "Winston, the relocating ape."
    stringWinstonAbility1 = "Leap a far distance, along with anyone else you are carrying."
    stringWinstonAbility2 = "When holding no one, pick up a teammate within range (the ring).\nWhen holding someone, throw them in your current facing direction."
    stringTracerTeleportMessage = "Teleported you back to safety my love!"
    stringMoiraHeal = "I have healed you."
    stringMoiraSacrifice = "I have sacrificed my life for you all! Do not fail me."
    stringTeamKill = "Nice job, you killed a teammate. Now you're dead."
    stringWinstonGrab = "I have picked you up! I can throw you far distances for your safety!"
    stringTimeRemaining = "Time Remaining"
    stringObjectiveSurvivors = "Survive until time runs out!"
    stringObjectiveReaper = "Kill all the mortals before time runs out!"
    stringReaperTeleport = "Finish Teleporting"
    stringReaperTeleportGhost = "Spawn a ghost"
    stringLateJoin = "Joined mid-match. Please wait until next match!"
    stringTip = "Tip: Only one REAL Phantom exists. Hanzo pings phantoms."
    stringTip2 = "Tip: Wrecking Ball's mines can be deactivated with melee."
    stringReaperTeleportSpawn = "You think you can hide..."
    stringArrayFog = ["A ghostly fog settles in...", "A snow storm forms...", "A dust storm rolls in..."]
    stringWinstonRide = "Hop off of Winston"
    stringGhost = "Ghost"
    stringChase = "Chasing survivor..."
    stringOneHit = "Only one hit left!"
    stringWaitingGame = "Please have the host start the game"
    stringMoiraPassive = "Passive: You can see teammates in the fog & their health status."
    stringGH = "{0} Certified by Grandeur Hammers".format(abilityIconString(Hero.TORBJORN, Button.ABILITY_2))
    stringGHDiscord = "{0}".format(stringGHDiscordLink)
    stringReaperHit = "Successful hit! Recharging..."
    stringInvalidPosition = "Teleported into an invalid position!"
    #Right now just executes English since no other languages are available