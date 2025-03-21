;======================================================================
; Script: LZP:SystemScript
; Description: This script provides various utility functions for the Lazy Panda mod.
; It includes functions for opening inventories, moving items, and reporting status.
; Debug logging is integrated to assist with troubleshooting.
;======================================================================

ScriptName LZP:SystemScript Extends ScriptObject

;======================================================================
; MAIN FUNCTIONS
;======================================================================

;-- OpenHoldingInventory Function --
; Opens the inventory of the dummy holding container.
; cgf "LZP:SystemScript.OpenHoldingInventory"
Function OpenHoldingInventory() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering OpenHoldingInventory")
    EndIf

    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x09C1, "LazyPanda.esm") as ObjectReference
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Attempting to open inventory for dummy holding container")
    EndIf
    (LPDummyHoldingRef as Actor).OpenInventory(True, None, False)

    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting OpenHoldingInventory")
    EndIf
EndFunction

;-- OpenLodgeSafe Function --
; Opens the lodge safe container.
; cgf "LZP:SystemScript.OpenLodgeSafe"
Function OpenLodgeSafe() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering OpenLodgeSafe")
    EndIf

    ObjectReference LodgeSafeRef = Game.GetForm(0x266E81) as ObjectReference
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Activating LodgeSafe container")
    EndIf
    LodgeSafeRef.Activate(Game.GetPlayer() as ObjectReference, False)

    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting OpenLodgeSafe")
    EndIf
EndFunction

;-- OpenShipCargo Function --
; Opens the inventory of the player's ship.
; cgf "LZP:SystemScript.OpenShipCargo"
Function OpenShipCargo() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering OpenShipCargo")
    EndIf

    Quest SQ_PlayerShip = Game.GetFormFromFile(0x174A2, "LazyPanda.esm") as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    spaceshipreference PlayerShip = PlayerHomeShip.GetRef() as spaceshipreference
    
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Opening player's ship inventory")
    EndIf
    PlayerShip.OpenInventory()

    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting OpenShipCargo")
    EndIf
EndFunction

;-- MoveAllToShip Function --
; Moves all items from the dummy holding container to the player's ship.
; cgf "LZP:SystemScript.MoveAllToShip"
Function MoveAllToShip() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering MoveAllToShip")
    EndIf

    Message LPAllItemsToShipMsg = Game.GetFormFromFile(0x091D, "LazyPanda.esm") as Message
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x09C1, "LazyPanda.esm") as ObjectReference
    Quest SQ_PlayerShip = Game.GetFormFromFile(0x174A2, "LazyPanda.esm") as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    ObjectReference PlayerShip = PlayerHomeShip.GetRef()

    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Removing all items from dummy holding container to player's ship")
    EndIf
    LPDummyHoldingRef.RemoveAllItems(PlayerShip, False, False)

    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Displaying message for MoveAllToShip")
    EndIf
    LPAllItemsToShipMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting MoveAllToShip")
    EndIf
EndFunction

;-- MoveResourcesToShip Function --
; Moves resources from both the dummy holding container and the player to the ship.
; cgf "LZP:SystemScript.MoveResourcesToShip"
Function MoveResourcesToShip() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering MoveResourcesToShip")
    EndIf

    Message LPResourcesToShipMsg = Game.GetFormFromFile(0x091E, "LazyPanda.esm") as Message
    FormList LPSystem_Script_Resources = Game.GetFormFromFile(0x08C9, "LazyPanda.esm") as FormList
    Quest SQ_PlayerShip = Game.GetFormFromFile(0x174A2, "LazyPanda.esm") as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    ObjectReference PlayerShip = PlayerHomeShip.GetRef()
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x09C1, "LazyPanda.esm") as ObjectReference

    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Removing resources from dummy holding container to player's ship")
    EndIf
    LPDummyHoldingRef.RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
    
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Removing resources from player to player's ship")
    EndIf
    Game.GetPlayer().RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
    
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Displaying message for MoveResourcesToShip")
    EndIf
    LPResourcesToShipMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting MoveResourcesToShip")
    EndIf
EndFunction

;-- MoveValuablesToPlayer Function --
; Moves valuables from the player's ship and the dummy holding container to the player.
; cgf "LZP:SystemScript.MoveValuablesToPlayer"
Function MoveValuablesToPlayer() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering MoveValuablesToPlayer")
    EndIf

    Message LPValuablesToPlayerMsg = Game.GetFormFromFile(0x091F, "LazyPanda.esm") as Message
    FormList LPSystem_Script_Valuables = Game.GetFormFromFile(0x08CA, "LazyPanda.esm") as FormList
    Quest SQ_PlayerShip = Game.GetFormFromFile(0x174A2, "LazyPanda.esm") as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    ObjectReference PlayerShip = PlayerHomeShip.GetRef()
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x09C1, "LazyPanda.esm") as ObjectReference

    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Removing valuables from player's ship to player")
    EndIf
    PlayerShip.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference)
    
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Removing valuables from dummy holding container to player")
    EndIf
    LPDummyHoldingRef.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference)
    
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Displaying message for MoveValuablesToPlayer")
    EndIf
    LPValuablesToPlayerMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)

    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting MoveValuablesToPlayer")
    EndIf
