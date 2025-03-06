ScriptName LZP:SystemScript Extends ScriptObject

GlobalVariable Property LPSystem_Debug Auto Const

Function InitializeDebug()
    LPSystem_Debug = Game.GetFormFromFile(0x00000A58, "LazyPanda.esm") as GlobalVariable
EndFunction

Function Log(String logMsg)
    If LPSystem_Debug.GetValue() as Bool
        Debug.Trace(logMsg, 0)
    EndIf
EndFunction

Function ShowMsg(Message msgToShow)
    msgToShow.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction

Function GetPlayerShip() Global spaceshipreference
    Quest SQ_PlayerShip = Game.GetForm(0x000174A2) as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    spaceshipreference PlayerShip = PlayerHomeShip.GetRef() as spaceshipreference
    Log("GetPlayerShip: Obtained PlayerShip reference: " + PlayerShip as String)
    Return PlayerShip
EndFunction

Function OpenHoldingInventory() Global
    Log("[Lazy Panda] OpenHoldingInventory called")
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x000009C1, "LazyPanda.esm") as ObjectReference
    (LPDummyHoldingRef as Actor).OpenInventory(True, None, False)
EndFunction

Function OpenLodgeSafe() Global
    Log("[Lazy Panda] OpenLodgeSafe called")
    ObjectReference LodgeSafeRef = Game.GetForm(0x00266E81) as ObjectReference
    LodgeSafeRef.Activate(Game.GetPlayer() as ObjectReference, False)
EndFunction

Function OpenShipCargo() Global
    Log("[Lazy Panda] OpenShipCargo called")
    spaceshipreference PlayerShip = GetPlayerShip()
    ; Custom logic to open the inventory
    Debug.Trace("Opening inventory for: " + PlayerShip as String, 0)
EndFunction

Function MoveAllToShip() Global
    Log("[Lazy Panda] MoveAllToShip called")
    Message LPAllItemsToShipMsg = Game.GetFormFromFile(0x0000091D, "LazyPanda.esm") as Message
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x000009C1, "LazyPanda.esm") as ObjectReference
    spaceshipreference PlayerShip = GetPlayerShip()
    LPDummyHoldingRef.RemoveAllItems(PlayerShip, False, False)
    ShowMsg(LPAllItemsToShipMsg)
EndFunction

Function MoveResourcesToShip() Global
    Log("[Lazy Panda] MoveResourcesToShip called")
    Message LPResourcesToShipMsg = Game.GetFormFromFile(0x0000091E, "LazyPanda.esm") as Message
    FormList LPSystem_Script_Resources = Game.GetFormFromFile(0x000008C9, "LazyPanda.esm") as FormList
    spaceshipreference PlayerShip = GetPlayerShip()
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x000009C1, "LazyPanda.esm") as ObjectReference
    LPDummyHoldingRef.RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
    Game.GetPlayer().RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
    ShowMsg(LPResourcesToShipMsg)
EndFunction

Function MoveValuablesToPlayer() Global
    Log("[Lazy Panda] MoveValuablesToPlayer called")
    Message LPValuablesToPlayerMsg = Game.GetFormFromFile(0x0000091F, "LazyPanda.esm") as Message
    FormList LPSystem_Script_Valuables = Game.GetFormFromFile(0x000008CA, "LazyPanda.esm") as FormList
    spaceshipreference PlayerShip = GetPlayerShip()
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x000009C1, "LazyPanda.esm") as ObjectReference
    PlayerShip.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference)
    LPDummyHoldingRef.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference)
    ShowMsg(LPValuablesToPlayerMsg)
EndFunction

Function MoveInventoryToLodgeSafe() Global
    Log("[Lazy Panda] MoveInventoryToLodgeSafe called")
    Message LPAllItemsToLodgeMsg = Game.GetFormFromFile(0x0000091C, "LazyPanda.esm") as Message
    Message LPNoItemsMsg = Game.GetFormFromFile(0x00000920, "LazyPanda.esm") as Message
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x000009C1, "LazyPanda.esm") as ObjectReference
    ObjectReference LodgeSafeRef = Game.GetForm(0x00266E81) as ObjectReference
    If LPDummyHoldingRef.GetItemCount(None) > 0
        LPDummyHoldingRef.RemoveAllItems(LodgeSafeRef, False, False)
        ShowMsg(LPAllItemsToLodgeMsg)
    Else
        ShowMsg(LPNoItemsMsg)
    EndIf
