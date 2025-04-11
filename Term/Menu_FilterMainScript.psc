;======================================================================
; Script Name   : LZP:Term:Menu_FilterMainScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Controls filter settings via terminal menu interactions
; Description   : Updates global setting values and UI feedback messages based
;                 on menu selections. Uses terminal replacement data and logs
;                 each interaction for debugging and validation.
; Dependencies  : LazyPanda.esm, LoggerScript, TerminalMenu, GlobalVariables
; Usage         : Attach to a TerminalMenu and respond to user interactions
;======================================================================

ScriptName LZP:Term:Menu_FilterMainScript Extends TerminalMenu hidden

;======================================================================
; PROPERTIES
;======================================================================

;------------------------------
; Autofill
; Messages displayed to the player when toggling settings
;------------------------------
Group Autofill
    Message Property LPOffMsg Auto Const mandatory
    Message Property LPOnMsg  Auto Const mandatory
EndGroup

;------------------------------
; MenuSpecific
; FormLists and properties tied to menu configuration
;------------------------------
Group MenuSpecific
    FormList Property SettingsGlobals Auto Const mandatory
EndGroup

;------------------------------
; Terminal
; Terminal menu instance used by this script
;------------------------------
Group Terminal
    TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
EndGroup

;------------------------------
; Logger
; LoggerScript reference for output and diagnostics
;------------------------------
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;------------------------------
; Tokens
; Replacement token keys used in the terminal menu
;------------------------------
Group Tokens
    String Property Token_AllToggle = "AllToggle" Auto Const hidden
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;----------------------------------------------------------------------
; Function : SetAllSettings
; Purpose  : Sets all settings in the SettingsGlobals list to the specified value.
; Params   : newValue - The value to apply to all GlobalVariables
;----------------------------------------------------------------------
Function SetAllSettings(float newValue)
    int size = SettingsGlobals.GetSize()
    int index = 0
    While index < size
        GlobalVariable currentSetting = SettingsGlobals.GetAt(index) as GlobalVariable
        currentSetting.SetValue(newValue)
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("Menu_FilterMainScript: Setting index " + index as String + " to " + newValue as String, 1, "Menu_FilterMainScript")
        EndIf
        index += 1
    EndWhile
EndFunction

;----------------------------------------------------------------------
; Function : UpdateAllToggleDisplay
; Purpose  : Updates the display message for the toggle setting based on its current value.
; Params   : akTerminalRef - The terminal reference used for text replacement
;            currentValue  - The current toggle state (0.0 or 1.0)
;----------------------------------------------------------------------
Function UpdateAllToggleDisplay(ObjectReference akTerminalRef, float currentValue)
    If currentValue == 1.0
        akTerminalRef.AddTextReplacementData(Token_AllToggle, LPOnMsg as Form)
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("Menu_FilterMainScript: Setting " + Token_AllToggle + " to LPOnMsg", 1, "Menu_FilterMainScript")
        EndIf
    ElseIf currentValue == 0.0
        akTerminalRef.AddTextReplacementData(Token_AllToggle, LPOffMsg as Form)
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("Menu_FilterMainScript: Setting " + Token_AllToggle + " to LPOffMsg", 1, "Menu_FilterMainScript")
        EndIf
    EndIf
EndFunction

;----------------------------------------------------------------------
; Function : ForceTerminalRefresh
; Purpose  : Forces the terminal to refresh its display.
; Params   : akTerminalBase - The terminal menu base object
;            akTerminalRef  - The active terminal reference to refresh
;----------------------------------------------------------------------
Function ForceTerminalRefresh(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    akTerminalBase.ClearDynamicMenuItems(akTerminalRef)
    akTerminalBase.ClearDynamicBodyTextItems(akTerminalRef)
    akTerminalBase.AddDynamicMenuItem(akTerminalRef, 0, 0, None)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("Menu_FilterMainScript: Terminal forced refresh triggered", 1, "Menu_FilterMainScript")
    EndIf
EndFunction

;======================================================================
; EVENTS
;======================================================================

;----------------------------------------------------------------------
; Event : OnTerminalMenuEnter
; Purpose: Called when the terminal menu is entered. Updates the toggle display.
;----------------------------------------------------------------------
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("Menu_FilterMainScript: OnTerminalMenuEnter triggered", 1, "Menu_FilterMainScript")
    EndIf

    GlobalVariable currentSetting = SettingsGlobals.GetAt(0) as GlobalVariable

    If Logger && Logger.IsEnabled()
        Logger.LogAdv("Menu_FilterMainScript: Current setting value: " + currentSetting.GetValue() as String, 1, "Menu_FilterMainScript")
    EndIf

    UpdateAllToggleDisplay(akTerminalRef, currentSetting.GetValue())
EndEvent

;----------------------------------------------------------------------
; Event : OnTerminalMenuItemRun
; Purpose: Called when a menu item is selected. Toggles all settings if the appropriate item is selected.
;----------------------------------------------------------------------
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("Menu_FilterMainScript: OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String, 1, "Menu_FilterMainScript")
    EndIf

    If akTerminalBase == CurrentTerminalMenu
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("Menu_FilterMainScript: Terminal menu matches CurrentTerminalMenu", 1, "Menu_FilterMainScript")
        EndIf

        If auiMenuItemID == 0
            If Logger && Logger.IsEnabled()
                Logger.LogAdv("Menu_FilterMainScript: Menu item 0 selected: Toggle all settings", 1, "Menu_FilterMainScript")
            EndIf

            GlobalVariable AllToggle = SettingsGlobals.GetAt(0) as GlobalVariable
            float currentValue = AllToggle.GetValue()

            If Logger && Logger.IsEnabled()
                Logger.LogAdv("Menu_FilterMainScript: " + Token_AllToggle + " current value: " + currentValue as String, 1, "Menu_FilterMainScript")
            EndIf

            float newValue
            If currentValue == 1.0
                newValue = 0.0
            Else
                newValue = 1.0
            EndIf

            SetAllSettings(newValue)
            UpdateAllToggleDisplay(akTerminalRef, newValue)
            ForceTerminalRefresh(akTerminalBase, akTerminalRef)
        EndIf
    EndIf
EndEvent
