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
  If LPSystemUtil_Debug.GetValue() as Bool
    Debug.Trace("[LZP:UtilTransfer] " + logMsg, 0)
  EndIf
EndFunction

Function ShowMsg(Message msgToShow)
  msgToShow.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Log("OnTerminalMenuEnter triggered")
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  If akTerminalBase != CurrentTerminalMenu
    Return
  EndIf
  Log("Terminal menu matches CurrentTerminalMenu")
  If auiMenuItemID == 0
    Log("Menu item 0 selected: MoveAllToShip")
    MoveAllToShip()
  ElseIf auiMenuItemID == 1
    Log("Menu item 1 selected: MoveResourcesToShip")
    MoveResourcesToShip()
  ElseIf auiMenuItemID == 2
    Log("Menu item 2 selected: MoveInventoryToLodgeSafe")
    MoveInventoryToLodgeSafe()
  ElseIf auiMenuItemID == 3
    Log("Menu item 3 selected: MoveValuablesToPlayer")
    MoveValuablesToPlayer()
  Else
    Log("Invalid menu item selected: " + auiMenuItemID as String)
  EndIf
EndEvent

Function MoveAllToShip()
  Log("MoveAllToShip called")
  LPDummyHoldingRef.RemoveAllItems(PlayerHomeShip.GetRef(), False, False)
  ShowMsg(LPAllItemsToShipMsg)
EndFunction

Function MoveResourcesToShip()
  Log("MoveResourcesToShip called")
  ObjectReference PlayerShip = PlayerHomeShip.GetRef()
  If !PlayerShip
    Log("MoveResourcesToShip failed: No player ship reference")
    Return
  EndIf
  If Game.GetPlayer().GetItemCount(LPSystem_Script_Resources as Form) > 0
    Game.GetPlayer().RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
  EndIf
  If LPDummyHoldingRef.GetItemCount(LPSystem_Script_Resources as Form) > 0
    LPDummyHoldingRef.RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
  EndIf
  ShowMsg(LPResourcesToShipMsg)
EndFunction

Function MoveValuablesToPlayer()
  Log("MoveValuablesToPlayer called")
  ObjectReference PlayerShip = PlayerHomeShip.GetRef()
  If !PlayerShip
    Log("MoveValuablesToPlayer failed: No player ship reference")
    Return
  EndIf
  PlayerShip.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference)
  LPDummyHoldingRef.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference)
  ShowMsg(LPValuablesToPlayerMsg)
EndFunction

Function MoveInventoryToLodgeSafe()
  Log("MoveInventoryToLodgeSafe called")
  If LPDummyHoldingRef.GetItemCount(None) > 0
    Log("LPDummyHoldingRef has items")
    LPDummyHoldingRef.RemoveAllItems(LodgeSafeRef, False, False)
    ShowMsg(LPAllItemsToLodgeMsg)
  Else
    Log("LPDummyHoldingRef has no items")
    ShowMsg(LPNoItemsMsg)
  EndIf
EndFunction
