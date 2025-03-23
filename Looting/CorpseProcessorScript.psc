;======================================================================
; Script Name   : LZP:Looting:CorpseProcessorScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Handles post-death actor validation, looting, and corpse cleanup.
; Description   : Triggered by Kill Actor Event. This script processes a corpse
;                 based on Lazy Panda global settings and filters. Supports 
;                 duplicate protection using keyword tagging and destination-based
;                 inventory sorting via global FormLists.
; Dependencies  : LazyPanda.esm
; Usage         : Called by LP_DeathMonitorQuest fragment after Kill Actor event.
;======================================================================

Scriptname LZP:Looting:CorpseProcessorScript extends Quest

;======================================================================
; PROPERTIES
;======================================================================

;-- Required Loot System Dependencies
Group EffectSpecific_Mandatory
    Perk Property ActivePerk Auto Const mandatory                   ; Required for loot eligibility (perk-based logic)
    FormList Property ActiveLootList Auto Const mandatory           ; Defines loot categories to scan from container
EndGroup

;-- Loot Toggle Flags
Group EffectSpecific_LootMethod
    Bool Property bLootDeadActor = False Auto                       ; Enables looting logic on actor death
EndGroup

;-- Reserved Keyword Flags
Group EffectSpecific_FormType
    Bool Property bIsKeyword = False Auto                           ; Reserved for future use      
    Bool Property bIsMultipleKeyword = False Auto                   ; Reserved for future use
EndGroup

;-- Global Settings (Autofilled)
Group Settings_Autofill
    GlobalVariable Property LPSetting_Radius Auto Const             ; Loot radius (future expansion)
    GlobalVariable Property LPSetting_RemoveCorpses Auto Const      ; Toggle corpse disabling
    GlobalVariable Property LPSetting_SendTo Auto Const             ; Target ref to send loot to
    GlobalVariable Property LPSetting_ContTakeAll Auto Const        ; Global flag to take all from containers
    GlobalVariable Property LPSetting_AllowLootingShip Auto Const   ; Ship loot toggle (not used here)
EndGroup

;-- Filter Logic Lists
Group List_Autofill
    FormList Property LPSystem_Looting_Globals Auto Const           ; List of global flags for each filter list
    FormList Property LPSystem_Looting_Lists Auto Const             ; List of FormLists to match/filter items
EndGroup

;-- Misc Corpse Data
Group Misc
    Armor Property LP_Skin_Naked_NOTPLAYABLE Auto Const mandatory   ; Naked armor filter for unequip logic
    Race Property HumanRace Auto Const mandatory                    ; Fallback race validation for humanoid actors
EndGroup

;-- Destination References
Group DestinationLocations
    ObjectReference Property PlayerRef Auto Const                   ; Player inventory
    ObjectReference Property LodgeSafeRef Auto Const                ; Lodge safe (default stash)
    ObjectReference Property LPDummyHoldingRef Auto Const           ; Dummy holding container (blackhole)
    ReferenceAlias Property PlayerHomeShip Auto Const mandatory     ; Player's current home ship alias
EndGroup

;-- Runtime Flags
Group NoFill
    Bool Property bTakeAll = False Auto                             ; Local override for take all (future use)
EndGroup

;-- Keyword Dependencies
Keyword Property LPKeyword_LootedCorpse Auto Const                  ; Keyword to prevent double-processing
LZP:Debug:LoggerScript Property Logger Auto Const                   ; Debug logging utility

