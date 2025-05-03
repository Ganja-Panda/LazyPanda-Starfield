;======================================================================
; Script Name   : LZP:Term:Menu_SettingsAlwaysLootScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Toggles Always Loot settings from terminal menu
; Description   : Updates a list of GlobalVariables tied to Always Loot
;                 behavior. Displays appropriate UI message feedback
;                 and logs activity using LoggerScript.
; Dependencies  : LazyPanda.esm, LoggerScript, GlobalVariables, TerminalMenu
; Usage         : Attach to a TerminalMenu that lists Always Loot options
;======================================================================

ScriptName LZP:Term:Menu_SettingsAlwaysLootScript Extends TerminalMenu hidden

;======================================================================
; PROPERTIES
;======================================================================

;------------------------------
; TerminalMenuConfig
; Terminal menu instance and all associated message/setting data
;------------------------------
Group TerminalMenuConfig
    TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
    Form[] Property SettingsGlobals Auto Const mandatory
    Message Property LZP_MESG_Status_Disabled Auto Const mandatory
    Message Property LZP_MESG_Status_Enabled Auto Const mandatory
EndGroup

;------------------------------
; Logger
; LoggerScript instance for logging
;------------------------------
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;------------------------------
; Tokens
; Replacement token prefix for toggle display
;------------------------------
Group Tokens
    String Property Token_StatePrefix = "State" Auto Const hidden
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;----------------------------------------------------------------------
; Function : UpdateSettingDisplay
; Purpose  : Updates replacement message text based on toggle state
; Params   : index          - Index of the GlobalVariable to check
;            akTerminalRef  - Terminal reference to update
;----------------------------------------------------------------------
Function UpdateSettingDisplay(Int index, ObjectReference akTerminalRef)
    GlobalVariable setting = SettingsGlobals[index] as GlobalVariable
    If setting
        Float value = setting.GetValue()
        Message replacementMsg

        If value == 1.0
            replacementMsg = LZP_MESG_Status_Enabled
            If Logger && Logger.IsEnabled()
                Logger.LogAdv("LZP:Term:Menu_SettingsAlwaysLootScript: UpdateSettingDisplay: Setting at index", 1, "Menu_SettingsAlwaysLootScript")
                Logger.LogAdv(index as String, 1, "Menu_SettingsAlwaysLootScript")
                Logger.LogAdv("set to LZP_MESG_Status_Enabled", 1, "Menu_SettingsAlwaysLootScript")
            EndIf
        Else
            replacementMsg = LZP_MESG_Status_Disabled
            If Logger && Logger.IsEnabled()
                Logger.LogAdv("LZP:Term:Menu_SettingsAlwaysLootScript: UpdateSettingDisplay: Setting at index", 1, "Menu_SettingsAlwaysLootScript")
                Logger.LogAdv(index as String, 1, "Menu_SettingsAlwaysLootScript")
                Logger.LogAdv("set to LZP_MESG_Status_Disabled", 1, "Menu_SettingsAlwaysLootScript")
            EndIf
        EndIf

        akTerminalRef.AddTextReplacementData(Token_StatePrefix + index as String, replacementMsg as Form)
    Else
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("LZP:Term:Menu_SettingsAlwaysLootScript: UpdateSettingDisplay: Setting at index not found", 2, "Menu_SettingsAlwaysLootScript")
            Logger.LogAdv(index as String, 2, "Menu_SettingsAlwaysLootScript")
        EndIf
    EndIf
EndFunction

;======================================================================
; EVENTS
;======================================================================

;----------------------------------------------------------------------
; Event : OnTerminalMenuEnter
; Purpose: Called when the terminal menu is entered. Updates display for all settings.
;----------------------------------------------------------------------
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    Int index = 0
    While index < SettingsGlobals.Length
        UpdateSettingDisplay(index, akTerminalRef)
        index += 1
    EndWhile
EndEvent

;----------------------------------------------------------------------
; Event : OnTerminalMenuItemRun
; Purpose: Toggles setting and updates replacement text
;----------------------------------------------------------------------
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If akTerminalBase == CurrentTerminalMenu
        GlobalVariable setting = SettingsGlobals[auiMenuItemID] as GlobalVariable
        If setting
            Float value = setting.GetValue()
            Float newValue
            If value == 1.0
                newValue = 0.0
                If Logger && Logger.IsEnabled()
                    Logger.LogAdv("LZP:Term:Menu_SettingsAlwaysLootScript: OnTerminalMenuItemRun: Setting at index", 1, "Menu_SettingsAlwaysLootScript")
                    Logger.LogAdv(auiMenuItemID as String, 1, "Menu_SettingsAlwaysLootScript")
                    Logger.LogAdv("toggled to 0.0", 1, "Menu_SettingsAlwaysLootScript")
                EndIf
            Else
                newValue = 1.0
                If Logger && Logger.IsEnabled()
                    Logger.LogAdv("LZP:Term:Menu_SettingsAlwaysLootScript: OnTerminalMenuItemRun: Setting at index", 1, "Menu_SettingsAlwaysLootScript")
                    Logger.LogAdv(auiMenuItemID as String, 1, "Menu_SettingsAlwaysLootScript")
                    Logger.LogAdv("toggled to 1.0", 1, "Menu_SettingsAlwaysLootScript")
                EndIf
            EndIf
            setting.SetValue(newValue)
            UpdateSettingDisplay(auiMenuItemID, akTerminalRef)
        Else
            If Logger && Logger.IsEnabled()
                Logger.LogAdv("LZP:Term:Menu_SettingsAlwaysLootScript: OnTerminalMenuItemRun: Setting at index not found", 2, "Menu_SettingsAlwaysLootScript")
                Logger.LogAdv(auiMenuItemID as String, 2, "Menu_SettingsAlwaysLootScript")
            EndIf
        EndIf
    EndIf
EndEvent