EndFunction

;-- MoveAllToLodgeSafe Function --
; Moves all items from the dummy holding container to the lodge safe.
Function MoveInventoryToLodgeSafe() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering MoveInventoryToLodgeSafe")
    EndIf

    Debug.Trace("[Lazy Panda] MoveInventoryToLodgeSafe called", 0)
    Message LPAllItemsToLodgeMsg = Game.GetFormFromFile(0x092C, "LazyPanda.esm") as Message
    Message LPNoItemsMsg = Game.GetFormFromFile(0x0920, "LazyPanda.esm") as Message
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x09C1, "LazyPanda.esm") as ObjectReference
    ObjectReference LodgeSafeRef = Game.GetFormFromFile(0x266E81, "LazyPanda.esm") as ObjectReference

    ; Detailed Logging: Checking item count in dummy holding container
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Checking item count in dummy holding container")
    EndIf
    If LPDummyHoldingRef.GetItemCount(None) > 0
        ; Detailed Logging: Items found, transferring to Lodge Safe
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.Log("LZP:SystemScript: Items found in dummy holding container. Transferring items to Lodge Safe")
        EndIf
        LPDummyHoldingRef.RemoveAllItems(LodgeSafeRef, False, False)
        LPAllItemsToLodgeMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    Else
        ; Detailed Logging: No items found, showing LPNoItemsMsg
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.Log("LZP:SystemScript: No items found in dummy holding container. Displaying LPNoItemsMsg")
        EndIf
        LPNoItemsMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    EndIf

    ; Detailed Logging: Exiting MoveInventoryToLodgeSafe
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting MoveInventoryToLodgeSafe")
    EndIf
EndFunction

;-- OpenTerminal Function --
; Opens the terminal object.
; cgf "LZP:SystemScript.OpenTerminal"
Function OpenTerminal() Global
    ; Detailed Logging: Entering OpenTerminal
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering OpenTerminal")
    EndIf

    ObjectReference TerminalRef = Game.GetFormFromFile(0x08CD, "LazyPanda.esm") as ObjectReference
    If TerminalRef
        ; Detailed Logging: Activating terminal object
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.Log("LZP:SystemScript: Activating terminal object")
        EndIf
        TerminalRef.Activate(Game.GetPlayer() as ObjectReference, False)
    Else
        ; Detailed Logging: Terminal reference not found
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.Log("LZP:SystemScript: Terminal reference not found")
        EndIf
    EndIf

    ; Detailed Logging: Exiting OpenTerminal
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting OpenTerminal")
    EndIf
EndFunction

;-- ToggleLooting Function --
; Toggles the looting state of the player character.
; cgf "LZScav:SystemScript.ToggleLooting"
Function ToggleLooting() Global
    ; Detailed Logging: Entering ToggleLooting
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering ToggleLooting")
    EndIf

    Message LPLootingEnabledMsg = Game.GetFormFromFile(0x097E, "LazyScav.esm") as Message
    Message LPLootingDisabledMsg = Game.GetFormFromFile(0x097F, "LazyScav.esm") as Message
    GlobalVariable LazyScavUtil_ToggleLooting = Game.GetFormFromFile(0x086A, "LazyScav.esm") as GlobalVariable
    Int currentToggle = LazyScavUtil_ToggleLooting.GetValue() as Int

    ; Detailed Logging: Current looting toggle value: " + currentToggle
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Current looting toggle value = " + currentToggle)
    EndIf

    If currentToggle == 0
        LazyScavUtil_ToggleLooting.SetValue(1.0)
        LPLootingEnabledMsg.Show()
        ; Detailed Logging: Looting enabled
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.Log("LZP:SystemScript: Looting enabled")
        EndIf
    ElseIf currentToggle == 1
        LazyScavUtil_ToggleLooting.SetValue(0.0)
        LPLootingDisabledMsg.Show()
        ; Detailed Logging: Looting disabled
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.Log("LZP:SystemScript: Looting disabled")
        EndIf
    EndIf

    ; Detailed Logging: Exiting ToggleLooting
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting ToggleLooting")
    EndIf
EndFunction

;-- ToggleLogging Function --
; Toggles Lazy Panda debug logging on/off.
; Safe to call from console: cgf "LZP:SystemScript.ToggleLogging"
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

;-- Logging Function --
; Internal-use logging passthrough
Function Logging()
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("SystemScript: Logging() called.")
    EndIf
EndFunction
