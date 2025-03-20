;======================================================================
; Script: LZP:Term:Menu_UtilInventoryScript
; Description: This script manages the utility inventory menu functionality.
; It updates settings based on user interactions and provides feedback
; through messages. Debug logging is integrated to assist with troubleshooting.
;======================================================================

ScriptName LZP:Term:Menu_UtilInventoryScript Extends TerminalMenu hidden

;======================================================================
; PROPERTY GROUPS
;======================================================================

;-- Menu Util Properties --
; Properties required for the menu utility functionality.
Group Menu_UtilProperties
  TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
  ObjectReference Property LodgeSafeRef Auto Const mandatory
  ObjectReference Property LPDummyHoldingRef Auto Const mandatory
  ObjectReference Property PlayerRef Auto Const mandatory
  ReferenceAlias Property PlayerHomeShip Auto Const mandatory
EndGroup

;-- Debug Properties --
; Properties required for debugging functionality.
Group DebugProperties
  GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory
EndGroup

;-- Global Variables --
; Global variables for settings such as looting toggle.
Group GlobalVariable_Autofill
  GlobalVariable Property LPSystemUtil_ToggleLooting Auto mandatory
EndGroup

;-- Messages --
; Messages displayed to the player when toggling settings.
Group Message_Autofill
  Message Property LPOffMsg Auto Const mandatory
  Message Property LPOnMsg Auto Const mandatory
  Message Property LPDebugOnMsg Auto Const mandatory
  Message Property LPDebugOffMsg Auto Const mandatory
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;-- UpdateLootingDisplay Function --
; Updates the terminal display for the looting status.
Function UpdateLootingDisplay(ObjectReference akTerminalRef, Bool currentLootSetting)
    If !currentLootSetting
        LZP:SystemScript.Log("Updating display: Looting is off", 3)
        akTerminalRef.AddTextReplacementData("Looting", LPOffMsg as Form)
    Else
        LZP:SystemScript.Log("Updating display: Looting is on", 3)
        akTerminalRef.AddTextReplacementData("Looting", LPOnMsg as Form)
    EndIf
EndFunction

;-- UpdateDebugDisplay Function --
; Updates the terminal display for the debug status.
Function UpdateDebugDisplay(ObjectReference akTerminalRef, Bool currentDebugStatus)
    If currentDebugStatus
        LZP:SystemScript.Log("Updating display: Debugging is on", 3)
        akTerminalRef.AddTextReplacementData("Logging", LPDebugOnMsg as Form)
    Else
        LZP:SystemScript.Log("Updating display: Debugging is off", 3)
        akTerminalRef.AddTextReplacementData("Logging", LPDebugOffMsg as Form)
    EndIf
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnTerminalMenuEnter Event Handler --
; Called when the terminal menu opens.
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    LZP:SystemScript.Log("OnTerminalMenuEnter triggered", 3)
    
    ; Get current settings
    Bool currentLootSetting = LPSystemUtil_ToggleLooting.GetValue() as Bool
    Bool currentDebugStatus = LPSystemUtil_Debug.GetValue() as Bool
    
    ; Log current settings
    LZP:SystemScript.Log("Current loot setting: " + currentLootSetting as String, 3)
    LZP:SystemScript.Log("Current debug status: " + currentDebugStatus as String, 3)
    
    ; Update displays
    UpdateLootingDisplay(akTerminalRef, currentLootSetting)
    UpdateDebugDisplay(akTerminalRef, currentDebugStatus)
EndEvent

;-- OnTerminalMenuItemRun Event Handler --
; Called when a menu item is selected.
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    LZP:SystemScript.Log("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String, 3)
    If akTerminalBase == CurrentTerminalMenu
        LZP:SystemScript.Log("Terminal menu matches CurrentTerminalMenu", 3)
        
        ; Toggle looting when menu item 1 is selected.
        If auiMenuItemID == 1
            LZP:SystemScript.Log("Menu item 1 selected", 3)
            Bool currentLootSetting = LPSystemUtil_ToggleLooting.GetValue() as Bool
            LZP:SystemScript.Log("Current loot setting: " + currentLootSetting as String, 3)
            If !currentLootSetting
                LZP:SystemScript.Log("Turning looting on", 3)
                LPSystemUtil_ToggleLooting.SetValue(1.0)
            Else
                LZP:SystemScript.Log("Turning looting off", 3)
                LPSystemUtil_ToggleLooting.SetValue(0.0)
            EndIf
            ; Update the display after toggling.
            UpdateLootingDisplay(akTerminalRef, LPSystemUtil_ToggleLooting.GetValue() as Bool)
            
        ; Activate LodgeSafeRef when menu item 2 is selected.
        ElseIf auiMenuItemID == 2
            LZP:SystemScript.Log("Menu item 2 selected", 3)
            LZP:SystemScript.Log("Activating LodgeSafeRef", 3)
            LodgeSafeRef.Activate(PlayerRef, False)
            
        ; Open inventory for LPDummyHoldingRef when menu item 3 is selected.
        ElseIf auiMenuItemID == 3
            LZP:SystemScript.Log("Menu item 3 selected", 3)
            LZP:SystemScript.Log("Opening inventory for LPDummyHoldingRef", 3)
            (LPDummyHoldingRef as Actor).OpenInventory(True, None, False)
            
        ; Open inventory for PlayerHomeShip when menu item 4 is selected.
        ElseIf auiMenuItemID == 4
            LZP:SystemScript.Log("Menu item 4 selected", 3)
            LZP:SystemScript.Log("Opening inventory for PlayerHomeShip", 3)
            spaceshipreference PlayerShip = PlayerHomeShip.GetRef() as spaceshipreference
            PlayerShip.OpenInventory()
            
        ; Toggle debug status when menu item 5 is selected.
        ElseIf auiMenuItemID == 5
            LZP:SystemScript.Log("Menu item 5 selected", 3)
            Bool currentDebugStatus = LPSystemUtil_Debug.GetValue() as Bool
            LZP:SystemScript.Log("Current debug status: " + currentDebugStatus as String, 3)
            If !currentDebugStatus
                LZP:SystemScript.Log("Turning debugging on", 3)
                LPSystemUtil_Debug.SetValue(1.0)
            Else
                LZP:SystemScript.Log("Turning debugging off", 3)
                LPSystemUtil_Debug.SetValue(0.0)
            EndIf
            ; Update the display after toggling.
            UpdateDebugDisplay(akTerminalRef, LPSystemUtil_Debug.GetValue() as Bool)
        EndIf
    EndIf
EndEvent