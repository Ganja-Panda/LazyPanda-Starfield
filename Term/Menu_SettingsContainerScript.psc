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

;------------------------------
; GlobalSettings
; Container-related setting toggles (autofilled)
;------------------------------
Group GlobalVariable_Autofill
    GlobalVariable Property LPSetting_RemoveCorpses Auto mandatory
    GlobalVariable Property LPSetting_ContTakeAll Auto mandatory
    GlobalVariable Property LPSetting_AutoUnlock Auto mandatory
    GlobalVariable Property LPSetting_AutoUnlockSkillCheck Auto mandatory
EndGroup

;------------------------------
; FeedbackMessages
; On/Off message forms for terminal replacement
;------------------------------
Group Message_Autofill
    Message Property LPOffMsg Auto Const mandatory
    Message Property LPOnMsg Auto Const mandatory
EndGroup

;------------------------------
; TerminalConfig
; Terminal menu reference and configuration data
;------------------------------
Group Misc
    TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
EndGroup

;------------------------------
; Logger
; Central LoggerScript instance for output
;------------------------------
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;------------------------------
; Tokens
; Replacement tokens for each setting
;------------------------------
Group Tokens
    String Property Token_AutoUnlock = "AutoUnlock" Auto Const hidden
    String Property Token_AutoUnlockSkillCheck = "AutoUnlockSkillCheck" Auto Const hidden
    String Property Token_Corpses = "Corpses" Auto Const hidden
    String Property Token_TakeAll = "TakeAll" Auto Const hidden
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;----------------------------------------------------------------------
; Function : UpdateSettingDisplay
; Purpose  : Updates replacement message text based on toggle state
; Params   : setting         - GlobalVariable to check value of
;            label           - Replacement label key for terminal
;            akTerminalRef   - Terminal object for message updates
;----------------------------------------------------------------------
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

;----------------------------------------------------------------------
; Function : ToggleSetting
; Purpose  : Toggles value (0/1) and updates corresponding message
; Params   : setting         - GlobalVariable to toggle
;            label           - Label used for terminal text replacement
;            akTerminalRef   - Terminal instance to update
;----------------------------------------------------------------------
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

;----------------------------------------------------------------------
; Event : OnTerminalMenuEnter
; Purpose: Refreshes text display and logs current setting values
;----------------------------------------------------------------------
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
    UpdateSettingDisplay(LPSetting_AutoUnlock, Token_AutoUnlock, akTerminalRef)
    UpdateSettingDisplay(LPSetting_AutoUnlockSkillCheck, Token_AutoUnlockSkillCheck, akTerminalRef)
    UpdateSettingDisplay(LPSetting_RemoveCorpses, Token_Corpses, akTerminalRef)
    UpdateSettingDisplay(LPSetting_ContTakeAll, Token_TakeAll, akTerminalRef)
EndEvent

;----------------------------------------------------------------------
; Event : OnTerminalMenuItemRun
; Purpose: Executes toggle based on menu item selection index
;----------------------------------------------------------------------
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
            ToggleSetting(LPSetting_AutoUnlock, Token_AutoUnlock, akTerminalRef)
        ElseIf auiMenuItemID == 1
            If Logger && Logger.IsEnabled()
                Logger.Log("Toggling AutoUnlockSkillCheck")
            EndIf
            ToggleSetting(LPSetting_AutoUnlockSkillCheck, Token_AutoUnlockSkillCheck, akTerminalRef)
        ElseIf auiMenuItemID == 2
            If Logger && Logger.IsEnabled()
                Logger.Log("Toggling Corpses")
            EndIf
            ToggleSetting(LPSetting_RemoveCorpses, Token_Corpses, akTerminalRef)
        ElseIf auiMenuItemID == 3
            If Logger && Logger.IsEnabled()
                Logger.Log("Toggling TakeAll")
            EndIf
            ToggleSetting(LPSetting_ContTakeAll, Token_TakeAll, akTerminalRef)
        EndIf
    EndIf
EndEvent
