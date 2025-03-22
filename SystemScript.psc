;======================================================================
; Script: LZP:SystemScript
; Author: Ganja Panda
; Description: Stateless global utility functions for Lazy Panda mod. 
;======================================================================

ScriptName LZP:SystemScript Extends ScriptObject

;======================================================================
; GLOBAL FUNCTIONS
;======================================================================

;---------------------------------------------------------------------
; Opens the dummy holding container’s inventory.
; Used for accessing items temporarily held by the system.
; cgf "LZP:SystemScript.OpenHoldingInventory"
;---------------------------------------------------------------------
Function OpenHoldingInventory() Global
    ; Log entry
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering OpenHoldingInventory", 0)
    EndIf

    ; Attempt to open the holding container’s inventory
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x09C1, "LazyPanda.esm") as ObjectReference
    If LPDummyHoldingRef
        (LPDummyHoldingRef as Actor).OpenInventory(True, None, False)
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: ERROR - LPDummyHoldingRef not found", 3)
    EndIf

    ; Log exit
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting OpenHoldingInventory", 0)
    EndIf
EndFunction

;---------------------------------------------------------------------
; Opens the Lodge Safe container.
; Used to retrieve or deposit items manually.
; cgf "LZP:SystemScript.OpenLodgeSafe"
;---------------------------------------------------------------------
Function OpenLodgeSafe() Global
    ; Log entry
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering OpenLodgeSafe", 0)
    EndIf

    ; Activate safe container
    ObjectReference LodgeSafeRef = Game.GetForm(0x266E81) as ObjectReference
    If LodgeSafeRef
        LodgeSafeRef.Activate(Game.GetPlayer() as ObjectReference, False)
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: ERROR - LodgeSafeRef not found", 3)
    EndIf

    ; Log exit
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting OpenLodgeSafe", 0)
    EndIf
EndFunction

;---------------------------------------------------------------------
; Opens the inventory of the player’s current home ship.
; cgf "LZP:SystemScript.OpenShipCargo"
;---------------------------------------------------------------------
Function OpenShipCargo() Global
    ; Log entry
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering OpenShipCargo", 0)
    EndIf

    ; Resolve ship alias and open inventory
    Quest SQ_PlayerShip = Game.GetFormFromFile(0x174A2, "LazyPanda.esm") as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    spaceshipreference PlayerShip = PlayerHomeShip.GetRef() as spaceshipreference
    If PlayerShip
        PlayerShip.OpenInventory()
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: ERROR - PlayerShip reference not found", 3)
    EndIf

    ; Log exit
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting OpenShipCargo", 0)
    EndIf
EndFunction

;---------------------------------------------------------------------
; Transfers all items from the dummy container to the player's ship.
; Useful for bulk offloading.
; cgf "LZP:SystemScript.MoveAllToShip"
;---------------------------------------------------------------------
Function MoveAllToShip() Global
    ; Log entry
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering MoveAllToShip", 0)
    EndIf

    Message LPAllItemsToShipMsg = Game.GetFormFromFile(0x091D, "LazyPanda.esm") as Message
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x09C1, "LazyPanda.esm") as ObjectReference
    Quest SQ_PlayerShip = Game.GetFormFromFile(0x174A2, "LazyPanda.esm") as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    ObjectReference PlayerShip = PlayerHomeShip.GetRef()

    If LPDummyHoldingRef && PlayerShip
        LPDummyHoldingRef.RemoveAllItems(PlayerShip, False, False)
        LPAllItemsToShipMsg.Show()
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: ERROR - LPDummyHoldingRef or PlayerShip not found", 3)
    EndIf

    ; Log exit
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting MoveAllToShip", 0)
    EndIf
EndFunction

;---------------------------------------------------------------------
; Transfers defined resources from both player and dummy container
; to the player's ship cargo. Uses resource FormList.
; cgf "LZP:SystemScript.MoveResourcesToShip"
;---------------------------------------------------------------------
Function MoveResourcesToShip() Global
    ; Log entry
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering MoveResourcesToShip", 0)
    EndIf

    Message LPResourcesToShipMsg = Game.GetFormFromFile(0x091E, "LazyPanda.esm") as Message
    FormList LPSystem_Script_Resources = Game.GetFormFromFile(0x08C9, "LazyPanda.esm") as FormList
    Quest SQ_PlayerShip = Game.GetFormFromFile(0x174A2, "LazyPanda.esm") as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    ObjectReference PlayerShip = PlayerHomeShip.GetRef()
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x09C1, "LazyPanda.esm") as ObjectReference

    If PlayerShip && LPDummyHoldingRef
        LPDummyHoldingRef.RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
        Game.GetPlayer().RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
        LPResourcesToShipMsg.Show()
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: ERROR - PlayerShip or LPDummyHoldingRef not found", 3)
    EndIf

    ; Log exit
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting MoveResourcesToShip", 0)
    EndIf
EndFunction

