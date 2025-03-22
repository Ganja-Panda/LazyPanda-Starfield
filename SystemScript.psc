;======================================================================
; Script: LZP:SystemScript
; Description: Stateless global utility functions for Lazy Panda mod.
; Refactored for safe use with cgf (Call Global Function) execution.
;======================================================================

ScriptName LZP:SystemScript Extends ScriptObject

;======================================================================
; GLOBAL FUNCTIONS (ALL SELF-CONTAINED)
;======================================================================

Function OpenHoldingInventory() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering OpenHoldingInventory")
    EndIf

    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x09C1, "LazyPanda.esm") as ObjectReference
    If LPDummyHoldingRef
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.Log("LZP:SystemScript: Opening dummy holding container inventory")
        EndIf
        (LPDummyHoldingRef as Actor).OpenInventory(True, None, False)
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Failed to resolve LPDummyHoldingRef")
    EndIf

    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting OpenHoldingInventory")
    EndIf
EndFunction

Function OpenLodgeSafe() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering OpenLodgeSafe")
    EndIf

    ObjectReference LodgeSafeRef = Game.GetForm(0x266E81) as ObjectReference
    If LodgeSafeRef
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.Log("LZP:SystemScript: Activating LodgeSafe container")
        EndIf
        LodgeSafeRef.Activate(Game.GetPlayer() as ObjectReference, False)
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: LodgeSafeRef not found")
    EndIf

    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting OpenLodgeSafe")
    EndIf
EndFunction

Function OpenShipCargo() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering OpenShipCargo")
    EndIf

    Quest SQ_PlayerShip = Game.GetFormFromFile(0x174A2, "LazyPanda.esm") as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    spaceshipreference PlayerShip = PlayerHomeShip.GetRef() as spaceshipreference

    If PlayerShip
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.Log("LZP:SystemScript: Opening player's ship inventory")
        EndIf
        PlayerShip.OpenInventory()
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: PlayerShip not resolved")
    EndIf

    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting OpenShipCargo")
    EndIf
EndFunction

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

    If LPDummyHoldingRef && PlayerShip
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.Log("LZP:SystemScript: Transferring items to ship")
        EndIf
        LPDummyHoldingRef.RemoveAllItems(PlayerShip, False, False)
        LPAllItemsToShipMsg.Show()
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Failed to resolve references in MoveAllToShip")
    EndIf

    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting MoveAllToShip")
    EndIf
EndFunction

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

    If PlayerShip && LPDummyHoldingRef
        LPDummyHoldingRef.RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
        Game.GetPlayer().RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
        LPResourcesToShipMsg.Show()
    EndIf

    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting MoveResourcesToShip")
    EndIf
EndFunction

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

    If PlayerShip
        PlayerShip.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer())
    EndIf
    If LPDummyHoldingRef
        LPDummyHoldingRef.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer())
    EndIf
    LPValuablesToPlayerMsg.Show()

    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting MoveValuablesToPlayer")
    EndIf
EndFunction

Function MoveInventoryToLodgeSafe() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering MoveInventoryToLodgeSafe")
    EndIf

    Message LPAllItemsToLodgeMsg = Game.GetFormFromFile(0x092C, "LazyPanda.esm") as Message
    Message LPNoItemsMsg = Game.GetFormFromFile(0x0920, "LazyPanda.esm") as Message
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x09C1, "LazyPanda.esm") as ObjectReference
    ObjectReference LodgeSafeRef = Game.GetFormFromFile(0x266E81, "LazyPanda.esm") as ObjectReference

    If LPDummyHoldingRef.GetItemCount(None) > 0
        LPDummyHoldingRef.RemoveAllItems(LodgeSafeRef, False, False)
        LPAllItemsToLodgeMsg.Show()
    Else
        LPNoItemsMsg.Show()
    EndIf

    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting MoveInventoryToLodgeSafe")
    EndIf
EndFunction

Function OpenTerminal() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering OpenTerminal")
    EndIf

    ObjectReference TerminalRef = Game.GetFormFromFile(0x08CD, "LazyPanda.esm") as ObjectReference
    If TerminalRef
        TerminalRef.Activate(Game.GetPlayer(), False)
    EndIf

    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting OpenTerminal")
    EndIf
EndFunction

Function ToggleLooting() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering ToggleLooting")
    EndIf

    Message LPLootingEnabledMsg = Game.GetFormFromFile(0x097E, "LazyScav.esm") as Message
    Message LPLootingDisabledMsg = Game.GetFormFromFile(0x097F, "LazyScav.esm") as Message
    GlobalVariable LazyScavUtil_ToggleLooting = Game.GetFormFromFile(0x086A, "LazyScav.esm") as GlobalVariable
    Int currentToggle = LazyScavUtil_ToggleLooting.GetValue() as Int

    If currentToggle == 0
        LazyScavUtil_ToggleLooting.SetValue(1.0)
        LPLootingEnabledMsg.Show()
    ElseIf currentToggle == 1
        LazyScavUtil_ToggleLooting.SetValue(0.0)
        LPLootingDisabledMsg.Show()
    EndIf

    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting ToggleLooting")
    EndIf
EndFunction

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


