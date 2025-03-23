;======================================================================
; Script Name   : LZP:Looting:LootProcessorScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Core logic to process lootable references and delegate
;                 by type: actors, containers, activators.
;======================================================================

ScriptName LZP:Looting:LootProcessorScript Extends Quest Hidden

;======================================================================
; PROPERTIES
;======================================================================
Group ModuleDependencies
    LZP:Looting:UnlockHelperScript Property UnlockHelper Auto Const     ; Added UnlockHelper dependency
    LZP:Looting:LootFilterScript Property LootFilter Auto Const         ; Added LootFilter dependency
    LZP:Looting:LootTransferScript Property LootTransfer Auto Const     ; Added LootTransfer dependency
    LZP:Debug:LoggerScript Property Logger Auto Const                   ; Added Logger dependency
EndGroup

Group LootTypeToggles
    Bool Property bLootDeadActor = True Auto Const                      ; Added bLootDeadActor property
    Bool Property bLootContainer = True Auto Const                      ; Added bLootContainer property
    Bool Property bLootActivator = True Auto Const                      ; Added bLootActivator property
EndGroup

Group Globals
    GlobalVariable Property LPSystemUtil_LoopCap Auto Const             ; Added LPSystemUtil_LoopCap property
    Keyword Property LPKeyword_LootedCorpse Auto Const                  ; Added LPKeyword_LootedCorpse property
    Armor Property LP_Skin_Naked_NOTPLAYABLE Auto Const                 ; Added LP_Skin_Naked_NOTPLAYABLE property
    Race Property HumanRace Auto Const                                  ; Added HumanRace property
EndGroup

;======================================================================
; FUNCTIONS
;======================================================================
Function ProcessTargets(ObjectReference[] lootTargets, ObjectReference looterRef, FormList activeList)
    If lootTargets == None || lootTargets.Length == 0
        If Logger && Logger.IsEnabled()
            Logger.Log("LootProcessor: No loot targets passed in.")
        EndIf
        Return
    EndIf

    Int i = 0
    Int cap = LPSystemUtil_LoopCap.GetValueInt()

    While i < lootTargets.Length && i < cap
        ObjectReference target = lootTargets[i]

        If target
            If IsCorpse(target) && bLootDeadActor
                Logger.Log("LootProcessor: Handling corpse -> " + target)
                HandleCorpse(target, looterRef, activeList)
            ElseIf target.IsLocked()
                Logger.Log("LootProcessor: Locked target detected -> " + target)
                UnlockHelper.TryUnlock(target)
            ElseIf IsContainer(target) && bLootContainer
                Logger.Log("LootProcessor: Handling container -> " + target)
                HandleContainer(target, looterRef, activeList)
            ElseIf IsActivator(target) && bLootActivator
                Logger.Log("LootProcessor: Handling activator -> " + target)
                HandleActivator(target, looterRef)
            Else
                Logger.Log("LootProcessor: Unknown or unsupported target -> " + target)
            EndIf
        Else
            Logger.Log("LootProcessor: Null target skipped at index " + i)
        EndIf
        i += 1
    EndWhile
EndFunction

Function HandleCorpse(ObjectReference corpseRef, ObjectReference looterRef, FormList activeList)
    Actor corpse = corpseRef as Actor
    If corpse == None || !corpse.IsDead()
        Logger.Log("LootProcessor: Invalid or alive actor skipped -> " + corpseRef)
        Return
    EndIf

    If corpse.HasKeyword(LPKeyword_LootedCorpse)
        Logger.Log("LootProcessor: Corpse already looted -> " + corpseRef)
        Return
    EndIf

    If corpse.GetRace() == HumanRace
        Logger.Log("LootProcessor: Stripping humanoid corpse -> " + corpseRef)
        corpse.UnequipAll()
        corpse.EquipItem(LP_Skin_Naked_NOTPLAYABLE, False, False)
    Else
        Logger.Log("LootProcessor: Non-human corpse -> " + corpseRef)
    EndIf

    ProcessFormListLoot(corpseRef, activeList)
    corpseRef.AddKeyword(LPKeyword_LootedCorpse)
    Logger.Log("LootProcessor: Corpse marked and looted -> " + corpseRef)
EndFunction

Function HandleContainer(ObjectReference containerRef, ObjectReference looterRef, FormList activeList)
    ProcessFormListLoot(containerRef, activeList)
    Logger.Log("LootProcessor: Container looted -> " + containerRef)
EndFunction

Function HandleActivator(ObjectReference activatorRef, ObjectReference looterRef)
    activatorRef.Activate(looterRef, False)
    Logger.Log("LootProcessor: Activator triggered -> " + activatorRef)
EndFunction

Function ProcessFormListLoot(ObjectReference lootRef, FormList activeList)
    If activeList == None
        Logger.Log("LootProcessor: FormList is None; cannot loot -> " + lootRef)
        Return
    EndIf

    Int count = activeList.GetSize()
    Int i = 0
    Int transferred = 0
    Int skipped = 0

    While i < count
        Form itemForm = activeList.GetAt(i)
        If itemForm
            Int qty = lootRef.GetItemCount(itemForm)
            If qty > 0
                If LootFilter.ShouldLoot(itemForm)
                    LootTransfer.TransferItem(itemForm, qty, lootRef)
                    Logger.Log("LootProcessor: Transferred " + qty + " of " + itemForm + " from " + lootRef)
                    transferred += qty
                Else
                    Logger.Log("LootProcessor: Item filtered -> " + itemForm)
                    skipped += qty
                EndIf
            EndIf
        EndIf
        i += 1
    EndWhile

    Logger.Log("LootProcessor: Transfer Summary | Total: " + transferred + ", Skipped: " + skipped)
EndFunction

Bool Function IsCorpse(ObjectReference ref)
    Actor a = ref as Actor
    Return a != None
EndFunction

Bool Function IsContainer(ObjectReference ref)
    Container c = ref.GetBaseObject() as Container
    Return c != None
EndFunction

Bool Function IsActivator(ObjectReference ref)
    Activator a = ref.GetBaseObject() as Activator
    Return a != None
EndFunction
