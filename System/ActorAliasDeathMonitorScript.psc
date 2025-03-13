;======================================================================
; Script: LZP:Looting:LootEffectScript
; Description: This RefCollectionAlias Script is designed to listen for the OnDeath Event
; and call the CorpseProcessorScript to handle the processing
;======================================================================
Scriptname LZP:System:ActorAliasDeathMonitorScript extends RefCollectionAlias

;======================================================================
; PROPERTY GROUPS
;======================================================================
Group Misc
    GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory         ; Global debug flag for logging
    LZP:Looting:CorpseProcessorScript Property CorpseProcessorScript Auto
EndGroup

;======================================================================
; DEBUG LOGGING HELPER FUNCTION
;======================================================================
Function Log(String logMsg)
    If LPSystemUtil_Debug.GetValue() as Bool
        Debug.Trace(logMsg)
    EndIf
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================
Event OnDeath(ObjectReference akSenderRef, ObjectReference akKiller)
    Debug.Notification("[Lazy Panda] OnDeath event fired for alias in collection: " + akSenderRef)
    
    ; Wait briefly to ensure the game finalizes the death state.
    Utility.Wait(0.5)
    
    ; Use the provided akSenderRef as the corpse reference.
    ObjectReference corpseRef = akSenderRef
    If corpseRef
        ; Call the processor script using the player as the looter.
        CorpseProcessorScript.ProcessCorpse(corpseRef, Game.GetPlayer())
    Else
        Debug.Notification("[Lazy Panda] Alias did not return a valid ObjectReference.")
    EndIf
EndEvent

