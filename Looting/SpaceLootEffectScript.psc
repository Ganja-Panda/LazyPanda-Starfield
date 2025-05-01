;======================================================================
; Script Name   : LZP:Looting:SpaceLootEffectScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Controls looting logic for floating space objects
; Description   : Handles continuous looting of space debris or asteroids.
;                 Timer-based scanning of loot state, perk validation,
;                 and inventory transfer to PlayerHomeShip.
; Dependencies  : LazyPanda.esm, LoggerScript, PlayerHomeShip alias
; Usage         : Attached to space loot references (asteroids, debris).
;======================================================================

ScriptName LZP:Looting:SpaceLootEffectScript Extends ObjectReference

;======================================================================
; PROPERTIES
;======================================================================

;-- EffectSpecific_Mandatory
; Controls whether looting is active and gated by player perk
Group EffectSpecific_Mandatory
    Perk Property ActivePerk Auto Const mandatory                            ; Required perk to allow looting
    GlobalVariable Property LZP_Toggle_Container_Space Auto Const mandatory  ; Global toggle for continuous space looting
    GlobalVariable Property LZP_System_ToggleLooting Auto Const mandatory    ; Master toggle for all looting systems
EndGroup

;-- DestinationLocations
; Reference alias for player home ship to receive looted items
Group DestinationLocations
    ReferenceAlias Property PlayerHomeShip Auto Const                       ; Ship that receives transferred items
EndGroup

;-- NoFill
; Timer configuration used to repeat the looting cycle
Group NoFill
    Int Property lootTimerID = 1 Auto                                       ; Unique ID for timer-based scanning
    Float Property lootTimerDelay = 0.5 Auto                                ; Time in seconds between looting cycles
EndGroup

;-- Logger
; LoggerScript reference for centralized debug tracing
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const                       ; Lazy Panda logging system instance
EndGroup

;======================================================================
; EVENT: OnLoad
;======================================================================
Event OnLoad()
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("SpaceLootEffectScript: OnLoad triggered", 1, "SpaceLootEffectScript")
    EndIf
    StartTimer(lootTimerDelay, lootTimerID)
EndEvent

;======================================================================
; EVENT: OnTimer
;======================================================================
Event OnTimer(Int aiTimerID)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("SpaceLootEffectScript: OnTimer triggered. ID = " + aiTimerID as String, 1, "SpaceLootEffectScript")
    EndIf

    If aiTimerID == lootTimerID
        ExecuteLooting()
    EndIf
EndEvent

;======================================================================
; FUNCTION: ExecuteLooting
;======================================================================
Function ExecuteLooting()
    StartTimer(lootTimerDelay, lootTimerID)

    Float fSearchRadius = Game.GetGameSettingFloat("fMaxShipTransferDistance")
    Bool bToggleLooting = LZP_System_ToggleLooting.GetValue() == 1.0
    Bool bEnableContSpace = LZP_Toggle_Container_Space.GetValue() == 1.0
    Bool bHasPerk = Game.GetPlayer().HasPerk(ActivePerk)

    If Logger && Logger.IsEnabled()
        Logger.LogAdv("SpaceLootEffectScript: ExecuteLooting() fired.", 1, "SpaceLootEffectScript")
        Logger.LogAdv("Search radius: " + fSearchRadius as String, 1, "SpaceLootEffectScript")
    EndIf

    If !bToggleLooting
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("Looting system is disabled. Skipping.", 2, "SpaceLootEffectScript")
        EndIf
        Return
    EndIf

    If !bEnableContSpace
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("Space looting is disabled by global toggle.", 2, "SpaceLootEffectScript")
        EndIf
        Return
    EndIf

    If !bHasPerk
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("Player does not have required perk for space looting.", 2, "SpaceLootEffectScript")
        EndIf
        Return
    EndIf

    ObjectReference homeShipRef = PlayerHomeShip.GetRef()
    If homeShipRef == None
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("PlayerHomeShip alias is None. Cannot transfer loot.", 3, "SpaceLootEffectScript")
        EndIf
        Return
    EndIf

    RemoveAllItems(homeShipRef, False, False)

    If Logger && Logger.IsEnabled()
        Logger.LogAdv("Items transferred to PlayerHomeShip - all items.", 1, "SpaceLootEffectScript")
    EndIf
EndFunction
