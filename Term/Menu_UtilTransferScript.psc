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

;------------------------------
; Terminal Menu Base
; Reference to the terminal menu this script responds to.
;------------------------------
Group TerminalMenuProperties
    TerminalMenu Property CurrentTerminalMenu Auto Const Mandatory
EndGroup

;------------------------------
; Static Object References
; Containers and actors involved in transfer logic.
;------------------------------
Group ObjectReferences
    ObjectReference Property LodgeSafeRef Auto Const Mandatory
    ObjectReference Property LZP_Cont_StorageRef Auto Const Mandatory
    ObjectReference Property PlayerRef Auto Const Mandatory
EndGroup

;------------------------------
; Alias References
; Dynamic references resolved from alias system.
;------------------------------
Group Aliases
    ReferenceAlias Property PlayerHomeShip Auto Const Mandatory
EndGroup

;------------------------------
; Transferable Item Lists
; Used to filter what should be moved.
;------------------------------
Group ItemLists
    FormList Property LZP_System_Script_Resources Auto Const Mandatory
    FormList Property LZP_System_Script_Valuables Auto Const Mandatory
EndGroup

;------------------------------
; Transfer Feedback Messages
; Player-facing messages displayed after an action completes.
;------------------------------
Group TransferMessages
    Message Property LZP_MESG_AllItems_Lodge Auto Const Mandatory
    Message Property LZP_MESG_AllItems_Ship Auto Const Mandatory
    Message Property LZP_MESG_ResourcesToShip Auto Const Mandatory
    Message Property LZP_MESG_ValuablesToPlayer Auto Const Mandatory
    Message Property LZP_MESG_NoItems Auto Const Mandatory
EndGroup

;------------------------------
; Logger Reference
; Used to route debug messages to LazyPanda.log.
;------------------------------
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;------------------------------
; Tokens
; Transfer Message Tokens for display keys.
; (These tokens provide a central reference for message keys,
;  even though this script uses the message properties directly.)
;------------------------------
Group Tokens
    String Property Token_AllItemsToShip   = "AllItemsToShip" Auto Const Hidden
    String Property Token_ResourcesToShip    = "ResourcesToShip" Auto Const Hidden
    String Property Token_ValuablesToPlayer  = "ValuablesToPlayer" Auto Const Hidden
    String Property Token_AllItemsToLodge    = "AllItemsToLodge" Auto Const Hidden
    String Property Token_NoItems            = "NoItems" Auto Const Hidden
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;----------------------------------------------------------------------
; Function : ShowMsg
; Purpose  : Displays a message box with no buttons.
; Parameters:
;    msgToShow - The message object to show.
;----------------------------------------------------------------------
Function ShowMsg(Message msgToShow)
    msgToShow.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;----------------------------------------------------------------------
; Event : OnTerminalMenuEnter
; Purpose: Called when the terminal menu is entered.
;----------------------------------------------------------------------
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("OnTerminalMenuEnter: Triggered", 1, "Menu_UtilTransferScript")
    EndIf
EndEvent

;----------------------------------------------------------------------
; Event : OnTerminalMenuItemRun
; Purpose: Called when a terminal menu option is selected.
; Parameters:
;    auiMenuItemID - Index of selected menu item.
;----------------------------------------------------------------------
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If akTerminalBase != CurrentTerminalMenu
        Return
    EndIf

    If Logger && Logger.IsEnabled()
        Logger.LogAdv("OnTerminalMenuItemRun: Terminal menu matches CurrentTerminalMenu", 1, "Menu_UtilTransferScript")
    EndIf

    ; Route to appropriate transfer operation
    If auiMenuItemID == 0
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("OnTerminalMenuItemRun: Menu item 0 selected: MoveAllToShip", 1, "Menu_UtilTransferScript")
        EndIf
        MoveAllToShip()
    ElseIf auiMenuItemID == 1
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("OnTerminalMenuItemRun: Menu item 1 selected: MoveResourcesToShip", 1, "Menu_UtilTransferScript")
        EndIf
        MoveResourcesToShip()
    ElseIf auiMenuItemID == 2
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("OnTerminalMenuItemRun: Menu item 2 selected: MoveInventoryToLodgeSafe", 1, "Menu_UtilTransferScript")
        EndIf
        MoveInventoryToLodgeSafe()
    ElseIf auiMenuItemID == 3
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("OnTerminalMenuItemRun: Menu item 3 selected: MoveValuablesToPlayer", 1, "Menu_UtilTransferScript")
        EndIf
        MoveValuablesToPlayer()
    Else
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("OnTerminalMenuItemRun: Invalid menu item selected", 2, "Menu_UtilTransferScript")
            Logger.LogAdv(auiMenuItemID as String, 2, "Menu_UtilTransferScript")
        EndIf
    EndIf
