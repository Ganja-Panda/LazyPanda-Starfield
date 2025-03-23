;======================================================================
; Script Name   : LZP:Looting:UnlockHelperScript
; Author        : Ganja Panda
; Description   : Handles unlocking logic via Digipick, Keys, or Perks.
;======================================================================

ScriptName LZP:Looting:UnlockHelperScript Extends Quest Hidden

;======================================================================
; PROPERTIES
;======================================================================
GlobalVariable Property LPSetting_AutoUnlock Auto Const
GlobalVariable Property LPSetting_AutoUnlockSkillCheck Auto Const
GlobalVariable Property LockLevel_RequiresKey Auto Const
GlobalVariable Property LockLevel_Inaccessible Auto Const
Key Property DefaultKey Auto Const
MiscObject Property Digipick Auto Const

ConditionForm Property Perk_CND_AdvancedLocksCheck Auto Const
ConditionForm Property Perk_CND_ExpertLocksCheck Auto Const
ConditionForm Property Perk_CND_MasterLocksCheck Auto Const

Actor Property PlayerRef Auto Const
LZP:Debug:LoggerScript Property Logger Auto Const

;======================================================================
; FUNCTION: TryUnlock
;======================================================================
Function TryUnlock(ObjectReference theContainer)
    If !LPSetting_AutoUnlock.GetValue()
        Return
    EndIf

    Int lockLevel = theContainer.GetLockLevel()
    Int requiresKey = LockLevel_RequiresKey.GetValue() as Int
    Int inaccessible = LockLevel_Inaccessible.GetValue() as Int

    If lockLevel == inaccessible
        Log("Container inaccessible. Skipping unlock.")
        Return
    ElseIf lockLevel == requiresKey
        TryKeyUnlock(theContainer)
    Else
        TryDigipickUnlock(theContainer)
    EndIf
EndFunction

;======================================================================
; FUNCTION: TryKeyUnlock
;======================================================================
Function TryKeyUnlock(ObjectReference theContainer)
    Key foundKey = theContainer.GetKey() || DefaultKey
    If PlayerRef.GetItemCount(foundKey as Form) > 0
        theContainer.Unlock()
        Log("Container unlocked with key: " + foundKey)
    Else
        Log("Key required but not found.")
    EndIf
EndFunction

;======================================================================
; FUNCTION: TryDigipickUnlock
;======================================================================
Function TryDigipickUnlock(ObjectReference theContainer)
    Bool skillCheck = LPSetting_AutoUnlockSkillCheck.GetValue() as Bool

    If PlayerRef.GetItemCount(Digipick as Form) == 0
        Log("No digipicks available.")
        Return
    EndIf

    If !skillCheck || CanUnlockByPerk(theContainer.GetLockLevel())
        theContainer.Unlock()
        PlayerRef.RemoveItem(Digipick as Form, 1)
        Game.RewardPlayerXP(10, False)
        Log("Container unlocked with digipick.")
    Else
        Log("Unlock failed: skill check not passed.")
    EndIf
EndFunction

;======================================================================
; FUNCTION: CanUnlockByPerk
;======================================================================
Bool Function CanUnlockByPerk(Int lockLevel)
    If lockLevel <= 0
        Return True
    ElseIf lockLevel <= 25
        Return Perk_CND_AdvancedLocksCheck.IsTrue(PlayerRef, None)
    ElseIf lockLevel <= 50
        Return Perk_CND_ExpertLocksCheck.IsTrue(PlayerRef, None)
    ElseIf lockLevel <= 75
        Return Perk_CND_MasterLocksCheck.IsTrue(PlayerRef, None)
    EndIf
    Return False
EndFunction

;======================================================================
; FUNCTION: Log (Internal)
;======================================================================
Function Log(String msg)
    If Logger && Logger.IsEnabled()
        Logger.Log("UnlockHelper: " + msg)
    EndIf
EndFunction
