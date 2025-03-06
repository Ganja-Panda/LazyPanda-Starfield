ScriptName LZP:Term:Menu_FilterMainScript Extends TerminalMenu hidden

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
  Debug.Trace("OnTerminalMenuEnter triggered", 0) ; #DEBUG_LINE_NO:21
  GlobalVariable currentSetting = Self.SettingsGlobals.GetAt(0) as GlobalVariable ; #DEBUG_LINE_NO:22
  Debug.Trace("Current setting value: " + currentSetting.GetValue() as String, 0) ; #DEBUG_LINE_NO:23
  If currentSetting.GetValue() == 1.0 ; #DEBUG_LINE_NO:24
    akTerminalRef.AddTextReplacementData("AllToggle", Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:25
    Debug.Trace("Setting AllToggle to LPOnMsg", 0) ; #DEBUG_LINE_NO:26
  ElseIf currentSetting.GetValue() == 0.0 ; #DEBUG_LINE_NO:27
    akTerminalRef.AddTextReplacementData("AllToggle", Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:28
    Debug.Trace("Setting AllToggle to LPOffMsg", 0) ; #DEBUG_LINE_NO:29
  EndIf
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Debug.Trace("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String, 0) ; #DEBUG_LINE_NO:35
  If akTerminalBase == Self.CurrentTerminalMenu ; #DEBUG_LINE_NO:36
    Debug.Trace("Terminal menu matches CurrentTerminalMenu", 0) ; #DEBUG_LINE_NO:37
    If auiMenuItemID == 0 ; #DEBUG_LINE_NO:38
      Debug.Trace("Menu item 0 selected: Toggle all settings", 0) ; #DEBUG_LINE_NO:39
      GlobalVariable AllToggle = Self.SettingsGlobals.GetAt(0) as GlobalVariable ; #DEBUG_LINE_NO:40
      Debug.Trace("AllToggle current value: " + AllToggle.GetValue() as String, 0) ; #DEBUG_LINE_NO:41
      Int index = 0 ; #DEBUG_LINE_NO:42
      If AllToggle.GetValue() == 1.0 ; #DEBUG_LINE_NO:43
        Debug.Trace("Turning off all settings", 0) ; #DEBUG_LINE_NO:44
        While index < Self.SettingsGlobals.GetSize() ; #DEBUG_LINE_NO:45
          GlobalVariable currentSetting = Self.SettingsGlobals.GetAt(index) as GlobalVariable ; #DEBUG_LINE_NO:46
          currentSetting.SetValue(0.0) ; #DEBUG_LINE_NO:47
          Debug.Trace(("Setting index " + index as String) + " to 0.0", 0) ; #DEBUG_LINE_NO:48
          index += 1 ; #DEBUG_LINE_NO:49
        EndWhile
        akTerminalRef.AddTextReplacementData("AllToggle", Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:51
        Debug.Trace("Setting AllToggle to LPOffMsg", 0) ; #DEBUG_LINE_NO:52
      ElseIf AllToggle.GetValue() == 0.0 ; #DEBUG_LINE_NO:53
        Debug.Trace("Turning on all settings", 0) ; #DEBUG_LINE_NO:54
        While index < Self.SettingsGlobals.GetSize() ; #DEBUG_LINE_NO:55
          GlobalVariable currentsetting = Self.SettingsGlobals.GetAt(index) as GlobalVariable ; #DEBUG_LINE_NO:56
          currentsetting.SetValue(1.0) ; #DEBUG_LINE_NO:57
          Debug.Trace(("Setting index " + index as String) + " to 1.0", 0) ; #DEBUG_LINE_NO:58
          index += 1 ; #DEBUG_LINE_NO:59
        EndWhile
        akTerminalRef.AddTextReplacementData("AllToggle", Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:61
        Debug.Trace("Setting AllToggle to LPOnMsg", 0) ; #DEBUG_LINE_NO:62
      EndIf
    EndIf
  EndIf
EndEvent