;---------------------------------------------------------------------
; Transfers valuable items from the ship and holding container
; to the player. Valuables are defined in a FormList.
; cgf "LZP:SystemScript.MoveValuablesToPlayer"
;---------------------------------------------------------------------
Function MoveValuablesToPlayer() Global
    ; Log entry
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering MoveValuablesToPlayer", 0)
    EndIf

    Message LPValuablesToPlayerMsg = Game.GetFormFromFile(0x091F, "LazyPanda.esm") as Message
    FormList LPSystem_Script_Valuables = Game.GetFormFromFile(0x08CA, "LazyPanda.esm") as FormList
    Quest SQ_PlayerShip = Game.GetFormFromFile(0x174A2, "LazyPanda.esm") as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    ObjectReference PlayerShip = PlayerHomeShip.GetRef()
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x09C1, "LazyPanda.esm") as ObjectReference

    If PlayerShip
        PlayerShip.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer())
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: WARNING - PlayerShip not found", 2)
    EndIf
    If LPDummyHoldingRef
        LPDummyHoldingRef.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer())
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: WARNING - LPDummyHoldingRef not found", 2)
    EndIf

    LPValuablesToPlayerMsg.Show()

    ; Log exit
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting MoveValuablesToPlayer", 0)
    EndIf
EndFunction

;---------------------------------------------------------------------
; Transfers all inventory from dummy container to Lodge Safe.
; Shows a message depending on whether items exist.
; cgf "LZP:SystemScript.MoveInventoryToLodgeSafe"
;---------------------------------------------------------------------
Function MoveInventoryToLodgeSafe() Global
    ; Log entry
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering MoveInventoryToLodgeSafe", 0)
    EndIf

    Message LPAllItemsToLodgeMsg = Game.GetFormFromFile(0x092C, "LazyPanda.esm") as Message
    Message LPNoItemsMsg = Game.GetFormFromFile(0x0920, "LazyPanda.esm") as Message
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x09C1, "LazyPanda.esm") as ObjectReference
    ObjectReference LodgeSafeRef = Game.GetFormFromFile(0x266E81, "LazyPanda.esm") as ObjectReference

    If LPDummyHoldingRef && LodgeSafeRef
        If LPDummyHoldingRef.GetItemCount(None) > 0
            LPDummyHoldingRef.RemoveAllItems(LodgeSafeRef, False, False)
            LPAllItemsToLodgeMsg.Show()
        Else
            LPNoItemsMsg.Show()
        EndIf
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: ERROR - LPDummyHoldingRef or LodgeSafeRef not found", 3)
    EndIf

    ; Log exit
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting MoveInventoryToLodgeSafe", 0)
    EndIf
EndFunction

;---------------------------------------------------------------------
; Activates the player-assigned terminal object.
; cgf "LZP:SystemScript.OpenTerminal"
;---------------------------------------------------------------------
Function OpenTerminal() Global
    ; Log entry
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering OpenTerminal", 0)
    EndIf

    ObjectReference TerminalRef = Game.GetFormFromFile(0x08CD, "LazyPanda.esm") as ObjectReference
    If TerminalRef
        TerminalRef.Activate(Game.GetPlayer(), False)
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: ERROR - TerminalRef not found", 3)
    EndIf

    ; Log exit
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting OpenTerminal", 0)
    EndIf
EndFunction

;---------------------------------------------------------------------
; Toggles global looting state via global variable.
; Displays confirmation message to player.
; cgf "LZP:SystemScript.ToggleLooting"
;---------------------------------------------------------------------
Function ToggleLooting() Global
    ; Log entry
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering ToggleLooting", 0)
    EndIf

    Message LPLootingEnabledMsg = Game.GetFormFromFile(0x097E, "LazyScav.esm") as Message
    Message LPLootingDisabledMsg = Game.GetFormFromFile(0x097F, "LazyScav.esm") as Message
    GlobalVariable LazyScavUtil_ToggleLooting = Game.GetFormFromFile(0x086A, "LazyScav.esm") as GlobalVariable

    Int currentToggle = LazyScavUtil_ToggleLooting.GetValue() as Int
    If currentToggle == 0
        LazyScavUtil_ToggleLooting.SetValue(1.0)
        LPLootingEnabledMsg.Show()
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.Log("LZP:SystemScript: Looting enabled", 1)
        EndIf
    ElseIf currentToggle == 1
        LazyScavUtil_ToggleLooting.SetValue(0.0)
        LPLootingDisabledMsg.Show()
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.Log("LZP:SystemScript: Looting disabled", 1)
        EndIf
    EndIf

    ; Log exit
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting ToggleLooting", 0)
    EndIf
EndFunction

;---------------------------------------------------------------------
; Toggles the global logging variable and shows confirmation.
; cgf "LZP:SystemScript.ToggleLogging"
;---------------------------------------------------------------------
Function ToggleLogging() Global
    GlobalVariable LPSystemUtil_Debug = Game.GetFormFromFile(0x0922, "LazyPanda.esm") as GlobalVariable
    Message LPDebugOnMsg = Game.GetFormFromFile(0x0996, "LazyPanda.esm") as Message
    Message LPDebugOffMsg = Game.GetFormFromFile(0x0995, "LazyPanda.esm") as Message

    Int currentDebug = LPSystemUtil_Debug.GetValue() as Int
    If currentDebug == 0
        LPSystemUtil_Debug.SetValue(1.0)
        LPDebugOnMsg.Show()
    ElseIf currentDebug == 1
        LPSystemUtil_Debug.SetValue(0.0)
        LPDebugOffMsg.Show()
    EndIf
EndFunction
