;======================================================================
; Script: LZP:Term:Menu_SettingsStealScript
; Description: This script handles the settings for stealing in the terminal menu.
; It updates the settings based on user input and provides feedback through messages.
; Debug logging is integrated to assist with troubleshooting.
;======================================================================

ScriptName LZP:Term:Menu_SettingsStealScript Extends TerminalMenu Hidden

;======================================================================
; PROPERTY GROUPS
;======================================================================

;-- Global Variables --
; Global variables that control the stealing settings.
Group GlobalVariable_Autofill
    GlobalVariable Property LPSetting_AllowStealing Auto Mandatory
    GlobalVariable Property LPSetting_StealingIsHostile Auto Mandatory
EndGroup

;-- Messages --
; Messages displayed to the player when updating the settings.
Group Message_Autofill
    Message Property LPOffMsg Auto Const Mandatory
    Message Property LPOnMsg Auto Const Mandatory
EndGroup

;-- Miscellaneous --
; Miscellaneous properties including the current terminal menu and debug setting.
Group Misc
    TerminalMenu Property CurrentTerminalMenu Auto Const Mandatory
    GlobalVariable Property LPSystemUtil_Debug Auto Const Mandatory
EndGroup

;======================================================================
; FUNCTIONS
;======================================================================

;-- UpdateStealingSetting Function --
; Updates the stealing setting and provides feedback to the player.
Function UpdateStealingSetting(ObjectReference akTerminalRef, Bool isEnabled)
    Message msgToUse = LPOffMsg
    If isEnabled
        msgToUse = LPOnMsg
    EndIf
    akTerminalRef.AddTextReplacementData("Stealing", msgToUse as Form)
    LZP:SystemScript.Log("Updated Stealing to " + (isEnabled as String), 3)
EndFunction

;-- UpdateHostileSetting Function --
; Updates the hostile setting and provides feedback to the player.
Function UpdateHostileSetting(ObjectReference akTerminalRef, Bool isEnabled)
    Message msgToUse = LPOffMsg
    If isEnabled
        msgToUse = LPOnMsg
    EndIf
    akTerminalRef.AddTextReplacementData("Hostile", msgToUse as Form)
    LZP:SystemScript.Log("Updated Hostile to " + (isEnabled as String), 3)
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnTerminalMenuEnter Event Handler --
; Called when the terminal menu is entered. Updates the settings based on current values.
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    LZP:SystemScript.Log("OnTerminalMenuEnter triggered", 3)

    Bool allowStealing = LPSetting_AllowStealing.GetValue() as Bool
    Bool stealingIsHostile = LPSetting_StealingIsHostile.GetValue() as Bool

    UpdateStealingSetting(akTerminalRef, allowStealing)
    UpdateHostileSetting(akTerminalRef, stealingIsHostile)
EndEvent

;-- OnTerminalMenuItemRun Event Handler --
; Called when a menu item is selected. Updates the settings based on user input.
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    LZP:SystemScript.Log("OnTerminalMenuItemRun triggered: MenuItemID = " + auiMenuItemID, 3)

    If akTerminalBase != CurrentTerminalMenu
        LZP:SystemScript.Log("Terminal menu does not match. Exiting event.", 3)
        Return
    EndIf

    If auiMenuItemID == 0
        Bool newStealState = !(LPSetting_AllowStealing.GetValue() as Bool)
        LPSetting_AllowStealing.SetValue(newStealState as Float)
        UpdateStealingSetting(akTerminalRef, newStealState)

        If !newStealState
            LPSetting_StealingIsHostile.SetValue(0.0)
            UpdateHostileSetting(akTerminalRef, False)
        EndIf

    ElseIf auiMenuItemID == 1
        Bool newHostileState = !(LPSetting_StealingIsHostile.GetValue() as Bool)
        LPSetting_StealingIsHostile.SetValue(newHostileState as Float)
        UpdateHostileSetting(akTerminalRef, newHostileState)
    EndIf
EndEvent