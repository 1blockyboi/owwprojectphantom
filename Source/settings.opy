/* Lobby Settings for mode */

settings {
    "main": {
        "description": "Project: Phantom. Survive the nightmare until time runs out! Choose from multiple and unique survivors to help both yourself and your teammates. Version 1.1.1. Created by Block#12425. Discord server: https://discord.gg/CSKSVDH"
    },
    "lobby": {
        "allowPlayersInQueue": true,
        "team1Slots": 1,
        "team2Slots": 9,
        "returnToLobby": "never",
        "teamBalancing": "afterGame"
    },
    "gamemodes": {
        "tdm": {
            "enabledMaps": [
                "ecopointAntarcticaWinter",
                "eichenwaldeHalloween",
                "necropolis"
            ]
        },
        "general": {
            "heroLimit": "2PerTeam",
            "enableSkins": false,
            "spawnHealthPacks": "disabled"
        }
    },
    "heroes": {
        "team1": {
            "reaper": {
                "movementSpeed%": 110,
                "damageDealt%": 500,
                "damageReceived%": 10,
                "enablePrimaryFire": false,
                "enableAbility2": false,
                "enableUlt": false
            },
            "enabledHeroes": [
                "reaper"
            ]
        },
        "team2": {
            "brigitte": {
                "secondaryFireCooldown%": 20,
                "secondaryFireRechargeRate%": 150,
                "healingDealt%": 10,
                "enablePrimaryFire": false,
                "enableAbility2": false,
                "enableUlt": false,
                "ability1Kb%": 150
            },
            "hanzo": {
                "enableAbility3": false,
                "enablePrimaryFire": false,
                "enableAbility2": false,
                "enableUlt": false
            },
            "moira": {
                "enableAbility2": false,
                "enablePrimaryFire": false,
                "enableSecondaryFire": false,
                "enableUlt": false
            },
            "reaper": {
                "damageDealt%": 350,
                "damageReceived%": 10
            },
            "symmetra": {
                "enablePrimaryFire": false,
                "enableSecondaryFire": false,
                "ability1Cooldown%": 150,
                "enableUlt": false
            },
            "tracer": {
                "ability1Cooldown%": 400,
                "enablePrimaryFire": false,
                "enableUlt": false
            },
            "winston": {
                "enableAbility2": false,
                "enablePrimaryFire": false,
                "enableUlt": false
            },
            "hammond": {
                "enableSecondaryFire": false,
                "enableInfiniteUlt": true,
                "ultKb%": 200,
                "enableAbility3": false,
                "enablePrimaryFire": false,
                "projectileGravity%": 150,
                "projectileSpeed%": 150,
                "enableAbility1": false,
                "enableSpawningWithUlt": true,
                "combatUltGen%": 0,
                "passiveUltGen%": 500,
                "ultGen%": 100
            },
            "enabledHeroes": [
                "brigitte",
                "hanzo",
                "moira",
                "symmetra",
                "tracer",
                "winston",
                "hammond"
            ],
            "general": {
                "enableMelee": false
            }
        },
    }
}