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
    GlobalVariable Property LZP_Setting_Radius Auto Const             ; Loot radius (future expansion)
    GlobalVariable Property LZP_Setting_RemoveCorpses Auto Const      ; Toggle corpse disabling
    GlobalVariable Property LZP_Setting_SendTo Auto Const             ; Target ref to send loot to
    GlobalVariable Property LZP_Setting_TakeAll_Containers Auto Const ; Global flag to take all from containers
    GlobalVariable Property LZP_Setting_AllowLootingShip Auto Const   ; Ship loot toggle (not used here)
EndGroup

;-- Filter Logic Lists
Group List_Autofill
    FormList Property LZP_System_Looting_Globals Auto Const           ; List of global flags for each filter list
    FormList Property LZP_System_Looting_Lists Auto Const             ; List of FormLists to match/filter items
EndGroup

;-- Misc Corpse Data
Group Misc
    Armor Property LZP_Armor_Naked_NOTPLAYABLE Auto Const mandatory   ; Naked armor filter for unequip logic
    Race Property HumanRace Auto Const mandatory                      ; Fallback race validation for humanoid actors
EndGroup

;-- Destination References
Group DestinationLocations
    ObjectReference Property PlayerRef Auto Const                   ; Player inventory
    ObjectReference Property LodgeSafeRef Auto Const                ; Lodge safe (default stash)
    ObjectReference Property LZP_Cont_StorageRef Auto Const         ; Dummy holding container (blackhole)
    ReferenceAlias Property PlayerHomeShip Auto Const mandatory     ; Player's current home ship alias
EndGroup

;-- Runtime Flags
Group NoFill
    Bool Property bTakeAll = False Auto                             ; Local override for take all (future use)
EndGroup

;-- Keyword Dependencies
Keyword Property LZP_KYWD_LootedCorpse Auto Const                   ; Keyword to prevent double-processing
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
        Logger.LogAdv("ProcessCorpse() called", 1, "CorpseProcessorScript")
    endif

    Actor corpse = theCorpse as Actor

    ;-- Verify actor reference is valid and currently dead
    if corpse == None
        if Logger && Logger.IsEnabled()
            Logger.LogAdv("Corpse reference is None. Skipping processing.", 3, "CorpseProcessorScript")
        endif
        return
    elseif !corpse.IsDead()
        if Logger && Logger.IsEnabled()
            Logger.LogAdv("Corpse reference is not dead. Skipping processing.", 2, "CorpseProcessorScript")
        endif
        return
    endif

    ;-- Skip if this corpse has already been processed
    if corpse.HasKeyword(LZP_KYWD_LootedCorpse)
        if Logger && Logger.IsEnabled()
            Logger.LogAdv("Corpse already marked as looted. Skipping.", 2, "CorpseProcessorScript")
        endif
        return
    endif

    ;-- Mark this corpse to prevent double-processing
    corpse.AddKeyword(LZP_KYWD_LootedCorpse)
    if Logger && Logger.IsEnabled()
        Logger.LogAdv("Corpse keyword LZP_KYWD_LootedCorpse applied.", 1, "CorpseProcessorScript")
    endif

    ;-- Only perform loot logic if enabled
    if bLootDeadActor
        ProcessFilteredContainerItems(corpse, PlayerRef)
    endif

    ;-- Optionally remove (disable) the corpse after looting
    if LZP_Setting_RemoveCorpses.GetValue() == 1.0
        corpse.DisableNoWait(True)
        if Logger && Logger.IsEnabled()
            Logger.LogAdv("Corpse disabled (removed from world).", 1, "CorpseProcessorScript")
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
            Logger.LogAdv("Container reference is None. Aborting loot processing.", 3, "CorpseProcessorScript")
        endif
        return
    endif

    if Logger && Logger.IsEnabled()
        Logger.LogAdv("ProcessFilteredContainerItems() called", 1, "CorpseProcessorScript")
    endif

    int listSize = LZP_System_Looting_Lists.GetSize()
    if listSize <= 0
        if Logger && Logger.IsEnabled()
            Logger.LogAdv("No filter lists defined. Skipping container processing.", 2, "CorpseProcessorScript")
        endif
        return
    endif

    ObjectReference destination = GetDestRef()
    int index = 0

    ;-- Loop through filter list pairs and remove matching items
    while index < listSize
        FormList currentList = LZP_System_Looting_Lists.GetAt(index) as FormList
        GlobalVariable currentGlobal = LZP_System_Looting_Globals.GetAt(index) as GlobalVariable

        if currentList != None && currentGlobal != None
            if currentGlobal.GetValue() == 1.0
                if Logger && Logger.IsEnabled()
                    Logger.LogAdv("Removing items using filter list at index " + index as String, 1, "CorpseProcessorScript")
                endif
                akContainer.RemoveItem(currentList as Form, -1, True, destination)
            endif
        else
            if Logger && Logger.IsEnabled()
                Logger.LogAdv("Skipping index " + index as String + ": invalid list or global.", 2, "CorpseProcessorScript")
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
    int destination = LZP_Setting_SendTo.GetValue() as Int

    if destination == 1
        return PlayerRef
    elseif destination == 2
        return LodgeSafeRef
    elseif destination == 3
        return LZP_Cont_StorageRef
    endif

    return None
EndFunction
