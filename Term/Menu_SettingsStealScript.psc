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

;------------------------------
; GlobalSettings
; Controls stealing behavior toggles
;------------------------------
Group GlobalVariable_Autofill
    GlobalVariable Property LZP_Setting_AllowStealing Auto Mandatory
    GlobalVariable Property LZP_Setting_StealingIsHostile Auto Mandatory
EndGroup

;------------------------------
; FeedbackMessages
; Replacement messages for On/Off feedback
;------------------------------
Group Message_Autofill
    Message Property LZP_MESG_Status_Disabled Auto Const Mandatory
    Message Property LZP_MESG_Status_Enabled Auto Const Mandatory
EndGroup

;------------------------------
; TerminalConfig
; Menu object currently in use
;------------------------------
Group Misc
    TerminalMenu Property CurrentTerminalMenu Auto Const Mandatory
EndGroup

;------------------------------
; Logger
; Central debug logging utility
;------------------------------
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;------------------------------
; Tokens
; Replacement tokens for terminal display keys
;------------------------------
Group Tokens
    String Property Token_Stealing = "Stealing" Auto Const Hidden
    String Property Token_Hostile = "Hostile" Auto Const Hidden
EndGroup

;======================================================================
; FUNCTIONS
;======================================================================

;----------------------------------------------------------------------
; Function : UpdateStealingSetting
; Purpose  : Updates the terminal replacement label for stealing status.
; Parameters:
;    akTerminalRef - Terminal instance being modified.
;    isEnabled     - Boolean indicating whether stealing is allowed.
;----------------------------------------------------------------------
Function UpdateStealingSetting(ObjectReference akTerminalRef, Bool isEnabled)
    Message msgToUse = LZP_MESG_Status_Disabled
    If isEnabled
        msgToUse = LZP_MESG_Status_Enabled
    EndIf
    akTerminalRef.AddTextReplacementData(Token_Stealing, msgToUse as Form)
    
    If Logger && Logger.IsEnabled()
        If isEnabled
            Logger.LogAdv("UpdateStealingSetting: Stealing set to True", 1, "Menu_SettingsStealScript")
        Else
            Logger.LogAdv("UpdateStealingSetting: Stealing set to False", 1, "Menu_SettingsStealScript")
        EndIf
    EndIf
EndFunction

;----------------------------------------------------------------------
; Function : UpdateHostileSetting
; Purpose  : Updates the terminal replacement label for hostile behavior.
; Parameters:
;    akTerminalRef - Terminal instance being modified.
;    isEnabled     - Boolean indicating if stealing triggers hostility.
;----------------------------------------------------------------------
Function UpdateHostileSetting(ObjectReference akTerminalRef, Bool isEnabled)
    Message msgToUse = LZP_MESG_Status_Disabled
    If isEnabled
        msgToUse = LZP_MESG_Status_Enabled
    EndIf
    akTerminalRef.AddTextReplacementData(Token_Hostile, msgToUse as Form)
    
    If Logger && Logger.IsEnabled()
        If isEnabled
            Logger.LogAdv("UpdateHostileSetting: Hostile set to True", 1, "Menu_SettingsStealScript")
        Else
            Logger.LogAdv("UpdateHostileSetting: Hostile set to False", 1, "Menu_SettingsStealScript")
        EndIf
    EndIf
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;----------------------------------------------------------------------
; Event : OnTerminalMenuEnter
; Purpose: Updates text replacements for current stealing and hostility settings.
; Parameters:
;    akTerminalBase - Terminal menu base object.
;    akTerminalRef  - Terminal instance being entered.
;----------------------------------------------------------------------
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("OnTerminalMenuEnter: Triggered", 1, "Menu_SettingsStealScript")
    EndIf

    Bool allowStealing = LZP_Setting_AllowStealing.GetValue() as Bool
    Bool stealingIsHostile = LZP_Setting_StealingIsHostile.GetValue() as Bool

    UpdateStealingSetting(akTerminalRef, allowStealing)
    UpdateHostileSetting(akTerminalRef, stealingIsHostile)
EndEvent

;----------------------------------------------------------------------
; Event : OnTerminalMenuItemRun
; Purpose: Handles toggles for stealing settings and updates the UI.
; Parameters:
;    auiMenuItemID  - Selected menu item index.
;    akTerminalBase - Terminal menu base.
;    akTerminalRef  - Terminal instance where the menu item was selected.
;----------------------------------------------------------------------
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("OnTerminalMenuItemRun: Triggered with MenuItemID", 1, "Menu_SettingsStealScript")
        Logger.LogAdv(auiMenuItemID as String, 1, "Menu_SettingsStealScript")
    EndIf

    If akTerminalBase != CurrentTerminalMenu
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("OnTerminalMenuItemRun: Terminal menu does not match. Exiting event.", 2, "Menu_SettingsStealScript")
        EndIf
        Return
    EndIf

    If auiMenuItemID == 0
        Bool newStealState = !(LZP_Setting_AllowStealing.GetValue() as Bool)
        LZP_Setting_AllowStealing.SetValue(newStealState as Float)
        UpdateStealingSetting(akTerminalRef, newStealState)
        
        If !newStealState
            LZP_Setting_StealingIsHostile.SetValue(0.0)
            UpdateHostileSetting(akTerminalRef, False)
        EndIf

        If Logger && Logger.IsEnabled()
            Logger.LogAdv("OnTerminalMenuItemRun: Stealing toggled to", 1, "Menu_SettingsStealScript")
            Logger.LogAdv(newStealState as String, 1, "Menu_SettingsStealScript")
        EndIf

    ElseIf auiMenuItemID == 1
        Bool newHostileState = !(LZP_Setting_StealingIsHostile.GetValue() as Bool)
        LZP_Setting_StealingIsHostile.SetValue(newHostileState as Float)
        UpdateHostileSetting(akTerminalRef, newHostileState)

        If Logger && Logger.IsEnabled()
            Logger.LogAdv("OnTerminalMenuItemRun: Hostile toggled to", 1, "Menu_SettingsStealScript")
            Logger.LogAdv(newHostileState as String, 1, "Menu_SettingsStealScript")
        EndIf
    EndIf
EndEvent