;======================================================================
; FUNCTION: ProcessCorpse
; Called when an actor is killed and passed into the DeathMonitorQuest.
; Validates the corpse, tags it, optionally loots it, and removes it.
;
; @param theCorpse  - The ObjectReference of the dead actor (victim)
; @param killerRef  - Unused, placeholder for future killer analysis
;======================================================================
Function ProcessCorpse(ObjectReference theCorpse, ObjectReference killerRef)
    if Logger && Logger.IsEnabled()
        Logger.Log("ProcessCorpse() called", 1)
    endif

    Actor corpse = theCorpse as Actor

    ;-- Verify actor reference is valid and currently dead
    if corpse == None
        if Logger && Logger.IsEnabled()
            Logger.LogError("Corpse reference is None. Skipping processing.")
        endif
        return
    elseif !corpse.IsDead()
        if Logger && Logger.IsEnabled()
            Logger.LogWarn("Corpse reference is not dead. Skipping processing.")
        endif
        return
    endif

    ;-- Skip if this corpse has already been processed
    if corpse.HasKeyword(LPKeyword_LootedCorpse)
        if Logger && Logger.IsEnabled()
            Logger.LogWarn("Corpse already marked as looted. Skipping.")
        endif
        return
    endif

    ;-- Mark this corpse to prevent double-processing
    corpse.AddKeyword(LPKeyword_LootedCorpse)
    if Logger && Logger.IsEnabled()
        Logger.Log("Corpse keyword LPKeyword_LootedCorpse applied.", 1)
    endif

    ;-- Only perform loot logic if enabled
    if bLootDeadActor
        ProcessFilteredContainerItems(corpse, PlayerRef)
    endif

    ;-- Optionally remove (disable) the corpse after looting
    if LPSetting_RemoveCorpses.GetValue() == 1.0
        corpse.DisableNoWait(True)
        if Logger && Logger.IsEnabled()
            Logger.Log("Corpse disabled (removed from world).", 1)
        endif
    endif
EndFunction

;======================================================================
; FUNCTION: ProcessFilteredContainerItems
; Filters the container inventory using paired FormLists and Globals.
; Each global determines whether the matching filter should be applied.
;
; @param akContainer - The ObjectReference container to process
; @param akLooter    - The reference receiving the looted items
;======================================================================
Function ProcessFilteredContainerItems(ObjectReference akContainer, ObjectReference akLooter)
    if akContainer == None
        if Logger && Logger.IsEnabled()
            Logger.LogError("Container reference is None. Aborting loot processing.")
        endif
        return
    endif

    if Logger && Logger.IsEnabled()
        Logger.Log("ProcessFilteredContainerItems() called", 1)
    endif

    int listSize = LPSystem_Looting_Lists.GetSize()
    if listSize <= 0
        if Logger && Logger.IsEnabled()
            Logger.LogWarn("No filter lists defined. Skipping container processing.")
        endif
        return
    endif

    ObjectReference destination = GetDestRef()
    int index = 0

    ;-- Loop through filter list pairs and remove matching items
    while index < listSize
        FormList currentList = LPSystem_Looting_Lists.GetAt(index) as FormList
        GlobalVariable currentGlobal = LPSystem_Looting_Globals.GetAt(index) as GlobalVariable

        if currentList != None && currentGlobal != None
            if currentGlobal.GetValue() == 1.0
                if Logger && Logger.IsEnabled()
                    Logger.Log("Removing items using filter list at index " + index as String, 1)
                endif
            akContainer.RemoveItem(currentList as Form, -1, True, destination)
        endif

                else
            if Logger && Logger.IsEnabled()
                Logger.LogWarn("Skipping index " + index as String + ": invalid list or global.")
            endif
        endif
        index += 1
    endwhile
EndFunction

;======================================================================
; FUNCTION: GetDestRef
; Determines where filtered items should be sent after looting.
; Based on the value of LPSetting_SendTo:
;   1 = Player, 2 = Lodge Safe, 3 = Dummy Holding Container
;
; @return ObjectReference - The destination container or None if invalid
;======================================================================
ObjectReference Function GetDestRef()
    int destination = LPSetting_SendTo.GetValue() as Int

    if destination == 1
        return PlayerRef
    elseif destination == 2
        return LodgeSafeRef
    elseif destination == 3
        return LPDummyHoldingRef
    endif

    return None
EndFunction
