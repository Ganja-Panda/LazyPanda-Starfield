;======================================================================
; Script: LZP:Looting:LootEffectScript
; Description: This Quest Script is designed to handle the processing of corpses when called from LZP:System:ActorAliasDeathListnerScript.
; It provides functionality for processing corpses, including unequipping
; items, looting, and ; removing the corpse from the world. Debug logging is integrated to
; assist with troubleshooting.
;======================================================================
Scriptname LZP:Looting:CorpseProcessorScript extends Quest

;======================================================================
; PROPERTY GROUPS
;======================================================================

Group EffectSpecific_Mandatory
    Perk Property ActivePerk Auto Const mandatory              ; Perk required for activating the loot effect
    FormList Property ActiveLootList Auto Const mandatory        ; List of forms representing potential loot targets
EndGroup

;-- Loot Method Configuration --
; Booleans to define the method used for looting.
Group EffectSpecific_LootMethod
    Bool Property bLootDeadActor = False Auto                      ; Should the effect loot dead actors?
EndGroup

;-- Form Type Configuration --
; Booleans to determine whether to use keyword-based searches.
Group EffectSpecific_FormType
    Bool Property bIsKeyword = False Auto                          ; Use a single keyword to locate loot?
    Bool Property bIsMultipleKeyword = False Auto                  ; Use multiple keywords to locate loot?
EndGroup

;-- Settings Autofill --
; Global variables that control looting settings such as search radius,
; stealing permissions, corpse removal, destination, and container behavior.
Group Settings_Autofill
    GlobalVariable Property LPSetting_Radius Auto Const          ; Global setting for loot search radius
    GlobalVariable Property LPSetting_RemoveCorpses Auto Const        ; Remove corpses after looting?
    GlobalVariable Property LPSetting_SendTo Auto Const             ; Destination setting for looted items
    GlobalVariable Property LPSetting_ContTakeAll Auto Const          ; Loot all items from a container?
    GlobalVariable Property LPSetting_AllowLootingShip Auto Const       ; Allow looting from ships?
EndGroup


;-- List Autofill --
; Form lists used for looting system configuration and filtering.
Group List_Autofill
    FormList Property LPSystem_Looting_Globals Auto Const          ; Global looting configuration list
    FormList Property LPSystem_Looting_Lists Auto Const             ; Loot filtering lists for containers
EndGroup

;-- Miscellaneous Properties --
; Additional properties including keywords, races, and debug settings.
Group Misc
    Armor Property LP_Skin_Naked_NOTPLAYABLE Auto Const mandatory       ; Armor for unequipping corpses (non-playable)
    Race Property HumanRace Auto Const mandatory                       ; Standard human race
    GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory         ; Global debug flag for logging
EndGroup

;-- Destination Locations --
; References for where looted items should be sent.
Group DestinationLocations
    ObjectReference Property PlayerRef Auto Const                     ; Reference to the player
    ObjectReference Property LodgeSafeRef Auto Const                    ; Reference to the lodge safe container
    ObjectReference Property LPDummyHoldingRef Auto Const               ; Reference to a dummy holding container for loot
    ReferenceAlias Property PlayerHomeShip Auto Const mandatory           ; Alias for the player's home ship
EndGroup

;-- No Fill Settings --
; Timer and local flags for looting behavior.
Group NoFill
    Bool Property bTakeAll = False Auto                                   ; Local flag to loot all items from a container
EndGroup

;======================================================================
; DEBUG LOGGING HELPER FUNCTION
;======================================================================

; Logs a message if the global debug setting is enabled.
Function Log(String logMsg)
    If LPSystemUtil_Debug.GetValue() as Bool
        Log(logMsg)
    EndIf
EndFunction

;======================================================================
; MAIN FUNCTIONS
;======================================================================

;-- ProcessCorpse Function --
; Handles processing of a corpse object including unequipping, looting, and removal.
Function ProcessCorpse(ObjectReference theCorpse, ObjectReference theLooter)
    Log("[Lazy Panda] ProcessCorpse called with corpse: " + theCorpse as String)
    Bool takeAll = LPSetting_ContTakeAll.GetValue() as Bool
    bTakeAll = takeAll
     
    ; Attempt to cast the corpse to an Actor for actor-specific processing.
    Actor corpseActor = theCorpse as Actor
    If corpseActor != None
        Race corpseRace = corpseActor.GetRace()
        ; Check if the corpse is human and process accordingly.
        If corpseRace == HumanRace
            corpseActor.UnequipAll()
            corpseActor.EquipItem(LP_Skin_Naked_NOTPLAYABLE as Form, False, False)
        EndIf
    Else
        Log("[Lazy Panda] Corpse is not an Actor; skipping actor-specific processing.")
    EndIf

    Utility.Wait(0.1)
    ; Loot the corpse based on the take-all setting.
    If takeAll
        theCorpse.RemoveAllItems(GetDestRef(), False, False)
    Else
        ProcessFilteredContainerItems(theCorpse, theLooter)
    EndIf
    RemoveCorpse(theCorpse)
EndFunction

;-- RemoveCorpse Function --
; Removes the corpse from the world if the setting is enabled.
Function RemoveCorpse(ObjectReference theCorpse)
    Log("[Lazy Panda] RemoveCorpse called with corpse: " + theCorpse as String)
    If LPSetting_RemoveCorpses.GetValue() as Bool
        theCorpse.DisableNoWait(True)
    EndIf
EndFunction

;-- ProcessFilteredContainerItems Function --
; Processes container items using filtering lists to remove specific items.
Function ProcessFilteredContainerItems(ObjectReference theContainer, ObjectReference theLooter)
    Log("[Lazy Panda] ProcessFilteredContainerItems called with container: " + theContainer as String)
    Int listSize = LPSystem_Looting_Lists.GetSize()
    Int index = 0
    While index < listSize
        FormList currentList = LPSystem_Looting_Lists.GetAt(index) as FormList
        GlobalVariable currentGlobal = LPSystem_Looting_Globals.GetAt(index) as GlobalVariable
        Float globalValue = currentGlobal.GetValue()
        ; Remove items matching the current list if the corresponding global value is enabled.
        If globalValue == 1.0
            theContainer.RemoveItem(currentList as Form, -1, True, GetDestRef())
        EndIf
        index += 1
    EndWhile
EndFunction

;-- GetDestRef Function --
; Determines the destination reference for looted items based on the global "Send To" setting.
ObjectReference Function GetDestRef()
    Log("[Lazy Panda] GetDestRef called")
    Int destination = LPSetting_SendTo.GetValue() as Int
    If destination == 1
        Log("[Lazy Panda] Destination: Player")
        Return PlayerRef
    ElseIf destination == 2
        Log("[Lazy Panda] Destination: Lodge Safe")
        Return LodgeSafeRef
    ElseIf destination == 3
        Log("[Lazy Panda] Destination: Dummy Holding")
        Return LPDummyHoldingRef
    Else
        Log("[Lazy Panda] Destination: Unknown")
        Return None
    EndIf
EndFunction
