;======================================================================
; Script Name   : LZP:Term:Menu_UtilTransferScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Handles item transfer menu actions from terminal interface.
; Description   : Supports various item transfer operations (resources, valuables, 
;                 all items) between the player, ship, lodge safe, and dummy holding container.
;                 Integrates with LoggerScript for debug output.
;======================================================================

ScriptName LZP:Term:Menu_UtilTransferScript Extends TerminalMenu hidden

;======================================================================
; PROPERTIES
;======================================================================

;-- Terminal Menu Base --
; Reference to the terminal menu this script responds to.
Group TerminalMenuProperties
    TerminalMenu Property CurrentTerminalMenu Auto Const Mandatory
EndGroup

;-- Static Object References --
; Containers and actors involved in transfer logic.
Group ObjectReferences
    ObjectReference Property LodgeSafeRef Auto Const Mandatory
    ObjectReference Property LPDummyHoldingRef Auto Const Mandatory
    ObjectReference Property PlayerRef Auto Const Mandatory
EndGroup

;-- Alias References --
; Dynamic references resolved from alias system.
Group Aliases
    ReferenceAlias Property PlayerHomeShip Auto Const Mandatory
EndGroup

;-- Transferable Item Lists --
; Used to filter what should be moved.
Group ItemLists
    FormList Property LPSystem_Script_Resources Auto Const Mandatory
    FormList Property LPSystem_Script_Valuables Auto Const Mandatory
EndGroup

;-- Transfer Feedback Messages --
; Player-facing messages displayed after an action completes.
Group TransferMessages
    Message Property LPAllItemsToLodgeMsg Auto Const Mandatory
    Message Property LPAllItemsToShipMsg Auto Const Mandatory
    Message Property LPResourcesToShipMsg Auto Const Mandatory
    Message Property LPValuablesToPlayerMsg Auto Const Mandatory
    Message Property LPNoItemsMsg Auto Const Mandatory
EndGroup

;-- Logger Reference --
; Used to route debug messages to LazyPanda.log.
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;-- ShowMsg Function --
; Displays a message box with no buttons.
; @param msgToShow : Message - The message object to show.
Function ShowMsg(Message msgToShow)
    msgToShow.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnTerminalMenuEnter Event --
; Called when the terminal menu is entered.
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    Logger?.Log("OnTerminalMenuEnter triggered")
EndEvent

;-- OnTerminalMenuItemRun Event --
; Called when a terminal menu option is selected.
; @param auiMenuItemID : Int - Index of selected menu item.
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If akTerminalBase != CurrentTerminalMenu
        Return
    EndIf

    Logger?.Log("Terminal menu matches CurrentTerminalMenu")

    ; Route to appropriate transfer operation
    If auiMenuItemID == 0
        Logger?.Log("Menu item 0 selected: MoveAllToShip")
        MoveAllToShip()
    ElseIf auiMenuItemID == 1
        Logger?.Log("Menu item 1 selected: MoveResourcesToShip")
        MoveResourcesToShip()
    ElseIf auiMenuItemID == 2
        Logger?.Log("Menu item 2 selected: MoveInventoryToLodgeSafe")
        MoveInventoryToLodgeSafe()
    ElseIf auiMenuItemID == 3
        Logger?.Log("Menu item 3 selected: MoveValuablesToPlayer")
        MoveValuablesToPlayer()
    Else
        Logger?.Log("Invalid menu item selected: " + auiMenuItemID as String)
    EndIf
EndEvent

;======================================================================
; MAIN TRANSFER FUNCTIONS
;======================================================================

;-- MoveAllToShip Function --
; Transfers all items from the dummy container to the player's home ship.
Function MoveAllToShip()
    Logger?.Log("MoveAllToShip called")
    LPDummyHoldingRef.RemoveAllItems(PlayerHomeShip.GetRef(), False, False)
    ShowMsg(LPAllItemsToShipMsg)
EndFunction

;-- MoveResourcesToShip Function --
; Transfers all resources from player and dummy container to the ship.
Function MoveResourcesToShip()
    Logger?.Log("MoveResourcesToShip called")

    ObjectReference PlayerShip = PlayerHomeShip.GetRef()
    If !PlayerShip
        Logger?.Log("MoveResourcesToShip failed: No player ship reference")
        Return
    EndIf

    ; Transfer from player
    If Game.GetPlayer().GetItemCount(LPSystem_Script_Resources as Form) > 0
        Game.GetPlayer().RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
    EndIf

    ; Transfer from dummy container
    If LPDummyHoldingRef.GetItemCount(LPSystem_Script_Resources as Form) > 0
        LPDummyHoldingRef.RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
    EndIf

    ShowMsg(LPResourcesToShipMsg)
EndFunction

;-- MoveValuablesToPlayer Function --
; Transfers valuables from ship and dummy container to the player.
Function MoveValuablesToPlayer()
    Logger?.Log("MoveValuablesToPlayer called")

    ObjectReference PlayerShip = PlayerHomeShip.GetRef()
    If !PlayerShip
        Logger?.Log("MoveValuablesToPlayer failed: No player ship reference")
        Return
    EndIf

    ; Move from ship
    PlayerShip.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer())

    ; Move from dummy container
    LPDummyHoldingRef.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer())

    ShowMsg(LPValuablesToPlayerMsg)
EndFunction

;-- MoveInventoryToLodgeSafe Function --
; Transfers all items from the dummy container to the lodge safe if any exist.
Function MoveInventoryToLodgeSafe()
    Logger?.Log("MoveInventoryToLodgeSafe called")

    If LPDummyHoldingRef.GetItemCount(None) > 0
        Logger?.Log("LPDummyHoldingRef has items")
        LPDummyHoldingRef.RemoveAllItems(LodgeSafeRef, False, False)
        ShowMsg(LPAllItemsToLodgeMsg)
    Else
        Logger?.Log("LPDummyHoldingRef has no items")
        ShowMsg(LPNoItemsMsg)
    EndIf
EndFunction
