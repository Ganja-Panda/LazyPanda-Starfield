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
    Perk Property ActivePerk Auto Const mandatory           ; Required perk to allow looting
    GlobalVariable Property LPEnableCont_Space Auto Const mandatory  ; Global toggle for continuous space looting
    GlobalVariable Property LPSystemUtil_ToggleLooting Auto Const mandatory ; Master toggle for all looting systems
EndGroup

;-- DestinationLocations
; Reference alias for player home ship to receive looted items
Group DestinationLocations
    ReferenceAlias Property PlayerHomeShip Auto Const           ; Ship that receives transferred items
EndGroup

;-- NoFill
; Timer configuration used to repeat the looting cycle
Group NoFill
    Int Property lootTimerID = 1 Auto                           ; Unique ID for timer-based scanning
    Float Property lootTimerDelay = 0.5 Auto                    ; Time in seconds between looting cycles
EndGroup

;-- Logger
; LoggerScript reference for centralized debug tracing
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const           ; Lazy Panda logging system instance
EndGroup

;======================================================================
; EVENT: OnLoad
;======================================================================
Event OnLoad()
    if Logger && Logger.IsEnabled()
        Logger.LogInfo("SpaceLootEffectScript: OnLoad triggered")
    endif
    StartTimer(lootTimerDelay, lootTimerID)
EndEvent

;======================================================================
; EVENT: OnTimer
;======================================================================
Event OnTimer(Int aiTimerID)
    if Logger && Logger.IsEnabled()
        Logger.LogInfo("SpaceLootEffectScript: OnTimer triggered. ID = " + aiTimerID as String)
    endif

    if aiTimerID == lootTimerID
        ExecuteLooting()
    endif
EndEvent

;======================================================================
; FUNCTION: ExecuteLooting
;======================================================================
Function ExecuteLooting()
    StartTimer(lootTimerDelay, lootTimerID)

    Float fSearchRadius = Game.GetGameSettingFloat("fMaxShipTransferDistance")
    Bool bToggleLooting = LPSystemUtil_ToggleLooting.GetValue() == 1.0
    Bool bEnableContSpace = LPEnableCont_Space.GetValue() == 1.0
    Bool bHasPerk = Game.GetPlayer().HasPerk(ActivePerk)

    if Logger && Logger.IsEnabled()
        Logger.LogInfo("SpaceLootEffectScript: ExecuteLooting() fired.")
        Logger.LogInfo("Search radius: " + fSearchRadius as String)
    endif

    if !bToggleLooting
        if Logger && Logger.IsEnabled()
            Logger.LogWarn("Looting system is disabled. Skipping.")
        endif
        return
    endif

    if !bEnableContSpace
        if Logger && Logger.IsEnabled()
            Logger.LogWarn("Space looting is disabled by global toggle.")
        endif
        return
    endif

    if !bHasPerk
        if Logger && Logger.IsEnabled()
            Logger.LogWarn("Player does not have required perk for space looting.")
        endif
        return
    endif

    ObjectReference homeShipRef = PlayerHomeShip.GetRef()
    if homeShipRef == None
        if Logger && Logger.IsEnabled()
            Logger.LogError("PlayerHomeShip alias is None. Cannot transfer loot.")
        endif
        return
    endif

    RemoveAllItems(homeShipRef, False, False)

    if Logger && Logger.IsEnabled()
        Logger.LogInfo("Items transferred to PlayerHomeShip - all items.")
    endif
EndFunction
