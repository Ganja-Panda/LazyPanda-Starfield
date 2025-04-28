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
    GlobalVariable Property LZP_System_LoopCap Auto Const             ; Added LPSystemUtil_LoopCap property
    Keyword Property LZP_KYWD_LootedCorpse Auto Const                  ; Added LPKeyword_LootedCorpse property
    Armor Property LZP_Armor_Naked_NOTPLAYABLE Auto Const                 ; Added LP_Skin_Naked_NOTPLAYABLE property
    Race Property HumanRace Auto Const                                  ; Added HumanRace property
EndGroup

;======================================================================
; FUNCTIONS
;======================================================================
Function ProcessTargets(ObjectReference[] lootTargets, ObjectReference looterRef, FormList activeList)
    If lootTargets == None || lootTargets.Length == 0
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("LootProcessor: No loot targets passed in.", 1, "LootProcessorScript")
        EndIf
        Return
    EndIf

    Int i = 0
    Int cap = LZP_System_LoopCap.GetValueInt()

    While i < lootTargets.Length && i < cap
        ObjectReference target = lootTargets[i]

        If target
            If IsCorpse(target) && bLootDeadActor
                Logger.LogAdv("LootProcessor: Handling corpse -> " + target, 1, "LootProcessorScript")
                HandleCorpse(target, looterRef, activeList)
            ElseIf target.IsLocked()
                Logger.LogAdv("LootProcessor: Locked target detected -> " + target, 2, "LootProcessorScript")
                UnlockHelper.TryUnlock(target)
            ElseIf IsContainer(target) && bLootContainer
                Logger.LogAdv("LootProcessor: Handling container -> " + target, 1, "LootProcessorScript")
                HandleContainer(target, looterRef, activeList)
            ElseIf IsActivator(target) && bLootActivator
                Logger.LogAdv("LootProcessor: Handling activator -> " + target, 1, "LootProcessorScript")
                HandleActivator(target, looterRef)
            Else
                Logger.LogAdv("LootProcessor: Unknown or unsupported target -> " + target, 2, "LootProcessorScript")
            EndIf
        Else
            Logger.LogAdv("LootProcessor: Null target skipped at index " + i, 2, "LootProcessorScript")
        EndIf
        i += 1
    EndWhile
EndFunction

Function HandleCorpse(ObjectReference corpseRef, ObjectReference looterRef, FormList activeList)
    Actor corpse = corpseRef as Actor
    If corpse == None || !corpse.IsDead()
        Logger.LogAdv("LootProcessor: Invalid or alive actor skipped -> " + corpseRef, 2, "LootProcessorScript")
        Return
    EndIf

    If corpse.HasKeyword(LZP_KYWD_LootedCorpse)
        Logger.LogAdv("LootProcessor: Corpse already looted -> " + corpseRef, 2, "LootProcessorScript")
        Return
    EndIf

    If corpse.GetRace() == HumanRace
        Logger.LogAdv("LootProcessor: Stripping humanoid corpse -> " + corpseRef, 1, "LootProcessorScript")
        corpse.UnequipAll()
        corpse.EquipItem(LZP_Armor_Naked_NOTPLAYABLE, False, False)
    Else
        Logger.LogAdv("LootProcessor: Non-human corpse -> " + corpseRef, 1, "LootProcessorScript")
    EndIf

    ProcessFormListLoot(corpseRef, activeList)
    corpseRef.AddKeyword(LZP_KYWD_LootedCorpse)
    Logger.LogAdv("LootProcessor: Corpse marked and looted -> " + corpseRef, 1, "LootProcessorScript")
EndFunction

Function HandleContainer(ObjectReference containerRef, ObjectReference looterRef, FormList activeList)
    ProcessFormListLoot(containerRef, activeList)
    Logger.LogAdv("LootProcessor: Container looted -> " + containerRef, 1, "LootProcessorScript")
EndFunction

Function HandleActivator(ObjectReference activatorRef, ObjectReference looterRef)
    activatorRef.Activate(looterRef, False)
    Logger.LogAdv("LootProcessor: Activator triggered -> " + activatorRef, 1, "LootProcessorScript")
EndFunction

Function ProcessFormListLoot(ObjectReference lootRef, FormList activeList)
    If activeList == None
        Logger.LogAdv("LootProcessor: FormList is None; cannot loot -> " + lootRef, 2, "LootProcessorScript")
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
                    Logger.LogAdv("LootProcessor: Transferred " + qty + " of " + itemForm + " from " + lootRef, 1, "LootProcessorScript")
                    transferred += qty
                Else
                    Logger.LogAdv("LootProcessor: Item filtered -> " + itemForm, 2, "LootProcessorScript")
                    skipped += qty
                EndIf
            EndIf
        EndIf
        i += 1
    EndWhile

    Logger.LogAdv("LootProcessor: Transfer Summary | Total: " + transferred + ", Skipped: " + skipped, 1, "LootProcessorScript")
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
