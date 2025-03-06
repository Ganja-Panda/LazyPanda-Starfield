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
  GlobalVariable Property LPSystem_Debug Auto Const mandatory
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
EndGroup

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;-- Log Function --
; Logs a message if the global debug setting is enabled.
Function Log(String logMsg)
  If LPSystem_Debug.GetValue() as Bool
    Debug.Trace(logMsg, 0)
  EndIf
EndFunction

;-- UpdateLootingDisplay Function --
; Updates the terminal display for the looting status.
Function UpdateLootingDisplay(ObjectReference akTerminalRef, Bool currentLootSetting)
  If !currentLootSetting
    Log("Updating display: Looting is off")
    akTerminalRef.AddTextReplacementData("Looting", LPOffMsg as Form)
  Else
    Log("Updating display: Looting is on")
    akTerminalRef.AddTextReplacementData("Looting", LPOnMsg as Form)
  EndIf
EndFunction

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnTerminalMenuEnter Event Handler --
; Called when the terminal menu opens.
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Log("OnTerminalMenuEnter triggered")
  Bool currentLootSetting = LPSystemUtil_ToggleLooting.GetValue() as Bool
  Log("Current loot setting: " + currentLootSetting as String)
  UpdateLootingDisplay(akTerminalRef, currentLootSetting)
EndEvent

;-- OnTerminalMenuItemRun Event Handler --
; Called when a menu item is selected.
Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Log("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String)
  If akTerminalBase == CurrentTerminalMenu
    Log("Terminal menu matches CurrentTerminalMenu")
    ; Toggle looting when menu item 1 is selected.
    If auiMenuItemID == 1
      Log("Menu item 1 selected")
      Bool currentLootSetting = LPSystemUtil_ToggleLooting.GetValue() as Bool
      Log("Current loot setting: " + currentLootSetting as String)
      If !currentLootSetting
        Log("Turning looting on")
        LPSystemUtil_ToggleLooting.SetValue(1.0)
      Else
        Log("Turning looting off")
        LPSystemUtil_ToggleLooting.SetValue(0.0)
      EndIf
      ; Update the display after toggling.
      UpdateLootingDisplay(akTerminalRef, LPSystemUtil_ToggleLooting.GetValue() as Bool)
      
    ; Activate LodgeSafeRef when menu item 2 is selected.
    ElseIf auiMenuItemID == 2
      Log("Menu item 2 selected")
      Log("Activating LodgeSafeRef")
      LodgeSafeRef.Activate(PlayerRef, False)
      
    ; Open inventory for LPDummyHoldingRef when menu item 3 is selected.
    ElseIf auiMenuItemID == 3
      Log("Menu item 3 selected")
      Log("Opening inventory for LPDummyHoldingRef")
      (LPDummyHoldingRef as Actor).OpenInventory(True, None, False)
      
    ; Open inventory for PlayerHomeShip when menu item 4 is selected.
    ElseIf auiMenuItemID == 4
      Log("Menu item 4 selected")
      Log("Opening inventory for PlayerHomeShip")
      spaceshipreference PlayerShip = PlayerHomeShip.GetRef() as spaceshipreference
      PlayerShip.OpenInventory()
    EndIf
  EndIf
EndEvent