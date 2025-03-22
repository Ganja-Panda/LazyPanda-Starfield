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

;-- Autofill Properties --
; Messages displayed to the player when toggling settings.
;-- Autofill
; Messages displayed to the player when toggling settings
Group Autofill
    Message Property LPOffMsg Auto Const mandatory
    Message Property LPOnMsg Auto Const mandatory
EndGroup

;-- Menu-Specific Properties --
; Form lists and other properties specific to the menu.
;-- MenuSpecific
; FormLists and properties tied to menu configuration
Group MenuSpecific
    FormList Property SettingsGlobals Auto Const mandatory
EndGroup

;-- Terminal Properties --
; References to the current terminal menu.
;-- Terminal
; Terminal menu instance used by this script
Group Terminal
    TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
EndGroup

;-- Logger Property --
;-- Logger
; LoggerScript reference for output and diagnostics
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;-- SetAllSettings Function --
; @param newValue: The value to apply to all GlobalVariables
; Sets all settings in the SettingsGlobals list to the specified value.
Function SetAllSettings(float newValue)
    int size = Self.SettingsGlobals.GetSize()
    int index = 0
    While index < size
        GlobalVariable currentSetting = Self.SettingsGlobals.GetAt(index) as GlobalVariable
        currentSetting.SetValue(newValue)
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Term:Menu_FilterMainScript: Setting index " + index as String + " to " + newValue as String)
        EndIf
        index += 1
    EndWhile
EndFunction

;-- UpdateAllToggleDisplay Function --
; @param akTerminalRef: The terminal reference used for text replacement
; @param currentValue: The current toggle state (0.0 or 1.0)
; Updates the display message for the toggle setting based on its current value.
Function UpdateAllToggleDisplay(ObjectReference akTerminalRef, float currentValue)
    If currentValue == 1.0
        akTerminalRef.AddTextReplacementData("AllToggle", Self.LPOnMsg as Form)
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Term:Menu_FilterMainScript: Setting AllToggle to LPOnMsg")
        EndIf
    ElseIf currentValue == 0.0
        akTerminalRef.AddTextReplacementData("AllToggle", Self.LPOffMsg as Form)
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Term:Menu_FilterMainScript: Setting AllToggle to LPOffMsg")
        EndIf
    EndIf
EndFunction

;-- ForceTerminalRefresh Function --
; @param akTerminalBase: The terminal menu base object
; @param akTerminalRef: The active terminal reference to refresh
; Forces the terminal to refresh its display.
Function ForceTerminalRefresh(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    akTerminalBase.ClearDynamicMenuItems(akTerminalRef)
    akTerminalBase.ClearDynamicBodyTextItems(akTerminalRef)
    akTerminalBase.AddDynamicMenuItem(akTerminalRef, 0, 0, None)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Term:Menu_FilterMainScript: Terminal forced refresh triggered")
    EndIf
EndFunction

;======================================================================
; EVENTS
;======================================================================

;-- OnTerminalMenuEnter Event Handler --
; @param akTerminalBase: The terminal menu base object
; @param akTerminalRef: The terminal reference entered by the player
; Called when the terminal menu is entered. Updates the toggle display.
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Term:Menu_FilterMainScript: OnTerminalMenuEnter triggered")
    EndIf
    GlobalVariable currentSetting = Self.SettingsGlobals.GetAt(0) as GlobalVariable
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Term:Menu_FilterMainScript: Current setting value: " + currentSetting.GetValue() as String)
    EndIf
    UpdateAllToggleDisplay(akTerminalRef, currentSetting.GetValue())
EndEvent

;-- OnTerminalMenuItemRun Event Handler --
; @param auiMenuItemID: The ID of the selected menu item
; @param akTerminalBase: The terminal base instance
; @param akTerminalRef: The terminal reference where selection occurred
; Called when a menu item is selected. Toggles all settings if the appropriate item is selected.
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Term:Menu_FilterMainScript: OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String)
    EndIf
    If akTerminalBase == Self.CurrentTerminalMenu
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Term:Menu_FilterMainScript: Terminal menu matches CurrentTerminalMenu")
        EndIf
        If auiMenuItemID == 0
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Term:Menu_FilterMainScript: Menu item 0 selected: Toggle all settings")
            EndIf
            GlobalVariable AllToggle = Self.SettingsGlobals.GetAt(0) as GlobalVariable
            float currentValue = AllToggle.GetValue()
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Term:Menu_FilterMainScript: AllToggle current value: " + currentValue as String)
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
