;======================================================================
; Script: LZP:Looting:CorpseProcessorScript
; Description: This Quest Script is designed to handle the processing of corpses when called from LZP:System:ActorAliasDeathListnerScript.
; It provides functionality for processing corpses, including unequipping
; items, looting, and removing the corpse from the world. Debug logging is integrated to
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
Group EffectSpecific_LootMethod
    Bool Property bLootDeadActor = False Auto                    ; Should the effect loot dead actors?
EndGroup

;-- Form Type Configuration --
Group EffectSpecific_FormType
    Bool Property bIsKeyword = False Auto                         ; Use a single keyword to locate loot?
    Bool Property bIsMultipleKeyword = False Auto                 ; Use multiple keywords to locate loot?
EndGroup

;-- Settings Autofill --
Group Settings_Autofill
    GlobalVariable Property LPSetting_Radius Auto Const           ; Global setting for loot search radius
    GlobalVariable Property LPSetting_RemoveCorpses Auto Const      ; Remove corpses after looting?
    GlobalVariable Property LPSetting_SendTo Auto Const             ; Destination setting for looted items
    GlobalVariable Property LPSetting_ContTakeAll Auto Const        ; Loot all items from a container?
    GlobalVariable Property LPSetting_AllowLootingShip Auto Const    ; Allow looting from ships?
EndGroup

;-- List Autofill --
Group List_Autofill
    FormList Property LPSystem_Looting_Globals Auto Const          ; Global looting configuration list
    FormList Property LPSystem_Looting_Lists Auto Const             ; Loot filtering lists for containers
EndGroup

;-- Miscellaneous Properties --
Group Misc
    Armor Property LP_Skin_Naked_NOTPLAYABLE Auto Const mandatory   ; Armor for unequipping corpses (non-playable)
    Race Property HumanRace Auto Const mandatory                    ; Standard human race
EndGroup

;-- Destination Locations --
Group DestinationLocations
    ObjectReference Property PlayerRef Auto Const                   ; Reference to the player
    ObjectReference Property LodgeSafeRef Auto Const                  ; Reference to the lodge safe container
    ObjectReference Property LPDummyHoldingRef Auto Const             ; Reference to a dummy holding container for loot
    ReferenceAlias Property PlayerHomeShip Auto Const mandatory       ; Alias for the player's home ship
EndGroup

;-- No Fill Settings --
Group NoFill
    Bool Property bTakeAll = False Auto                              ; Local flag to loot all items from a container
EndGroup

;-- Logger Property --
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const                ; Declared logger using the new logging system
EndGroup

;======================================================================
; MAIN FUNCTIONS
;======================================================================

;-- ProcessCorpse Function --
Function ProcessCorpse(ObjectReference akVictim, ObjectReference akKiller)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:CorpseProcessorScript: ProcessCorpse called with corpse: " + akVictim as String)
    EndIf

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
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:CorpseProcessorScript: Corpse is not an Actor; skipping actor-specific processing.")
        EndIf
    EndIf

    Utility.Wait(0.1)

    ; Log the killer if one is detected.
    If akKiller != None
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:CorpseProcessorScript: Killer: " + akKiller as String)
        EndIf
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:CorpseProcessorScript: No killer detected.")
        EndIf
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
Function RemoveCorpse(ObjectReference theCorpse)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:CorpseProcessorScript: RemoveCorpse called with corpse: " + theCorpse as String)
    EndIf

    If LPSetting_RemoveCorpses.GetValue() as Bool
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:CorpseProcessorScript: Corpse removal enabled, disabling corpse")
        EndIf
        theCorpse.DisableNoWait(True)
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:CorpseProcessorScript: Corpse removal disabled, leaving corpse in world")
        EndIf
    EndIf
EndFunction

;-- ProcessFilteredContainerItems Function --
Function ProcessFilteredContainerItems(ObjectReference akContainer, ObjectReference akLooter)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:CorpseProcessorScript: ProcessFilteredContainerItems called")
    EndIf
    
    If akContainer == None
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:CorpseProcessorScript: No valid container found!")
        EndIf
        Return
    EndIf

    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:CorpseProcessorScript: Processing filtered items in: " + akContainer as String)
    EndIf

    Int listSize = LPSystem_Looting_Lists.GetSize()
    Int index = 0

    While index < listSize
        FormList currentList = LPSystem_Looting_Lists.GetAt(index) as FormList
        GlobalVariable currentGlobal = LPSystem_Looting_Globals.GetAt(index) as GlobalVariable

        If currentList != None && currentGlobal != None
            Float globalValue = currentGlobal.GetValue()
            If globalValue == 1.0
                If Logger && Logger.IsEnabled()
                    Logger.Log("LZP:Looting:CorpseProcessorScript: Removing items from category: " + currentList as String)
                EndIf
                akContainer.RemoveItem(currentList as Form, -1, True, GetDestRef())
            Else
                If Logger && Logger.IsEnabled()
                    Logger.Log("LZP:Looting:CorpseProcessorScript: Skipping list: " + currentList as String)
                EndIf
            EndIf
        Else
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Looting:CorpseProcessorScript: Skipping index " + index as String + " due to missing data.")
            EndIf
        EndIf

        index += 1
    EndWhile
EndFunction

;-- GetDestRef Function --
ObjectReference Function GetDestRef()
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:CorpseProcessorScript: GetDestRef called")
    EndIf

    Int destination = LPSetting_SendTo.GetValue() as Int
    If destination == 1
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:CorpseProcessorScript: Destination: Player")
        EndIf
        Return PlayerRef
    ElseIf destination == 2
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:CorpseProcessorScript: Destination: Lodge Safe")
        EndIf
        Return LodgeSafeRef
    ElseIf destination == 3
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:CorpseProcessorScript: Destination: Dummy Holding")
        EndIf
        Return LPDummyHoldingRef
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:CorpseProcessorScript: Destination: Unknown")
        EndIf
        Return None
    EndIf
EndFunction