EndFunction

Function OpenTerminal() Global
    Log("[Lazy Panda] OpenTerminal called")
    ObjectReference LPDummyTerminalRef = Game.GetFormFromFile(0x000008CD, "LazyPanda.esm") as ObjectReference
    LPDummyTerminalRef.Activate(Game.GetPlayer() as ObjectReference, False)
EndFunction

Function ToggleLooting() Global
    Log("[Lazy Panda] ToggleLooting called")
    Message LPLootingEnabledMsg = Game.GetFormFromFile(0x0000097E, "LazyPanda.esm") as Message
    Message LPLootingDisabledMsg = Game.GetFormFromFile(0x0000097F, "LazyPanda.esm") as Message
    GlobalVariable LPSystemUtil_ToggleLooting = Game.GetFormFromFile(0x0000086A, "LazyPanda.esm") as GlobalVariable
    Int currentToggle = LPSystemUtil_ToggleLooting.GetValue() as Int
    If currentToggle == 0
        LPSystemUtil_ToggleLooting.SetValue(1.0)
        ShowMsg(LPLootingEnabledMsg)
    ElseIf currentToggle == 1
        LPSystemUtil_ToggleLooting.SetValue(0.0)
        ShowMsg(LPLootingDisabledMsg)
    EndIf
EndFunction

Function ReportStatus() Global
    Log("[Lazy Panda] ReportStatus called")
    FormList LPSystem_Script_Perks = Game.GetFormFromFile(0x000008C8, "LazyPanda.esm") as FormList
    Int perkCount = LPSystem_Script_Perks.GetSize()
    Log("[Lazy Panda] Reporting Perks:")
    Int I = 0
    While I < perkCount
        Perk currentPerk = LPSystem_Script_Perks.GetAt(I) as Perk
        If currentPerk
            Bool hasPerk = Game.GetPlayer().hasPerk(currentPerk)
            If hasPerk
                Log("[Lazy Panda] Perk: " + currentPerk as String + " - Enabled: " + hasPerk as String)
            Else
                Log("[Lazy Panda] Perk: " + currentPerk as String + " - Disabled")
            EndIf
        EndIf
        I += 1
    EndWhile
    FormList LPSystem_Debug_MagicEffects = Game.GetFormFromFile(0x0000081E, "LazyPanda.esm") as FormList
    Int magicEffectCount = LPSystem_Debug_MagicEffects.GetSize()
    Log("[Lazy Panda] Reporting Magic Effects:")
    Int j = 0
    While j < magicEffectCount
        MagicEffect currentMagicEffect = LPSystem_Debug_MagicEffects.GetAt(j) as MagicEffect
        If currentMagicEffect
            Bool hasMagicEffect = Game.GetPlayer().hasMagicEffect(currentMagicEffect)
            If hasMagicEffect
                Log("[Lazy Panda] Magic Effect: " + currentMagicEffect as String + " - Enabled: " + hasMagicEffect as String)
            Else
                Log("[Lazy Panda] Magic Effect: " + currentMagicEffect as String + " - Disabled")
            EndIf
        EndIf
        j += 1
    EndWhile
    FormList LPSystem_Loot_Globals = Game.GetFormFromFile(0x000008B9, "LazyPanda.esm") as FormList
    Int globalCount = LPSystem_Loot_Globals.GetSize()
    Log("[Lazy Panda] Reporting Globals:")
    Int k = 0
    While k < globalCount
        GlobalVariable currentGlobal = LPSystem_Loot_Globals.GetAt(k) as GlobalVariable
        If currentGlobal
            Log("[Lazy Panda] Global: " + currentGlobal as String + " - Value: " + currentGlobal.GetValue() as String)
        EndIf
        k += 1
    EndWhile
EndFunction

Event OnInit()
    InitializeDebug()
    Log("[Lazy Panda] SystemScript OnInit triggered")
    ReportStatus()
EndEvent