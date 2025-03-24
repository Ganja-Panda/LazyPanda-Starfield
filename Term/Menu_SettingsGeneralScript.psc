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
  GlobalVariable Property LPSetting_Radius Auto mandatory
  GlobalVariable Property LPSetting_SendTo Auto mandatory
EndGroup

;------------------------------
; Message Autofill
;------------------------------
Group Message_Autofill
  Message Property LPDestLodgeSafeMsg Auto Const mandatory
  Message Property LPDestPlayerMsg Auto Const mandatory
  Message Property LPDestDummyMsg Auto Const mandatory
  Message Property LPOffMsg Auto Const mandatory
  Message Property LPOnMsg Auto Const mandatory
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
        akTerminalRef.AddTextReplacementData(Token_Destination, LPDestPlayerMsg as Form)
        If Logger && Logger.IsEnabled()
            Logger.Log("Setting Destination to LPDestPlayerMsg")
        EndIf
    ElseIf dest == 2
        akTerminalRef.AddTextReplacementData(Token_Destination, LPDestLodgeSafeMsg as Form)
        If Logger && Logger.IsEnabled()
            Logger.Log("Setting Destination to LPDestLodgeSafeMsg")
        EndIf
    ElseIf dest == 3
        akTerminalRef.AddTextReplacementData(Token_Destination, LPDestDummyMsg as Form)
        If Logger && Logger.IsEnabled()
            Logger.Log("Setting Destination to LPDestDummyMsg")
        EndIf
    EndIf
EndFunction

;----------------------------------------------------------------------
; Function : CycleRadius
; Purpose  : Cycles the current radius setting through the RadiusChoices array.
;----------------------------------------------------------------------
Function CycleRadius(ObjectReference akTerminalRef)
    Float currentRadius = LPSetting_Radius.GetValue()
    Int currentRadiusIndex = RadiusChoices.find(currentRadius, 0)
    Int newRadiusIndex = currentRadiusIndex + 1

    ; Wrap around to the first element if at the end.
    If newRadiusIndex >= RadiusChoices.Length
        newRadiusIndex = 0
    EndIf

    LPSetting_Radius.SetValue(RadiusChoices[newRadiusIndex])
    akTerminalRef.AddTextReplacementValue(Token_CurrentRadius, RadiusChoices[newRadiusIndex])
    If Logger && Logger.IsEnabled()
        Logger.Log("Cycled radius to " + RadiusChoices[newRadiusIndex] as String)
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
        Logger.Log("OnTerminalMenuEnter triggered")
    EndIf

    Float currentRadius = LPSetting_Radius.GetValue()
    akTerminalRef.AddTextReplacementValue(Token_CurrentRadius, currentRadius)
    If Logger && Logger.IsEnabled()
        Logger.Log("Current radius: " + currentRadius as String)
    EndIf
  
    Int currentDest = LPSetting_SendTo.GetValue() as Int
    UpdateDestinationDisplay(akTerminalRef, currentDest)
    If Logger && Logger.IsEnabled()
        Logger.Log("Current destination: " + currentDest as String)
    EndIf
EndEvent

;----------------------------------------------------------------------
; Event : OnTerminalMenuItemRun
; Purpose: Called when a menu item is selected. Handles cycling radius 
;          or destination setting.
;----------------------------------------------------------------------
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.Log("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String)
    EndIf

    If akTerminalBase == CurrentTerminalMenu
        If Logger && Logger.IsEnabled()
            Logger.Log("Terminal menu matches CurrentTerminalMenu")
        EndIf

        ; Menu item 0: Cycle the radius value.
        If auiMenuItemID == 0
            If Logger && Logger.IsEnabled()
                Logger.Log("Cycling radius")
            EndIf
            CycleRadius(akTerminalRef)

        ; Menu item 1: Cycle the destination setting.
        ElseIf auiMenuItemID == 1
            If Logger && Logger.IsEnabled()
                Logger.Log("Cycling destination")
            EndIf
            Int currentDest = LPSetting_SendTo.GetValue() as Int
            ; Cycle destination by incrementing, wrapping after 3.
            Int newDest = currentDest + 1
            If newDest > 3
                newDest = 1
            EndIf
            LPSetting_SendTo.SetValue(newDest as Float)
            UpdateDestinationDisplay(akTerminalRef, newDest)
            If Logger && Logger.IsEnabled()
                Logger.Log("New destination: " + newDest as String)
            EndIf
        EndIf
    EndIf
EndEvent
