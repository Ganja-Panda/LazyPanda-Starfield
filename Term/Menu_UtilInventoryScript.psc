ScriptName LZP:Term:Menu_UtilInventoryScript Extends TerminalMenu hidden

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
Group Menu_UtilProperties
  TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
  ObjectReference Property LodgeSafeRef Auto Const mandatory
  ObjectReference Property LPDummyHoldingRef Auto Const mandatory
  ObjectReference Property PlayerRef Auto Const mandatory
  ReferenceAlias Property PlayerHomeShip Auto Const mandatory
EndGroup

Group DebugProperties
  GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory
EndGroup

Group GlobalVariable_Autofill
  GlobalVariable Property LPSystemUtil_ToggleLooting Auto mandatory
EndGroup

Group Message_Autofill
  Message Property LPOffMsg Auto Const mandatory
  Message Property LPOnMsg Auto Const mandatory
  Message Property LPDebugOnMsg Auto Const mandatory
  Message Property LPDebugOffMsg Auto Const mandatory
EndGroup


;-- Functions ---------------------------------------

Function Log(String logMsg)
  If LPSystemUtil_Debug.GetValue() as Bool
    Debug.Trace(logMsg, 0)
  EndIf
EndFunction

Function UpdateLootingDisplay(ObjectReference akTerminalRef, Bool currentLootSetting)
  If !currentLootSetting
    Log("Updating display: Looting is off")
    akTerminalRef.AddTextReplacementData("Looting", LPOffMsg as Form)
  Else
    Log("Updating display: Looting is on")
    akTerminalRef.AddTextReplacementData("Looting", LPOnMsg as Form)
  EndIf
EndFunction

Function UpdateDebugDisplay(ObjectReference akTerminalRef, Bool currentDebugStatus)
  If currentDebugStatus
    Log("Updating display: Debugging is on")
    akTerminalRef.AddTextReplacementData("Logging", LPDebugOnMsg as Form)
  Else
    Log("Updating display: Debugging is off")
    akTerminalRef.AddTextReplacementData("Logging", LPDebugOffMsg as Form)
  EndIf
EndFunction

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Log("OnTerminalMenuEnter triggered")
  Bool currentLootSetting = LPSystemUtil_ToggleLooting.GetValue() as Bool
  Bool currentDebugStatus = LPSystemUtil_Debug.GetValue() as Bool
  Log("Current loot setting: " + currentLootSetting as String)
  Log("Current debug status: " + currentDebugStatus as String)
  UpdateLootingDisplay(akTerminalRef, currentLootSetting)
  UpdateDebugDisplay(akTerminalRef, currentDebugStatus)
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Log("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String)
  If akTerminalBase == CurrentTerminalMenu
    Log("Terminal menu matches CurrentTerminalMenu")
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
      UpdateLootingDisplay(akTerminalRef, LPSystemUtil_ToggleLooting.GetValue() as Bool)
    ElseIf auiMenuItemID == 2
      Log("Menu item 2 selected")
      Log("Activating LodgeSafeRef")
      LodgeSafeRef.Activate(PlayerRef, False)
    ElseIf auiMenuItemID == 3
      Log("Menu item 3 selected")
      Log("Opening inventory for LPDummyHoldingRef")
      (LPDummyHoldingRef as Actor).OpenInventory(True, None, False)
    ElseIf auiMenuItemID == 4
      Log("Menu item 4 selected")
      Log("Opening inventory for PlayerHomeShip")
      spaceshipreference PlayerShip = PlayerHomeShip.GetRef() as spaceshipreference
      PlayerShip.OpenInventory()
    ElseIf auiMenuItemID == 5
      Log("Menu item 5 selected - Enable Debugging")
      Bool currentDebugSetting = LPSystemUtil_Debug.GetValue() as Bool
      Log("Current debug setting: " + currentDebugSetting as String)
      If !currentDebugSetting
        Log("Turning debugging on")
        LPSystemUtil_Debug.SetValue(1.0)
      Else
        Log("Turning debugging off")
        LPSystemUtil_Debug.SetValue(0.0)
      EndIf
      UpdateDebugDisplay(akTerminalRef, LPSystemUtil_Debug.GetValue() as Bool)
    EndIf
  EndIf
EndEvent
