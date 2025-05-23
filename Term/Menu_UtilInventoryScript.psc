;======================================================================
; Script Name   : LZP:Term:Menu_UtilInventoryScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Provides access to utility containers and system toggles
; Description   : This script allows the player to interact with utility options
;                 such as toggling looting/debugging, opening the Lodge Safe, the
;                 Dummy Holding container, or the Player Home Ship. Displays feedback
;                 in the terminal via replacement messages and logs all actions.
; Dependencies  : LazyPanda.esm, LoggerScript, TerminalMenu, GlobalVariables
; Usage         : Attach to a terminal menu that maps these utilities to item IDs
;======================================================================

ScriptName LZP:Term:Menu_UtilInventoryScript Extends TerminalMenu hidden

;======================================================================
; PROPERTIES
;======================================================================

;------------------------------
; TerminalConfig
; Primary references for inventory/activation targets
;------------------------------
Group Menu_UtilProperties
    TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
    ObjectReference Property LodgeSafeRef Auto Const mandatory
    ObjectReference Property LZP_Cont_StorageRef Auto Const mandatory
    ObjectReference Property PlayerRef Auto Const mandatory
    ReferenceAlias Property PlayerHomeShip Auto Const mandatory
EndGroup

;------------------------------
; DebugGlobals
; GlobalVariable controlling debug toggle
;------------------------------
Group DebugProperties
    GlobalVariable Property LZP_System_Logging Auto Const mandatory
EndGroup

;------------------------------
; LootSettings
; GlobalVariable for system-wide toggle looting
;------------------------------
Group GlobalVariable_Autofill
    GlobalVariable Property LZP_System_ToggleLooting Auto mandatory
EndGroup

;------------------------------
; FeedbackMessages
; Terminal message output (On/Off/Debug)
;------------------------------
Group Message_Autofill
    Message Property LZP_MESG_Status_Enabled Auto Const mandatory
    Message Property LZP_MESG_Status_Disabled Auto Const mandatory
EndGroup

;------------------------------
; Logger
; LoggerScript instance for debug output
;------------------------------
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;------------------------------
; Tokens
; Replacement tokens for terminal display keys
;------------------------------
Group Tokens
    String Property Token_Looting = "Looting" Auto Const hidden
    String Property Token_Logging = "Logging" Auto Const hidden
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;----------------------------------------------------------------------
; Function : UpdateLootingDisplay
; Purpose  : Sets the terminal label for current looting status.
; Parameters:
;    akTerminalRef        - Terminal reference to update.
;    currentLootSetting   - Bool value of looting enabled.
;----------------------------------------------------------------------
Function UpdateLootingDisplay(ObjectReference akTerminalRef, Bool currentLootSetting)
    If !currentLootSetting
        akTerminalRef.AddTextReplacementData(Token_Looting, LZP_MESG_Status_Disabled as Form)
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("UpdateLootingDisplay: Looting is off", 1, "Menu_UtilInventoryScript")
        EndIf
    Else
        akTerminalRef.AddTextReplacementData(Token_Looting, LZP_MESG_Status_Enabled as Form)
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("UpdateLootingDisplay: Looting is on", 1, "Menu_UtilInventoryScript")
        EndIf
    EndIf
EndFunction

;----------------------------------------------------------------------
; Function : UpdateDebugDisplay
; Purpose  : Sets the terminal label for current debug setting.
; Parameters:
;    akTerminalRef        - Terminal reference to update.
;    currentDebugStatus   - Bool value of debug enabled.
;----------------------------------------------------------------------
Function UpdateDebugDisplay(ObjectReference akTerminalRef, Bool currentDebugStatus)
    If currentDebugStatus
        akTerminalRef.AddTextReplacementData(Token_Logging, LZP_MESG_Status_Enabled as Form)
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("UpdateDebugDisplay: Logging is on", 1, "Menu_UtilInventoryScript")
        EndIf
    Else
        akTerminalRef.AddTextReplacementData(Token_Logging, LZP_MESG_Status_Disabled as Form)
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("UpdateDebugDisplay: Logging is off", 1, "Menu_UtilInventoryScript")
        EndIf
    EndIf
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;----------------------------------------------------------------------
; Event : OnTerminalMenuEnter
; Purpose: Initializes display values for loot and debug toggles.
;----------------------------------------------------------------------
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("OnTerminalMenuEnter: Triggered", 1, "Menu_UtilInventoryScript")
    EndIf

    ; Get current settings.
    Bool currentLootSetting = LZP_System_ToggleLooting.GetValue() as Bool
    Bool currentDebugStatus = LZP_System_Logging.GetValue() as Bool

    ; Log current settings.
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("OnTerminalMenuEnter: Current loot setting", 1, "Menu_UtilInventoryScript")
        Logger.LogAdv(currentLootSetting as String, 1, "Menu_UtilInventoryScript")
        Logger.LogAdv("OnTerminalMenuEnter: Current logging status", 1, "Menu_UtilInventoryScript")
        Logger.LogAdv(currentDebugStatus as String, 1, "Menu_UtilInventoryScript")
    EndIf

    ; Update displays.
    UpdateLootingDisplay(akTerminalRef, currentLootSetting)
    UpdateDebugDisplay(akTerminalRef, currentDebugStatus)
