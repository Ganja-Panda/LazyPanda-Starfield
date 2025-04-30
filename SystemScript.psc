;======================================================================
; Script Name   : LZP:SystemScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Stateless utility functions for use with cgf calls.
; Description   : Provides global inventory and system control functions
;                 including ship transfers, lodge access, and safe toggles.
;                 Includes integrated logging with verbosity levels:
;                   0 = Debug, 1 = Info, 2 = Warning, 3 = Error
; Dependencies  : LazyPanda.esm
; Usage         : All functions are global and safe to invoke via console:
;                   cgf "LZP:SystemScript.FunctionName"
;======================================================================

ScriptName LZP:SystemScript Extends ScriptObject

;======================================================================
; DYNAMIC VERSION GLOBALS
;======================================================================

GlobalVariable Function GetGlobalVersionMajor() Global
    return Game.GetFormFromFile(0x00000856, "LazyPanda_210.esm") as GlobalVariable
EndFunction

GlobalVariable Function GetGlobalVersionMinor() Global
    return Game.GetFormFromFile(0x00000857, "LazyPanda_210.esm") as GlobalVariable
EndFunction

GlobalVariable Function GetGlobalVersionPatch() Global
    return Game.GetFormFromFile(0x00000858, "LazyPanda_210.esm") as GlobalVariable
EndFunction

;======================================================================
; INTERNAL HELPERS
;======================================================================

LZP:Debug:LoggerScript Function GetLogger() Global
    Return Game.GetFormFromFile(0x0000098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
EndFunction

String Function GetFormattedVersion() Global
    Float major = GetGlobalVersionMajor().GetValue()
    Float minor = GetGlobalVersionMinor().GetValue()
    Float patch = GetGlobalVersionPatch().GetValue()
    Return major + "." + minor + "." + patch
EndFunction

Function LogIfEnabled(String msg, Int level = 1, String tag = "SystemScript") Global
    LZP:Debug:LoggerScript logger = GetLogger()
    If logger && logger.IsEnabled()
        logger.LogAdv(msg, level, tag)
    EndIf
EndFunction

;======================================================================
; GLOBAL FUNCTIONS
;======================================================================

;---------------------------------------------------------------------
; Opens the inventory of the dummy holding container.
; Used for temporary storage access.
; cgf "LZP:SystemScript.OpenHoldingInventory"
;---------------------------------------------------------------------
Function OpenHoldingInventory() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Entering OpenHoldingInventory", 0, "SystemScript")
    EndIf
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x09C1, "LazyPanda.esm") as ObjectReference
    If LPDummyHoldingRef
        (LPDummyHoldingRef as Actor).OpenInventory(True, None, False)
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: ERROR - LPDummyHoldingRef not found", 3, "SystemScript")
    EndIf
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Exiting OpenHoldingInventory", 0, "SystemScript")
    EndIf
EndFunction

;---------------------------------------------------------------------
; Opens the Lodge Safe container for item deposit/retrieval.
; cgf "LZP:SystemScript.OpenLodgeSafe"
;---------------------------------------------------------------------
Function OpenLodgeSafe() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Entering OpenLodgeSafe", 0, "SystemScript")
    EndIf
    ObjectReference LodgeSafeRef = Game.GetForm(0x266E81) as ObjectReference
    If LodgeSafeRef
        LodgeSafeRef.Activate(Game.GetPlayer() as ObjectReference, False)
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: ERROR - LodgeSafeRef not found", 3, "SystemScript")
    EndIf
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Exiting OpenLodgeSafe", 0, "SystemScript")
    EndIf
EndFunction

;---------------------------------------------------------------------
; Opens the player's home ship cargo hold.
; cgf "LZP:SystemScript.OpenShipCargo"
;---------------------------------------------------------------------
Function OpenShipCargo() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Entering OpenShipCargo", 0, "SystemScript")
    EndIf
    Quest SQ_PlayerShip = Game.GetFormFromFile(0x174A2, "LazyPanda.esm") as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    spaceshipreference PlayerShip = PlayerHomeShip.GetRef() as spaceshipreference
    If PlayerShip
        PlayerShip.OpenInventory()
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: ERROR - PlayerShip reference not found", 3, "SystemScript")
    EndIf
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Exiting OpenShipCargo", 0, "SystemScript")
    EndIf
EndFunction

;---------------------------------------------------------------------
; Transfers all items from dummy container to player's ship.
; cgf "LZP:SystemScript.MoveAllToShip"
;---------------------------------------------------------------------
Function MoveAllToShip() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Entering MoveAllToShip", 0, "SystemScript")
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
        LoggerScript.LogAdv("LZP:SystemScript: ERROR - LPDummyHoldingRef or PlayerShip not found", 3, "SystemScript")
    EndIf
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Exiting MoveAllToShip", 0, "SystemScript")
    EndIf
EndFunction

;---------------------------------------------------------------------
; Transfers resource items from player and dummy container
; to the player's ship. Uses defined resource FormList.
; cgf "LZP:SystemScript.MoveResourcesToShip"
;---------------------------------------------------------------------
Function MoveResourcesToShip() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Entering MoveResourcesToShip", 0, "SystemScript")
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
        LoggerScript.LogAdv("LZP:SystemScript: ERROR - PlayerShip or LPDummyHoldingRef not found", 3, "SystemScript")
    EndIf
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Exiting MoveResourcesToShip", 0, "SystemScript")
    EndIf
