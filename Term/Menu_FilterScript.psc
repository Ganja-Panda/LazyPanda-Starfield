;======================================================================
; Script: LZP:Term:Menu_FilterScript
; Description: This script manages the main menu filter functionality.
; It updates settings based on user interactions and provides feedback
; through messages. Debug logging is integrated to assist with troubleshooting.
;======================================================================

ScriptName LZP:Term:Menu_FilterScript Extends TerminalMenu hidden

;======================================================================
; PROPERTIES
;======================================================================

;-- Autofill Properties --
; Messages displayed to the player when toggling settings.
Group Autofill
    Message Property LPOffMsg Auto Const mandatory
    Message Property LPOnMsg Auto Const mandatory
EndGroup

;-- Menu-Specific Properties --
; Form lists and other properties specific to the menu.
Group MenuSpecific
    FormList Property SettingsGlobals Auto Const mandatory
EndGroup

;-- Terminal Properties --
; References to the current terminal menu.
Group Terminal
    TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
EndGroup

;-- Logger Property --
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;-- UpdateSetting Function --
; Updates a setting and logs the change.
Function UpdateSetting(Int index, Float newValue, Message newMsg, ObjectReference akTerminalRef)
    GlobalVariable setting = SettingsGlobals.GetAt(index) as GlobalVariable
    If setting
        setting.SetValue(newValue)
        akTerminalRef.AddTextReplacementData("State" + index as String, newMsg as Form)
        
        String stateStr = ""
        If newValue == 1.0
            stateStr = "LPOnMsg"
        Else
            stateStr = "LPOffMsg"
        EndIf
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Term:Menu_FilterScript: Setting State" + index as String + " updated to " + stateStr)
        EndIf
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Term:Menu_FilterScript: No setting found at index: " + index as String)
        EndIf
    EndIf
EndFunction

;======================================================================
; EVENTS
;======================================================================

;-- OnTerminalMenuEnter Event Handler --
; Called when the terminal menu is entered.
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Term:Menu_FilterScript: OnTerminalMenuEnter triggered")
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
                replacementMsg = LPOnMsg
                stateStr = "LPOnMsg"
            Else
                replacementMsg = LPOffMsg
                stateStr = "LPOffMsg"
            EndIf
            akTerminalRef.AddTextReplacementData("State" + index as String, replacementMsg as Form)
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Term:Menu_FilterScript: Setting State" + index as String + " to " + stateStr)
            EndIf
        Else
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Term:Menu_FilterScript: No setting found at index: " + index as String)
            EndIf
        EndIf
        index += 1
    EndWhile
EndEvent

;-- OnTerminalMenuItemRun Event Handler --
; Called when a terminal menu item is run.
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Term:Menu_FilterScript: OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String)
    EndIf
    If akTerminalBase != CurrentTerminalMenu
        Return
    EndIf

    If auiMenuItemID == 0
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Term:Menu_FilterScript: Menu item 0 selected: Toggle all settings")
        EndIf
        GlobalVariable allToggle = SettingsGlobals.GetAt(0) as GlobalVariable
        Float newValue = 0.0
        If allToggle.GetValue() == 1.0
            newValue = 0.0
        Else
            newValue = 1.0
        EndIf

        Message newMsg
        If newValue == 1.0
            newMsg = LPOnMsg
        Else
            newMsg = LPOffMsg
        EndIf

        Int count = SettingsGlobals.GetSize()
        Int index = 0
        While index < count
            UpdateSetting(index, newValue, newMsg, akTerminalRef)
            index += 1
        EndWhile
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Term:Menu_FilterScript: Menu item " + auiMenuItemID as String + " selected: Toggle specific setting")
        EndIf
        GlobalVariable setting = SettingsGlobals.GetAt(auiMenuItemID) as GlobalVariable
        If setting
            Float newValue = 0.0
            If setting.GetValue() == 1.0
                newValue = 0.0
            Else
                newValue = 1.0
            EndIf

            Message newMsg
            If newValue == 1.0
                newMsg = LPOnMsg
            Else
                newMsg = LPOffMsg
            EndIf

            UpdateSetting(auiMenuItemID, newValue, newMsg, akTerminalRef)
        Else
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Term:Menu_FilterScript: No setting found for menu item " + auiMenuItemID as String)
            EndIf
        EndIf
    EndIf
EndEvent