EndEvent

;----------------------------------------------------------------------
; Event : OnTerminalMenuItemRun
; Purpose: Executes action based on selected menu item index.
;----------------------------------------------------------------------
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("OnTerminalMenuItemRun: Triggered with MenuItemID", 1, "Menu_UtilInventoryScript")
        Logger.LogAdv(auiMenuItemID as String, 1, "Menu_UtilInventoryScript")
    EndIf

    If akTerminalBase == CurrentTerminalMenu
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("OnTerminalMenuItemRun: Terminal menu matches CurrentTerminalMenu", 1, "Menu_UtilInventoryScript")
        EndIf

        ; Toggle logging when menu item 0 is selected.
        If auiMenuItemID == 0
            Bool currentLoggingSetting = LZP_System_Logging.GetValue() as Bool
            If Logger && Logger.IsEnabled()
                Logger.LogAdv("OnTerminalMenuItemRun: Current logging setting", 1, "Menu_UtilInventoryScript")
                Logger.LogAdv(currentLoggingSetting as String, 1, "Menu_UtilInventoryScript")
            EndIf
            If !currentLoggingSetting
                LZP_System_Logging.SetValue(1.0)
                If Logger && Logger.IsEnabled()
                    Logger.LogAdv("OnTerminalMenuItemRun: Turning logging on", 1, "Menu_UtilInventoryScript")
                EndIf
            Else
                LZP_System_Logging.SetValue(0.0)
                If Logger && Logger.IsEnabled()
                    Logger.LogAdv("OnTerminalMenuItemRun: Turning logging off", 1, "Menu_UtilInventoryScript")
                EndIf
            EndIf
            UpdateDebugDisplay(akTerminalRef, LZP_System_Logging.GetValue() as Bool)

        ; Toggle looting when menu item 1 is selected.
        ElseIf auiMenuItemID == 1
            Bool currentLootSetting = LZP_System_ToggleLooting.GetValue() as Bool
            If Logger && Logger.IsEnabled()
                Logger.LogAdv("OnTerminalMenuItemRun: Current looting setting", 1, "Menu_UtilInventoryScript")
                Logger.LogAdv(currentLootSetting as String, 1, "Menu_UtilInventoryScript")
            EndIf
            If !currentLootSetting
                LZP_System_ToggleLooting.SetValue(1.0)
                If Logger && Logger.IsEnabled()
                    Logger.LogAdv("OnTerminalMenuItemRun: Turning looting on", 1, "Menu_UtilInventoryScript")
                EndIf
            Else
                LZP_System_ToggleLooting.SetValue(0.0)
                If Logger && Logger.IsEnabled()
                    Logger.LogAdv("OnTerminalMenuItemRun: Turning looting off", 1, "Menu_UtilInventoryScript")
                EndIf
            EndIf
            UpdateLootingDisplay(akTerminalRef, LZP_System_ToggleLooting.GetValue() as Bool)

        ; Open inventory for LPDummyHoldingRef when menu item 2 is selected.
        ElseIf auiMenuItemID == 2
            If Logger && Logger.IsEnabled()
                Logger.LogAdv("OnTerminalMenuItemRun: Opening inventory for LZP_Cont_StorageRef", 1, "Menu_UtilInventoryScript")
            EndIf
            (LZP_Cont_StorageRef as Actor).OpenInventory(True, None, False)

        ; Activate LodgeSafeRef when menu item 3 is selected.
        ElseIf auiMenuItemID == 3
            If Logger && Logger.IsEnabled()
                Logger.LogAdv("OnTerminalMenuItemRun: Activating LodgeSafeRef", 1, "Menu_UtilInventoryScript")
            EndIf
            LodgeSafeRef.Activate(PlayerRef, False)

        ; Open inventory for PlayerHomeShip when menu item 4 is selected.
        ElseIf auiMenuItemID == 4
            If Logger && Logger.IsEnabled()
                Logger.LogAdv("OnTerminalMenuItemRun: Opening inventory for PlayerHomeShip", 1, "Menu_UtilInventoryScript")
            EndIf
            spaceshipreference PlayerShip = PlayerHomeShip.GetRef() as spaceshipreference
            PlayerShip.OpenInventory()
        EndIf
    EndIf
EndEvent
