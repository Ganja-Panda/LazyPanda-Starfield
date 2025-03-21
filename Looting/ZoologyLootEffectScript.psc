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
Group EffectSpecific_Mandatory
    Perk Property ActivePerk Auto Const mandatory              ; Perk required for activating the loot effect
    FormList Property ActiveLootList Auto Const mandatory        ; List of forms representing potential loot targets
    conditionform Property Perk_CND_Zoology_NonLethalHarvest_Target Auto Const mandatory ; Condition form for non-lethal harvest
    Spell Property ActiveLootSpell Auto Const                  ; Spell used to trigger looting
    ObjectReference Property PlayerRef Auto mandatory          ; Reference to the player
EndGroup

;-- Settings Autofill --
Group Settings_Autofill
    GlobalVariable Property LPSetting_Radius Auto Const        ; Global setting for loot search radius
EndGroup

;-- No Fill Settings --
Int Property lootTimerID = 1 Auto mandatory                    ; Timer identifier for looting
Float Property lootTimerDelay = 0.5 Auto mandatory             ; Delay between loot cycles

;-- Logger Property --
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const            ; Declared logger using the new logging system
EndGroup

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnEffectStart Event Handler --
Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:ZoologyLootEffectScript: OnEffectStart triggered")
    EndIf
    StartTimer(lootTimerDelay, lootTimerID)
EndEvent

;-- OnTimer Event Handler --
Event OnTimer(Int aiTimerID)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:ZoologyLootEffectScript: OnTimer triggered with aiTimerID: " + aiTimerID as String)
    EndIf
    If aiTimerID == lootTimerID
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:ZoologyLootEffectScript: lootTimerID matched")
        EndIf
        If Game.GetPlayer().HasPerk(ActivePerk)
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Looting:ZoologyLootEffectScript: Player has ActivePerk")
            EndIf
            ExecuteLooting()
        Else
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Looting:ZoologyLootEffectScript: Player does not have ActivePerk")
            EndIf
        EndIf
    EndIf
EndEvent

;======================================================================
; MAIN FUNCTIONS
;======================================================================

;-- ExecuteLooting Function --
Function ExecuteLooting()
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:ZoologyLootEffectScript: ExecuteLooting called")
    EndIf
    LocateLoot(ActiveLootList)
    StartTimer(lootTimerDelay, lootTimerID)
EndFunction

;-- LocateLoot Function --
Function LocateLoot(FormList LootList)
    If LootList.GetSize() == 0
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:ZoologyLootEffectScript: ActiveLootList is empty")
        EndIf
        Return
    EndIf

    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:ZoologyLootEffectScript: LocateLoot called with LootList: " + LootList as String)
    EndIf
    ObjectReference[] lootArray = new ObjectReference[0]
    If LootList.GetSize() > 0
        lootArray = PlayerRef.FindAllReferencesWithKeyword(LootList.GetAt(0), GetRadius())
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:ZoologyLootEffectScript: LootList is empty, no references to find")
        EndIf
        Return
    EndIf
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:ZoologyLootEffectScript: Found " + (lootArray.Length as String) + " loot items")
    EndIf
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
Function ProcessLoot(ObjectReference[] theLootArray)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:ZoologyLootEffectScript: ProcessLoot called with " + (theLootArray.Length as String) + " items")
    EndIf
    Int index = 0
    While index < theLootArray.Length && Game.IsActivateControlsEnabled()
        ObjectReference currentLoot = theLootArray[index]
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:ZoologyLootEffectScript: Processing loot at index: " + index as String)
        EndIf
        If currentLoot != None && IsLootLoaded(currentLoot)
            If Perk_CND_Zoology_NonLethalHarvest_Target.IsTrue(currentLoot, PlayerRef)
                If Logger && Logger.IsEnabled()
                    Logger.Log("LZP:Looting:ZoologyLootEffectScript: Condition is true for loot")
                EndIf
                If PlayerRef As Actor
                    ActiveLootSpell.RemoteCast(PlayerRef, PlayerRef as Actor, currentLoot)
                    currentLoot.Activate(PlayerRef, False)
                Else
                    If Logger && Logger.IsEnabled()
                        Logger.Log("LZP:Looting:ZoologyLootEffectScript: PlayerRef is not an Actor")
                    EndIf
                EndIf
            Else
                If Logger && Logger.IsEnabled()
                    Logger.Log("LZP:Looting:ZoologyLootEffectScript: Condition is false for loot")
                EndIf
            EndIf
        Else
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Looting:ZoologyLootEffectScript: Loot is not loaded or invalid")
            EndIf
        EndIf
        index += 1
    EndWhile
EndFunction

;-- IsLootLoaded Function --
Bool Function IsLootLoaded(ObjectReference theLoot)
    Bool isLoaded = theLoot.Is3DLoaded() && !theLoot.IsDisabled() && !theLoot.IsDeleted()
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:ZoologyLootEffectScript: IsLootLoaded called for " + theLoot as String + ": " + (isLoaded as String))
    EndIf
    Return isLoaded
EndFunction

;-- GetRadius Function --
Float Function GetRadius()
    Float radius = LPSetting_Radius.GetValue()
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:ZoologyLootEffectScript: GetRadius called: " + radius as String)
    EndIf
    Return radius
EndFunction