EndFunction

;---------------------------------------------------------------------
; Transfers valuable items from ship and container to player.
; cgf "LZP:SystemScript.MoveValuablesToPlayer"
;---------------------------------------------------------------------
Function MoveValuablesToPlayer() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Entering MoveValuablesToPlayer", 0, "SystemScript")
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
        LoggerScript.LogAdv("LZP:SystemScript: WARNING - PlayerShip not found", 2, "SystemScript")
    EndIf
    If LPDummyHoldingRef
        LPDummyHoldingRef.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer())
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: WARNING - LPDummyHoldingRef not found", 2, "SystemScript")
    EndIf
    LPValuablesToPlayerMsg.Show()
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Exiting MoveValuablesToPlayer", 0, "SystemScript")
    EndIf
EndFunction

;---------------------------------------------------------------------
; Transfers all items from dummy container to Lodge Safe.
; Displays a message depending on whether items exist.
; cgf "LZP:SystemScript.MoveInventoryToLodgeSafe"
;---------------------------------------------------------------------
Function MoveInventoryToLodgeSafe() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Entering MoveInventoryToLodgeSafe", 0, "SystemScript")
    EndIf
    Message LPAllItemsToLodgeMsg = Game.GetFormFromFile(0x092C, "LazyPanda.esm") as Message
    Message LPNoItemsMsg = Game.GetFormFromFile(0x0920, "LazyPanda.esm") as Message
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x09C1, "LazyPanda.esm") as ObjectReference
    ObjectReference LodgeSafeRef = Game.GetFormFromFile(0x266E81, "LazyPanda.esm") as ObjectReference
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Checking item count in dummy holding container", 0, "SystemScript")
    EndIf
    If LPDummyHoldingRef.GetItemCount(None) > 0
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.LogAdv("LZP:SystemScript: Items found in dummy holding container. Transferring items to Lodge Safe", 1, "SystemScript")
        EndIf
        LPDummyHoldingRef.RemoveAllItems(LodgeSafeRef, False, False)
        LPAllItemsToLodgeMsg.Show()
    Else
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.LogAdv("LZP:SystemScript: No items found in dummy holding container. Displaying LPNoItemsMsg", 1, "SystemScript")
        EndIf
        LPNoItemsMsg.Show()
    EndIf
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Exiting MoveInventoryToLodgeSafe", 0, "SystemScript")
    EndIf
EndFunction

;---------------------------------------------------------------------
; Opens the player-assigned terminal object.
; cgf "LZP:SystemScript.OpenTerminal"
;---------------------------------------------------------------------
Function OpenTerminal() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Entering OpenTerminal", 0, "SystemScript")
    EndIf
    ObjectReference TerminalRef = Game.GetFormFromFile(0x08CD, "LazyPanda.esm") as ObjectReference
    If TerminalRef
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.LogAdv("LZP:SystemScript: Activating terminal object", 1, "SystemScript")
        EndIf
        TerminalRef.Activate(Game.GetPlayer(), False)
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: ERROR - TerminalRef not found", 3, "SystemScript")
    EndIf
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Exiting OpenTerminal", 0, "SystemScript")
    EndIf
EndFunction

;---------------------------------------------------------------------
; Toggles the looting state of the player character.
; Controlled via global variable.
; cgf "LZP:SystemScript.ToggleLooting"
;---------------------------------------------------------------------
Function ToggleLooting() Global
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x098D, "LazyPanda.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Entering ToggleLooting", 0, "SystemScript")
    EndIf
    Message LPLootingEnabledMsg = Game.GetFormFromFile(0x097E, "LazyPanda.esm") as Message
    Message LPLootingDisabledMsg = Game.GetFormFromFile(0x097F, "LazyPanda.esm") as Message
    GlobalVariable LPUtil_ToggleLooting = Game.GetFormFromFile(0x086A, "LazyPanda.esm") as GlobalVariable
    Int currentToggle = LPUtil_ToggleLooting.GetValue() as Int
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Current looting toggle value = " + currentToggle, 1, "SystemScript")
    EndIf
    If currentToggle == 0
        LPUtil_ToggleLooting.SetValue(1.0)
        LPLootingEnabledMsg.Show()
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.LogAdv("LZP:SystemScript: Looting enabled", 1, "SystemScript")
        EndIf
    ElseIf currentToggle == 1
        LPUtil_ToggleLooting.SetValue(0.0)
        LPLootingDisabledMsg.Show()
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.LogAdv("LZP:SystemScript: Looting disabled", 1, "SystemScript")
        EndIf
    EndIf
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Exiting ToggleLooting", 0, "SystemScript")
    EndIf
EndFunction

;---------------------------------------------------------------------
; Toggles Lazy Panda debug logging on/off.
; Safe to call from console.
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


;----------------------------------------------------------------------
; Version: Get build number from global variable (e.g., 20100 = v2.1.0)
;----------------------------------------------------------------------
GlobalVariable Function GetGlobalVersionBuild() Global
    return Game.GetFormFromFile(0x0863, "LazyPanda.esm") as GlobalVariable
EndFunction

Int Function GetBuildVersion() Global
    return GetGlobalVersionBuild().GetValueInt()
EndFunction
