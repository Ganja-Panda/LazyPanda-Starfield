ScriptName LZP:Looting:SpaceLootEffectScript Extends ObjectReference

;======================================================================
; PROPERTY GROUPS
;======================================================================

;-- Effect-Specific Mandatory Properties --
; Contains the essential properties needed for the loot effect.
Group EffectSpecific_Mandatory
    Perk Property ActivePerk Auto Const mandatory              ; Perk required for activating the loot effect
    GlobalVariable Property LPEnableCont_Space Auto Const mandatory ; Enable continuous space looting
    GlobalVariable Property LPSystemUtil_ToggleLooting Auto Const mandatory ; Toggle looting system
    GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory ; Global debug flag for logging
EndGroup

;-- Destination Locations --
; References for where looted items should be sent.
Group DestinationLocations
    ReferenceAlias Property PlayerHomeShip Auto Const           ; Alias for the player's home ship
EndGroup

;-- No Fill Settings --
; Timer and local flags for looting behavior.
Group NoFill
    Int Property lootTimerID = 1 Auto                           ; Timer identifier for looting
    Float Property lootTimerDelay = 0.5 Auto                    ; Delay between loot cycles
EndGroup

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnLoad Event Handler --
; Called when the object is loaded. Begins the loot timer.
Event OnLoad()
    LZP:SystemScript.Log("OnLoad triggered", 3)
    StartTimer(lootTimerDelay, lootTimerID)
EndEvent

;-- OnTimer Event Handler --
; Called when the loot timer expires. Checks if the timer ID matches before executing looting.
Event OnTimer(Int aiTimerID)
    LZP:SystemScript.Log("OnTimer triggered with TimerID: " + aiTimerID as String, 3)
    If aiTimerID == lootTimerID
        ExecuteLooting()
    EndIf
EndEvent

;======================================================================
; MAIN FUNCTIONS
;======================================================================

;-- ExecuteLooting Function --
; Main function that initiates the looting process and restarts the loot timer.
Function ExecuteLooting()
    LZP:SystemScript.Log("ExecuteLooting called", 3)
    StartTimer(lootTimerDelay, lootTimerID)
    
    ; Retrieve game settings and properties
    Float fSearchRadius = Game.GetGameSettingFloat("fMaxShipTransferDistance")
    Bool bToggleLooting = LPSystemUtil_ToggleLooting.GetValue() == 1.0
    Bool bEnableContSpace = LPEnableCont_Space.GetValue() == 1.0
    Bool bHasPerk = Game.GetPlayer().HasPerk(ActivePerk)
    
    LZP:SystemScript.Log("fSearchRadius: " + fSearchRadius as String, 3)
    
    ; Check if looting conditions are met
    If fSearchRadius > 0.0 && bToggleLooting && bEnableContSpace && bHasPerk
        LZP:SystemScript.Log("Looting enabled and within search radius", 3)
        ObjectReference homeShipRef = PlayerHomeShip.GetRef()
        If homeShipRef != None
            RemoveAllItems(homeShipRef, False, False)
            LZP:SystemScript.Log("Items removed and transferred to PlayerHomeShip", 3)
        Else
            LZP:SystemScript.Log("PlayerHomeShip reference is None", 3)
            ; Additional error handling or fallback behavior can be added here
        EndIf
    Else
        LZP:SystemScript.Log("Looting not enabled, you don't have the proper perk or out of search radius", 3)
        ; Additional error handling or fallback behavior can be added here
    EndIf
EndFunction