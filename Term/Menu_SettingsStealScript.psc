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
Group GlobalVariable_Autofill
    GlobalVariable Property LPSetting_AllowStealing Auto Mandatory
    GlobalVariable Property LPSetting_StealingIsHostile Auto Mandatory
EndGroup

;-- Messages --
Group Message_Autofill
    Message Property LPOffMsg Auto Const Mandatory
    Message Property LPOnMsg Auto Const Mandatory
EndGroup

;-- Miscellaneous --
Group Misc
    TerminalMenu Property CurrentTerminalMenu Auto Const Mandatory
EndGroup

;-- Logger Property --
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
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
    If Logger && Logger.IsEnabled()
        Logger.Log("Updated Stealing to " + (isEnabled as String))
    EndIf
EndFunction

;-- UpdateHostileSetting Function --
; Updates the hostile setting and provides feedback to the player.
Function UpdateHostileSetting(ObjectReference akTerminalRef, Bool isEnabled)
    Message msgToUse = LPOffMsg
    If isEnabled
        msgToUse = LPOnMsg
    EndIf
    akTerminalRef.AddTextReplacementData("Hostile", msgToUse as Form)
    If Logger && Logger.IsEnabled()
        Logger.Log("Updated Hostile to " + (isEnabled as String))
    EndIf
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnTerminalMenuEnter Event Handler --
; Called when the terminal menu is entered. Updates the settings based on current values.
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.Log("OnTerminalMenuEnter triggered")
    EndIf

    Bool allowStealing = LPSetting_AllowStealing.GetValue() as Bool
    Bool stealingIsHostile = LPSetting_StealingIsHostile.GetValue() as Bool

    UpdateStealingSetting(akTerminalRef, allowStealing)
    UpdateHostileSetting(akTerminalRef, stealingIsHostile)
EndEvent

;-- OnTerminalMenuItemRun Event Handler --
; Called when a menu item is selected. Updates the settings based on user input.
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.Log("OnTerminalMenuItemRun triggered: MenuItemID = " + auiMenuItemID as String)
    EndIf

    If akTerminalBase != CurrentTerminalMenu
        If Logger && Logger.IsEnabled()
            Logger.Log("Terminal menu does not match. Exiting event.")
        EndIf
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
