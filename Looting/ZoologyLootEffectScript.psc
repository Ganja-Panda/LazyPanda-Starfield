;======================================================================
; Script Name   : LZP:Looting:ZoologyLootEffectScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Automates zoological looting of non-hostile creatures
; Description   : This ActiveMagicEffect script processes nearby wildlife 
;                 based on player perks and filters using radius scanning.
;                 It performs non-lethal harvesting through condition checks
;                 and logs each stage for debugging. Uses a timer loop for
;                 repeated scans and auto-activation of loot sources.
; Dependencies  : LazyPanda.esm, LoggerScript, FormLists, Spells, Perks
; Usage         : Attached to an ActiveMagicEffect; triggers on start
;======================================================================

ScriptName LZP:Looting:ZoologyLootEffectScript Extends ActiveMagicEffect hidden

;======================================================================
; PROPERTIES
;======================================================================

;-- EffectSpecific_Mandatory
; Core setup: required conditions, perks, and references
Group EffectSpecific_Mandatory
    Perk Property ActivePerk Auto Const mandatory                               ; Required perk for zoology looting
    FormList Property ActiveLootList Auto Const mandatory                       ; FormList of keywords to scan for
    ConditionForm Property Perk_CND_Zoology_NonLethalHarvest_Target Auto Const mandatory ; Non-lethal condition check
    Spell Property ActiveLootSpell Auto Const                                   ; Spell to trigger looting behavior
    ObjectReference Property PlayerRef Auto mandatory                           ; Player reference to cast and activate from
EndGroup

;-- Settings_Autofill
; Automatically set global scan control values
Group Settings_Autofill
    GlobalVariable Property LPSetting_Radius Auto Const                         ; Global controlling loot scan radius
    GlobalVariable Property LPSystemUtil_LoopCap Auto Const                     ; Safety cap for max iterations per scan
EndGroup

;-- NoFill
; Timer loop control
Int Property lootTimerID = 1 Auto mandatory                                     ; Timer ID for zoology loop
Float Property lootTimerDelay = 0.5 Auto mandatory                              ; Delay between loop cycles

;-- Logger
; Central debug logging controller
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const                           ; Logger instance for debug trace
EndGroup

String Property ScriptTag = "ZoologyLootEffectScript" Auto Const                ; Consistent tag prefix for logger

;======================================================================
; EVENTS
;======================================================================

;----------------------------------------------------------------------
; Event         : OnEffectStart
; Description   : Initializes periodic zoology scan via timer
;----------------------------------------------------------------------
Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv(ScriptTag + ": OnEffectStart triggered", 1, ScriptTag)
    EndIf
    StartTimer(lootTimerDelay, lootTimerID)
EndEvent

;----------------------------------------------------------------------
; Event         : OnTimer
; Description   : Timer-driven execution of looting logic
;----------------------------------------------------------------------
Event OnTimer(Int aiTimerID)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv(ScriptTag + ": OnTimer triggered with aiTimerID: " + aiTimerID as String, 1, ScriptTag)
    EndIf

    If aiTimerID == lootTimerID
        If Logger && Logger.IsEnabled()
            Logger.LogAdv(ScriptTag + ": lootTimerID matched", 1, ScriptTag)
        EndIf

        If Game.GetPlayer().HasPerk(ActivePerk)
            If Logger && Logger.IsEnabled()
                Logger.LogAdv(ScriptTag + ": Player has ActivePerk", 1, ScriptTag)
            EndIf
            ExecuteLooting()
        Else
            If Logger && Logger.IsEnabled()
                Logger.LogAdv(ScriptTag + ": Player does not have ActivePerk", 2, ScriptTag)
            EndIf
        EndIf

        StartTimer(lootTimerDelay, lootTimerID)
    EndIf
EndEvent

;======================================================================
; FUNCTIONS
;======================================================================

;----------------------------------------------------------------------
; Function      : ExecuteLooting
; Description   : Starts loot detection using the assigned list
;----------------------------------------------------------------------
Function ExecuteLooting()
    If Logger && Logger.IsEnabled()
        Logger.LogAdv(ScriptTag + ": ExecuteLooting called", 1, ScriptTag)
    EndIf
    LocateLoot(ActiveLootList)
EndFunction

