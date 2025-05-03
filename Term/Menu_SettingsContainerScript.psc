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
    GlobalVariable Property LZP_Setting_RemoveCorpses Auto mandatory
    GlobalVariable Property LZP_Setting_TakeAll_Containers Auto mandatory
    GlobalVariable Property LZP_Setting_Unlock_Auto Auto mandatory
    GlobalVariable Property LZP_Setting_Unlock_SkillCheck Auto mandatory
EndGroup

;------------------------------
; FeedbackMessages
; On/Off message forms for terminal replacement
;------------------------------
Group Message_Autofill
    Message Property LZP_MESG_Status_Disabled Auto Const mandatory
    Message Property LZP_MESG_Status_Enabled Auto Const mandatory
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
        akTerminalRef.AddTextReplacementData(label, LZP_MESG_Status_Enabled as Form)
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("UpdateSettingDisplay: Setting", 1, "Menu_SettingsContainerScript")
            Logger.LogAdv(label, 1, "Menu_SettingsContainerScript")
            Logger.LogAdv("set to LZP_MESG_Status_Enabled", 1, "Menu_SettingsContainerScript")
        EndIf
    Else
        akTerminalRef.AddTextReplacementData(label, LZP_MESG_Status_Disabled as Form)
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("UpdateSettingDisplay: Setting", 1, "Menu_SettingsContainerScript")
            Logger.LogAdv(label, 1, "Menu_SettingsContainerScript")
            Logger.LogAdv("set to LZP_MESG_Status_Disabled", 1, "Menu_SettingsContainerScript")
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
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("ToggleSetting: Setting", 1, "Menu_SettingsContainerScript")
            Logger.LogAdv(label, 1, "Menu_SettingsContainerScript")
            Logger.LogAdv("toggled to 0.0", 1, "Menu_SettingsContainerScript")
        EndIf
    Else
        setting.SetValue(1.0)
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("ToggleSetting: Setting", 1, "Menu_SettingsContainerScript")
            Logger.LogAdv(label, 1, "Menu_SettingsContainerScript")
            Logger.LogAdv("toggled to 1.0", 1, "Menu_SettingsContainerScript")
        EndIf
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
        Logger.LogAdv("OnTerminalMenuEnter triggered", 1, "Menu_SettingsContainerScript")
    EndIf

    ; Log current settings for debugging purposes.
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("Current settings - RemoveCorpses:", 1, "Menu_SettingsContainerScript")
        Logger.LogAdv(LZP_Setting_RemoveCorpses.GetValue() as String, 1, "Menu_SettingsContainerScript")
        Logger.LogAdv("TakeAll:", 1, "Menu_SettingsContainerScript")
        Logger.LogAdv(LZP_Setting_TakeAll_Containers.GetValue() as String, 1, "Menu_SettingsContainerScript")
        Logger.LogAdv("AutoUnlock:", 1, "Menu_SettingsContainerScript")
        Logger.LogAdv(LZP_Setting_Unlock_Auto.GetValue() as String, 1, "Menu_SettingsContainerScript")
        Logger.LogAdv("AutoUnlockSkillCheck:", 1, "Menu_SettingsContainerScript")
        Logger.LogAdv(LZP_Setting_Unlock_SkillCheck.GetValue() as String, 1, "Menu_SettingsContainerScript")
    EndIf

    ; Update display for each setting.
    UpdateSettingDisplay(LZP_Setting_Unlock_Auto, Token_AutoUnlock, akTerminalRef)
    UpdateSettingDisplay(LZP_Setting_Unlock_SkillCheck, Token_AutoUnlockSkillCheck, akTerminalRef)
    UpdateSettingDisplay(LZP_Setting_RemoveCorpses, Token_Corpses, akTerminalRef)
    UpdateSettingDisplay(LZP_Setting_TakeAll_Containers, Token_TakeAll, akTerminalRef)
EndEvent

;----------------------------------------------------------------------
; Event : OnTerminalMenuItemRun
; Purpose: Executes toggle based on menu item selection index
;----------------------------------------------------------------------
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("OnTerminalMenuItemRun triggered with auiMenuItemID", 1, "Menu_SettingsContainerScript")
        Logger.LogAdv(auiMenuItemID as String, 1, "Menu_SettingsContainerScript")
    EndIf

    If akTerminalBase == CurrentTerminalMenu
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("Terminal menu matches CurrentTerminalMenu", 1, "Menu_SettingsContainerScript")
        EndIf

        ; Toggle the appropriate setting based on the menu item ID.
        If auiMenuItemID == 0
            If Logger && Logger.IsEnabled()
                Logger.LogAdv("Toggling AutoUnlock", 1, "Menu_SettingsContainerScript")
            EndIf
            ToggleSetting(LZP_Setting_Unlock_Auto, Token_AutoUnlock, akTerminalRef)
        ElseIf auiMenuItemID == 1
            If Logger && Logger.IsEnabled()
                Logger.LogAdv("Toggling AutoUnlockSkillCheck", 1, "Menu_SettingsContainerScript")
            EndIf
            ToggleSetting(LZP_Setting_Unlock_SkillCheck, Token_AutoUnlockSkillCheck, akTerminalRef)
        ElseIf auiMenuItemID == 2
            If Logger && Logger.IsEnabled()
                Logger.LogAdv("Toggling Corpses", 1, "Menu_SettingsContainerScript")
            EndIf
            ToggleSetting(LZP_Setting_RemoveCorpses, Token_Corpses, akTerminalRef)
        ElseIf auiMenuItemID == 3
            If Logger && Logger.IsEnabled()
                Logger.LogAdv("Toggling TakeAll", 1, "Menu_SettingsContainerScript")
            EndIf
            ToggleSetting(LZP_Setting_TakeAll_Containers, Token_TakeAll, akTerminalRef)
        EndIf
    EndIf
EndEvent
