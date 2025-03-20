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
    GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;-- UpdateSettingDisplay Function --
; Updates the display of the setting on the terminal.
Function UpdateSettingDisplay(GlobalVariable setting, String label, ObjectReference akTerminalRef)
    If setting.GetValue() == 1.0
        akTerminalRef.AddTextReplacementData(label, LPOnMsg as Form)
        LZP:SystemScript.Log("Setting " + label + " to LPOnMsg", 3)
    Else
        akTerminalRef.AddTextReplacementData(label, LPOffMsg as Form)
        LZP:SystemScript.Log("Setting " + label + " to LPOffMsg", 3)
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
    LZP:SystemScript.Log("OnTerminalMenuEnter triggered", 3)

    ; Log current settings for debugging purposes.
    Bool currentRemoveCorpsesSetting = LPSetting_RemoveCorpses.GetValue() == 1.0
    Bool currentTakeAllSetting = LPSetting_ContTakeAll.GetValue() == 1.0
    Bool currentAutoUnlockSetting = LPSetting_AutoUnlock.GetValue() == 1.0
    Bool currentAutoUnlockSkillCheckSetting = LPSetting_AutoUnlockSkillCheck.GetValue() == 1.0
    LZP:SystemScript.Log("Current settings - " + "RemoveCorpses: " + currentRemoveCorpsesSetting + ", TakeAll: " + currentTakeAllSetting + ", AutoUnlock: " + currentAutoUnlockSetting + ", AutoUnlockSkillCheck: " + currentAutoUnlockSkillCheckSetting, 3)

    ; Update display for each setting.
    UpdateSettingDisplay(LPSetting_AutoUnlock, "AutoUnlock", akTerminalRef)
    UpdateSettingDisplay(LPSetting_AutoUnlockSkillCheck, "AutoUnlockSkillCheck", akTerminalRef)
    UpdateSettingDisplay(LPSetting_RemoveCorpses, "Corpses", akTerminalRef)
    UpdateSettingDisplay(LPSetting_ContTakeAll, "TakeAll", akTerminalRef)
EndEvent

;-- OnTerminalMenuItemRun Event Handler --
; Called when a menu item is selected.
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    LZP:SystemScript.Log("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID, 3)
    If akTerminalBase == CurrentTerminalMenu
        LZP:SystemScript.Log("Terminal menu matches CurrentTerminalMenu", 3)
        ; Toggle the appropriate setting based on the menu item ID.
        If auiMenuItemID == 0
            LZP:SystemScript.Log("Toggling AutoUnlock", 3)
            ToggleSetting(LPSetting_AutoUnlock, "AutoUnlock", akTerminalRef)
        ElseIf auiMenuItemID == 1
            LZP:SystemScript.Log("Toggling AutoUnlockSkillCheck", 3)
            ToggleSetting(LPSetting_AutoUnlockSkillCheck, "AutoUnlockSkillCheck", akTerminalRef)
        ElseIf auiMenuItemID == 2
            LZP:SystemScript.Log("Toggling Corpses", 3)
            ToggleSetting(LPSetting_RemoveCorpses, "Corpses", akTerminalRef)
        ElseIf auiMenuItemID == 3
            LZP:SystemScript.Log("Toggling TakeAll", 3)
            ToggleSetting(LPSetting_ContTakeAll, "TakeAll", akTerminalRef)
        EndIf
    EndIf
EndEvent
