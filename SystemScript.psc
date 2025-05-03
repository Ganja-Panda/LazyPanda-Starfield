;======================================================================
; Script Name   : LZP:SystemScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Stateless utility functions for use with cgf calls.
; Description   : Provides global inventory and system control functions
;                 including ship transfers, lodge access, and safe toggles.
;                 Includes integrated logging with verbosity levels:
;                   0 = Debug, 1 = Info, 2 = Warning, 3 = Error
; Dependencies  :  LazyPanda_210.esm
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
    Return Game.GetFormFromFile(0x0000098D, "LazyPanda_210.esm") as LZP:Debug:LoggerScript
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
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x09CE, "LazyPanda_210.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Entering OpenHoldingInventory", 0, "SystemScript")
    EndIf
    ObjectReference LZP_Cont_StorageRef = Game.GetFormFromFile(0x09AD, "LazyPanda_210.esm") as ObjectReference
    If LZP_Cont_StorageRef
        (LZP_Cont_StorageRef as Actor).OpenInventory(True, None, False)
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: ERROR - LZP_Cont_StorageRef not found", 3, "SystemScript")
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
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x09CE, "LazyPanda_210.esm") as LZP:Debug:LoggerScript
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
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x09CE, "LazyPanda_210.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Entering OpenShipCargo", 0, "SystemScript")
    EndIf
    Quest SQ_PlayerShip = Game.GetFormFromFile(0x174A2, "LazyPanda_210.esm") as Quest
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
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x09CE, "LazyPanda_210.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Entering MoveAllToShip", 0, "SystemScript")
    EndIf
    Message LZP_MESG_AllItems_Ship = Game.GetFormFromFile(0x0962, "LazyPanda_210.esm") as Message
    ObjectReference LZP_Cont_StorageRef = Game.GetFormFromFile(0x09AD, "LazyPanda_210.esm") as ObjectReference
    Quest SQ_PlayerShip = Game.GetFormFromFile(0x174A2, "LazyPanda_210.esm") as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    ObjectReference PlayerShip = PlayerHomeShip.GetRef()
    If LZP_Cont_StorageRef && PlayerShip
        LZP_Cont_StorageRef.RemoveAllItems(PlayerShip, False, False)
        LZP_MESG_AllItems_Ship.Show()
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: ERROR - LZP_Cont_StorageRef or PlayerShip not found", 3, "SystemScript")
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
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x09CE, "LazyPanda_210.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Entering MoveResourcesToShip", 0, "SystemScript")
    EndIf
    Message LZP_MESG_ResourcesToShip = Game.GetFormFromFile(0x0967, "LazyPanda_210.esm") as Message
    FormList LZP_System_Script_Resources = Game.GetFormFromFile(0x08AE, "LazyPanda_210.esm") as FormList
    Quest SQ_PlayerShip = Game.GetFormFromFile(0x174A2, "LazyPanda_210.esm") as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    ObjectReference PlayerShip = PlayerHomeShip.GetRef()
    ObjectReference LZP_Cont_StorageRef = Game.GetFormFromFile(0x09AD, "LazyPanda_210.esm") as ObjectReference
    If PlayerShip && LZP_Cont_StorageRef
        LZP_Cont_StorageRef.RemoveItem(LZP_System_Script_Resources as Form, -1, True, PlayerShip)
        Game.GetPlayer().RemoveItem(LZP_System_Script_Resources as Form, -1, True, PlayerShip)
        LZP_MESG_ResourcesToShip.Show()
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: ERROR - PlayerShip or LZP_Cont_StorageRef not found", 3, "SystemScript")
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
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x09CE, "LazyPanda_210.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Entering MoveValuablesToPlayer", 0, "SystemScript")
    EndIf
    Message LZP_MESG_ValuablesToPlayer = Game.GetFormFromFile(0x0968, "LazyPanda_210.esm") as Message
    FormList LZP_System_Script_Valuables = Game.GetFormFromFile(0x08AF, "LazyPanda_210.esm") as FormList
    Quest SQ_PlayerShip = Game.GetFormFromFile(0x174A2, "LazyPanda_210.esm") as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    ObjectReference PlayerShip = PlayerHomeShip.GetRef()
    ObjectReference LZP_Cont_StorageRef = Game.GetFormFromFile(0x09AD, "LazyPanda_210.esm") as ObjectReference
    If PlayerShip
        PlayerShip.RemoveItem(LZP_System_Script_Valuables as Form, -1, True, Game.GetPlayer())
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: WARNING - PlayerShip not found", 2, "SystemScript")
    EndIf
    If LZP_Cont_StorageRef
        LZP_Cont_StorageRef.RemoveItem(LZP_System_Script_Valuables as Form, -1, True, Game.GetPlayer())
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: WARNING - LZP_Cont_StorageRef not found", 2, "SystemScript")
    EndIf
    LZP_MESG_ValuablesToPlayer.Show()
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
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x09CE, "LazyPanda_210.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Entering MoveInventoryToLodgeSafe", 0, "SystemScript")
    EndIf
    Message LZP_MESG_AllItems_Lodge = Game.GetFormFromFile(0x0961, "LazyPanda_210.esm") as Message
    Message LZP_MESG_NoItems = Game.GetFormFromFile(0x0966, "LazyPanda_210.esm") as Message
    ObjectReference LZP_Cont_StorageRef = Game.GetFormFromFile(0x09AD, "LazyPanda_210.esm") as ObjectReference
    ObjectReference LodgeSafeRef = Game.GetFormFromFile(0x266E81, "LazyPanda_210.esm") as ObjectReference
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Checking item count in dummy holding container", 0, "SystemScript")
    EndIf
    If LZP_Cont_StorageRef.GetItemCount(None) > 0
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.LogAdv("LZP:SystemScript: Items found in dummy holding container. Transferring items to Lodge Safe", 1, "SystemScript")
        EndIf
        LZP_Cont_StorageRef.RemoveAllItems(LodgeSafeRef, False, False)
        LZP_MESG_AllItems_Lodge.Show()
    Else
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.LogAdv("LZP:SystemScript: No items found in dummy holding container. Displaying LPNoItemsMsg", 1, "SystemScript")
        EndIf
        LZP_MESG_NoItems.Show()
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
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x09CE, "LazyPanda_210.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Entering OpenTerminal", 0, "SystemScript")
    EndIf
    ObjectReference LZP_Terminal_DummyRef = Game.GetFormFromFile(0x09AE, "LazyPanda_210.esm") as ObjectReference
    If LZP_Terminal_DummyRef
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.LogAdv("LZP:SystemScript: Activating terminal object", 1, "SystemScript")
        EndIf
        LZP_Terminal_DummyRef.Activate(Game.GetPlayer(), False)
    ElseIf LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: ERROR - LZP_Terminal_DummyRef not found", 3, "SystemScript")
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
    LZP:Debug:LoggerScript LoggerScript = Game.GetFormFromFile(0x09CE, "LazyPanda_210.esm") as LZP:Debug:LoggerScript
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Entering ToggleLooting", 0, "SystemScript")
    EndIf
    Message LZP_MESG_Looting_Enabled = Game.GetFormFromFile(0x0959, "LazyPanda_210.esm") as Message
    Message LZP_MESG_Looting_Disabled = Game.GetFormFromFile(0x095A, "LazyPanda_210.esm") as Message
    GlobalVariable LZP_System_ToggleLooting = Game.GetFormFromFile(0x0810, "LazyPanda_210.esm") as GlobalVariable
    Int currentToggle = LZP_System_ToggleLooting.GetValue() as Int
    If LoggerScript && LoggerScript.IsEnabled()
        LoggerScript.LogAdv("LZP:SystemScript: Current looting toggle value = " + currentToggle, 1, "SystemScript")
    EndIf
    If currentToggle == 0
        LZP_System_ToggleLooting.SetValue(1.0)
        LZP_MESG_Looting_Enabled.Show()
        If LoggerScript && LoggerScript.IsEnabled()
            LoggerScript.LogAdv("LZP:SystemScript: Looting enabled", 1, "SystemScript")
        EndIf
    ElseIf currentToggle == 1
        LZP_System_ToggleLooting.SetValue(0.0)
        LZP_MESG_Looting_Disabled.Show()
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
    GlobalVariable LZP_System_Logging = Game.GetFormFromFile(0x080F, "LazyPanda_210.esm") as GlobalVariable
    Message LZP_MESG_Logging_Enabled = Game.GetFormFromFile(0x0964, "LazyPanda_210.esm") as Message
    Message LZP_MESG_Logging_Disabled = Game.GetFormFromFile(0x0963, "LazyPanda_210.esm") as Message
    Int currentDebug = LZP_System_Logging.GetValue() as Int
    If currentDebug == 0
        LZP_System_Logging.SetValue(1.0)
        LZP_MESG_Logging_Enabled.Show()
    ElseIf currentDebug == 1
        LZP_System_Logging.SetValue(0.0)
        LZP_MESG_Logging_Disabled.Show()
    EndIf
EndFunction


;----------------------------------------------------------------------
; Version: Get build number from global variable (e.g., 20100 = v2.1.0)
;----------------------------------------------------------------------
GlobalVariable Function GetGlobalVersionBuild() Global
    return Game.GetFormFromFile(0x0854, "LazyPanda_210.esm") as GlobalVariable
EndFunction

Int Function GetBuildVersion() Global
    return GetGlobalVersionBuild().GetValueInt()
EndFunction
