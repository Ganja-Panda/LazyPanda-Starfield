;======================================================================
; Script Name   : LZP:Term:Menu_SettingsContainerScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Toggles container-related looting features via terminal
; Description   : This script manages toggles for AutoUnlock, SkillCheck,
;                 corpse removal, and container "Take All" features. It updates
;                 GlobalVariables, reflects feedback through messages, and
;                 logs all activity for debugging via LoggerScript.
; Dependencies  : LazyPanda.esm, LoggerScript, GlobalVariables, TerminalMenu
; Usage         : Attach to a terminal menu and map setting actions by index
;======================================================================


ScriptName LZP:Term:Menu_SettingsContainerScript Extends TerminalMenu hidden

;======================================================================
; PROPERTIES
;======================================================================

;-- GlobalSettings
; Container-related setting toggles (autofilled)
Group GlobalVariable_Autofill
    GlobalVariable Property LPSetting_RemoveCorpses Auto mandatory
    GlobalVariable Property LPSetting_ContTakeAll Auto mandatory
    GlobalVariable Property LPSetting_AutoUnlock Auto mandatory
    GlobalVariable Property LPSetting_AutoUnlockSkillCheck Auto mandatory
EndGroup

;-- FeedbackMessages
; On/Off message forms for terminal replacement
Group Message_Autofill
    Message Property LPOffMsg Auto Const mandatory
    Message Property LPOnMsg Auto Const mandatory
EndGroup

;-- TerminalConfig
; Terminal menu reference and configuration data
Group Misc
    TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
EndGroup

;-- Logger
; Central LoggerScript instance for output
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup


;======================================================================
; HELPER FUNCTIONS
;======================================================================

;-- UpdateSettingDisplay Function --
; @param setting: GlobalVariable to check value of
; @param label: Replacement label key for terminal
; @param akTerminalRef: Terminal object for message updates
; Updates terminal text replacement with On/Off message
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
; @param setting: GlobalVariable to toggle
; @param label: Label used for terminal text replacement
; @param akTerminalRef: Terminal instance to update
; Toggles value (0/1) and updates corresponding message
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
; @param akTerminalBase: Terminal menu base object
; @param akTerminalRef: Terminal instance reference
; Refreshes text display and logs current setting values
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
; @param auiMenuItemID: ID of the selected terminal menu item
; @param akTerminalBase: Terminal base object for comparison
; @param akTerminalRef: Reference to the terminal interacted with
; Executes toggle based on menu item selection index
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
