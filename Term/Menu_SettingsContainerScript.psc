;======================================================================
; Script: LZP:Term:Menu_SettingsContainerScript
; Description: This script manages the settings for container options.
; It updates settings based on user interactions and provides feedback
; through messages. Debug logging is integrated to assist with troubleshooting.
;======================================================================

ScriptName LZP:Term:Menu_SettingsContainerScript Extends TerminalMenu hidden

;======================================================================
; PROPERTY GROUPS
;======================================================================

;-- Global Variables --
Group GlobalVariable_Autofill
    GlobalVariable Property LPSetting_RemoveCorpses Auto mandatory
    GlobalVariable Property LPSetting_ContTakeAll Auto mandatory
    GlobalVariable Property LPSetting_AutoUnlock Auto mandatory
    GlobalVariable Property LPSetting_AutoUnlockSkillCheck Auto mandatory
EndGroup

;-- Messages --
Group Message_Autofill
    Message Property LPOffMsg Auto Const mandatory
    Message Property LPOnMsg Auto Const mandatory
EndGroup

;-- Miscellaneous --
Group Misc
    TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
EndGroup

;-- Logger Property --
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;-- UpdateSettingDisplay Function --
; Updates the display of the setting on the terminal.
Function UpdateSettingDisplay(GlobalVariable setting, String label, ObjectReference akTerminalRef)
    If setting.GetValue() == 1.0
        akTerminalRef.AddTextReplacementData(label, LPOnMsg as Form)
        If Logger && Logger.IsEnabled()
            Logger.Log("Setting " + label + " to LPOnMsg")
        EndIf
    Else
        akTerminalRef.AddTextReplacementData(label, LPOffMsg as Form)
        If Logger && Logger.IsEnabled()
            Logger.Log("Setting " + label + " to LPOffMsg")
        EndIf
    EndIf
EndFunction

;-- ToggleSetting Function --
; Toggles the setting value and updates the display.
Function ToggleSetting(GlobalVariable setting, String label, ObjectReference akTerminalRef)
    If setting.GetValue() == 1.0
        setting.SetValue(0.0)
    Else
        setting.SetValue(1.0)
    EndIf
    UpdateSettingDisplay(setting, label, akTerminalRef)
EndFunction

;======================================================================
; EVENTS
;======================================================================

;-- OnTerminalMenuEnter Event Handler --
; Called when the terminal menu is entered.
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.Log("OnTerminalMenuEnter triggered")
    EndIf

    ; Log current settings for debugging purposes.
    Bool currentRemoveCorpsesSetting = LPSetting_RemoveCorpses.GetValue() == 1.0
    Bool currentTakeAllSetting = LPSetting_ContTakeAll.GetValue() == 1.0
    Bool currentAutoUnlockSetting = LPSetting_AutoUnlock.GetValue() == 1.0
    Bool currentAutoUnlockSkillCheckSetting = LPSetting_AutoUnlockSkillCheck.GetValue() == 1.0
    If Logger && Logger.IsEnabled()
        Logger.Log("Current settings - RemoveCorpses: " + currentRemoveCorpsesSetting + ", TakeAll: " + currentTakeAllSetting + ", AutoUnlock: " + currentAutoUnlockSetting + ", AutoUnlockSkillCheck: " + currentAutoUnlockSkillCheckSetting)
    EndIf

    ; Update display for each setting.
    UpdateSettingDisplay(LPSetting_AutoUnlock, "AutoUnlock", akTerminalRef)
    UpdateSettingDisplay(LPSetting_AutoUnlockSkillCheck, "AutoUnlockSkillCheck", akTerminalRef)
    UpdateSettingDisplay(LPSetting_RemoveCorpses, "Corpses", akTerminalRef)
    UpdateSettingDisplay(LPSetting_ContTakeAll, "TakeAll", akTerminalRef)
EndEvent

;-- OnTerminalMenuItemRun Event Handler --
; Called when a menu item is selected.
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.Log("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String)
    EndIf
    If akTerminalBase == CurrentTerminalMenu
        If Logger && Logger.IsEnabled()
            Logger.Log("Terminal menu matches CurrentTerminalMenu")
        EndIf
        ; Toggle the appropriate setting based on the menu item ID.
        If auiMenuItemID == 0
            If Logger && Logger.IsEnabled()
                Logger.Log("Toggling AutoUnlock")
            EndIf
            ToggleSetting(LPSetting_AutoUnlock, "AutoUnlock", akTerminalRef)
        ElseIf auiMenuItemID == 1
            If Logger && Logger.IsEnabled()
                Logger.Log("Toggling AutoUnlockSkillCheck")
            EndIf
            ToggleSetting(LPSetting_AutoUnlockSkillCheck, "AutoUnlockSkillCheck", akTerminalRef)
        ElseIf auiMenuItemID == 2
            If Logger && Logger.IsEnabled()
                Logger.Log("Toggling Corpses")
            EndIf
            ToggleSetting(LPSetting_RemoveCorpses, "Corpses", akTerminalRef)
        ElseIf auiMenuItemID == 3
            If Logger && Logger.IsEnabled()
                Logger.Log("Toggling TakeAll")
            EndIf
            ToggleSetting(LPSetting_ContTakeAll, "TakeAll", akTerminalRef)
        EndIf
    EndIf
EndEvent
