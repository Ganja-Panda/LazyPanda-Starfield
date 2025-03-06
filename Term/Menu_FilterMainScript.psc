;======================================================================
; Script: LZP:Term:Menu_FilterMainScript
; Description: This script manages the main menu filter functionality.
; It updates settings based on user interactions and provides feedback
; through messages. Debug logging is integrated to assist with troubleshooting.
;======================================================================

ScriptName LZP:Term:Menu_FilterMainScript Extends TerminalMenu hidden

;======================================================================
; PROPERTIES
;======================================================================

;-- Autofill Properties --
; Messages displayed to the player when toggling settings.
Group Autofill
    Message Property LPOffMsg Auto Const mandatory
    Message Property LPOnMsg Auto Const mandatory
EndGroup

;-- Menu-Specific Properties --
; Form lists and other properties specific to the menu.
Group MenuSpecific
    FormList Property SettingsGlobals Auto Const mandatory
EndGroup

;-- Terminal Properties --
; References to the current terminal menu.
Group Terminal
    TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
EndGroup

GlobalVariable Property LPSystem_Debug Auto Const Mandatory

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

;-- SetAllSettings Function --
; Sets all settings in the SettingsGlobals list to the specified value.
Function SetAllSettings(float newValue)
    int size = Self.SettingsGlobals.GetSize()
    int index = 0
    While index < size
        GlobalVariable currentSetting = Self.SettingsGlobals.GetAt(index) as GlobalVariable
        currentSetting.SetValue(newValue)
        Log("Setting index " + index as String + " to " + newValue as String)
        index += 1
    EndWhile
EndFunction

;-- UpdateAllToggleDisplay Function --
; Updates the display message for the toggle setting based on its current value.
Function UpdateAllToggleDisplay(ObjectReference akTerminalRef, float currentValue)
    If currentValue == 1.0
        akTerminalRef.AddTextReplacementData("AllToggle", Self.LPOnMsg as Form)
        Log("Setting AllToggle to LPOnMsg")
    ElseIf currentValue == 0.0
        akTerminalRef.AddTextReplacementData("AllToggle", Self.LPOffMsg as Form)
        Log("Setting AllToggle to LPOffMsg")
    EndIf
EndFunction

;-- ForceTerminalRefresh Function --
; Forces the terminal to refresh its display.
Function ForceTerminalRefresh(ObjectReference akTerminalRef)
    TerminalMenu terminalMenu = akTerminalRef as TerminalMenu
    If terminalMenu
        terminalMenu.ClearDynamicMenuItems(akTerminalRef)
        terminalMenu.ClearDynamicBodyTextItems(akTerminalRef)
        terminalMenu.AddDynamicMenuItem(akTerminalRef, 0, 0, None)
        Log("Terminal forced refresh triggered")
    Else
        Log("Terminal refresh failed: TerminalMenu not found")
    EndIf
EndFunction

;======================================================================
; EVENTS
;======================================================================

;-- OnTerminalMenuEnter Event Handler --
; Called when the terminal menu is entered. Updates the toggle display.
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    Log("OnTerminalMenuEnter triggered")
    GlobalVariable currentSetting = Self.SettingsGlobals.GetAt(0) as GlobalVariable
    Log("Current setting value: " + currentSetting.GetValue() as String)
    UpdateAllToggleDisplay(akTerminalRef, currentSetting.GetValue())
EndEvent

;-- OnTerminalMenuItemRun Event Handler --
; Called when a menu item is selected. Toggles all settings if the appropriate item is selected.
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    Log("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String)
    If akTerminalBase == Self.CurrentTerminalMenu
        Log("Terminal menu matches CurrentTerminalMenu")
        If auiMenuItemID == 0
            Log("Menu item 0 selected: Toggle all settings")
            GlobalVariable AllToggle = Self.SettingsGlobals.GetAt(0) as GlobalVariable
            float currentValue = AllToggle.GetValue()
            Log("AllToggle current value: " + currentValue as String)
            
            float newValue
            If currentValue == 1.0
                newValue = 0.0
            Else
                newValue = 1.0
            EndIf
            
            SetAllSettings(newValue)
            UpdateAllToggleDisplay(akTerminalRef, newValue)
            ForceTerminalRefresh(akTerminalRef)
        EndIf
    EndIf
EndEvent