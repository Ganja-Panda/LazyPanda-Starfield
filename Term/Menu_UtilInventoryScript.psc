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

Group GlobalVariable_Autofill
  GlobalVariable Property LPSystemUtil_ToggleLooting Auto mandatory
EndGroup

Group Message_Autofill
  Message Property LPOffMsg Auto Const mandatory
  Message Property LPOnMsg Auto Const mandatory
EndGroup


;-- Functions ---------------------------------------

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Debug.Trace("OnTerminalMenuEnter triggered", 0) ; #DEBUG_LINE_NO:25
  Bool currentLootSetting = Self.LPSystemUtil_ToggleLooting.GetValue() as Bool ; #DEBUG_LINE_NO:26
  Debug.Trace("Current loot setting: " + currentLootSetting as String, 0) ; #DEBUG_LINE_NO:27
  If !currentLootSetting ; #DEBUG_LINE_NO:28
    Debug.Trace("Looting is off", 0) ; #DEBUG_LINE_NO:29
    akTerminalRef.AddTextReplacementData("Looting", Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:30
  ElseIf currentLootSetting
    Debug.Trace("Looting is on", 0) ; #DEBUG_LINE_NO:32
    akTerminalRef.AddTextReplacementData("Looting", Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:33
  EndIf
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Debug.Trace("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String, 0) ; #DEBUG_LINE_NO:39
  If akTerminalBase == Self.CurrentTerminalMenu ; #DEBUG_LINE_NO:40
    Debug.Trace("Terminal menu matches CurrentTerminalMenu", 0) ; #DEBUG_LINE_NO:41
    If auiMenuItemID == 1 ; #DEBUG_LINE_NO:42
      Debug.Trace("Menu item 1 selected", 0) ; #DEBUG_LINE_NO:43
      Bool currentLootSetting = Self.LPSystemUtil_ToggleLooting.GetValue() as Bool ; #DEBUG_LINE_NO:44
      Debug.Trace("Current loot setting: " + currentLootSetting as String, 0) ; #DEBUG_LINE_NO:45
      If !currentLootSetting ; #DEBUG_LINE_NO:46
        Debug.Trace("Turning looting on", 0) ; #DEBUG_LINE_NO:47
        Self.LPSystemUtil_ToggleLooting.SetValue(1.0) ; #DEBUG_LINE_NO:48
        akTerminalRef.AddTextReplacementData("Looting", Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:49
      ElseIf currentLootSetting
        Debug.Trace("Turning looting off", 0) ; #DEBUG_LINE_NO:51
        Self.LPSystemUtil_ToggleLooting.SetValue(0.0) ; #DEBUG_LINE_NO:52
        akTerminalRef.AddTextReplacementData("Looting", Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:53
      EndIf
    ElseIf auiMenuItemID == 2 ; #DEBUG_LINE_NO:55
      Debug.Trace("Menu item 2 selected", 0) ; #DEBUG_LINE_NO:56
      Debug.Trace("Activating LodgeSafeRef", 0) ; #DEBUG_LINE_NO:58
      Self.LodgeSafeRef.Activate(Self.PlayerRef, False) ; #DEBUG_LINE_NO:59
    ElseIf auiMenuItemID == 3 ; #DEBUG_LINE_NO:60
      Debug.Trace("Menu item 3 selected", 0) ; #DEBUG_LINE_NO:61
      Debug.Trace("Opening inventory for LPDummyHoldingRef", 0) ; #DEBUG_LINE_NO:63
      (Self.LPDummyHoldingRef as Actor).OpenInventory(True, None, False) ; #DEBUG_LINE_NO:64
    ElseIf auiMenuItemID == 4 ; #DEBUG_LINE_NO:65
      Debug.Trace("Menu item 4 selected", 0) ; #DEBUG_LINE_NO:66
      Debug.Trace("Opening inventory for PlayerHomeShip", 0) ; #DEBUG_LINE_NO:68
      spaceshipreference PlayerShip = Self.PlayerHomeShip.GetRef() as spaceshipreference ; #DEBUG_LINE_NO:69
      PlayerShip.OpenInventory() ; #DEBUG_LINE_NO:70
    EndIf
  EndIf
EndEvent
