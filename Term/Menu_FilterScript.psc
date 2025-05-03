;======================================================================
; Script Name   : LZP:Term:Menu_FilterScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Manages toggle settings through a terminal menu interface
; Description   : This script handles player interactions with a terminal
;                 menu that modifies gameplay settings. Based on selections,
;                 it updates GlobalVariables and reflects new states via
;                 message replacement text. Logger integration ensures traceable
;                 user behavior for debugging.
; Dependencies  : LazyPanda.esm, LoggerScript, TerminalMenu, GlobalVariables
; Usage         : Attach to a TerminalMenu and configure menu items by index
;======================================================================

ScriptName LZP:Term:Menu_FilterScript Extends TerminalMenu hidden

;======================================================================
; PROPERTIES
;======================================================================

;------------------------------
; Autofill
; Messages displayed to the player when toggling settings
;------------------------------
Group Autofill
    Message Property LZP_MESG_Status_Disabled Auto Const mandatory
    Message Property LZP_MESG_Status_Enabled Auto Const mandatory
EndGroup

;------------------------------
; MenuSpecific
; Form lists and properties used for menu configuration
;------------------------------
Group MenuSpecific
    FormList Property SettingsGlobals Auto Const mandatory
EndGroup

;------------------------------
; Terminal
; Terminal menu instance that this script controls
;------------------------------
Group Terminal
    TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
EndGroup

;------------------------------
; Logger
; LoggerScript instance for tracking debug output
;------------------------------
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;------------------------------
; Tokens
; Dynamic replacement tokens used in the terminal menu
;------------------------------
Group Tokens
    String Property Token_StatePrefix = "State" Auto Const hidden
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;----------------------------------------------------------------------
; Function : UpdateSetting
; Purpose  : Updates a single setting and sends trace output
; Params   : index         - Index of the GlobalVariable to update
;            newValue      - New float value to set
;            newMsg        - Message form to display after update
;            akTerminalRef - Terminal reference used to apply replacement
;----------------------------------------------------------------------
Function UpdateSetting(Int index, Float newValue, Message newMsg, ObjectReference akTerminalRef)
    GlobalVariable setting = SettingsGlobals.GetAt(index) as GlobalVariable
    If setting
        setting.SetValue(newValue)
        akTerminalRef.AddTextReplacementData(Token_StatePrefix + index as String, newMsg as Form)

        String stateStr = ""
        If newValue == 1.0
            stateStr = "LZP_MESG_Status_Enabled"
        Else
            stateStr = "LZP_MESG_Status_Enabled"
        EndIf

        If Logger && Logger.IsEnabled()
            Logger.LogAdv("Menu_FilterScript: Setting " + Token_StatePrefix + index as String + " updated to " + stateStr, 1, "Menu_FilterScript")
        EndIf
    Else
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("Menu_FilterScript: No setting found at index: " + index as String, 2, "Menu_FilterScript")
        EndIf
    EndIf
EndFunction

;======================================================================
; EVENTS
;======================================================================

;----------------------------------------------------------------------
; Event : OnTerminalMenuEnter
; Purpose: Called when terminal menu is entered. Updates toggle display text.
;----------------------------------------------------------------------
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("Menu_FilterScript: OnTerminalMenuEnter triggered", 1, "Menu_FilterScript")
    EndIf

    Int count = SettingsGlobals.GetSize()
    Int index = 0
    While index < count
        GlobalVariable setting = SettingsGlobals.GetAt(index) as GlobalVariable
        If setting
            Float value = setting.GetValue()
            Message replacementMsg
            String stateStr = ""

            If value == 1.0
                replacementMsg =  LZP_MESG_Status_Enabled
                stateStr = "LZP_MESG_Status_Enable"
            Else
                replacementMsg = LZP_MESG_Status_Disabled
                stateStr = "LZP_MESG_Status_Disable"
            EndIf

            akTerminalRef.AddTextReplacementData(Token_StatePrefix + index as String, replacementMsg as Form)

            If Logger && Logger.IsEnabled()
                Logger.LogAdv("Menu_FilterScript: Setting " + Token_StatePrefix + index as String + " to " + stateStr, 1, "Menu_FilterScript")
            EndIf
        Else
            If Logger && Logger.IsEnabled()
                Logger.LogAdv("Menu_FilterScript: No setting found at index: " + index as String, 2, "Menu_FilterScript")
            EndIf
        EndIf
        index += 1
    EndWhile
EndEvent

;----------------------------------------------------------------------
; Event : OnTerminalMenuItemRun
; Purpose: Handles toggling logic for selected item or all settings.
;----------------------------------------------------------------------
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("Menu_FilterScript: OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String, 1, "Menu_FilterScript")
    EndIf

    If akTerminalBase != CurrentTerminalMenu
        Return
    EndIf

    If auiMenuItemID == 0
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("Menu_FilterScript: Menu item 0 selected: Toggle all settings", 1, "Menu_FilterScript")
        EndIf

        GlobalVariable allToggle = SettingsGlobals.GetAt(0) as GlobalVariable

        Float newValue
        If allToggle.GetValue() == 1.0
            newValue = 0.0
        Else
            newValue = 1.0
        EndIf

        Message newMsg
        If newValue == 1.0
            newMsg = LZP_MESG_Status_Enabled
        Else
            newMsg = LZP_MESG_Status_Disabled
        EndIf

        Int count = SettingsGlobals.GetSize()
        Int index = 0
        While index < count
            UpdateSetting(index, newValue, newMsg, akTerminalRef)
            index += 1
        EndWhile
    Else
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("Menu_FilterScript: Menu item " + auiMenuItemID as String + " selected: Toggle specific setting", 1, "Menu_FilterScript")
        EndIf

        GlobalVariable setting = SettingsGlobals.GetAt(auiMenuItemID) as GlobalVariable
        If setting
            Float newValue
            If setting.GetValue() == 1.0
                newValue = 0.0
            Else
                newValue = 1.0
            EndIf

            Message newMsg
            If newValue == 1.0
                newMsg = LZP_MESG_Status_Enabled
            Else
                newMsg = LZP_MESG_Status_Disabled
            EndIf

            UpdateSetting(auiMenuItemID, newValue, newMsg, akTerminalRef)
        Else
            If Logger && Logger.IsEnabled()
                Logger.LogAdv("Menu_FilterScript: No setting found for menu item " + auiMenuItemID as String, 2, "Menu_FilterScript")
            EndIf
        EndIf
    EndIf
EndEvent
