ScriptName LZP:Term:Menu_SettingsContainerScript Extends TerminalMenu hidden

;======================================================================
; PROPERTY GROUPS
;======================================================================

;-- Global Variables --
; Global variables for settings such as radius and destination.
Group GlobalVariable_Autofill
    GlobalVariable Property LPSetting_RemoveCorpses Auto mandatory
    GlobalVariable Property LPSetting_ContTakeAll Auto mandatory
    GlobalVariable Property LPSetting_AutoUnlock Auto mandatory
    GlobalVariable Property LPSetting_AutoUnlockSkillCheck Auto mandatory
EndGroup

;-- Messages --
; Messages displayed to the player when toggling settings.
Group Message_Autofill
    Message Property LPOffMsg Auto Const mandatory
    Message Property LPOnMsg Auto Const mandatory
EndGroup

;-- Miscellaneous --
; Additional properties including the current terminal menu.
Group Misc
    TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
    GlobalVariable Property LPSystem_Debug Auto Const mandatory
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;-- Log Function --
; Logs a message if the global debug setting is enabled.
Function Log(String logMsg)
    If LPSystem_Debug.GetValue() as Bool
        Debug.Trace(logMsg, 0)
    EndIf
EndFunction

;-- UpdateSettingDisplay Function --
; Updates the display of the setting on the terminal.
Function UpdateSettingDisplay(GlobalVariable setting, String label, ObjectReference akTerminalRef)
    If setting.GetValue() == 1.0
        akTerminalRef.AddTextReplacementData(label, LPOnMsg as Form)
        Log("Setting " + label + " to LPOnMsg")
    Else
        akTerminalRef.AddTextReplacementData(label, LPOffMsg as Form)
        Log("Setting " + label + " to LPOffMsg")
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
    Log("OnTerminalMenuEnter triggered")

    ; Log current settings for debugging purposes.
    Bool currentRemoveCorpsesSetting = LPSetting_RemoveCorpses.GetValue() == 1.0
    Bool currentTakeAllSetting = LPSetting_ContTakeAll.GetValue() == 1.0
    Bool currentAutoUnlockSetting = LPSetting_AutoUnlock.GetValue() == 1.0
    Bool currentAutoUnlockSkillCheckSetting = LPSetting_AutoUnlockSkillCheck.GetValue() == 1.0
    Log("Current settings - RemoveCorpses: " + currentRemoveCorpsesSetting + ", TakeAll: " + currentTakeAllSetting + ", AutoUnlock: " + currentAutoUnlockSetting + ", AutoUnlockSkillCheck: " + currentAutoUnlockSkillCheckSetting)

    ; Update display for each setting.
    UpdateSettingDisplay(LPSetting_AutoUnlock, "AutoUnlock", akTerminalRef)
    UpdateSettingDisplay(LPSetting_AutoUnlockSkillCheck, "AutoUnlockSkillCheck", akTerminalRef)
    UpdateSettingDisplay(LPSetting_RemoveCorpses, "Corpses", akTerminalRef)
    UpdateSettingDisplay(LPSetting_ContTakeAll, "TakeAll", akTerminalRef)
EndEvent

;-- OnTerminalMenuItemRun Event Handler --
; Called when a terminal menu item is selected.
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    Log("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID)
    If akTerminalBase == CurrentTerminalMenu
        Log("Terminal menu matches CurrentTerminalMenu")
        ; Toggle the appropriate setting based on the menu item ID.
        If auiMenuItemID == 0
            Log("Toggling AutoUnlock")
            ToggleSetting(LPSetting_AutoUnlock, "AutoUnlock", akTerminalRef)
        ElseIf auiMenuItemID == 1
            Log("Toggling AutoUnlockSkillCheck")
            ToggleSetting(LPSetting_AutoUnlockSkillCheck, "AutoUnlockSkillCheck", akTerminalRef)
        ElseIf auiMenuItemID == 2
            Log("Toggling Corpses")
            ToggleSetting(LPSetting_RemoveCorpses, "Corpses", akTerminalRef)
        ElseIf auiMenuItemID == 3
            Log("Toggling TakeAll")
            ToggleSetting(LPSetting_ContTakeAll, "TakeAll", akTerminalRef)
        EndIf
    EndIf
EndEvent