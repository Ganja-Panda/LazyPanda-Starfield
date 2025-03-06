ScriptName LZP:SystemScript Extends ScriptObject

;-- Functions ---------------------------------------

Function ReportStatus() Global
    Debug.Trace("[Lazy Panda] ReportStatus called", 0)
    
    ; Report Perks
    FormList perksList = Game.GetFormFromFile(0x8C8, "LazyPanda.esm") as FormList
    Debug.Trace("[Lazy Panda] Reporting Perks:", 0)
    ReportFormList(perksList, "Perk", "hasPerk")
    
    ; Report Magic Effects
    FormList magicEffectsList = Game.GetFormFromFile(0x81E, "LazyPanda.esm") as FormList
    Debug.Trace("[Lazy Panda] Reporting Magic Effects:", 0)
    ReportFormList(magicEffectsList, "Magic Effect", "hasMagicEffect")
    
    ; Report Globals
    FormList globalsList = Game.GetFormFromFile(0x8B9, "LazyPanda.esm") as FormList
    Debug.Trace("[Lazy Panda] Reporting Globals:", 0)
    ReportFormList(globalsList, "Global", "GetValue")
EndFunction

Function ReportFormList(FormList list, String itemType, String checkFunction) Global
    Int itemCount = list.GetSize()
    Int index = 0
    While index < itemCount
        Form currentItem = list.GetAt(index)
        If currentItem
            Bool hasItem = False
            If checkFunction == "hasPerk"
                hasItem = Game.GetPlayer().hasPerk(currentItem as Perk)
            ElseIf checkFunction == "hasMagicEffect"
                hasItem = Game.GetPlayer().hasMagicEffect(currentItem as MagicEffect)
            ElseIf checkFunction == "GetValue"
                hasItem = (currentItem as GlobalVariable).GetValue() != 0.0
            EndIf
            Debug.Trace(("[Lazy Panda] " + itemType + ": " + currentItem as String) + " - Enabled: " + hasItem as String, 0)
            If !hasItem
                Debug.Trace("[Lazy Panda] WARNING: Player does not have " + itemType + ": " + currentItem as String, 1)
            EndIf
        EndIf
        index += 1
    EndWhile
EndFunction

;-- Other functions ---------------------------------

Function OpenHoldingInventory() Global
    Debug.Trace("[Lazy Panda] OpenHoldingInventory called", 0)
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x9C1, "LazyPanda.esm") as ObjectReference
    (LPDummyHoldingRef as Actor).OpenInventory(True, None, False)
EndFunction

Function OpenLodgeSafe() Global
    Debug.Trace("[Lazy Panda] OpenLodgeSafe called", 0)
    ObjectReference LodgeSafeRef = Game.GetFormFromFile(0x266E81, "LazyPanda.esm") as ObjectReference
    LodgeSafeRef.Activate(Game.GetPlayer() as ObjectReference, False)
EndFunction

Function OpenShipCargo() Global
    Debug.Trace("[Lazy Panda] OpenShipCargo called", 0)
    Quest SQ_PlayerShip = Game.GetFormFromFile(0x174A2, "LazyPanda.esm") as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    spaceshipreference PlayerShip = PlayerHomeShip.GetRef() as spaceshipreference
    PlayerShip.OpenInventory()
EndFunction

Function MoveAllToShip() Global
    Debug.Trace("[Lazy Panda] MoveAllToShip called", 0)
    Message LPAllItemsToShipMsg = Game.GetFormFromFile(2333, "LazyPanda.esm") as Message
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(2497, "LazyPanda.esm") as ObjectReference
    Quest SQ_PlayerShip = Game.GetForm(95394) as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    ObjectReference PlayerShip = PlayerHomeShip.GetRef()
    LPDummyHoldingRef.RemoveAllItems(PlayerShip, False, False)
    LPAllItemsToShipMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction

Function MoveResourcesToShip() Global
    Debug.Trace("[Lazy Panda] MoveResourcesToShip called", 0)
    Message LPResourcesToShipMsg = Game.GetFormFromFile(2334, "LazyPanda.esm") as Message
    FormList LPSystem_Script_Resources = Game.GetFormFromFile(2249, "LazyPanda.esm") as FormList
    Quest SQ_PlayerShip = Game.GetForm(95394) as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    ObjectReference PlayerShip = PlayerHomeShip.GetRef()
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(2497, "LazyPanda.esm") as ObjectReference
    LPDummyHoldingRef.RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
    Game.GetPlayer().RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
    LPResourcesToShipMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction

Function MoveValuablesToPlayer() Global
    Debug.Trace("[Lazy Panda] MoveValuablesToPlayer called", 0)
    Message LPValuablesToPlayerMsg = Game.GetFormFromFile(2335, "LazyPanda.esm") as Message
    FormList LPSystem_Script_Valuables = Game.GetFormFromFile(2250, "LazyPanda.esm") as FormList
    Quest SQ_PlayerShip = Game.GetForm(95394) as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    ObjectReference PlayerShip = PlayerHomeShip.GetRef()
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(2497, "LazyPanda.esm") as ObjectReference
    PlayerShip.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference)
    LPDummyHoldingRef.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference)
    LPValuablesToPlayerMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction

Function MoveInventoryToLodgeSafe() Global
    Debug.Trace("[Lazy Panda] MoveInventoryToLodgeSafe called", 0)
    Message LPAllItemsToLodgeMsg = Game.GetFormFromFile(2332, "LazyPanda.esm") as Message
    Message LPNoItemsMsg = Game.GetFormFromFile(2336, "LazyPanda.esm") as Message
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(2497, "LazyPanda.esm") as ObjectReference
    ObjectReference LodgeSafeRef = Game.GetFormFromFile(0x266E81, "LazyPanda.esm") as ObjectReference
    If LPDummyHoldingRef.GetItemCount(None) > 0
        LPDummyHoldingRef.RemoveAllItems(LodgeSafeRef, False, False)
        LPAllItemsToLodgeMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    Else
        LPNoItemsMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    EndIf
EndFunction

Function OpenTerminal() Global
    Debug.Trace("[Lazy Panda] OpenTerminal called", 0)
    ObjectReference LPDummyTerminalRef = Game.GetFormFromFile(2253, "LazyPanda.esm") as ObjectReference
    LPDummyTerminalRef.Activate(Game.GetPlayer() as ObjectReference, False)
EndFunction

Function ToggleLooting() Global
    Debug.Trace("[Lazy Panda] ToggleLooting called", 0)
    Message LPLootingEnabledMsg = Game.GetFormFromFile(2430, "LazyPanda.esm") as Message
    Message LPLootingDisabledMsg = Game.GetFormFromFile(2431, "LazyPanda.esm") as Message
    GlobalVariable LPSystemUtil_ToggleLooting = Game.GetFormFromFile(2154, "LazyPanda.esm") as GlobalVariable
    Int currentToggle = LPSystemUtil_ToggleLooting.GetValue() as Int
    If currentToggle == 0
        LPSystemUtil_ToggleLooting.SetValue(1.0)
        LPLootingEnabledMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    ElseIf currentToggle == 1
        LPSystemUtil_ToggleLooting.SetValue(0.0)
        LPLootingDisabledMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    EndIf
EndFunction
