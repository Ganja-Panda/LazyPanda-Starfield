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
    GlobalVariable Property LPSystem_Debug Auto Const mandatory ; Global debug flag for logging
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
; DEBUG LOGGING HELPER FUNCTION
;======================================================================

; Logs a message if the global debug setting is enabled.
Function Log(String logMsg)
    If LPSystem_Debug.GetValue() as Bool
        Debug.Trace(logMsg, 0)
    EndIf
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnLoad Event Handler --
; Called when the object is loaded. Begins the loot timer.
Event OnLoad()
    Log("[Lazy Panda] OnLoad triggered")
    StartTimer(lootTimerDelay, lootTimerID)
EndEvent

;-- OnTimer Event Handler --
; Called when the loot timer expires. Checks if the timer ID matches before executing looting.
Event OnTimer(Int aiTimerID)
    Log("[Lazy Panda] OnTimer triggered with TimerID: " + aiTimerID as String)
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
    Log("[Lazy Panda] ExecuteLooting called")
    StartTimer(lootTimerDelay, lootTimerID)
    
    ; Retrieve game settings and properties
    Float fSearchRadius = Game.GetGameSettingFloat("fMaxShipTransferDistance")
    Bool bToggleLooting = LPSystemUtil_ToggleLooting.GetValue() == 1.0
    Bool bEnableContSpace = LPEnableCont_Space.GetValue() == 1.0
    Bool bHasPerk = Game.GetPlayer().HasPerk(ActivePerk)
    
    Log("[Lazy Panda] fSearchRadius: " + fSearchRadius as String)
    
    ; Check if looting conditions are met
    If fSearchRadius > 0.0 && bToggleLooting && bEnableContSpace && bHasPerk
        Log("[Lazy Panda] Looting enabled and within search radius")
        ObjectReference homeShipRef = PlayerHomeShip.GetRef()
        If homeShipRef != None
            RemoveAllItems(homeShipRef, False, False)
            Log("[Lazy Panda] Items removed and transferred to PlayerHomeShip")
        Else
            Log("[Lazy Panda] PlayerHomeShip reference is None")
            ; Additional error handling or fallback behavior can be added here
        EndIf
    Else
        Log("[Lazy Panda] Looting not enabled, you don't have the proper perk or out of search radius")
        ; Additional error handling or fallback behavior can be added here
    EndIf
EndFunction