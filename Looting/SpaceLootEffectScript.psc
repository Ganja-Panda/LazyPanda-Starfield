ScriptName LZP:Looting:SpaceLootEffectScript Extends ObjectReference

;======================================================================
; PROPERTY GROUPS
;======================================================================

;-- Effect-Specific Mandatory Properties --
Group EffectSpecific_Mandatory
    Perk Property ActivePerk Auto Const mandatory              ; Perk required for activating the loot effect
    GlobalVariable Property LPEnableCont_Space Auto Const mandatory ; Enable continuous space looting
    GlobalVariable Property LPSystemUtil_ToggleLooting Auto Const mandatory ; Toggle looting system
EndGroup

;-- Destination Locations --
Group DestinationLocations
    ReferenceAlias Property PlayerHomeShip Auto Const           ; Alias for the player's home ship
EndGroup

;-- No Fill Settings --
Group NoFill
    Int Property lootTimerID = 1 Auto                           ; Timer identifier for looting
    Float Property lootTimerDelay = 0.5 Auto                    ; Delay between loot cycles
EndGroup

;-- Logger Property --
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const            ; Declared logger using the new logging system
EndGroup

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnLoad Event Handler --
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
