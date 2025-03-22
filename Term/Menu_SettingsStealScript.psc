;======================================================================
; Script Name   : LZP:Term:Menu_SettingsStealScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Controls theft-related settings via a terminal menu
; Description   : Allows toggling of stealing permission and whether it
;                 triggers hostility. Updates terminal text feedback using
;                 replacement data and logs events with LoggerScript.
; Dependencies  : LazyPanda.esm, LoggerScript, TerminalMenu, GlobalVariables
; Usage         : Attach to a TerminalMenu where menu item IDs correspond to
;                 stealing toggles
;======================================================================


ScriptName LZP:Term:Menu_SettingsStealScript Extends TerminalMenu Hidden

;======================================================================
; PROPERTIES
;======================================================================

;-- GlobalSettings
; Controls stealing behavior toggles
Group GlobalVariable_Autofill
    GlobalVariable Property LPSetting_AllowStealing Auto Mandatory
    GlobalVariable Property LPSetting_StealingIsHostile Auto Mandatory
EndGroup

;-- FeedbackMessages
; Replacement messages for On/Off feedback
Group Message_Autofill
    Message Property LPOffMsg Auto Const Mandatory
    Message Property LPOnMsg Auto Const Mandatory
EndGroup

;-- TerminalConfig
; Menu object currently in use
Group Misc
    TerminalMenu Property CurrentTerminalMenu Auto Const Mandatory
EndGroup

;-- Logger
; Central debug logging utility
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup


;======================================================================
; FUNCTIONS
;======================================================================

;-- UpdateStealingSetting Function --
; @param akTerminalRef: Terminal instance being modified
; @param isEnabled: Boolean indicating whether stealing is allowed
; Updates terminal replacement label for stealing status
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
; @param akTerminalRef: Terminal instance being modified
; @param isEnabled: Boolean indicating if stealing triggers hostility
; Updates terminal replacement label for hostile behavior
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
; @param akTerminalBase: Terminal menu base object
; @param akTerminalRef: Terminal instance being entered
; Updates text replacements for current stealing/hostility settings
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
; @param auiMenuItemID: Selected menu item index
; @param akTerminalBase: Terminal menu base
; @param akTerminalRef: Terminal instance where the menu item was selected
; Handles toggles for stealing settings and updates UI
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
