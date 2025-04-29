;======================================================================
; Script Name   : LZP:Term:Menu_SettingsGeneralScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Handles general mod settings via terminal interface
; Description   : Allows user to cycle between preset loot radius values and 
;                 change destination for looted items. Reflects values on the 
;                 terminal UI and logs all actions using LoggerScript.
; Dependencies  : LazyPanda.esm, LoggerScript, GlobalVariables, TerminalMenu
; Usage         : Attach to a terminal menu; configure menu items by index
;======================================================================

ScriptName LZP:Term:Menu_SettingsGeneralScript Extends TerminalMenu hidden

;======================================================================
; PROPERTY GROUPS
;======================================================================

;------------------------------
; GlobalVariable Autofill
;------------------------------
Group GlobalVariable_Autofill
  GlobalVariable Property LZP_Setting_Radius Auto mandatory
  GlobalVariable Property LZP_Setting_SendTo Auto mandatory
EndGroup

;------------------------------
; Message Autofill
;------------------------------
Group Message_Autofill
  Message Property LZP_MESG_Dest_LodgeSafe Auto Const mandatory
  Message Property LZP_MESG_Dest_Player Auto Const mandatory
  Message Property LZP_MESG_Dest_Dummy Auto Const mandatory
  Message Property LZP_MESG_Status_Disable Auto Const mandatory
  Message Property LZP_MESG_Status_Enable Auto Const mandatory
EndGroup

;------------------------------
; Miscellaneous Properties
;------------------------------
Group Misc
  Float[] Property RadiusChoices Auto Const mandatory
  TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
EndGroup

;------------------------------
; Logger
;------------------------------
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;------------------------------
; Tokens
; Replacement tokens for terminal display keys
;------------------------------
Group Tokens
    String Property Token_CurrentRadius = "currentRadius" Auto Const hidden
    String Property Token_Destination   = "Destination" Auto Const hidden
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;----------------------------------------------------------------------
; Function : UpdateDestinationDisplay
; Purpose  : Updates the terminal display for the destination setting 
;            based on its value.
;----------------------------------------------------------------------
Function UpdateDestinationDisplay(ObjectReference akTerminalRef, Int dest)
    If dest == 1
        akTerminalRef.AddTextReplacementData(Token_Destination, LZP_MESG_Dest_Player as Form)
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("UpdateDestinationDisplay: Setting Destination to LZP_MESG_Dest_Player", 1, "Menu_SettingsGeneralScript")
        EndIf
    ElseIf dest == 2
        akTerminalRef.AddTextReplacementData(Token_Destination, LZP_MESG_Dest_LodgeSafe as Form)
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("UpdateDestinationDisplay: Setting Destination to LZP_MESG_Dest_LodgeSafe", 1, "Menu_SettingsGeneralScript")
        EndIf
    ElseIf dest == 3
        akTerminalRef.AddTextReplacementData(Token_Destination, LZP_MESG_Dest_Dummy as Form)
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("UpdateDestinationDisplay: Setting Destination to LZP_MESG_Dest_Dummy", 1, "Menu_SettingsGeneralScript")
        EndIf
    EndIf
EndFunction

;----------------------------------------------------------------------
; Function : CycleRadius
; Purpose  : Cycles the current radius setting through the RadiusChoices array.
;----------------------------------------------------------------------
Function CycleRadius(ObjectReference akTerminalRef)
    Float currentRadius = LZP_Setting_Radius.GetValue()
    Int currentRadiusIndex = RadiusChoices.find(currentRadius, 0)
    Int newRadiusIndex = currentRadiusIndex + 1

    ; Wrap around to the first element if at the end.
    If newRadiusIndex >= RadiusChoices.Length
        newRadiusIndex = 0
    EndIf

    LZP_Setting_Radius.SetValue(RadiusChoices[newRadiusIndex])
    akTerminalRef.AddTextReplacementValue(Token_CurrentRadius, RadiusChoices[newRadiusIndex])
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("CycleRadius: Cycled radius to new value", 1, "Menu_SettingsGeneralScript")
        Logger.LogAdv(RadiusChoices[newRadiusIndex] as String, 1, "Menu_SettingsGeneralScript")
    EndIf
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;----------------------------------------------------------------------
; Event : OnTerminalMenuEnter
; Purpose: Called when the terminal menu is opened. Updates current radius 
;          and destination displays.
;----------------------------------------------------------------------
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("OnTerminalMenuEnter: Triggered", 1, "Menu_SettingsGeneralScript")
    EndIf

    Float currentRadius = LZP_Setting_Radius.GetValue()
    akTerminalRef.AddTextReplacementValue(Token_CurrentRadius, currentRadius)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("OnTerminalMenuEnter: Current radius value", 1, "Menu_SettingsGeneralScript")
        Logger.LogAdv(currentRadius as String, 1, "Menu_SettingsGeneralScript")
    EndIf
  
    Int currentDest = LZP_Setting_SendTo.GetValue() as Int
    UpdateDestinationDisplay(akTerminalRef, currentDest)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("OnTerminalMenuEnter: Current destination value", 1, "Menu_SettingsGeneralScript")
        Logger.LogAdv(currentDest as String, 1, "Menu_SettingsGeneralScript")
    EndIf
EndEvent

;----------------------------------------------------------------------
; Event : OnTerminalMenuItemRun
; Purpose: Called when a menu item is selected. Handles cycling radius 
;          or destination setting.
;----------------------------------------------------------------------
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("OnTerminalMenuItemRun: Triggered with menu item ID", 1, "Menu_SettingsGeneralScript")
        Logger.LogAdv(auiMenuItemID as String, 1, "Menu_SettingsGeneralScript")
    EndIf

    If akTerminalBase == CurrentTerminalMenu
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("OnTerminalMenuItemRun: Terminal menu matches CurrentTerminalMenu", 1, "Menu_SettingsGeneralScript")
        EndIf

        ; Menu item 0: Cycle the radius value.
        If auiMenuItemID == 0
            If Logger && Logger.IsEnabled()
                Logger.LogAdv("OnTerminalMenuItemRun: Cycling radius", 1, "Menu_SettingsGeneralScript")
            EndIf
            CycleRadius(akTerminalRef)

        ; Menu item 1: Cycle the destination setting.
        ElseIf auiMenuItemID == 1
            If Logger && Logger.IsEnabled()
                Logger.LogAdv("OnTerminalMenuItemRun: Cycling destination", 1, "Menu_SettingsGeneralScript")
            EndIf
            Int currentDest = LZP_Setting_SendTo.GetValue() as Int
            ; Cycle destination by incrementing, wrapping after 3.
            Int newDest = currentDest + 1
            If newDest > 3
                newDest = 1
            EndIf
            LZP_Setting_SendTo.SetValue(newDest as Float)
            UpdateDestinationDisplay(akTerminalRef, newDest)
            If Logger && Logger.IsEnabled()
                Logger.LogAdv("OnTerminalMenuItemRun: New destination value", 1, "Menu_SettingsGeneralScript")
                Logger.LogAdv(newDest as String, 1, "Menu_SettingsGeneralScript")
            EndIf
        EndIf
    EndIf
EndEvent
