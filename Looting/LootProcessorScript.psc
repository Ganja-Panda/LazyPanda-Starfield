;======================================================================
; Script Name   : LZP:Looting:LootProcessorScript
; Author        : Ganja Panda
; Description   : Processes a batch of lootable references and delegates
;                 handling by type (corpse, container, activator, etc.)
;======================================================================

ScriptName LZP:Looting:LootProcessorScript Extends Quest Hidden

;======================================================================
; PROPERTIES
;======================================================================
LZP:Looting:UnlockHelperScript Property UnlockHelper Auto Const
LZP:Looting:LootFilterScript Property LootFilter Auto Const
LZP:Looting:LootTransferScript Property LootTransfer Auto Const
LZP:Debug:LoggerScript Property Logger Auto Const
Keyword Property LPKeyword_LootedCorpse Auto Const
Race Property HumanRace Auto Const
Armor Property LP_Skin_Naked_NOTPLAYABLE Auto Const
GlobalVariable Property LPSystemUtil_LoopCap Auto Const

;======================================================================
; FUNCTION: ProcessTargets
; @param lootTargets : Array of lootable references
; @param looterRef   : Player or origin reference
;======================================================================
Function ProcessTargets(ObjectReference[] lootTargets, ObjectReference looterRef)
    If lootTargets == None || lootTargets.Length == 0
        Return
    EndIf

    Int i = 0
    Int cap = LPSystemUtil_LoopCap.GetValueInt()

    While i < lootTargets.Length && i < cap
        ObjectReference target = lootTargets[i]
        If target == None
            i += 1
            Continue
        EndIf

        If IsCorpse(target)
            HandleCorpse(target, looterRef)
        ElseIf target.IsLocked()
            UnlockHelper.TryUnlock(target)
        ElseIf target.IsContainer()
            HandleContainer(target, looterRef)
        ElseIf target.IsActivator()
            HandleActivator(target, looterRef)
        EndIf

        i += 1
    EndWhile
EndFunction

;======================================================================
; FUNCTION: HandleCorpse
;======================================================================
Function HandleCorpse(ObjectReference corpseRef, ObjectReference looterRef)
    Actor corpse = corpseRef as Actor
    If corpse && corpse.IsDead() && !corpse.HasKeyword(LPKeyword_LootedCorpse)
        corpse.UnequipAll()
        corpse.EquipItem(LP_Skin_Naked_NOTPLAYABLE, False, False)

        Int itemCount = corpseRef.GetNumItems()
        Int j = 0
        While j < itemCount
            Form itemForm = corpseRef.GetNthForm(j)
            If LootFilter.ShouldLoot(itemForm)
                LootTransfer.TransferItem(itemForm, -1, corpseRef)
            EndIf
            j += 1
        EndWhile

        corpseRef.AddKeyword(LPKeyword_LootedCorpse)
        If Logger && Logger.IsEnabled()
            Logger.Log("LootProcessor: Corpse looted: " + corpseRef)
        EndIf
    EndIf
EndFunction

;======================================================================
; FUNCTION: HandleContainer
;======================================================================
Function HandleContainer(ObjectReference containerRef, ObjectReference looterRef)
    Int itemCount = containerRef.GetNumItems()
    Int j = 0
    While j < itemCount
        Form itemForm = containerRef.GetNthForm(j)
        If LootFilter.ShouldLoot(itemForm)
            LootTransfer.TransferItem(itemForm, -1, containerRef)
        EndIf
        j += 1
    EndWhile

    If Logger && Logger.IsEnabled()
        Logger.Log("LootProcessor: Container looted: " + containerRef)
    EndIf
EndFunction

;======================================================================
; FUNCTION: HandleActivator
;======================================================================
Function HandleActivator(ObjectReference activatorRef, ObjectReference looterRef)
    activatorRef.Activate(looterRef, False)
    If Logger && Logger.IsEnabled()
        Logger.Log("LootProcessor: Activator triggered: " + activatorRef)
    EndIf
EndFunction

;======================================================================
; FUNCTION: IsCorpse
;======================================================================
Bool Function IsCorpse(ObjectReference ref)
    Actor a = ref as Actor
    Return a != None
EndFunction
