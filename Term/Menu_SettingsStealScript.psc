ScriptName LZP:Term:Menu_SettingsStealScript Extends TerminalMenu hidden

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
Group GlobalVariable_Autofill
  GlobalVariable Property LPSetting_AllowStealing Auto mandatory
  GlobalVariable Property LPSetting_StealingIsHostile Auto mandatory
EndGroup

Group Message_Autofill
  Message Property LPOffMsg Auto Const mandatory
  Message Property LPOnMsg Auto Const mandatory
EndGroup

Group Misc
  TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
EndGroup


;-- Functions ---------------------------------------

Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Debug.Trace("OnTerminalMenuEnter triggered", 0) ; #DEBUG_LINE_NO:22
  Bool currentStealSetting = Self.LPSetting_AllowStealing.GetValue() as Bool ; #DEBUG_LINE_NO:23
  Bool currentHostileSetting = Self.LPSetting_StealingIsHostile.GetValue() as Bool ; #DEBUG_LINE_NO:24
  Debug.Trace(("Current settings - AllowStealing: " + currentStealSetting as String) + ", StealingIsHostile: " + currentHostileSetting as String, 0) ; #DEBUG_LINE_NO:25
  If !currentStealSetting ; #DEBUG_LINE_NO:26
    akTerminalRef.AddTextReplacementData("Stealing", Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:27
    Debug.Trace("Setting Stealing to LPOffMsg", 0) ; #DEBUG_LINE_NO:28
  ElseIf currentStealSetting
    akTerminalRef.AddTextReplacementData("Stealing", Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:30
    Debug.Trace("Setting Stealing to LPOnMsg", 0) ; #DEBUG_LINE_NO:31
  EndIf
  If !currentHostileSetting ; #DEBUG_LINE_NO:33
    akTerminalRef.AddTextReplacementData("Hostile", Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:34
    Debug.Trace("Setting Hostile to LPOffMsg", 0) ; #DEBUG_LINE_NO:35
  ElseIf currentHostileSetting
    akTerminalRef.AddTextReplacementData("Hostile", Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:37
    Debug.Trace("Setting Hostile to LPOnMsg", 0) ; #DEBUG_LINE_NO:38
  EndIf
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
  Debug.Trace("OnTerminalMenuItemRun triggered with auiMenuItemID: " + auiMenuItemID as String, 0) ; #DEBUG_LINE_NO:44
  If akTerminalBase == Self.CurrentTerminalMenu ; #DEBUG_LINE_NO:45
    Debug.Trace("Terminal menu matches CurrentTerminalMenu", 0) ; #DEBUG_LINE_NO:46
    If auiMenuItemID == 0 ; #DEBUG_LINE_NO:47
      Bool currentStealSetting = Self.LPSetting_AllowStealing.GetValue() as Bool ; #DEBUG_LINE_NO:48
      Debug.Trace("Current AllowStealing setting: " + currentStealSetting as String, 0) ; #DEBUG_LINE_NO:49
      If !currentStealSetting ; #DEBUG_LINE_NO:50
        Self.LPSetting_AllowStealing.SetValue(1.0) ; #DEBUG_LINE_NO:51
        akTerminalRef.AddTextReplacementData("Stealing", Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:52
        Debug.Trace("Setting Stealing to LPOnMsg", 0) ; #DEBUG_LINE_NO:53
      ElseIf currentStealSetting
        Self.LPSetting_AllowStealing.SetValue(0.0) ; #DEBUG_LINE_NO:55
        akTerminalRef.AddTextReplacementData("Stealing", Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:56
        Debug.Trace("Setting Stealing to LPOffMsg", 0) ; #DEBUG_LINE_NO:57
        Self.LPSetting_StealingIsHostile.SetValue(0.0) ; #DEBUG_LINE_NO:58
        akTerminalRef.AddTextReplacementData("Hostile", Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:59
        Debug.Trace("Setting Hostile to LPOffMsg", 0) ; #DEBUG_LINE_NO:60
      EndIf
    ElseIf auiMenuItemID == 1 ; #DEBUG_LINE_NO:62
      Bool currentHostileSetting = Self.LPSetting_StealingIsHostile.GetValue() as Bool ; #DEBUG_LINE_NO:63
      Debug.Trace("Current StealingIsHostile setting: " + currentHostileSetting as String, 0) ; #DEBUG_LINE_NO:64
      If !currentHostileSetting ; #DEBUG_LINE_NO:65
        Self.LPSetting_StealingIsHostile.SetValue(1.0) ; #DEBUG_LINE_NO:66
        akTerminalRef.AddTextReplacementData("Hostile", Self.LPOnMsg as Form) ; #DEBUG_LINE_NO:67
        Debug.Trace("Setting Hostile to LPOnMsg", 0) ; #DEBUG_LINE_NO:68
      ElseIf currentHostileSetting
        Self.LPSetting_StealingIsHostile.SetValue(0.0) ; #DEBUG_LINE_NO:70
        akTerminalRef.AddTextReplacementData("Hostile", Self.LPOffMsg as Form) ; #DEBUG_LINE_NO:71
        Debug.Trace("Setting Hostile to LPOffMsg", 0) ; #DEBUG_LINE_NO:72
      EndIf
    EndIf
  EndIf
EndEvent
