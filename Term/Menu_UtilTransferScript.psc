ScriptName LZP:Term:Menu_UtilTransferScript Extends TerminalMenu hidden

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
Group Menu_UtilTransferProperties
  TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
  ObjectReference Property LodgeSafeRef Auto Const mandatory
  ObjectReference Property LPDummyHoldingRef Auto Const mandatory
  ObjectReference Property PlayerRef Auto Const mandatory
  ReferenceAlias Property PlayerHomeShip Auto Const mandatory
  FormList Property LPSystem_Script_Resources Auto Const mandatory
  FormList Property LPSystem_Script_Valuables Auto Const mandatory
  Message Property LPAllItemsToLodgeMsg Auto Const mandatory
  Message Property LPAllItemsToShipMsg Auto Const mandatory
  Message Property LPResourcesToShipMsg Auto Const mandatory
  Message Property LPValuablesToPlayerMsg Auto Const mandatory
  Message Property LPNoItemsMsg Auto Const mandatory
  GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory
EndGroup


;-- Functions ---------------------------------------

Function Log(String logMsg)
  If LPSystemUtil_Debug.GetValue() as Bool ; #DEBUG_LINE_NO:39
    Debug.Trace("[LZP:UtilTransfer] " + logMsg, 0) ; #DEBUG_LINE_NO:40
  EndIf
EndFunction

Function ShowMsg(Message msgToShow)
  msgToShow.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:47
EndFunction

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Self.Log("OnTerminalMenuEnter triggered") ; #DEBUG_LINE_NO:57
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  If akTerminalBase != CurrentTerminalMenu ; #DEBUG_LINE_NO:63
    Return  ; #DEBUG_LINE_NO:64
  EndIf
  Self.Log("Terminal menu matches CurrentTerminalMenu") ; #DEBUG_LINE_NO:67
  If auiMenuItemID == 0 ; #DEBUG_LINE_NO:68
    Self.Log("Menu item 0 selected: MoveAllToShip") ; #DEBUG_LINE_NO:69
    Self.MoveAllToShip() ; #DEBUG_LINE_NO:70
  ElseIf auiMenuItemID == 1 ; #DEBUG_LINE_NO:71
    Self.Log("Menu item 1 selected: MoveResourcesToShip") ; #DEBUG_LINE_NO:72
    Self.MoveResourcesToShip() ; #DEBUG_LINE_NO:73
  ElseIf auiMenuItemID == 2 ; #DEBUG_LINE_NO:74
    Self.Log("Menu item 2 selected: MoveInventoryToLodgeSafe") ; #DEBUG_LINE_NO:75
    Self.MoveInventoryToLodgeSafe() ; #DEBUG_LINE_NO:76
  ElseIf auiMenuItemID == 3 ; #DEBUG_LINE_NO:77
    Self.Log("Menu item 3 selected: MoveValuablesToPlayer") ; #DEBUG_LINE_NO:78
    Self.MoveValuablesToPlayer() ; #DEBUG_LINE_NO:79
  Else
    Self.Log("Invalid menu item selected: " + auiMenuItemID as String) ; #DEBUG_LINE_NO:81
  EndIf
EndEvent

Function MoveAllToShip()
  Self.Log("MoveAllToShip called") ; #DEBUG_LINE_NO:92
  LPDummyHoldingRef.RemoveAllItems(PlayerHomeShip.GetRef(), False, False) ; #DEBUG_LINE_NO:93
  Self.ShowMsg(LPAllItemsToShipMsg) ; #DEBUG_LINE_NO:94
EndFunction

Function MoveResourcesToShip()
  Self.Log("MoveResourcesToShip called") ; #DEBUG_LINE_NO:100
  ObjectReference PlayerShip = PlayerHomeShip.GetRef() ; #DEBUG_LINE_NO:101
  If !PlayerShip ; #DEBUG_LINE_NO:102
    Self.Log("MoveResourcesToShip failed: No player ship reference") ; #DEBUG_LINE_NO:103
    Return  ; #DEBUG_LINE_NO:104
  EndIf
  If Game.GetPlayer().GetItemCount(LPSystem_Script_Resources as Form) > 0 ; #DEBUG_LINE_NO:107
    Game.GetPlayer().RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip) ; #DEBUG_LINE_NO:108
  EndIf
  If LPDummyHoldingRef.GetItemCount(LPSystem_Script_Resources as Form) > 0 ; #DEBUG_LINE_NO:110
    LPDummyHoldingRef.RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip) ; #DEBUG_LINE_NO:111
  EndIf
  Self.ShowMsg(LPResourcesToShipMsg) ; #DEBUG_LINE_NO:113
EndFunction

Function MoveValuablesToPlayer()
  Self.Log("MoveValuablesToPlayer called") ; #DEBUG_LINE_NO:119
  ObjectReference PlayerShip = PlayerHomeShip.GetRef() ; #DEBUG_LINE_NO:120
  If !PlayerShip ; #DEBUG_LINE_NO:121
    Self.Log("MoveValuablesToPlayer failed: No player ship reference") ; #DEBUG_LINE_NO:122
    Return  ; #DEBUG_LINE_NO:123
  EndIf
  PlayerShip.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference) ; #DEBUG_LINE_NO:126
  LPDummyHoldingRef.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference) ; #DEBUG_LINE_NO:127
  Self.ShowMsg(LPValuablesToPlayerMsg) ; #DEBUG_LINE_NO:128
EndFunction

Function MoveInventoryToLodgeSafe()
  Self.Log("MoveInventoryToLodgeSafe called") ; #DEBUG_LINE_NO:134
  If LPDummyHoldingRef.GetItemCount(None) > 0 ; #DEBUG_LINE_NO:135
    Self.Log("LPDummyHoldingRef has items") ; #DEBUG_LINE_NO:136
    LPDummyHoldingRef.RemoveAllItems(LodgeSafeRef, False, False) ; #DEBUG_LINE_NO:137
    Self.ShowMsg(LPAllItemsToLodgeMsg) ; #DEBUG_LINE_NO:138
  Else
    Self.Log("LPDummyHoldingRef has no items") ; #DEBUG_LINE_NO:140
    Self.ShowMsg(LPNoItemsMsg) ; #DEBUG_LINE_NO:141
  EndIf
EndFunction
