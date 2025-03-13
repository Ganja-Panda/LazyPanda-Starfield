ScriptName LZP:SystemScript Extends ScriptObject

;-- Functions ---------------------------------------

Function DebugLog(String logMsg) Global
  GlobalVariable LPSystemUtil_Debug = Game.GetFormFromFile(2748, "LazyPanda.esm") as GlobalVariable
  If LPSystemUtil_Debug.GetValue() as Bool
    Debug.Trace(logMsg, 0)
  EndIf
EndFunction

Function OpenHoldingInventory() Global
  LZP:SystemScript.DebugLog("[Lazy Panda] OpenHoldingInventory called")
  ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(2497, "LazyPanda.esm") as ObjectReference
  (LPDummyHoldingRef as Actor).OpenInventory(True, None, False)
EndFunction

Function OpenLodgeSafe() Global
  LZP:SystemScript.DebugLog("[Lazy Panda] OpenLodgeSafe called")
  ObjectReference LodgeSafeRef = Game.GetForm(158113) as ObjectReference
  LodgeSafeRef.Activate(Game.GetPlayer() as ObjectReference, False)
EndFunction

Function OpenShipCargo() Global
  LZP:SystemScript.DebugLog("[Lazy Panda] OpenShipCargo called")
  Quest SQ_PlayerShip = Game.GetForm(95314) as Quest
  ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
  spaceshipreference PlayerShip = PlayerHomeShip.GetRef() as spaceshipreference
  PlayerShip.OpenInventory()
EndFunction

Function MoveAllToShip() Global
  LZP:SystemScript.DebugLog("[Lazy Panda] MoveAllToShip called")
  Message LPAllItemsToShipMsg = Game.GetFormFromFile(2333, "LazyPanda.esm") as Message
  ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(2497, "LazyPanda.esm") as ObjectReference
  Quest SQ_PlayerShip = Game.GetForm(95314) as Quest
  ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
  ObjectReference PlayerShip = PlayerHomeShip.GetRef()
  LPDummyHoldingRef.RemoveAllItems(PlayerShip, False, False)
  LPAllItemsToShipMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction

Function MoveResourcesToShip() Global
  LZP:SystemScript.DebugLog("[Lazy Panda] MoveResourcesToShip called")
  Message LPResourcesToShipMsg = Game.GetFormFromFile(2334, "LazyPanda.esm") as Message
  FormList LPSystem_Script_Resources = Game.GetFormFromFile(2249, "LazyPanda.esm") as FormList
  Quest SQ_PlayerShip = Game.GetForm(95314) as Quest
  ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
  ObjectReference PlayerShip = PlayerHomeShip.GetRef()
  ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(2497, "LazyPanda.esm") as ObjectReference
  LPDummyHoldingRef.RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
  Game.GetPlayer().RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
  LPResourcesToShipMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction

Function MoveValuablesToPlayer() Global
  LZP:SystemScript.DebugLog("[Lazy Panda] MoveValuablesToPlayer called")
  Message LPValuablesToPlayerMsg = Game.GetFormFromFile(2335, "LazyPanda.esm") as Message
  FormList LPSystem_Script_Valuables = Game.GetFormFromFile(2250, "LazyPanda.esm") as FormList
  Quest SQ_PlayerShip = Game.GetForm(95314) as Quest
  ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
  ObjectReference PlayerShip = PlayerHomeShip.GetRef()
  ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(2497, "LazyPanda.esm") as ObjectReference
  PlayerShip.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference)
  LPDummyHoldingRef.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference)
  LPValuablesToPlayerMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction

Function ReportStatus() Global
  GlobalVariable LPSystemUtil_Debug = Game.GetFormFromFile(2748, "LazyPanda.esm") as GlobalVariable
  LZP:SystemScript.DebugLog("[Lazy Panda] ReportStatus called")
  FormList LPSystem_Script_Perks = Game.GetFormFromFile(2248, "LazyPanda.esm") as FormList
  Int perkCount = LPSystem_Script_Perks.GetSize()
  LZP:SystemScript.DebugLog("[Lazy Panda] Reporting Perks:")
  Int I = 0
  While I < perkCount
    Perk currentPerk = LPSystem_Script_Perks.GetAt(I) as Perk
    If currentPerk
      Bool hasPerk = Game.GetPlayer().hasPerk(currentPerk)
      If hasPerk
        LZP:SystemScript.DebugLog(("[Lazy Panda] Perk: " + currentPerk as String) + " - Enabled: " + hasPerk as String)
      Else
        LZP:SystemScript.DebugLog(("[Lazy Panda] Perk: " + currentPerk as String) + " - Disabled")
      EndIf
    EndIf
    I += 1
  EndWhile
  FormList LPSystemUtil_Debug_MagicEffects = Game.GetFormFromFile(2273, "LazyPanda.esm") as FormList
  Int magicEffectCount = LPSystemUtil_Debug_MagicEffects.GetSize()
  LZP:SystemScript.DebugLog("[Lazy Panda] Reporting Magic Effects:")
  Int j = 0
  While j < magicEffectCount
    MagicEffect currentMagicEffect = LPSystemUtil_Debug_MagicEffects.GetAt(j) as MagicEffect
    If currentMagicEffect
      Bool hasMagicEffect = Game.GetPlayer().hasMagicEffect(currentMagicEffect)
      If hasMagicEffect
        LZP:SystemScript.DebugLog(("[Lazy Panda] Magic Effect: " + currentMagicEffect as String) + " - Enabled: " + hasMagicEffect as String)
      Else
        LZP:SystemScript.DebugLog(("[Lazy Panda] Magic Effect: " + currentMagicEffect as String) + " - Disabled")
      EndIf
    EndIf
    j += 1
  EndWhile
  FormList LPSystem_Loot_Globals = Game.GetFormFromFile(2233, "LazyPanda.esm") as FormList
  Int globalCount = LPSystem_Loot_Globals.GetSize()
  LZP:SystemScript.DebugLog("[Lazy Panda] Reporting Globals:")
  Int k = 0
  While k < globalCount
    GlobalVariable currentGlobal = LPSystem_Loot_Globals.GetAt(k) as GlobalVariable
    If currentGlobal
      LZP:SystemScript.DebugLog(("[Lazy Panda] Global: " + currentGlobal as String) + " - Value: " + currentGlobal.GetValue() as String)
    EndIf
    k += 1
  EndWhile
EndFunction
