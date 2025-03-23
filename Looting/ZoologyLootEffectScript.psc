;======================================================================
; Script Name   : LZP:Looting:ZoologyLootEffectScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Handles automatic looting behavior on passive creatures
; Description   : Casts remote scan spell and auto-activates loot behavior
;                 on nearby qualifying targets. Driven by perk gating and
;                 keyword/condition filtering. Triggered by magic effect.
; Dependencies  : LoggerScript, ActiveLootSpell, LazyPanda global settings
;======================================================================

ScriptName LZP:Looting:ZoologyLootEffectScript Extends ActiveMagicEffect

;======================================================================
; PROPERTIES
;======================================================================

;-- EffectSpecific_Mandatory
; Core setup: defines spell, perk requirement, and loot keyword filter
Group EffectSpecific_Mandatory
    Spell Property ActiveLootSpell Auto Const mandatory                 ; Spell to cast remotely on valid creatures
    Perk Property ActivePerk Auto Const mandatory                       ; Perk required for looting to be active
    Keyword Property ActiveLootKeyword Auto Const mandatory             ; Keyword used to find valid targets
    ConditionForm Property ConditionForm Auto Const                     ; Optional additional condition check
EndGroup

;-- Settings_Autofill
; Optional global scan radius control
Group Settings_Autofill
    GlobalVariable Property LPSystemUtil_LoopCap Auto Const              ; Max entries to process per loop (safety cap)
    GlobalVariable Property LPSetting_Radius Auto Const                 ; Controls loot scan radius
EndGroup

;-- Logger Integration
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const                   ; Lazy Panda Logger instance
EndGroup

;-- Runtime Configuration
Group NoFill
    Float Property lootTimerDelay = 0.5 Auto                            ; Delay between timer executions
    Int Property lootTimerID = 1 Auto                                   ; Timer ID used to identify this effect’s loop
EndGroup

;======================================================================
; EVENT: OnEffectStart
; Initializes looting loop upon effect start
;======================================================================
Event OnEffectStart(Actor akTarget, Actor akCaster)
    if Logger && Logger.IsEnabled()
        Logger.LogInfo("ZoologyLootEffectScript: OnEffectStart called.")
    endif

    StartTimer(lootTimerDelay, lootTimerID)
EndEvent

;======================================================================
; EVENT: OnTimer
; Timer-driven execution of loot scanning
;======================================================================
Event OnTimer(int aiTimerID)
    if aiTimerID != lootTimerID
        return
    endif

    if Logger && Logger.IsEnabled()
        Logger.LogInfo("ZoologyLootEffectScript: OnTimer fired.")
    endif

    if Game.GetPlayer().HasPerk(ActivePerk)
        ExecuteLooting()
    else
        if Logger && Logger.IsEnabled()
            Logger.LogWarn("Player does not have required perk for zoology looting.")
        endif
    endif

    StartTimer(lootTimerDelay, lootTimerID)
EndEvent

;======================================================================
; FUNCTION: ExecuteLooting
; Scans for valid targets and processes them
;======================================================================
Function ExecuteLooting()
    ObjectReference[] lootArray = LocateLoot(ActiveLootKeyword)

    if lootArray == None || lootArray.Length == 0
        if Logger && Logger.IsEnabled()
            Logger.LogInfo("No valid zoology loot targets found.")
        endif
        return
    endif

    if Logger && Logger.IsEnabled()
        Logger.LogInfo("Found " + lootArray.Length as String + " targets.")
    endif

    ProcessLoot(lootArray)
EndFunction

;======================================================================
; FUNCTION: LocateLoot
; Scans for nearby references using keyword and radius
;======================================================================
ObjectReference[] Function LocateLoot(Keyword lootKeyword) Global
    float scanRadius = GetRadius()

    ObjectReference playerRef = Game.GetPlayer()
    ObjectReference[] foundRefs = playerRef.FindAllReferencesWithKeyword(lootKeyword, scanRadius)

    return foundRefs
EndFunction

;======================================================================
; FUNCTION: ProcessLoot
; Casts spell and activates on valid targets
;======================================================================
Function ProcessLoot(ObjectReference[] lootArray)
    if ActiveLootSpell == None
        if Logger && Logger.IsEnabled()
            Logger.LogError("ActiveLootSpell is None — cannot cast.")
        endif
        return
    endif

    Actor player = Game.GetPlayer()
    int loopCap = LPSystemUtil_LoopCap.GetValueInt()
    int loopCount = 0
    int i = 0

    while i < lootArray.Length && loopCount < loopCap
        ObjectReference refTarget = lootArray[i]

        if IsLootLoaded(refTarget) && (ConditionForm == None || ConditionForm.IsTrue(refTarget, player))
            ActiveLootSpell.RemoteCast(player, refTarget)
            refTarget.Activate(player)
            if Logger && Logger.IsEnabled()
                Logger.LogInfo("Activated zoology target " + i as String)
            endif
        endif

        i += 1
        loopCount += 1
    endwhile

    if loopCount >= loopCap && Logger && Logger.IsEnabled()
        Logger.LogWarn("ZoologyLootEffectScript: Loop cap reached at " + loopCap as String)
    endif
EndFunction

;======================================================================
; FUNCTION: GetRadius
; Determines scan radius from global setting or fallback
;======================================================================
float Function GetRadius()
    return LPSetting_Radius.GetValue()
EndFunction

;======================================================================
; FUNCTION: IsLootLoaded
; Checks if reference is in the currently loaded 3D space
;======================================================================
bool Function IsLootLoaded(ObjectReference targetRef)
    return targetRef != None && targetRef.Is3DLoaded()
EndFunction