EndEvent

;======================================================================
; MAIN TRANSFER FUNCTIONS
;======================================================================

;----------------------------------------------------------------------
; Function : MoveAllToShip
; Purpose  : Transfers all items from the dummy container to the player's home ship.
;----------------------------------------------------------------------
Function MoveAllToShip()
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("MoveAllToShip: Called", 1, "Menu_UtilTransferScript")
    EndIf
    LZP_Cont_StorageRef.RemoveAllItems(PlayerHomeShip.GetRef(), False, False)
    ShowMsg(LZP_MESG_AllItems_Ship)
EndFunction

;----------------------------------------------------------------------
; Function : MoveResourcesToShip
; Purpose  : Transfers all resources from player and dummy container to the ship.
;----------------------------------------------------------------------
Function MoveResourcesToShip()
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("MoveResourcesToShip: Called", 1, "Menu_UtilTransferScript")
    EndIf

    ObjectReference PlayerShip = PlayerHomeShip.GetRef()
    If !PlayerShip
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("MoveResourcesToShip: Failed - No player ship reference", 2, "Menu_UtilTransferScript")
        EndIf
        Return
    EndIf

    ; Transfer from player
    If Game.GetPlayer().GetItemCount(LZP_System_Script_Resources as Form) > 0
        Game.GetPlayer().RemoveItem(LZP_System_Script_Resources as Form, -1, True, PlayerShip)
    EndIf

    ; Transfer from dummy container
    If LZP_Cont_StorageRef.GetItemCount(LZP_System_Script_Resources as Form) > 0
        LZP_Cont_StorageRef.RemoveItem(LZP_System_Script_Resources as Form, -1, True, PlayerShip)
    EndIf

    ShowMsg(LZP_MESG_ResourcesToShip)
EndFunction

;----------------------------------------------------------------------
; Function : MoveValuablesToPlayer
; Purpose  : Transfers valuables from ship and dummy container to the player.
;----------------------------------------------------------------------
Function MoveValuablesToPlayer()
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("MoveValuablesToPlayer: Called", 1, "Menu_UtilTransferScript")
    EndIf

    ObjectReference PlayerShip = PlayerHomeShip.GetRef()
    If !PlayerShip
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("MoveValuablesToPlayer: Failed - No player ship reference", 2, "Menu_UtilTransferScript")
        EndIf
        Return
    EndIf

    ; Move from ship
    PlayerShip.RemoveItem(LZP_System_Script_Valuables as Form, -1, True, Game.GetPlayer())

    ; Move from dummy container
    LZP_Cont_StorageRef.RemoveItem(LZP_System_Script_Valuables as Form, -1, True, Game.GetPlayer())

    ShowMsg(LZP_MESG_ValuablesToPlayer)
EndFunction

;----------------------------------------------------------------------
; Function : MoveInventoryToLodgeSafe
; Purpose  : Transfers all items from the dummy container to the lodge safe if any exist.
;----------------------------------------------------------------------
Function MoveInventoryToLodgeSafe()
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("MoveInventoryToLodgeSafe: Called", 1, "Menu_UtilTransferScript")
    EndIf

    If LZP_Cont_StorageRef.GetItemCount(None) > 0
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("MoveInventoryToLodgeSafe: LPDummyHoldingRef has items", 1, "Menu_UtilTransferScript")
        EndIf
        LZP_Cont_StorageRef.RemoveAllItems(LodgeSafeRef, False, False)
        ShowMsg(LZP_MESG_AllItems_Lodge)
    Else
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("MoveInventoryToLodgeSafe: LPDummyHoldingRef has no items", 1, "Menu_UtilTransferScript")
        EndIf
        ShowMsg(LZP_MESG_NoItems)
    EndIf
EndFunction
