;======================================================================
; Script Name   : LZP:Looting:CorpseProcessorScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Handles corpse processing and looting after actor death.
; Description   : Supports unequipping, filtered looting, destination sorting,
;                 and corpse removal with integrated logging using LoggerScript.
;                 unequipping, filtered looting, destination sorting, and corpse
;                 removal with integrated logging using LoggerScript. Verbosity:
;                   1 = Info, 2 = Warning, 3 = Error
; Dependencies  : LazyPanda.esm
; Usage         : Automatically invoked on actor death. Must have LoggerScript attached.
;======================================================================
Scriptname LZP:Looting:CorpseProcessorScript extends Quest

;======================================================================
; PROPERTIES
;======================================================================

;-- EffectSpecific_Mandatory
; Required perk and loot list dependencies.
Group EffectSpecific_Mandatory
    Perk Property ActivePerk Auto Const mandatory
    FormList Property ActiveLootList Auto Const mandatory
EndGroup

;-- EffectSpecific_LootMethod
; Toggle settings related to how corpses are looted.
Group EffectSpecific_LootMethod
    Bool Property bLootDeadActor = False Auto
EndGroup

;-- EffectSpecific_FormType
; Flags for handling specific keyword-based logic.
Group EffectSpecific_FormType
    Bool Property bIsKeyword = False Auto
    Bool Property bIsMultipleKeyword = False Auto
EndGroup

;-- Settings_Autofill
; Auto-filled global variables governing loot behavior.
Group Settings_Autofill
    GlobalVariable Property LPSetting_Radius Auto Const
    GlobalVariable Property LPSetting_RemoveCorpses Auto Const
    GlobalVariable Property LPSetting_SendTo Auto Const
    GlobalVariable Property LPSetting_ContTakeAll Auto Const
    GlobalVariable Property LPSetting_AllowLootingShip Auto Const
EndGroup

;-- List_Autofill
; Filter lists and global mappings used for selective looting.
Group List_Autofill
    FormList Property LPSystem_Looting_Globals Auto Const
    FormList Property LPSystem_Looting_Lists Auto Const
EndGroup

;-- Misc
; Core data definitions for actor skin and race.
Group Misc
    Armor Property LP_Skin_Naked_NOTPLAYABLE Auto Const mandatory
    Race Property HumanRace Auto Const mandatory
EndGroup

;-- DestinationLocations
; References for where looted items may be sent.
Group DestinationLocations
    ObjectReference Property PlayerRef Auto Const
    ObjectReference Property LodgeSafeRef Auto Const
    ObjectReference Property LPDummyHoldingRef Auto Const
    ReferenceAlias Property PlayerHomeShip Auto Const mandatory
EndGroup

;-- NoFill
; Local flags not filled by CK.
Group NoFill
    Bool Property bTakeAll = False Auto
EndGroup

;-- Logger
; LoggerScript reference for runtime debugging.
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;======================================================================
; MAIN FUNCTIONS
;======================================================================

;-- ProcessCorpse Function --
; @param akVictim: The actor or container representing the corpse
; @param akKiller: The actor responsible for the death, if any
; Processes looting behavior and corpse cleanup.
Function ProcessCorpse(ObjectReference akVictim, ObjectReference akKiller)
    If Logger && Logger.IsEnabled()
        Logger.Log("ProcessCorpse called with corpse: " + akVictim as String)
    EndIf

    Bool takeAll = LPSetting_ContTakeAll.GetValue() as Bool
    bTakeAll = takeAll

    Actor corpseActor = akVictim as Actor
    If corpseActor != None
        Race corpseRace = corpseActor.GetRace()
        If corpseRace == HumanRace
            corpseActor.UnequipAll()
            corpseActor.EquipItem(LP_Skin_Naked_NOTPLAYABLE as Form, False, False)
        EndIf
    Else
        If Logger && Logger.IsEnabled()
            Logger.LogWarn("Corpse is not an Actor; skipping actor-specific processing.")
        EndIf
    EndIf

    Utility.Wait(0.1)

    If akKiller != None
        If Logger && Logger.IsEnabled()
            Logger.Log("Killer: " + akKiller as String)
        EndIf
    Else
        If Logger && Logger.IsEnabled()
            Logger.LogWarn("No killer detected.")
        EndIf
    EndIf

    If takeAll
        akVictim.RemoveAllItems(GetDestRef(), False, False)
    Else
        ProcessFilteredContainerItems(akVictim, akKiller)
    EndIf

    RemoveCorpse(akVictim)
EndFunction

;-- RemoveCorpse Function --
; @param theCorpse: The ObjectReference representing the corpse
; Handles corpse removal if enabled by settings.
Function RemoveCorpse(ObjectReference theCorpse)
    If Logger && Logger.IsEnabled()
        Logger.Log("RemoveCorpse called with corpse: " + theCorpse as String)
    EndIf

    If LPSetting_RemoveCorpses.GetValue() as Bool
        If Logger && Logger.IsEnabled()
            Logger.Log("Corpse removal enabled, disabling corpse")
        EndIf
        theCorpse.DisableNoWait(True)
    Else
        If Logger && Logger.IsEnabled()
            Logger.LogWarn("Corpse removal disabled, leaving corpse in world")
        EndIf
    EndIf
EndFunction

;-- ProcessFilteredContainerItems Function --
; @param akContainer: The corpse container to filter
; @param akLooter: The entity looting
; Processes items from the corpse based on configured filters.
Function ProcessFilteredContainerItems(ObjectReference akContainer, ObjectReference akLooter)
    If Logger && Logger.IsEnabled()
        Logger.Log("ProcessFilteredContainerItems called")
    EndIf

    If akContainer == None
        If Logger && Logger.IsEnabled()
            Logger.LogError("No valid container found!")
        EndIf
        Return
    EndIf

    If Logger && Logger.IsEnabled()
        Logger.Log("Processing filtered items in: " + akContainer as String)
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
                    Logger.Log("Removing items from category: " + currentList as String)
                EndIf
                akContainer.RemoveItem(currentList as Form, -1, True, GetDestRef())
            Else
                If Logger && Logger.IsEnabled()
                    Logger.LogWarn("Skipping list: " + currentList as String)
                EndIf
            EndIf
        Else
            If Logger && Logger.IsEnabled()
                Logger.LogError("Skipping index " + index as String + " due to missing data.")
            EndIf
        EndIf

        index += 1
    EndWhile
EndFunction

;-- GetDestRef Function --
; @return: The destination reference for looted items
; Determines where items should be sent after looting
ObjectReference Function GetDestRef()
    If Logger && Logger.IsEnabled()
        Logger.Log("GetDestRef called")
    EndIf

    Int destination = LPSetting_SendTo.GetValue() as Int
    If destination == 1
        If Logger && Logger.IsEnabled()
            Logger.Log("Destination: Player")
        EndIf
        Return PlayerRef
    ElseIf destination == 2
        If Logger && Logger.IsEnabled()
            Logger.Log("Destination: Lodge Safe")
        EndIf
        Return LodgeSafeRef
    ElseIf destination == 3
        If Logger && Logger.IsEnabled()
            Logger.Log("Destination: Dummy Holding")
        EndIf
        Return LPDummyHoldingRef
    Else
        If Logger && Logger.IsEnabled()
            Logger.LogError("Destination: Unknown")
        EndIf
        Return None
    EndIf
EndFunction