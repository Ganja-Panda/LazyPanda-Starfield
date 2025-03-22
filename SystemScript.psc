;======================================================================
; Script: LZP:SystemScript
; Description: Stateless global utility functions for Lazy Panda mod.
; Refactored for safe use with cgf (Call Global Function) execution.
;======================================================================

ScriptName LZP:SystemScript Extends ScriptObject

;======================================================================
; GLOBAL FUNCTIONS
;======================================================================

Function OpenHoldingInventory() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering OpenHoldingInventory", 0)
    EndIf
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x09C1, "LazyPanda.esm") as ObjectReference
    If LPDummyHoldingRef
        (LPDummyHoldingRef as Actor).OpenInventory(True, None, False)
    EndIf
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting OpenHoldingInventory", 0)
    EndIf
EndFunction

Function OpenLodgeSafe() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering OpenLodgeSafe", 0)
    EndIf
    ObjectReference LodgeSafeRef = Game.GetForm(0x266E81) as ObjectReference
    If LodgeSafeRef
        LodgeSafeRef.Activate(Game.GetPlayer() as ObjectReference, False)
    EndIf
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting OpenLodgeSafe", 0)
    EndIf
EndFunction

Function OpenShipCargo() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering OpenShipCargo", 0)
    EndIf
    Quest SQ_PlayerShip = Game.GetFormFromFile(0x174A2, "LazyPanda.esm") as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    spaceshipreference PlayerShip = PlayerHomeShip.GetRef() as spaceshipreference
    If PlayerShip
        PlayerShip.OpenInventory()
    EndIf
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting OpenShipCargo", 0)
    EndIf
EndFunction

Function MoveAllToShip() Global
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
    EndIf
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting MoveAllToShip", 0)
    EndIf
EndFunction

Function MoveResourcesToShip() Global
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
    EndIf
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting MoveResourcesToShip", 0)
    EndIf
EndFunction

Function MoveValuablesToPlayer() Global
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
    EndIf
    If LPDummyHoldingRef
        LPDummyHoldingRef.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer())
    EndIf
    LPValuablesToPlayerMsg.Show()
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting MoveValuablesToPlayer", 0)
    EndIf
EndFunction

Function MoveInventoryToLodgeSafe() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering MoveInventoryToLodgeSafe", 0)
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
        LoggerScript.Log("LZP:SystemScript: Exiting MoveInventoryToLodgeSafe", 0)
    EndIf
EndFunction

Function OpenTerminal() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Entering OpenTerminal", 0)
    EndIf
    ObjectReference TerminalRef = Game.GetFormFromFile(0x08CD, "LazyPanda.esm") as ObjectReference
    If TerminalRef
        TerminalRef.Activate(Game.GetPlayer(), False)
    EndIf
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting OpenTerminal", 0)
    EndIf
EndFunction

Function ToggleLooting() Global
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
    ElseIf currentToggle == 1
        LazyScavUtil_ToggleLooting.SetValue(0.0)
        LPLootingDisabledMsg.Show()
    EndIf
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.Log("LZP:SystemScript: Exiting ToggleLooting", 0)
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
