;======================================================================
; Script: LZP:Term:Menu_SettingsAlwaysLootScript
; Description: This script manages the settings for the Always Loot feature.
; It updates settings based on user interactions and provides feedback
; through messages. Debug logging is integrated to assist with troubleshooting.
;======================================================================

ScriptName LZP:Term:Menu_SettingsAlwaysLootScript Extends TerminalMenu hidden

;======================================================================
; PROPERTIES
;======================================================================

;-- Terminal Menu Properties --
; Properties required for the terminal menu functionality.
TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
Form[] Property SettingsGlobals Auto Const mandatory
Message Property LPOffMsg Auto Const mandatory
Message Property LPOnMsg Auto Const mandatory

;-- Logger Property --
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

Function UpdateSettingDisplay(Int index, ObjectReference akTerminalRef)
    GlobalVariable setting = SettingsGlobals[index] as GlobalVariable
    If setting
        Float value = setting.GetValue()
        Message replacementMsg
        If value == 1.0
            replacementMsg = LPOnMsg
        Else
            replacementMsg = LPOffMsg
        EndIf
        akTerminalRef.AddTextReplacementData("State" + index as String, replacementMsg as Form)
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Term:Menu_SettingsAlwaysLootScript: UpdateSettingDisplay: Setting at index " + index as String + " not found")
        EndIf
    EndIf
EndFunction

;======================================================================
; EVENTS
;======================================================================

;-- OnTerminalMenuEnter Event Handler --
; Called when the terminal menu is entered. Updates the display for all settings.
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    Int index = 0
    While index < SettingsGlobals.Length
        UpdateSettingDisplay(index, akTerminalRef)
        index += 1
    EndWhile
EndEvent

;-- OnTerminalMenuItemRun Event Handler --
; Called when a menu item is selected. Toggles the setting value and updates the display.
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If akTerminalBase == CurrentTerminalMenu
        GlobalVariable setting = SettingsGlobals[auiMenuItemID] as GlobalVariable
        If setting
            Float value = setting.GetValue()
            If value == 1.0
                setting.SetValue(0.0)
            Else
                setting.SetValue(1.0)
            EndIf
            UpdateSettingDisplay(auiMenuItemID, akTerminalRef)
        Else
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Term:Menu_SettingsAlwaysLootScript: OnTerminalMenuItemRun: Setting at index " + auiMenuItemID as String + " not found")
            EndIf
        EndIf
    EndIf
EndEvent
