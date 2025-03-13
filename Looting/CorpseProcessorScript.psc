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
Function ProcessCorpse(ObjectReference akVictim, ObjectReference akKiller)
    Debug.Notification("[Lazy Panda] ProcessCorpse called with corpse: " + akVictim)

    Bool takeAll = LPSetting_ContTakeAll.GetValue() as Bool
    bTakeAll = takeAll
    
    ; Check if the corpse is an actor and unequip items if it is.
    Actor corpseActor = akVictim as Actor
    If corpseActor != None
        Race corpseRace = corpseActor.GetRace()
        If corpseRace == HumanRace
            corpseActor.UnequipAll()
            corpseActor.EquipItem(LP_Skin_Naked_NOTPLAYABLE as Form, False, False)
        EndIf
    Else
        Debug.Notification("[Lazy Panda] Corpse is not an Actor; skipping actor-specific processing.")
    EndIf

    Utility.Wait(0.1)

    ; Log the killer if one is detected.
    If akKiller != None
        Debug.Notification("[Lazy Panda] Killer: " + akKiller)
    Else
        Debug.Notification("[Lazy Panda] No killer detected.")
    EndIf

    ; Loot the corpse if the setting is enabled.
    If takeAll
        akVictim.RemoveAllItems(GetDestRef(), False, False)
    Else
        ProcessFilteredContainerItems(akVictim, akKiller)
    EndIf

    RemoveCorpse(akVictim)
EndFunction

;-- RemoveCorpse Function --
; Removes the corpse from the world if the setting is enabled.
Function RemoveCorpse(ObjectReference theCorpse)
    Debug.Notification("[Lazy Panda] RemoveCorpse called with corpse: " + theCorpse as String)
    If LPSetting_RemoveCorpses.GetValue() as Bool
        theCorpse.DisableNoWait(True)
    EndIf
EndFunction

;-- ProcessFilteredContainerItems Function --
; Processes container items using filtering lists to remove specific items.
Function ProcessFilteredContainerItems(ObjectReference akContainer, ObjectReference akLooter)
    If akContainer == None
        Debug.Notification("[Lazy Panda] ProcessFilteredContainerItems: No valid container found!")
        Return
    EndIf

    Debug.Notification("[Lazy Panda] Processing filtered items in: " + akContainer)

    Int listSize = LPSystem_Looting_Lists.GetSize()
    Int index = 0

    While index < listSize
        FormList currentList = LPSystem_Looting_Lists.GetAt(index) as FormList
        GlobalVariable currentGlobal = LPSystem_Looting_Globals.GetAt(index) as GlobalVariable

        If currentList != None && currentGlobal != None
            Float globalValue = currentGlobal.GetValue()

            If globalValue == 1.0
                Debug.Notification("[Lazy Panda] Removing items from category: " + currentList)
                akContainer.RemoveItem(currentList as Form, -1, True, GetDestRef())
            Else
                Debug.Notification("[Lazy Panda] Skipping list: " + currentList)
            EndIf
        Else
            Debug.Notification("[Lazy Panda] Skipping index " + index + " due to missing data.")
        EndIf

        index += 1
    EndWhile
EndFunction

;-- GetDestRef Function --
; Determines the destination reference for looted items based on the global "Send To" setting.
ObjectReference Function GetDestRef()
    Debug.Notification("[Lazy Panda] GetDestRef called")
    Int destination = LPSetting_SendTo.GetValue() as Int
    If destination == 1
        Debug.Notification("[Lazy Panda] Destination: Player")
        Return PlayerRef
    ElseIf destination == 2
        Debug.Notification("[Lazy Panda] Destination: Lodge Safe")
        Return LodgeSafeRef
    ElseIf destination == 3
        Debug.Notification("[Lazy Panda] Destination: Dummy Holding")
        Return LPDummyHoldingRef
    Else
        Debug.Notification("[Lazy Panda] Destination: Unknown")
        Return None
    EndIf
EndFunction
