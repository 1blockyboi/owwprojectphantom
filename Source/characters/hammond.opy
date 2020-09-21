#!include "character.opy"

/*
    Survivor: Wrecking Ball
    Abilities: Force Field, Minefield
    Passive: None
    Team Synergy: Locks down an area, making it difficult for Reaper to push directly into it. Can be good to help teammates escape or hide in.
*/

/*
    Spawns Wrecking Ball. Uses commonSpawnConditions and startProcess from character.opy
*/
rule "Wrecking Ball Spawn":
    @Event eachPlayer
    @Team 2
    @Hero hammond
    commonSpawnConditions

    startProcess
        hudHeader(eventPlayer, "{0}\n{1}".format("{0}: {2}".format(abilityIconString(Hero.HAMMOND, Button.ABILITY_2), null, "{0} {1}".format(ceil(eventPlayer.getAbilityCooldown(Button.ABILITY_2)), stringSec)), "{0}: {2}".format(abilityIconString(Hero.HAMMOND, Button.ULTIMATE), null, "{0}%".format(ceil(eventPlayer.getUltCharge())))), HudPosition.LEFT, 0, Color.TURQUOISE, HudReeval.VISIBILITY_AND_STRING, SpecVisibility.DEFAULT)
        hudIDs[eventPlayer.getSlot()].append(getLastCreatedText())
        eventPlayer.setMaxHealth(50 / eventPlayer.getMaxHealth() * 100)
        eventPlayer.addHealthPool(Health.NORMAL, 150, true, true)
        commonSub()
        eventPlayer.setAbilityCooldown(Button.ABILITY_2,0)

/*
    Wrecking Ball uses his force field to push the monster back, regardless of ability.
*/
rule "Block#12425 - Wrecdking Ball Push Back":
    @Event eachPlayer
    @Team 2
    @Hero hammond
    @Condition eventPlayer.isUsingAbility2() == true
    @Condition getPlayersInSlot(0, Team.1).survivorSpecificVariable[0] == false
    @Condition isInLoS(eventPlayer, getPlayersInSlot(0, Team.1), BarrierLos.PASS_THROUGH_BARRIERS) == true
    @Condition distance(eventPlayer, getPlayersInSlot(0, Team.1)) <= 7
    
    #Wrecking Ball can push back Reaper even in wraith form.
    getPlayersInSlot(0, Team.1).applyImpulse(directionTowards(eventPlayer.getPosition(), getPlayersInSlot(0, Team.1).getEyePosition()), 20, Relativity.TO_WORLD, Impulse.CANCEL_CONTRARY_MOTION)
    wait(0.05)
    if RULE_CONDITION:
        goto RULE_START

/*
    Every time the monster hits a mine, he is stunned for some time. Punishing.
*/
rule "Block#12425 - Wrecking Ball Mine Stun":
    @Event playerDealtDamage
    @Team 2
    @Hero hammond
    
    #If Reaper hits a mine, he is stunned.
    victim.setStatusEffect(null, Status.KNOCKED_DOWN, 3)

/*
    Manually set the force field cooldown.
*/
rule "Force Field Cooldown":
    @Event eachPlayer
    @Team 2
    @Hero hammond
    @Condition eventPlayer.getAbilityCooldown(Button.ABILITY_2) >= 0

    wait(0.1)
    #To counter balancing patches.
    eventPlayer.setAbilityCooldown(Button.ABILITY_2,20)