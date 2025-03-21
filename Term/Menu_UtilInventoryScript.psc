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
Group Menu_UtilProperties
    TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
    ObjectReference Property LodgeSafeRef Auto Const mandatory
    ObjectReference Property LPDummyHoldingRef Auto Const mandatory
    ObjectReference Property PlayerRef Auto Const mandatory
    ReferenceAlias Property PlayerHomeShip Auto Const mandatory
EndGroup

;-- Debug Properties --
Group DebugProperties
    GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory
EndGroup

;-- Global Variables --
Group GlobalVariable_Autofill
    GlobalVariable Property LPSystemUtil_ToggleLooting Auto mandatory
EndGroup

;-- Messages --
Group Message_Autofill
    Message Property LPOffMsg Auto Const mandatory
    Message Property LPOnMsg Auto Const mandatory
    Message Property LPDebugOnMsg Auto Const mandatory
    Message Property LPDebugOffMsg Auto Const mandatory
EndGroup

;-- Logger Property --
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;-- UpdateLootingDisplay Function --
; Updates the terminal display for the looting status.
Function UpdateLootingDisplay(ObjectReference akTerminalRef, Bool currentLootSetting)
    If !currentLootSetting
        If Logger && Logger.IsEnabled()
            Logger.Log("Updating display: Looting is off")
        EndIf
        akTerminalRef.AddTextReplacementData("Looting", LPOffMsg as Form)
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("Updating display: Looting is on")
        EndIf
        akTerminalRef.AddTextReplacementData("Looting", LPOnMsg as Form)
    EndIf
EndFunction

;-- UpdateDebugDisplay Function --
; Updates the terminal display for the debug status.
Function UpdateDebugDisplay(ObjectReference akTerminalRef, Bool currentDebugStatus)
    If currentDebugStatus
        If Logger && Logger.IsEnabled()
            Logger.Log("Updating display: Debugging is on")
        EndIf
        akTerminalRef.AddTextReplacementData("Logging", LPDebugOnMsg as Form)
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("Updating display: Debugging is off")
        EndIf
        akTerminalRef.AddTextReplacementData("Logging", LPDebugOffMsg as Form)
    EndIf
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnTerminalMenuEnter Event Handler --
; Called when the terminal menu opens.
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If Logger && Logger.IsEnabled()
        Logger.Log("OnTerminalMenuEnter triggered")
    EndIf
    
    ; Get current settings
    Bool currentLootSetting = LPSystemUtil_ToggleLooting.GetValue() as Bool
    Bool currentDebugStatus = LPSystemUtil_Debug.GetValue() as Bool
    
    ; Log current settings
    If Logger && Logger.IsEnabled()
        Logger.Log("Current loot setting: " + currentLootSetting as String)
        Logger.Log("Current debug status: " + currentDebugStatus as String)
    EndIf
    
    ; Update displays
    UpdateLootingDisplay(akTerminalRef, currentLootSetting)
    UpdateDebugDisplay(akTerminalRef, currentDebugStatus)
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
        
        ; Toggle looting when menu item 1 is selected.
        If auiMenuItemID == 1
            If Logger && Logger.IsEnabled()
                Logger.Log("Menu item 1 selected")
            EndIf
            Bool currentLootSetting = LPSystemUtil_ToggleLooting.GetValue() as Bool
            If Logger && Logger.IsEnabled()
                Logger.Log("Current loot setting: " + currentLootSetting as String)
            EndIf
            If !currentLootSetting
                If Logger && Logger.IsEnabled()
                    Logger.Log("Turning looting on")
                EndIf
                LPSystemUtil_ToggleLooting.SetValue(1.0)
            Else
                If Logger && Logger.IsEnabled()
                    Logger.Log("Turning looting off")
                EndIf
                LPSystemUtil_ToggleLooting.SetValue(0.0)
            EndIf
            ; Update the display after toggling.
            UpdateLootingDisplay(akTerminalRef, LPSystemUtil_ToggleLooting.GetValue() as Bool)
            
        ; Activate LodgeSafeRef when menu item 2 is selected.
        ElseIf auiMenuItemID == 2
            If Logger && Logger.IsEnabled()
                Logger.Log("Menu item 2 selected")
                Logger.Log("Activating LodgeSafeRef")
            EndIf
            LodgeSafeRef.Activate(PlayerRef, False)
            
        ; Open inventory for LPDummyHoldingRef when menu item 3 is selected.
        ElseIf auiMenuItemID == 3
            If Logger && Logger.IsEnabled()
                Logger.Log("Menu item 3 selected")
                Logger.Log("Opening inventory for LPDummyHoldingRef")
            EndIf
            (LPDummyHoldingRef as Actor).OpenInventory(True, None, False)
            
        ; Open inventory for PlayerHomeShip when menu item 4 is selected.
        ElseIf auiMenuItemID == 4
            If Logger && Logger.IsEnabled()
                Logger.Log("Menu item 4 selected")
                Logger.Log("Opening inventory for PlayerHomeShip")
            EndIf
            spaceshipreference PlayerShip = PlayerHomeShip.GetRef() as spaceshipreference
            PlayerShip.OpenInventory()
            
        ; Toggle debug status when menu item 5 is selected.
        ElseIf auiMenuItemID == 5
            If Logger && Logger.IsEnabled()
                Logger.Log("Menu item 5 selected")
            EndIf
            Bool currentDebugStatus = LPSystemUtil_Debug.GetValue() as Bool
            If Logger && Logger.IsEnabled()
                Logger.Log("Current debug status: " + currentDebugStatus as String)
            EndIf
            If !currentDebugStatus
                If Logger && Logger.IsEnabled()
                    Logger.Log("Turning debugging on")
                EndIf
                LPSystemUtil_Debug.SetValue(1.0)
            Else
                If Logger && Logger.IsEnabled()
                    Logger.Log("Turning debugging off")
                EndIf
                LPSystemUtil_Debug.SetValue(0.0)
            EndIf
            ; Update the display after toggling.
            UpdateDebugDisplay(akTerminalRef, LPSystemUtil_Debug.GetValue() as Bool)
        EndIf
    EndIf
EndEvent
