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

;-- TerminalMenuConfig
; Terminal menu instance and all associated message/setting data
Group TerminalMenuConfig
    TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
    Form[] Property SettingsGlobals Auto Const mandatory
    Message Property LPOffMsg Auto Const mandatory
    Message Property LPOnMsg Auto Const mandatory
EndGroup

;-- Logger Property --
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;-- UpdateSettingDisplay Function --
; @param index: Index of the GlobalVariable to check
; @param akTerminalRef: Reference of the terminal menu object
; Updates replacement message text based on toggle state
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
; @param akTerminalBase: Terminal menu base object
; @param akTerminalRef: The instance reference of the terminal menu
; Called when the terminal menu is entered. Updates the display for all settings.
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    Int index = 0
    While index < SettingsGlobals.Length
        UpdateSettingDisplay(index, akTerminalRef)
        index += 1
    EndWhile
EndEvent

;-- OnTerminalMenuItemRun Event Handler --
; @param auiMenuItemID: Index of the selected menu item
; @param akTerminalBase: Terminal menu definition
; @param akTerminalRef: Terminal menu instance
; Toggles setting and updates replacement text
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