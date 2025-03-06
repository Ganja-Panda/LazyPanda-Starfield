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
EndGroup


;-- Functions ---------------------------------------

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Debug.Trace("OnTerminalMenuEnter triggered", 0) ; #DEBUG_LINE_NO:21
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Debug.Trace("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String, 0) ; #DEBUG_LINE_NO:26
  If akTerminalBase == Self.CurrentTerminalMenu ; #DEBUG_LINE_NO:27
    Debug.Trace("Terminal menu matches CurrentTerminalMenu", 0) ; #DEBUG_LINE_NO:28
    If auiMenuItemID == 0 ; #DEBUG_LINE_NO:29
      Debug.Trace("Menu item 0 selected: MoveAllToShip", 0) ; #DEBUG_LINE_NO:30
      Self.MoveAllToShip() ; #DEBUG_LINE_NO:31
    ElseIf auiMenuItemID == 1 ; #DEBUG_LINE_NO:32
      Debug.Trace("Menu item 1 selected: MoveResourcesToShip", 0) ; #DEBUG_LINE_NO:33
      Self.MoveResourcesToShip() ; #DEBUG_LINE_NO:34
    ElseIf auiMenuItemID == 2 ; #DEBUG_LINE_NO:35
      Debug.Trace("Menu item 2 selected: MoveInventoryToLodgeSafe", 0) ; #DEBUG_LINE_NO:36
      Self.MoveInventoryToLodgeSafe() ; #DEBUG_LINE_NO:37
    ElseIf auiMenuItemID == 3 ; #DEBUG_LINE_NO:38
      Debug.Trace("Menu item 3 selected: MoveValuablesToPlayer", 0) ; #DEBUG_LINE_NO:39
      Self.MoveValuablesToPlayer() ; #DEBUG_LINE_NO:40
    EndIf
  EndIf
EndEvent

Function MoveAllToShip()
  Debug.Trace("MoveAllToShip called", 0) ; #DEBUG_LINE_NO:48
  ObjectReference PlayerShip = Self.PlayerHomeShip.GetRef() ; #DEBUG_LINE_NO:49
  Debug.Trace("PlayerShip reference obtained: " + PlayerShip as String, 0) ; #DEBUG_LINE_NO:50
  Self.LPDummyHoldingRef.RemoveAllItems(PlayerShip, False, False) ; #DEBUG_LINE_NO:51
  Self.LPAllItemsToShipMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:52
EndFunction

Function MoveResourcesToShip()
  Debug.Trace("MoveResourcesToShip called", 0) ; #DEBUG_LINE_NO:58
  ObjectReference PlayerShip = Self.PlayerHomeShip.GetRef() ; #DEBUG_LINE_NO:59
  Debug.Trace("PlayerShip reference obtained: " + PlayerShip as String, 0) ; #DEBUG_LINE_NO:60
  Self.LPDummyHoldingRef.RemoveItem(Self.LPSystem_Script_Resources as Form, -1, True, PlayerShip) ; #DEBUG_LINE_NO:61
  Game.GetPlayer().RemoveItem(Self.LPSystem_Script_Resources as Form, -1, True, PlayerShip) ; #DEBUG_LINE_NO:62
  Self.LPResourcesToShipMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:63
EndFunction

Function MoveValuablesToPlayer()
  Debug.Trace("MoveValuablesToPlayer called", 0) ; #DEBUG_LINE_NO:69
  ObjectReference PlayerShip = Self.PlayerHomeShip.GetRef() ; #DEBUG_LINE_NO:70
  Debug.Trace("PlayerShip reference obtained: " + PlayerShip as String, 0) ; #DEBUG_LINE_NO:71
  PlayerShip.RemoveItem(Self.LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference) ; #DEBUG_LINE_NO:72
  Self.LPDummyHoldingRef.RemoveItem(Self.LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference) ; #DEBUG_LINE_NO:73
  Self.LPValuablesToPlayerMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:74
EndFunction

Function MoveInventoryToLodgeSafe()
  Debug.Trace("MoveInventoryToLodgeSafe called", 0) ; #DEBUG_LINE_NO:80
  If Self.LPDummyHoldingRef.GetItemCount(None) > 0 ; #DEBUG_LINE_NO:81
    Debug.Trace("LPDummyHoldingRef has items", 0) ; #DEBUG_LINE_NO:82
    Self.LPDummyHoldingRef.RemoveAllItems(Self.LodgeSafeRef, False, False) ; #DEBUG_LINE_NO:83
    Self.LPAllItemsToLodgeMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:84
  Else
    Debug.Trace("LPDummyHoldingRef has no items", 0) ; #DEBUG_LINE_NO:86
    Self.LPNoItemsMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:87
  EndIf
EndFunction
