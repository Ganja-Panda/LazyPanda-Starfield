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
GlobalVariable Property LZP_Setting_Unlock_Auto Auto Const          ; Enable auto unlock
GlobalVariable Property LZP_Setting_Unlock_SkillCheck Auto Const    ; Enable skill check
GlobalVariable Property LockLevel_RequiresKey Auto Const            ; Lock level requiring key
GlobalVariable Property LockLevel_Inaccessible Auto Const           ; Lock level marked as inaccessible

;-- Unlock items
Key Property DefaultKey Auto Const                                  ; Default key to use
MiscObject Property Digipick Auto Const                             ; Digipick item  

;-- Perk check conditions
ConditionForm Property LZP_Perk_CND_LockCheck_Advanced Auto Const       ; Perk check condition for Advanced Locks
ConditionForm Property LZP_Perk_CND_LockCheck_Expert Auto Const         ; Perk check condition for Expert Locks
ConditionForm Property LZP_Perk_CND_LockCheck_Master Auto Const         ; Perk check condition for Master Locks

;-- Core references
Actor Property PlayerRef Auto Const                                 ; Player reference
LZP:Debug:LoggerScript Property Logger Auto Const                   ; Debug logger

;======================================================================
; MAIN ENTRY POINT
;======================================================================
Function TryUnlock(ObjectReference theContainer)
    If !LZP_Setting_Unlock_Auto.GetValue()
        Logger.LogAdv("Auto unlock disabled. Skipping.", 2, "UnlockHelperScript")
        Return
    EndIf

    Int lockLevel = theContainer.GetLockLevel()
    Int requiresKey = LockLevel_RequiresKey.GetValueInt()
    Int inaccessible = LockLevel_Inaccessible.GetValueInt()

    Logger.LogAdv("Attempting unlock | LockLevel: " + lockLevel, 1, "UnlockHelperScript")

    If lockLevel == inaccessible
        Logger.LogAdv("Container is marked as inaccessible. Skipping.", 2, "UnlockHelperScript")
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
    Key foundKey = theContainer.GetKey()
    if foundKey == None
        foundKey = DefaultKey
    endif

    If PlayerRef.GetItemCount(foundKey as Form) > 0
        theContainer.Unlock()
        Logger.LogAdv("Unlocked with key: " + foundKey, 1, "UnlockHelperScript")
    Else
        Logger.LogAdv("Key required but not found: " + foundKey, 2, "UnlockHelperScript")
    EndIf
EndFunction

;======================================================================
; DIGIPICK UNLOCK HANDLER
;======================================================================
Function TryDigipickUnlock(ObjectReference theContainer, Int lockLevel)
    Bool skillCheck = LZP_Setting_Unlock_SkillCheck.GetValue() as Bool

    If PlayerRef.GetItemCount(Digipick as Form) == 0
        Logger.LogAdv("No digipicks available to attempt unlock.", 2, "UnlockHelperScript")
        Return
    EndIf

    If !skillCheck || CanUnlockByPerk(lockLevel)
        theContainer.Unlock()
        PlayerRef.RemoveItem(Digipick as Form, 1)
        Game.RewardPlayerXP(10, False)
        Logger.LogAdv("Unlocked with digipick at LockLevel: " + lockLevel, 1, "UnlockHelperScript")
    Else
        Logger.LogAdv("Unlock failed - skill check not passed at LockLevel: " + lockLevel, 3, "UnlockHelperScript")
    EndIf
EndFunction

;======================================================================
; PERK-GATED UNLOCK VALIDATION
;======================================================================
Bool Function CanUnlockByPerk(Int lockLevel)
    If lockLevel <= 0
        Return True
    ElseIf lockLevel <= 25
        Bool hasPerk = LZP_Perk_CND_LockCheck_Advanced.IsTrue(PlayerRef, None)
        Logger.LogAdv("Checking AdvancedLocksCheck | Has Perk: " + hasPerk, 1, "UnlockHelperScript")
        Return hasPerk
    ElseIf lockLevel <= 50
        Bool hasPerk = LZP_Perk_CND_LockCheck_Expert.IsTrue(PlayerRef, None)
        Logger.LogAdv("Checking ExpertLocksCheck | Has Perk: " + hasPerk, 1, "UnlockHelperScript")
        Return hasPerk
    ElseIf lockLevel <= 75
        Bool hasPerk = LZP_Perk_CND_LockCheck_Master.IsTrue(PlayerRef, None)
        Logger.LogAdv("Checking MasterLocksCheck | Has Perk: " + hasPerk, 1, "UnlockHelperScript")
        Return hasPerk
    EndIf
    Logger.LogAdv("Unknown or unsupported lock level: " + lockLevel, 3, "UnlockHelperScript")
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