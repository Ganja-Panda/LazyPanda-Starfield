ScriptName LZP:SystemScript Extends ScriptObject

;-- Functions ---------------------------------------

Function DebugLog(String logMsg) Global
  GlobalVariable LPSystemUtil_Debug = Game.GetFormFromFile(2748, "LazyPanda.esm") as GlobalVariable ; #DEBUG_LINE_NO:17
  If LPSystemUtil_Debug.GetValue() as Bool ; #DEBUG_LINE_NO:18
    Debug.Trace(logMsg, 0) ; #DEBUG_LINE_NO:19
  EndIf
EndFunction

Function OpenHoldingInventory() Global
  LZP:SystemScript.DebugLog("[Lazy Panda] OpenHoldingInventory called") ; #DEBUG_LINE_NO:30
  ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(2497, "LazyPanda.esm") as ObjectReference ; #DEBUG_LINE_NO:31
  (LPDummyHoldingRef as Actor).OpenInventory(True, None, False) ; #DEBUG_LINE_NO:32
EndFunction

Function OpenLodgeSafe() Global
  LZP:SystemScript.DebugLog("[Lazy Panda] OpenLodgeSafe called") ; #DEBUG_LINE_NO:38
  ObjectReference LodgeSafeRef = Game.GetForm(158113) as ObjectReference ; #DEBUG_LINE_NO:39
  LodgeSafeRef.Activate(Game.GetPlayer() as ObjectReference, False) ; #DEBUG_LINE_NO:40
EndFunction

Function OpenShipCargo() Global
  LZP:SystemScript.DebugLog("[Lazy Panda] OpenShipCargo called") ; #DEBUG_LINE_NO:46
  Quest SQ_PlayerShip = Game.GetForm(95314) as Quest ; #DEBUG_LINE_NO:47
  ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias ; #DEBUG_LINE_NO:48
  spaceshipreference PlayerShip = PlayerHomeShip.GetRef() as spaceshipreference ; #DEBUG_LINE_NO:49
  PlayerShip.OpenInventory() ; #DEBUG_LINE_NO:50
EndFunction

Function MoveAllToShip() Global
  LZP:SystemScript.DebugLog("[Lazy Panda] MoveAllToShip called") ; #DEBUG_LINE_NO:56
  Message LPAllItemsToShipMsg = Game.GetFormFromFile(2333, "LazyPanda.esm") as Message ; #DEBUG_LINE_NO:57
  ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(2497, "LazyPanda.esm") as ObjectReference ; #DEBUG_LINE_NO:58
  Quest SQ_PlayerShip = Game.GetForm(95314) as Quest ; #DEBUG_LINE_NO:59
  ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias ; #DEBUG_LINE_NO:60
  ObjectReference PlayerShip = PlayerHomeShip.GetRef() ; #DEBUG_LINE_NO:61
  LPDummyHoldingRef.RemoveAllItems(PlayerShip, False, False) ; #DEBUG_LINE_NO:62
  LPAllItemsToShipMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:63
EndFunction

Function MoveResourcesToShip() Global
  LZP:SystemScript.DebugLog("[Lazy Panda] MoveResourcesToShip called") ; #DEBUG_LINE_NO:69
  Message LPResourcesToShipMsg = Game.GetFormFromFile(2334, "LazyPanda.esm") as Message ; #DEBUG_LINE_NO:70
  FormList LPSystem_Script_Resources = Game.GetFormFromFile(2249, "LazyPanda.esm") as FormList ; #DEBUG_LINE_NO:71
  Quest SQ_PlayerShip = Game.GetForm(95314) as Quest ; #DEBUG_LINE_NO:72
  ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias ; #DEBUG_LINE_NO:73
  ObjectReference PlayerShip = PlayerHomeShip.GetRef() ; #DEBUG_LINE_NO:74
  ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(2497, "LazyPanda.esm") as ObjectReference ; #DEBUG_LINE_NO:75
  LPDummyHoldingRef.RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip) ; #DEBUG_LINE_NO:76
  Game.GetPlayer().RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip) ; #DEBUG_LINE_NO:77
  LPResourcesToShipMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:78
EndFunction

Function MoveValuablesToPlayer() Global
  LZP:SystemScript.DebugLog("[Lazy Panda] MoveValuablesToPlayer called") ; #DEBUG_LINE_NO:84
  Message LPValuablesToPlayerMsg = Game.GetFormFromFile(2335, "LazyPanda.esm") as Message ; #DEBUG_LINE_NO:85
  FormList LPSystem_Script_Valuables = Game.GetFormFromFile(2250, "LazyPanda.esm") as FormList ; #DEBUG_LINE_NO:86
  Quest SQ_PlayerShip = Game.GetForm(95314) as Quest ; #DEBUG_LINE_NO:87
  ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias ; #DEBUG_LINE_NO:88
  ObjectReference PlayerShip = PlayerHomeShip.GetRef() ; #DEBUG_LINE_NO:89
  ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(2497, "LazyPanda.esm") as ObjectReference ; #DEBUG_LINE_NO:90
  PlayerShip.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference) ; #DEBUG_LINE_NO:91
  LPDummyHoldingRef.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference) ; #DEBUG_LINE_NO:92
  LPValuablesToPlayerMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:93
