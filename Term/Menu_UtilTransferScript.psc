;======================================================================
; Script: LZP:Term:Menu_UtilTransferScript
; Description: This script manages the utility transfer menu functionality.
; It handles transferring items between various containers and the player.
; Debug logging is integrated to assist with troubleshooting.
;======================================================================

ScriptName LZP:Term:Menu_UtilTransferScript Extends TerminalMenu hidden

;======================================================================
; PROPERTY GROUPS
;======================================================================

;-- Menu Util Transfer Properties --
; Properties required for the menu utility transfer functionality.
Group Menu_UtilTransferProperties
  TerminalMenu Property CurrentTerminalMenu Auto Const Mandatory
  ObjectReference Property LodgeSafeRef Auto Const Mandatory
  ObjectReference Property LPDummyHoldingRef Auto Const Mandatory
  ObjectReference Property PlayerRef Auto Const Mandatory
  ReferenceAlias Property PlayerHomeShip Auto Const Mandatory
  FormList Property LPSystem_Script_Resources Auto Const Mandatory
  FormList Property LPSystem_Script_Valuables Auto Const Mandatory
  Message Property LPAllItemsToLodgeMsg Auto Const Mandatory
  Message Property LPAllItemsToShipMsg Auto Const Mandatory
  Message Property LPResourcesToShipMsg Auto Const Mandatory
  Message Property LPValuablesToPlayerMsg Auto Const Mandatory
  Message Property LPNoItemsMsg Auto Const Mandatory
  GlobalVariable Property LPSystemUtil_Debug Auto Const Mandatory
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

Function ShowMsg(Message msgToShow)
    msgToShow.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnTerminalMenuEnter Event Handler --
; Called when the terminal menu is entered.
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    LZP:SystemScript.Log("OnTerminalMenuEnter triggered", 3)
EndEvent

;-- OnTerminalMenuItemRun Event Handler --
; Called when a menu item is selected.
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If akTerminalBase != CurrentTerminalMenu
        Return
    EndIf

    LZP:SystemScript.Log("Terminal menu matches CurrentTerminalMenu", 3)
    If auiMenuItemID == 0
        LZP:SystemScript.Log("Menu item 0 selected: MoveAllToShip", 3)
        MoveAllToShip()
    ElseIf auiMenuItemID == 1
        LZP:SystemScript.Log("Menu item 1 selected: MoveResourcesToShip", 3)
        MoveResourcesToShip()
    ElseIf auiMenuItemID == 2
        LZP:SystemScript.Log("Menu item 2 selected: MoveInventoryToLodgeSafe", 3)
        MoveInventoryToLodgeSafe()
    ElseIf auiMenuItemID == 3
        LZP:SystemScript.Log("Menu item 3 selected: MoveValuablesToPlayer", 3)
        MoveValuablesToPlayer()
    Else
        LZP:SystemScript.Log("Invalid menu item selected: " + auiMenuItemID as String, 3)
    EndIf
EndEvent

;======================================================================
; MAIN FUNCTIONS
;======================================================================

;-- MoveAllToShip Function --
; Moves all items from the dummy holding container to the player's ship.
Function MoveAllToShip()
    LZP:SystemScript.Log("MoveAllToShip called", 3)
    LPDummyHoldingRef.RemoveAllItems(PlayerHomeShip.GetRef(), False, False)
    ShowMsg(LPAllItemsToShipMsg)
EndFunction

;-- MoveResourcesToShip Function --
; Moves resources from both the dummy holding container and the player to the ship.
Function MoveResourcesToShip()
    LZP:SystemScript.Log("MoveResourcesToShip called", 3)
    ObjectReference PlayerShip = PlayerHomeShip.GetRef()
    If !PlayerShip
        LZP:SystemScript.Log("MoveResourcesToShip failed: No player ship reference", 2)
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

;-- MoveValuablesToPlayer Function --
; Moves valuables from the player's ship and the dummy holding container to the player.
Function MoveValuablesToPlayer()
    LZP:SystemScript.Log("MoveValuablesToPlayer called", 3)
    ObjectReference PlayerShip = PlayerHomeShip.GetRef()
    If !PlayerShip
        LZP:SystemScript.Log("MoveValuablesToPlayer failed: No player ship reference", 2)
        Return
    EndIf

    PlayerShip.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer())
    LPDummyHoldingRef.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer())
    ShowMsg(LPValuablesToPlayerMsg)
EndFunction

;-- MoveInventoryToLodgeSafe Function --
; Moves all items from the dummy holding container to the lodge safe if items exist.
Function MoveInventoryToLodgeSafe()
    LZP:SystemScript.Log("MoveInventoryToLodgeSafe called", 3)
    If LPDummyHoldingRef.GetItemCount(None) > 0
        LZP:SystemScript.Log("LPDummyHoldingRef has items", 3)
        LPDummyHoldingRef.RemoveAllItems(LodgeSafeRef, False, False)
        ShowMsg(LPAllItemsToLodgeMsg)
    Else
        LZP:SystemScript.Log("LPDummyHoldingRef has no items", 3)
        ShowMsg(LPNoItemsMsg)
    EndIf
EndFunction