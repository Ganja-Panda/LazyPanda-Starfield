;======================================================================
; Script Name   : LZP:Term:Menu_UtilInventoryScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Provides access to utility containers and system toggles
; Description   : This script allows the player to interact with utility options
;                 such as toggling looting/debugging, opening the Lodge Safe, the
;                 Dummy Holding container, or the Player Home Ship. Displays feedback
;                 in the terminal via replacement messages and logs all actions.
; Dependencies  : LazyPanda.esm, LoggerScript, TerminalMenu, GlobalVariables
; Usage         : Attach to a terminal menu that maps these utilities to item IDs
;======================================================================


ScriptName LZP:Term:Menu_UtilInventoryScript Extends TerminalMenu hidden

;======================================================================
; PROPERTIES
;======================================================================

;-- TerminalConfig
; Primary references for inventory/activation targets
Group Menu_UtilProperties
    TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
    ObjectReference Property LodgeSafeRef Auto Const mandatory
    ObjectReference Property LPDummyHoldingRef Auto Const mandatory
    ObjectReference Property PlayerRef Auto Const mandatory
    ReferenceAlias Property PlayerHomeShip Auto Const mandatory
EndGroup

;-- DebugGlobals
; GlobalVariable controlling debug toggle
Group DebugProperties
    GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory
EndGroup

;-- LootSettings
; GlobalVariable for system-wide toggle looting
Group GlobalVariable_Autofill
    GlobalVariable Property LPSystemUtil_ToggleLooting Auto mandatory
EndGroup

;-- FeedbackMessages
; Terminal message output (On/Off/Debug)
Group Message_Autofill
    Message Property LPOffMsg Auto Const mandatory
    Message Property LPOnMsg Auto Const mandatory
    Message Property LPDebugOnMsg Auto Const mandatory
    Message Property LPDebugOffMsg Auto Const mandatory
EndGroup

;-- Logger
; LoggerScript instance for debug output
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup


;======================================================================
; HELPER FUNCTIONS
;======================================================================

;-- UpdateLootingDisplay Function --
; @param akTerminalRef: Terminal reference to update
; @param currentLootSetting: Bool value of looting enabled
; Sets terminal label for current looting status
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
; @param akTerminalRef: Terminal reference to update
; @param currentDebugStatus: Bool value of debug enabled
; Sets terminal label for current debug setting
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
; @param akTerminalBase: Terminal menu base
; @param akTerminalRef: Terminal instance the player entered
; Initializes display values for loot and debug toggles
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
; @param auiMenuItemID: Selected terminal menu item index
; @param akTerminalBase: Base terminal definition
; @param akTerminalRef: Terminal instance being interacted with
; Executes action based on selected menu item index
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
