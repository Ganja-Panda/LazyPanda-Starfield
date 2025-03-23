;======================================================================
; Script Name   : LZP:Looting:UnlockHelperScript
; Author        : Ganja Panda
; Description   : Handles unlocking logic via Digipick, Keys, or Perks.
;======================================================================

ScriptName LZP:Looting:UnlockHelperScript Extends Quest Hidden

;======================================================================
; PROPERTIES
;======================================================================

;-- Settings and thresholds
GlobalVariable Property LPSetting_AutoUnlock Auto Const
GlobalVariable Property LPSetting_AutoUnlockSkillCheck Auto Const
GlobalVariable Property LockLevel_RequiresKey Auto Const
GlobalVariable Property LockLevel_Inaccessible Auto Const

;-- Unlock items
Key Property DefaultKey Auto Const
MiscObject Property Digipick Auto Const

;-- Perk check conditions
ConditionForm Property Perk_CND_AdvancedLocksCheck Auto Const
ConditionForm Property Perk_CND_ExpertLocksCheck Auto Const
ConditionForm Property Perk_CND_MasterLocksCheck Auto Const

;-- Core references
Actor Property PlayerRef Auto Const
LZP:Debug:LoggerScript Property Logger Auto Const

;======================================================================
; MAIN ENTRY POINT
;======================================================================
Function TryUnlock(ObjectReference theContainer)
    If !LPSetting_AutoUnlock.GetValue()
        Log("Auto unlock disabled. Skipping.", 1)
        Return
    EndIf

    Int lockLevel = theContainer.GetLockLevel()
    Int requiresKey = LockLevel_RequiresKey.GetValueInt()
    Int inaccessible = LockLevel_Inaccessible.GetValueInt()

    Log("Attempting unlock | LockLevel: " + lockLevel, 1)

    If lockLevel == inaccessible
        Log("Container is marked as inaccessible. Skipping.", 2)
        Return
    ElseIf lockLevel == requiresKey
        TryKeyUnlock(theContainer)
    Else
        TryDigipickUnlock(theContainer, lockLevel)
    EndIf
EndFunction

;======================================================================
; KEY UNLOCK HANDLER
;======================================================================
Function TryKeyUnlock(ObjectReference theContainer)
    Key foundKey = theContainer.GetKey() || DefaultKey

    If PlayerRef.GetItemCount(foundKey as Form) > 0
        theContainer.Unlock()
        Log("Unlocked with key: " + foundKey, 1)
    Else
        Log("Key required but not found: " + foundKey, 2)
    EndIf
EndFunction

;======================================================================
; DIGIPICK UNLOCK HANDLER
;======================================================================
Function TryDigipickUnlock(ObjectReference theContainer, Int lockLevel)
    Bool skillCheck = LPSetting_AutoUnlockSkillCheck.GetValue() as Bool

    If PlayerRef.GetItemCount(Digipick as Form) == 0
        Log("No digipicks available to attempt unlock.", 2)
        Return
    EndIf

    If !skillCheck || CanUnlockByPerk(lockLevel)
        theContainer.Unlock()
        PlayerRef.RemoveItem(Digipick as Form, 1)
        Game.RewardPlayerXP(10, False)
        Log("Unlocked with digipick at LockLevel: " + lockLevel, 1)
    Else
        Log("Unlock failed - skill check not passed at LockLevel: " + lockLevel, 3)
    EndIf
EndFunction

;======================================================================
; PERK-GATED UNLOCK VALIDATION
;======================================================================
Bool Function CanUnlockByPerk(Int lockLevel)
    If lockLevel <= 0
        Return True
    ElseIf lockLevel <= 25
        Bool hasPerk = Perk_CND_AdvancedLocksCheck.IsTrue(PlayerRef, None)
        Log("Checking AdvancedLocksCheck | Has Perk: " + hasPerk, 1)
        Return hasPerk
    ElseIf lockLevel <= 50
        Bool hasPerk = Perk_CND_ExpertLocksCheck.IsTrue(PlayerRef, None)
        Log("Checking ExpertLocksCheck | Has Perk: " + hasPerk, 1)
        Return hasPerk
    ElseIf lockLevel <= 75
        Bool hasPerk = Perk_CND_MasterLocksCheck.IsTrue(PlayerRef, None)
        Log("Checking MasterLocksCheck | Has Perk: " + hasPerk, 1)
        Return hasPerk
    EndIf
    Log("Unknown or unsupported lock level: " + lockLevel, 3)
    Return False
EndFunction

;======================================================================
; INTERNAL LOGGING WRAPPER WITH SEVERITY SUPPORT
;======================================================================
Function Log(String msg, Int severity = 1)
    If Logger && Logger.IsEnabled()
        String prefix = "[INFO] "
        If severity == 2
            prefix = "[WARN] "
        ElseIf severity == 3
            prefix = "[ERROR] "
        EndIf
        Logger.Log("UnlockHelper: " + prefix + msg)
    EndIf
EndFunction
