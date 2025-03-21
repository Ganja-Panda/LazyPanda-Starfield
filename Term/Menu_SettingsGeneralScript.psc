;======================================================================
; Script: LZP:Term:Menu_SettingsGeneralScript
; Description: This script manages the general settings menu functionality.
; It updates settings based on user interactions and provides feedback
; through messages. Debug logging is integrated to assist with troubleshooting.
;======================================================================

ScriptName LZP:Term:Menu_SettingsGeneralScript Extends TerminalMenu hidden

;======================================================================
; PROPERTY GROUPS
;======================================================================

;-- GlobalVariable Autofill --
Group GlobalVariable_Autofill
  GlobalVariable Property LPSetting_Radius Auto mandatory
  GlobalVariable Property LPSetting_SendTo Auto mandatory
EndGroup

;-- Message Autofill --
Group Message_Autofill
  Message Property LPDestLodgeSafeMsg Auto Const mandatory
  Message Property LPDestPlayerMsg Auto Const mandatory
  Message Property LPDestDummyMsg Auto Const mandatory
  Message Property LPOffMsg Auto Const mandatory
  Message Property LPOnMsg Auto Const mandatory
EndGroup

;-- Miscellaneous Properties --
Group Misc
  Float[] Property RadiusChoices Auto Const mandatory
  TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
EndGroup

;-- Logger Property --
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;-- UpdateDestinationDisplay Function --
; Updates the terminal display for the destination setting based on its value.
Function UpdateDestinationDisplay(ObjectReference akTerminalRef, Int dest)
    If dest == 1
        akTerminalRef.AddTextReplacementData("Destination", LPDestPlayerMsg as Form)
        If Logger && Logger.IsEnabled()
            Logger.Log("Setting Destination to LPDestPlayerMsg")
        EndIf
    ElseIf dest == 2
        akTerminalRef.AddTextReplacementData("Destination", LPDestLodgeSafeMsg as Form)
        If Logger && Logger.IsEnabled()
            Logger.Log("Setting Destination to LPDestLodgeSafeMsg")
        EndIf
    ElseIf dest == 3
        akTerminalRef.AddTextReplacementData("Destination", LPDestDummyMsg as Form)
        If Logger && Logger.IsEnabled()
            Logger.Log("Setting Destination to LPDestDummyMsg")
        EndIf
    EndIf
EndFunction

;-- CycleRadius Function --
; Cycles the current radius setting through the RadiusChoices array.
Function CycleRadius(ObjectReference akTerminalRef)
    Float currentRadius = LPSetting_Radius.GetValue()
    ; Find the current radius index in the array.
    Int currentRadiusIndex = RadiusChoices.find(currentRadius, 0)
    Int newRadiusIndex = currentRadiusIndex + 1

    ; If at the end of the array, wrap around to the first element.
    If currentRadiusIndex == RadiusChoices.Length - 1
        newRadiusIndex = 0
    EndIf

    ; Set the new radius value and update the display.
    LPSetting_Radius.SetValue(RadiusChoices[newRadiusIndex])
    akTerminalRef.AddTextReplacementValue("currentRadius", RadiusChoices[newRadiusIndex])
    If Logger && Logger.IsEnabled()
        Logger.Log("Cycled radius to " + RadiusChoices[newRadiusIndex] as String)
    EndIf
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnTerminalMenuEnter Event Handler --
; Called when the terminal menu is opened.
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.Log("OnTerminalMenuEnter triggered")
    EndIf

    ; Retrieve and display the current radius.
    Float currentRadius = LPSetting_Radius.GetValue()
    akTerminalRef.AddTextReplacementValue("currentRadius", currentRadius)
    If Logger && Logger.IsEnabled()
        Logger.Log("Current radius: " + currentRadius as String)
    EndIf
  
    ; Retrieve and display the current destination.
    Int currentDest = LPSetting_SendTo.GetValue() as Int
    UpdateDestinationDisplay(akTerminalRef, currentDest)
    If Logger && Logger.IsEnabled()
        Logger.Log("Current destination: " + currentDest as String)
    EndIf
EndEvent

;-- OnTerminalMenuItemRun Event Handler --
; Called when a menu item is selected.
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

            ; Cycle destination: 3 -> 1, 1 -> 2, 2 -> 3.
            If currentDest == 3
                LPSetting_SendTo.SetValue(1.0)
                currentDest = 1
            ElseIf currentDest == 1
                LPSetting_SendTo.SetValue(2.0)
                currentDest = 2
            ElseIf currentDest == 2
                LPSetting_SendTo.SetValue(3.0)
                currentDest = 3
            EndIf

            UpdateDestinationDisplay(akTerminalRef, currentDest)
            If Logger && Logger.IsEnabled()
                Logger.Log("New destination: " + currentDest as String)
            EndIf
        EndIf
    EndIf
EndEvent
