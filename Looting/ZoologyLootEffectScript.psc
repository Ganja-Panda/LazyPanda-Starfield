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
; DEBUG LOGGING HELPER FUNCTION
;======================================================================

; Logs a message if the global debug setting is enabled.
Function Log(String logMsg)
    If LPSystemUtil_Debug.GetValue()
        Debug.Trace(logMsg, 0)
    EndIf
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnEffectStart Event Handler --
; Called when the magic effect starts. Begins the loot timer.
Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
    Log("OnEffectStart triggered")
    StartTimer(lootTimerDelay, lootTimerID)
EndEvent

;-- OnTimer Event Handler --
; Called when the loot timer expires. Checks if the player has the required perk before executing looting.
Event OnTimer(Int aiTimerID)
    Log("OnTimer triggered with aiTimerID: " + aiTimerID as String)
    If aiTimerID == lootTimerID
        Log("lootTimerID matched")
        If Game.GetPlayer().HasPerk(ActivePerk)
            Log("Player has ActivePerk")
            ExecuteLooting()
        Else
            Log("Player does not have ActivePerk")
        EndIf
    EndIf
EndEvent

;======================================================================
; MAIN FUNCTIONS
;======================================================================

;-- ExecuteLooting Function --
; Main function that initiates the looting process and restarts the loot timer.
Function ExecuteLooting()
    Log("ExecuteLooting called")
    LocateLoot(ActiveLootList)
    StartTimer(lootTimerDelay, lootTimerID)
EndFunction

;-- LocateLoot Function --
; Determines the appropriate method for locating loot based on the form type.
Function LocateLoot(FormList LootList)
    If LootList.GetSize() == 0
        Log("ActiveLootList is empty")
        Return
    EndIf

    Log("LocateLoot called with LootList: " + LootList as String)
    ObjectReference[] lootArray = new ObjectReference[0]
    If LootList.GetSize() > 0
        lootArray = PlayerRef.FindAllReferencesWithKeyword(LootList.GetAt(0), GetRadius())
    Else
        Log("LootList is empty, no references to find")
        Return
    EndIf
    Log("Found " + (lootArray.Length as String) + " loot items")
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
    Log("ProcessLoot called with " + (theLootArray.Length as String) + " items")
    Int index = 0
    While index < theLootArray.Length && Game.IsActivateControlsEnabled()
        ObjectReference currentLoot = theLootArray[index]
        Log("Processing loot at index: " + index as String)
        If currentLoot != None && IsLootLoaded(currentLoot)
            If Perk_CND_Zoology_NonLethalHarvest_Target.IsTrue(currentLoot, PlayerRef)
                Log("Condition is true for loot")
                If PlayerRef As Actor
                    ActiveLootSpell.RemoteCast(PlayerRef, PlayerRef as Actor, currentLoot)
                    currentLoot.Activate(PlayerRef, False)
                Else
                    Log("PlayerRef is not an Actor")
                EndIf
            Else
                Log("Condition is false for loot")
            EndIf
        Else
            Log("Loot is not loaded or invalid")
        EndIf
        index += 1
    EndWhile
EndFunction

;-- IsLootLoaded Function --
; Determines if the loot object is currently loaded in the game (and not disabled or deleted).
Bool Function IsLootLoaded(ObjectReference theLoot)
    Bool isLoaded = theLoot.Is3DLoaded() && !theLoot.IsDisabled() && !theLoot.IsDeleted()
    Log("IsLootLoaded called for " + theLoot as String + ": " + (isLoaded as String))
    Return isLoaded
EndFunction

;-- GetRadius Function --
; Returns the search radius for loot detection.
Float Function GetRadius()
    Float radius = LPSetting_Radius.GetValue()
    Log("GetRadius called: " + radius as String)
    Return radius
EndFunction