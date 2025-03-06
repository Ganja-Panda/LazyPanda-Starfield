ScriptName LZP:Term:Menu_FilterScript Extends TerminalMenu hidden

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
Group Autofill
  Message Property LPOffMsg Auto Const mandatory
  Message Property LPOnMsg Auto Const mandatory
EndGroup

Group MenuSpecific
  FormList Property SettingsGlobals Auto Const mandatory
EndGroup

Group Terminal
  TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
EndGroup


;-- Functions ---------------------------------------

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Debug.Trace("OnTerminalMenuEnter triggered", 0) ; #DEBUG_LINE_NO:20
  Int index = 0 ; #DEBUG_LINE_NO:22
  While index < Self.SettingsGlobals.GetSize() ; #DEBUG_LINE_NO:24
    GlobalVariable currentSetting = Self.SettingsGlobals.GetAt(index) as GlobalVariable ; #DEBUG_LINE_NO:26
    Debug.Trace(("Checking setting at index: " + index as String) + " with value: " + currentSetting.GetValue() as String, 0) ; #DEBUG_LINE_NO:27
    If currentSetting.GetValue() == 1.0 ; #DEBUG_LINE_NO:29
      akTerminalRef.AddTextReplacementData("State" + index as String, Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:30
      Debug.Trace(("Setting State" + index as String) + " to LPOnMsg", 0) ; #DEBUG_LINE_NO:31
    ElseIf currentSetting.GetValue() == 0.0 ; #DEBUG_LINE_NO:32
      akTerminalRef.AddTextReplacementData("State" + index as String, Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:33
      Debug.Trace(("Setting State" + index as String) + " to LPOffMsg", 0) ; #DEBUG_LINE_NO:34
    EndIf
    index += 1 ; #DEBUG_LINE_NO:37
  EndWhile
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Debug.Trace("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String, 0) ; #DEBUG_LINE_NO:42
  If akTerminalBase == Self.CurrentTerminalMenu ; #DEBUG_LINE_NO:44
    Debug.Trace("Terminal menu matches CurrentTerminalMenu", 0) ; #DEBUG_LINE_NO:45
    If auiMenuItemID == 0 ; #DEBUG_LINE_NO:47
      Debug.Trace("Menu item 0 selected: Toggle all settings", 0) ; #DEBUG_LINE_NO:48
      GlobalVariable AllToggle = Self.SettingsGlobals.GetAt(0) as GlobalVariable ; #DEBUG_LINE_NO:50
      Debug.Trace("AllToggle current value: " + AllToggle.GetValue() as String, 0) ; #DEBUG_LINE_NO:51
      Int index = 0 ; #DEBUG_LINE_NO:53
      If AllToggle.GetValue() == 1.0 ; #DEBUG_LINE_NO:55
        Debug.Trace("Turning off all settings", 0) ; #DEBUG_LINE_NO:56
        While index < Self.SettingsGlobals.GetSize() ; #DEBUG_LINE_NO:57
          GlobalVariable currentSetting = Self.SettingsGlobals.GetAt(index) as GlobalVariable ; #DEBUG_LINE_NO:58
          currentSetting.SetValue(0.0) ; #DEBUG_LINE_NO:59
          akTerminalRef.AddTextReplacementData("State" + index as String, Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:60
          Debug.Trace(("Setting State" + index as String) + " to LPOffMsg", 0) ; #DEBUG_LINE_NO:61
          index += 1 ; #DEBUG_LINE_NO:62
        EndWhile
      ElseIf AllToggle.GetValue() == 0.0 ; #DEBUG_LINE_NO:65
        Debug.Trace("Turning on all settings", 0) ; #DEBUG_LINE_NO:66
        While index < Self.SettingsGlobals.GetSize() ; #DEBUG_LINE_NO:67
          GlobalVariable currentsetting = Self.SettingsGlobals.GetAt(index) as GlobalVariable ; #DEBUG_LINE_NO:68
          currentsetting.SetValue(1.0) ; #DEBUG_LINE_NO:69
          akTerminalRef.AddTextReplacementData("State" + index as String, Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:70
          Debug.Trace(("Setting State" + index as String) + " to LPOnMsg", 0) ; #DEBUG_LINE_NO:71
          index += 1 ; #DEBUG_LINE_NO:72
        EndWhile
      EndIf
    ElseIf auiMenuItemID != 0 ; #DEBUG_LINE_NO:76
      Debug.Trace(("Menu item " + auiMenuItemID as String) + " selected: Toggle specific setting", 0) ; #DEBUG_LINE_NO:77
      GlobalVariable currentsetting = Self.SettingsGlobals.GetAt(auiMenuItemID) as GlobalVariable ; #DEBUG_LINE_NO:78
      If currentsetting.GetValue() == 0.0 ; #DEBUG_LINE_NO:79
        currentsetting.SetValue(1.0) ; #DEBUG_LINE_NO:80
        akTerminalRef.AddTextReplacementData("State" + auiMenuItemID as String, Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:81
        Debug.Trace(("Setting State" + auiMenuItemID as String) + " to LPOnMsg", 0) ; #DEBUG_LINE_NO:82
      ElseIf currentsetting.GetValue() == 1.0 ; #DEBUG_LINE_NO:83
        currentsetting.SetValue(0.0) ; #DEBUG_LINE_NO:84
        akTerminalRef.AddTextReplacementData("State" + auiMenuItemID as String, Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:85
        Debug.Trace(("Setting State" + auiMenuItemID as String) + " to LPOffMsg", 0) ; #DEBUG_LINE_NO:86
      EndIf
    EndIf
  EndIf
EndEvent
