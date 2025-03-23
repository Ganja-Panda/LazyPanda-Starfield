;======================================================================
; Script Name   : LZP:Looting:LootProcessorScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Core logic to process lootable references and delegate
;                 by type: actors, containers, activators.
; Description   : Accepts a batch of loot targets and an active loot list.
;                 Handles transfer, unlocks, filtering, and corpse cleanup.
;======================================================================

ScriptName LZP:Looting:LootProcessorScript Extends Quest Hidden

;======================================================================
; PROPERTIES
;======================================================================

;-- Module Dependencies
Group ModuleDependencies
	LZP:Looting:UnlockHelperScript Property UnlockHelper Auto Const                ; Handles unlock logic for locked references
	LZP:Looting:LootFilterScript Property LootFilter Auto Const                    ; Evaluates if an item should be looted
	LZP:Looting:LootTransferScript Property LootTransfer Auto Const                ; Transfers items from source to player/container
	LZP:Debug:LoggerScript Property Logger Auto Const                              ; Logs all loot activity if enabled
EndGroup

;-- System Configuration
Group LootingConfig
	Keyword Property LPKeyword_LootedCorpse Auto Const                             ; Tag used to mark already looted corpses
	Armor Property LP_Skin_Naked_NOTPLAYABLE Auto Const                            ; Skin to equip corpses after strip
	Race Property HumanRace Auto Const                                             ; Used to verify if the actor is human
	GlobalVariable Property LPSystemUtil_LoopCap Auto Const                        ; Loop cap safety limit
EndGroup

;======================================================================
; FUNCTIONS
;======================================================================

;======================================================================
; FUNCTION: ProcessTargets
; Purpose : Iterates loot targets and handles each by type
; Params  : lootTargets - list of nearby references
;         : looterRef   - reference to looter (usually player)
;         : activeList  - FormList of allowed item forms
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

		If target != None
			If IsCorpse(target)
				Logger.Log("LootProcessor: Handling corpse -> " + target)
				HandleCorpse(target, looterRef, activeList)
			ElseIf target.IsLocked()
				Logger.Log("LootProcessor: Locked target detected -> " + target)
				UnlockHelper.TryUnlock(target)
			ElseIf IsContainer(target)
				Logger.Log("LootProcessor: Handling container -> " + target)
				HandleContainer(target, looterRef, activeList)
			ElseIf IsActivator(target)
				Logger.Log("LootProcessor: Handling activator -> " + target)
				HandleActivator(target, looterRef)
			Else
				Logger.Log("LootProcessor: Unknown type or unsupported ref -> " + target)
			EndIf
		Else
			Logger.Log("LootProcessor: Null target skipped at index " + i)
		EndIf

		i += 1
	EndWhile
EndFunction

;======================================================================
; FUNCTION: HandleCorpse
; Purpose : Strips a human corpse and transfers filtered items
;======================================================================
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

;======================================================================
; FUNCTION: HandleContainer
; Purpose : Transfers filtered items from containers
;======================================================================
Function HandleContainer(ObjectReference containerRef, ObjectReference looterRef, FormList activeList)
	ProcessFormListLoot(containerRef, activeList)
	Logger.Log("LootProcessor: Container looted -> " + containerRef)
EndFunction

;======================================================================
; FUNCTION: HandleActivator
; Purpose : Activates references like terminals or machines
;======================================================================
Function HandleActivator(ObjectReference activatorRef, ObjectReference looterRef)
	activatorRef.Activate(looterRef, False)
	Logger.Log("LootProcessor: Activator triggered -> " + activatorRef)
EndFunction

;======================================================================
; FUNCTION: ProcessFormListLoot
; Purpose : Loops through FormList and pulls matching items
;======================================================================
Function ProcessFormListLoot(ObjectReference lootRef, FormList activeList)
	If activeList == None
		Logger.Log("LootProcessor: FormList is None; cannot loot -> " + lootRef)
		Return
	EndIf

	Int count = activeList.GetSize()
	Int i = 0
	While i < count
		Form itemForm = activeList.GetAt(i)
		If itemForm
			Int qty = lootRef.GetItemCount(itemForm)
			If qty > 0
				If LootFilter.ShouldLoot(itemForm)
					Logger.Log("LootProcessor: Transferring " + qty + " of " + itemForm + " from " + lootRef)
					LootTransfer.TransferItem(itemForm, qty, lootRef)
				Else
					Logger.Log("LootProcessor: Item filtered -> " + itemForm)
				EndIf
			EndIf
		EndIf
		i += 1
	EndWhile
EndFunction

;======================================================================
; FUNCTION: IsCorpse
; Purpose : Returns true if reference is an Actor
;======================================================================
Bool Function IsCorpse(ObjectReference ref)
	Actor a = ref as Actor
	Return a != None
EndFunction

;======================================================================
; FUNCTION: IsContainer
; Purpose : Returns true if base object is a container
;======================================================================
Bool Function IsContainer(ObjectReference ref)
	Container c = ref.GetBaseObject() as Container
	Return c != None
EndFunction

;======================================================================
; FUNCTION: IsActivator
; Purpose : Returns true if base object is an activator
;======================================================================
Bool Function IsActivator(ObjectReference ref)
	Activator a = ref.GetBaseObject() as Activator
	Return a != None
EndFunction