EndFunction

Function ReportStatus() Global
  GlobalVariable LPSystemUtil_Debug = Game.GetFormFromFile(2748, "LazyPanda.esm") as GlobalVariable ; #DEBUG_LINE_NO:99
  LZP:SystemScript.DebugLog("[Lazy Panda] ReportStatus called") ; #DEBUG_LINE_NO:100
  FormList LPSystem_Script_Perks = Game.GetFormFromFile(2248, "LazyPanda.esm") as FormList ; #DEBUG_LINE_NO:101
  Int perkCount = LPSystem_Script_Perks.GetSize() ; #DEBUG_LINE_NO:102
  LZP:SystemScript.DebugLog("[Lazy Panda] Reporting Perks:") ; #DEBUG_LINE_NO:103
  Int I = 0 ; #DEBUG_LINE_NO:104
  While I < perkCount ; #DEBUG_LINE_NO:105
    Perk currentPerk = LPSystem_Script_Perks.GetAt(I) as Perk ; #DEBUG_LINE_NO:106
    If currentPerk ; #DEBUG_LINE_NO:107
      Bool hasPerk = Game.GetPlayer().hasPerk(currentPerk) ; #DEBUG_LINE_NO:108
      If hasPerk ; #DEBUG_LINE_NO:109
        LZP:SystemScript.DebugLog(("[Lazy Panda] Perk: " + currentPerk as String) + " - Enabled: " + hasPerk as String) ; #DEBUG_LINE_NO:110
      Else
        LZP:SystemScript.DebugLog(("[Lazy Panda] Perk: " + currentPerk as String) + " - Disabled") ; #DEBUG_LINE_NO:112
      EndIf
    EndIf
    I += 1 ; #DEBUG_LINE_NO:115
  EndWhile
  FormList LPSystemUtil_Debug_MagicEffects = Game.GetFormFromFile(2273, "LazyPanda.esm") as FormList ; #DEBUG_LINE_NO:117
  Int magicEffectCount = LPSystemUtil_Debug_MagicEffects.GetSize() ; #DEBUG_LINE_NO:118
  LZP:SystemScript.DebugLog("[Lazy Panda] Reporting Magic Effects:") ; #DEBUG_LINE_NO:119
  Int j = 0 ; #DEBUG_LINE_NO:120
  While j < magicEffectCount ; #DEBUG_LINE_NO:121
    MagicEffect currentMagicEffect = LPSystemUtil_Debug_MagicEffects.GetAt(j) as MagicEffect ; #DEBUG_LINE_NO:122
    If currentMagicEffect ; #DEBUG_LINE_NO:123
      Bool hasMagicEffect = Game.GetPlayer().hasMagicEffect(currentMagicEffect) ; #DEBUG_LINE_NO:124
      If hasMagicEffect ; #DEBUG_LINE_NO:125
        LZP:SystemScript.DebugLog(("[Lazy Panda] Magic Effect: " + currentMagicEffect as String) + " - Enabled: " + hasMagicEffect as String) ; #DEBUG_LINE_NO:126
      Else
        LZP:SystemScript.DebugLog(("[Lazy Panda] Magic Effect: " + currentMagicEffect as String) + " - Disabled") ; #DEBUG_LINE_NO:128
      EndIf
    EndIf
    j += 1 ; #DEBUG_LINE_NO:131
  EndWhile
  FormList LPSystem_Loot_Globals = Game.GetFormFromFile(2233, "LazyPanda.esm") as FormList ; #DEBUG_LINE_NO:133
  Int globalCount = LPSystem_Loot_Globals.GetSize() ; #DEBUG_LINE_NO:134
  LZP:SystemScript.DebugLog("[Lazy Panda] Reporting Globals:") ; #DEBUG_LINE_NO:135
  Int k = 0 ; #DEBUG_LINE_NO:136
  While k < globalCount ; #DEBUG_LINE_NO:137
    GlobalVariable currentGlobal = LPSystem_Loot_Globals.GetAt(k) as GlobalVariable ; #DEBUG_LINE_NO:138
    If currentGlobal ; #DEBUG_LINE_NO:139
      LZP:SystemScript.DebugLog(("[Lazy Panda] Global: " + currentGlobal as String) + " - Value: " + currentGlobal.GetValue() as String) ; #DEBUG_LINE_NO:140
    EndIf
    k += 1 ; #DEBUG_LINE_NO:142
  EndWhile
EndFunction
