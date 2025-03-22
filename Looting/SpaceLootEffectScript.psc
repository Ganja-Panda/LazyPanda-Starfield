;======================================================================
; Script Name   : LZP:Looting:SpaceLootEffectScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Controls looting logic for floating space objects
; Description   : Handles continuous looting in space environments. Tied to
;                 player ship presence and loot toggle states. Timer-driven
;                 activation of nearby lootable space objects.
; Dependencies  : LazyPanda.esm, LoggerScript, ship aliases
; Usage         : Automatically triggered by object reference OnLoad event
;======================================================================

ScriptName LZP:Looting:SpaceLootEffectScript Extends ObjectReference

;======================================================================
; PROPERTIES
;======================================================================

;-- Effect-Specific Mandatory Properties --
;-- EffectSpecific_Mandatory
; Required perk and toggle globals for space looting logic.
Group EffectSpecific_Mandatory
    Perk Property ActivePerk Auto Const mandatory              ; Perk required for activating the loot effect
    GlobalVariable Property LPEnableCont_Space Auto Const mandatory ; Enable continuous space looting
    GlobalVariable Property LPSystemUtil_ToggleLooting Auto Const mandatory ; Toggle looting system
EndGroup

;-- Destination Locations --
;-- DestinationLocations
; Reference aliases for target ship destinations.
Group DestinationLocations
    ReferenceAlias Property PlayerHomeShip Auto Const           ; Alias for the player's home ship
EndGroup

;-- No Fill Settings --
;-- NoFill
; Internal properties used for tracking timer-driven events.
Group NoFill
    Int Property lootTimerID = 1 Auto                           ; Timer identifier for looting
    Float Property lootTimerDelay = 0.5 Auto                    ; Delay between loot cycles
EndGroup

;-- Logger Property --
;-- Logger
; Logger reference for debug output.
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const            ; Declared logger using the new logging system
EndGroup

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnLoad Event Handler --
; Triggered when the object loads into the game world.
; Used to initialize the logging system and auto-start looting.
Event OnLoad()
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:SpaceLootEffectScript: OnLoad triggered")
    EndIf
    StartTimer(lootTimerDelay, lootTimerID)
EndEvent

;-- OnTimer Event Handler --
Event OnTimer(Int aiTimerID)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:SpaceLootEffectScript: OnTimer triggered with TimerID: " + aiTimerID as String)
    EndIf
    If aiTimerID == lootTimerID
        ExecuteLooting()
    EndIf
EndEvent

;======================================================================
; MAIN FUNCTIONS
;======================================================================

;-- ExecuteLooting Function --
Function ExecuteLooting()
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:SpaceLootEffectScript: ExecuteLooting called")
    EndIf
    StartTimer(lootTimerDelay, lootTimerID)
    
    ; Retrieve game settings and properties
    Float fSearchRadius = Game.GetGameSettingFloat("fMaxShipTransferDistance")
    Bool bToggleLooting = LPSystemUtil_ToggleLooting.GetValue() == 1.0
    Bool bEnableContSpace = LPEnableCont_Space.GetValue() == 1.0
    Bool bHasPerk = Game.GetPlayer().HasPerk(ActivePerk)
    
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:SpaceLootEffectScript: fSearchRadius: " + fSearchRadius as String)
    EndIf
    
    ; Check if looting conditions are met
    If fSearchRadius > 0.0 && bToggleLooting && bEnableContSpace && bHasPerk
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:SpaceLootEffectScript: Looting enabled and within search radius")
        EndIf
        ObjectReference homeShipRef = PlayerHomeShip.GetRef()
        If homeShipRef != None
            RemoveAllItems(homeShipRef, False, False)
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Looting:SpaceLootEffectScript: Items removed and transferred to PlayerHomeShip")
            EndIf
        EndIf
    EndIf
EndFunction
