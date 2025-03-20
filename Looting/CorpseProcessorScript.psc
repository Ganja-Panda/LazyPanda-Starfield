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
; MAIN FUNCTIONS
;======================================================================

;-- ProcessCorpse Function --
; Handles processing of a corpse object including unequipping, looting, and removal.
Function ProcessCorpse(ObjectReference akVictim, ObjectReference akKiller)
    LZP:SystemScript.Log("ProcessCorpse called with corpse: " + akVictim as String, 3)

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
        LZP:SystemScript.Log("Corpse is not an Actor; skipping actor-specific processing.", 3)
    EndIf

    Utility.Wait(0.1)

    ; Log the killer if one is detected.
    If akKiller != None
        LZP:SystemScript.Log("Killer: " + akKiller as String, 3)
    Else
       LZP:SystemScript.Log("No killer detected.", 3)
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
    LZP:SystemScript.Log("RemoveCorpse called with corpse: " + theCorpse as String, 3)
    If LPSetting_RemoveCorpses.GetValue() as Bool
        LZP:SystemScript.Log("Corpse removal enabled, disabling corpse", 3)
        theCorpse.DisableNoWait(True)
    Else
        LZP:SystemScript.Log("Corpse removal disabled, leaving corpse in world", 3)
    EndIf
EndFunction

;-- ProcessFilteredContainerItems Function --
; Processes container items using filtering lists to remove specific items.
Function ProcessFilteredContainerItems(ObjectReference akContainer, ObjectReference akLooter)
    If akContainer == None
        LZP:SystemScript.Log("ProcessFilteredContainerItems: No valid container found!", 3)
        Return
    EndIf

    LZP:SystemScript.Log("Processing filtered items in: " + akContainer as String, 3)

    Int listSize = LPSystem_Looting_Lists.GetSize()
    Int index = 0

    While index < listSize
        FormList currentList = LPSystem_Looting_Lists.GetAt(index) as FormList
        GlobalVariable currentGlobal = LPSystem_Looting_Globals.GetAt(index) as GlobalVariable

        If currentList != None && currentGlobal != None
            Float globalValue = currentGlobal.GetValue()

            If globalValue == 1.0
                LZP:SystemScript.Log("Removing items from category: " + currentList as String, 3)
                akContainer.RemoveItem(currentList as Form, -1, True, GetDestRef())
            Else
                LZP:SystemScript.Log("Skipping list: " + currentList as String, 3)
            EndIf
        Else
            LZP:SystemScript.Log("Skipping index " + index as String + " due to missing data.", 3)
        EndIf

        index += 1
    EndWhile
EndFunction

;-- GetDestRef Function --
; Determines the destination reference for looted items based on the global "Send To" setting.
ObjectReference Function GetDestRef()
    LZP:SystemScript.Log("GetDestRef called", 3)
    Int destination = LPSetting_SendTo.GetValue() as Int
    If destination == 1
        LZP:SystemScript.Log("Destination: Player", 3)
        Return PlayerRef
    ElseIf destination == 2
        LZP:SystemScript.Log("Destination: Lodge Safe", 3)
        Return LodgeSafeRef
    ElseIf destination == 3
        LZP:SystemScript.Log("Destination: Dummy Holding", 3)
        Return LPDummyHoldingRef
    Else
        LZP:SystemScript.Log("Destination: Unknown", 3)
        Return None
    EndIf
EndFunction

