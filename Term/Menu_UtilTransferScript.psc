ScriptName LZP:Term:Menu_UtilTransferScript Extends TerminalMenu hidden

;======================================================================
; PROPERTY GROUPS
;======================================================================

;-- Menu Util Transfer Properties --
; Properties required for the menu utility transfer functionality.
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
  GlobalVariable Property LPSystem_Debug Auto Const mandatory
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;-- Log Function --
; Logs a message if the global debug setting is enabled.
Function Log(String logMsg)
  If LPSystem_Debug.GetValue() as Bool
    Debug.Trace(logMsg, 0)
  EndIf
EndFunction

;-- GetPlayerShip Function --
; Returns the player ship reference from the PlayerHomeShip alias.
Function GetPlayerShip() Global ObjectReference
  spaceshipreference PlayerShip = PlayerHomeShip.GetRef() as spaceshipreference
  Log("GetPlayerShip: Obtained PlayerShip reference: " + PlayerShip as String)
  Return PlayerShip
EndFunction

;-- ShowMsg Function --
; Standardizes showing messages using default parameters (all zeros).
Function ShowMsg(Message msgToShow)
  msgToShow.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnTerminalMenuEnter Event Handler --
; Called when the terminal menu is entered.
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Log("OnTerminalMenuEnter triggered")
EndEvent

;-- OnTerminalMenuItemRun Event Handler --
; Called when a menu item is selected.
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Log("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String)
  If akTerminalBase == CurrentTerminalMenu
    Log("Terminal menu matches CurrentTerminalMenu")
    ; Menu item selection handling:
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
    EndIf
  EndIf
EndEvent

;======================================================================
; MAIN FUNCTIONS
;======================================================================

;-- MoveAllToShip Function --
; Moves all items from the dummy holding container to the player's ship.
Function MoveAllToShip()
  Log("MoveAllToShip called")
  ObjectReference PlayerShip = GetPlayerShip()
  LPDummyHoldingRef.RemoveAllItems(PlayerShip, False, False)
  ShowMsg(LPAllItemsToShipMsg)
EndFunction

;-- MoveResourcesToShip Function --
; Moves resources from both the dummy holding container and the player to the ship.
Function MoveResourcesToShip()
  Log("MoveResourcesToShip called")
  ObjectReference PlayerShip = GetPlayerShip()
  LPDummyHoldingRef.RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
  Game.GetPlayer().RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
  ShowMsg(LPResourcesToShipMsg)
EndFunction

;-- MoveValuablesToPlayer Function --
; Moves valuables from the player's ship and the dummy holding container to the player.
Function MoveValuablesToPlayer()
  Log("MoveValuablesToPlayer called")
  ObjectReference PlayerShip = GetPlayerShip()
  PlayerShip.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference)
  LPDummyHoldingRef.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference)
  ShowMsg(LPValuablesToPlayerMsg)
EndFunction

;-- MoveInventoryToLodgeSafe Function --
; Moves all items from the dummy holding container to the lodge safe if items exist.
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