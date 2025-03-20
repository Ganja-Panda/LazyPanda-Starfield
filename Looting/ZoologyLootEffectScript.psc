;======================================================================
; Script: LZP:Looting:ZoologyLootEffectScript
; Description: This ActiveMagicEffect script manages the looting process
; for zoology-related effects. It locates and processes loot based on
; specific conditions and player perks.
;======================================================================

ScriptName LZP:Looting:ZoologyLootEffectScript Extends ActiveMagicEffect hidden

;======================================================================
; PROPERTY GROUPS
;======================================================================

;-- Effect-Specific Mandatory Properties --
; Contains the essential properties needed for the loot effect.
Group EffectSpecific_Mandatory
    Perk Property ActivePerk Auto Const mandatory              ; Perk required for activating the loot effect
    FormList Property ActiveLootList Auto Const mandatory      ; List of forms representing potential loot targets
    conditionform Property Perk_CND_Zoology_NonLethalHarvest_Target Auto Const mandatory ; Condition form for non-lethal harvest
    Spell Property ActiveLootSpell Auto Const                  ; Spell used to trigger looting
    ObjectReference Property PlayerRef Auto mandatory          ; Reference to the player
EndGroup

;-- Settings Autofill --
; Global variables that control looting settings such as search radius and debug logging.
Group Settings_Autofill
    GlobalVariable Property LPSetting_Radius Auto Const        ; Global setting for loot search radius
    GlobalVariable Property LPSystemUtil_Debug Auto Const          ; Global debug flag for logging
EndGroup

;-- No Fill Settings --
; Timer and local flags for looting behavior.
Int Property lootTimerID = 1 Auto mandatory                    ; Timer identifier for looting
Float Property lootTimerDelay = 0.5 Auto mandatory             ; Delay between loot cycles

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnEffectStart Event Handler --
; Called when the magic effect starts. Begins the loot timer.
Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
    LZP:SystemScript.Log("OnEffectStart triggered", 3)
    StartTimer(lootTimerDelay, lootTimerID)
EndEvent

;-- OnTimer Event Handler --
; Called when the loot timer expires. Checks if the player has the required perk before executing looting.
Event OnTimer(Int aiTimerID)
    LZP:SystemScript.Log("OnTimer triggered with aiTimerID: " + aiTimerID as String, 3)
    If aiTimerID == lootTimerID
        LZP:SystemScript.Log("lootTimerID matched", 3)
        If Game.GetPlayer().HasPerk(ActivePerk)
            LZP:SystemScript.Log("Player has ActivePerk", 3)
            ExecuteLooting()
        Else
            LZP:SystemScript.Log("Player does not have ActivePerk", 3)
        EndIf
    EndIf
EndEvent

;======================================================================
; MAIN FUNCTIONS
;======================================================================

;-- ExecuteLooting Function --
; Main function that initiates the looting process and restarts the loot timer.
Function ExecuteLooting()
    LZP:SystemScript.Log("ExecuteLooting called", 3)
    LocateLoot(ActiveLootList)
    StartTimer(lootTimerDelay, lootTimerID)
EndFunction

;-- LocateLoot Function --
; Determines the appropriate method for locating loot based on the form type.
Function LocateLoot(FormList LootList)
    If LootList.GetSize() == 0
        LZP:SystemScript.Log("ActiveLootList is empty", 3)
        Return
    EndIf

    LZP:SystemScript.Log("LocateLoot called with LootList: " + LootList as String, 3)
    ObjectReference[] lootArray = new ObjectReference[0]
    If LootList.GetSize() > 0
        lootArray = PlayerRef.FindAllReferencesWithKeyword(LootList.GetAt(0), GetRadius())
    Else
        LZP:SystemScript.Log("LootList is empty, no references to find", 3)
        Return
    EndIf
    LZP:SystemScript.Log("Found " + (lootArray.Length as String) + " loot items", 3)
    If lootArray.Length > 0
        ProcessLoot(lootArray)
    EndIf
    Int index = 0
    Bool activateControlsEnabled = Game.IsActivateControlsEnabled()
    While index < lootArray.Length && activateControlsEnabled
        ProcessLoot(lootArray)
        index += 1
    EndWhile
EndFunction

;-- ProcessLoot Function --
; Processes an array of loot references, determining how to handle each based on its type.
Function ProcessLoot(ObjectReference[] theLootArray)
    LZP:SystemScript.Log("ProcessLoot called with " + (theLootArray.Length as String) + " items", 3)
    Int index = 0
    While index < theLootArray.Length && Game.IsActivateControlsEnabled()
        ObjectReference currentLoot = theLootArray[index]
        LZP:SystemScript.Log("Processing loot at index: " + index as String, 3)
        If currentLoot != None && IsLootLoaded(currentLoot)
            If Perk_CND_Zoology_NonLethalHarvest_Target.IsTrue(currentLoot, PlayerRef)
                LZP:SystemScript.Log("Condition is true for loot", 3)
                If PlayerRef As Actor
                    ActiveLootSpell.RemoteCast(PlayerRef, PlayerRef as Actor, currentLoot)
                    currentLoot.Activate(PlayerRef, False)
                Else
                    LZP:SystemScript.Log("PlayerRef is not an Actor", 3)
                EndIf
            Else
                LZP:SystemScript.Log("Condition is false for loot", 3)
            EndIf
        Else
            LZP:SystemScript.Log("Loot is not loaded or invalid", 3)
        EndIf
        index += 1
    EndWhile
EndFunction

;-- IsLootLoaded Function --
; Determines if the loot object is currently loaded in the game (and not disabled or deleted).
Bool Function IsLootLoaded(ObjectReference theLoot)
    Bool isLoaded = theLoot.Is3DLoaded() && !theLoot.IsDisabled() && !theLoot.IsDeleted()
    LZP:SystemScript.Log("IsLootLoaded called for " + theLoot as String + ": " + (isLoaded as String), 3)
    Return isLoaded
EndFunction

;-- GetRadius Function --
; Returns the search radius for loot detection.
Float Function GetRadius()
    Float radius = LPSetting_Radius.GetValue()
    LZP:SystemScript.Log("GetRadius called: " + radius as String, 3)
    Return radius
EndFunction