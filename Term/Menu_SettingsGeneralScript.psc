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
; Global variables for settings such as radius and destination.
Group GlobalVariable_Autofill
  GlobalVariable Property LPSetting_Radius Auto mandatory
  GlobalVariable Property LPSetting_SendTo Auto mandatory
EndGroup

;-- Message Autofill --
; Messages displayed to the player when toggling settings.
Group Message_Autofill
  Message Property LPDestLodgeSafeMsg Auto Const mandatory
  Message Property LPDestPlayerMsg Auto Const mandatory
  Message Property LPDestDummyMsg Auto Const mandatory
  Message Property LPOffMsg Auto Const mandatory
  Message Property LPOnMsg Auto Const mandatory
EndGroup

;-- Miscellaneous Properties --
; Additional properties including radius choices and the current terminal menu.
Group Misc
  Float[] Property RadiusChoices Auto Const mandatory
  TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
  GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;-- UpdateDestinationDisplay Function --
; Updates the terminal display for the destination setting based on its value.
Function UpdateDestinationDisplay(ObjectReference akTerminalRef, Int dest)
    If dest == 1
        akTerminalRef.AddTextReplacementData("Destination", LPDestPlayerMsg as Form)
        LZP:SystemScript.Log("Setting Destination to LPDestPlayerMsg", 3)
    ElseIf dest == 2
        akTerminalRef.AddTextReplacementData("Destination", LPDestLodgeSafeMsg as Form)
        LZP:SystemScript.Log("Setting Destination to LPDestLodgeSafeMsg", 3)
    ElseIf dest == 3
        akTerminalRef.AddTextReplacementData("Destination", LPDestDummyMsg as Form)
        LZP:SystemScript.Log("Setting Destination to LPDestDummyMsg", 3)
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
    LZP:SystemScript.Log("Cycled radius to " + RadiusChoices[newRadiusIndex] as String, 3)
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnTerminalMenuEnter Event Handler --
; Called when the terminal menu is opened.
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    LZP:SystemScript.Log("OnTerminalMenuEnter triggered", 3)

    ; Retrieve and display the current radius.
    Float currentRadius = LPSetting_Radius.GetValue()
    akTerminalRef.AddTextReplacementValue("currentRadius", currentRadius)
    LZP:SystemScript.Log("Current radius: " + currentRadius as String, 3)
  
    ; Retrieve and display the current destination.
    Int currentDest = LPSetting_SendTo.GetValue() as Int
    UpdateDestinationDisplay(akTerminalRef, currentDest)
    LZP:SystemScript.Log("Current destination: " + currentDest as String, 3)
EndEvent

;-- OnTerminalMenuItemRun Event Handler --
; Called when a menu item is selected.
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    LZP:SystemScript.Log("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String, 3)
    If akTerminalBase == CurrentTerminalMenu
        LZP:SystemScript.Log("Terminal menu matches CurrentTerminalMenu", 3)

        ; Menu item 0: Cycle the radius value.
        If auiMenuItemID == 0
            LZP:SystemScript.Log("Cycling radius", 3)
            CycleRadius(akTerminalRef)

        ; Menu item 1: Cycle the destination setting.
        ElseIf auiMenuItemID == 1
            LZP:SystemScript.Log("Cycling destination", 3)
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
            LZP:SystemScript.Log("New destination: " + currentDest as String, 3)
        EndIf
    EndIf
EndEvent