;----------------------------------------------------------------------
; Function      : LocateLoot
; Description   : Finds valid loot targets based on first entry in ActiveLootList
; Parameters    : LootList - FormList of keywords to use
; Returns       : None
;----------------------------------------------------------------------
Function LocateLoot(FormList LootList)
    Int listSize = LootList.GetSize()
    If listSize == 0
        If Logger && Logger.IsEnabled()
            Logger.LogAdv(ScriptTag + ": ActiveLootList is empty", 2, ScriptTag)
        EndIf
        Return
    EndIf

    If Logger && Logger.IsEnabled()
        Logger.LogAdv(ScriptTag + ": LocateLoot called with LootList: " + LootList as String, 1, ScriptTag)
    EndIf

    ObjectReference[] lootArray = PlayerRef.FindAllReferencesWithKeyword(LootList.GetAt(0) as Keyword, GetRadius())

    If Logger && Logger.IsEnabled()
        Logger.LogAdv(ScriptTag + ": Found " + lootArray.Length as String + " loot items", 1, ScriptTag)
    EndIf

    If lootArray.Length > 0
        ProcessLoot(lootArray)
    EndIf
EndFunction

;----------------------------------------------------------------------
; Function      : ProcessLoot
; Description   : Iterates over each valid target, applies spell, activates
; Parameters    : theLootArray - references to lootable objects
; Returns       : None
;----------------------------------------------------------------------
Function ProcessLoot(ObjectReference[] theLootArray)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv(ScriptTag + ": ProcessLoot called with " + theLootArray.Length as String + " items", 1, ScriptTag)
    EndIf

    Int index = 0
    Int loopCap = LPSystemUtil_LoopCap.GetValueInt()
    Int loopCount = 0
    Actor playerActor = PlayerRef as Actor

    While index < theLootArray.Length && Game.IsActivateControlsEnabled() && loopCount < loopCap
        ObjectReference currentLoot = theLootArray[index]

        If Logger && Logger.IsEnabled()
            Logger.LogAdv(ScriptTag + ": Processing loot at index: " + index as String, 1, ScriptTag)
        EndIf

        If currentLoot != None && IsLootLoaded(currentLoot)
            If Perk_CND_Zoology_NonLethalHarvest_Target.IsTrue(currentLoot, PlayerRef)
                If Logger && Logger.IsEnabled()
                    Logger.LogAdv(ScriptTag + ": Condition is true for loot", 1, ScriptTag)
                EndIf

                If playerActor && ActiveLootSpell != None
                    ActiveLootSpell.RemoteCast(PlayerRef, playerActor, currentLoot)
                    currentLoot.Activate(PlayerRef, False)
                ElseIf Logger && Logger.IsEnabled()
                    Logger.LogAdv(ScriptTag + ": PlayerRef is not an Actor or ActiveLootSpell is None", 2, ScriptTag)
                EndIf
            ElseIf Logger && Logger.IsEnabled()
                Logger.LogAdv(ScriptTag + ": Condition is false for loot", 2, ScriptTag)
            EndIf
        ElseIf Logger && Logger.IsEnabled()
            Logger.LogAdv(ScriptTag + ": Loot is not loaded or invalid", 2, ScriptTag)
        EndIf

        index += 1
        loopCount += 1
    EndWhile

    If loopCount >= loopCap && Logger && Logger.IsEnabled()
        Logger.LogAdv(ScriptTag + ": Loop cap reached at " + loopCap as String, 2, ScriptTag)
    EndIf

    If Logger && Logger.IsEnabled()
        Logger.LogAdv(ScriptTag + ": Loop processed " + loopCount as String + " of " + theLootArray.Length as String + " items", 1, ScriptTag)
    EndIf
EndFunction

;----------------------------------------------------------------------
; Function      : IsLootLoaded
; Description   : Verifies loot is valid, loaded, and not disabled
; Parameters    : theLoot - reference to check
; Returns       : Bool - whether loot is eligible
;----------------------------------------------------------------------
Bool Function IsLootLoaded(ObjectReference theLoot)
    Bool isLoaded = theLoot.Is3DLoaded() && !theLoot.IsDisabled() && !theLoot.IsDeleted()
    If Logger && Logger.IsEnabled()
        Logger.LogAdv(ScriptTag + ": IsLootLoaded called for " + theLoot as String + ": " + isLoaded as String, 1, ScriptTag)
    EndIf
    Return isLoaded
EndFunction

;----------------------------------------------------------------------
; Function      : GetRadius
; Description   : Returns current scan radius from setting
; Returns       : Float - radius in game units
;----------------------------------------------------------------------
Float Function GetRadius()
    Float radius = LPSetting_Radius.GetValue()
    If Logger && Logger.IsEnabled()
        Logger.LogAdv(ScriptTag + ": GetRadius called: " + radius as String, 1, ScriptTag)
    EndIf
    Return radius
EndFunction
