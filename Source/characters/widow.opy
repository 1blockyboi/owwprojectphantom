#!mainFile "../main.opy"

#!include "character.opy"

rule "Widowmaker Spawn":
    @Event eachPlayer
    @Team 1
    @Hero widowmaker
    @Condition eventPlayer.isAlive()
    @Condition eventPlayer.hasSpawned()
    
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)
    eventPlayer.setInvisibility(Invis.ALL)
    eventPlayer.startForcingPosition(vect(0,0,0), false)
    wait(1)
    eventPlayer.forceButtonPress(Button.ULTIMATE)