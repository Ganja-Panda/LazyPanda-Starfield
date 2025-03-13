ScriptName LZP:System:UpdateHandlerPlayerAliasScript Extends ReferenceAlias hidden

;-- Variables ---------------------------------------
Float fDebugCheckInterval = 10.0
String sUpdatesAppliedVersion = "0"

;-- Properties --------------------------------------
Actor Property PlayerRef Auto Const mandatory
FormList Property LPSystem_Script_Perks Auto Const mandatory
GlobalVariable Property LPVersion_Major Auto Const mandatory
GlobalVariable Property LPVersion_Minor Auto Const mandatory
GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory

;-- Functions ---------------------------------------

Function Log(String logMsg)
  If LPSystemUtil_Debug.GetValue() as Bool ; #DEBUG_LINE_NO:40
    Debug.Trace(logMsg, 0) ; #DEBUG_LINE_NO:41
  EndIf
EndFunction

Function CheckDebugGlobal()
  If LPSystemUtil_Debug.GetValue() as Bool ; #DEBUG_LINE_NO:48
    Self.Log("Debugging enabled") ; #DEBUG_LINE_NO:49
  EndIf
  Utility.Wait(fDebugCheckInterval) ; #DEBUG_LINE_NO:52
  Self.CheckDebugGlobal() ; #DEBUG_LINE_NO:53
EndFunction

Event OnAliasInit()
  Self.Log("OnAliasInit triggered") ; #DEBUG_LINE_NO:63
  Self.CheckForUpdates() ; #DEBUG_LINE_NO:64
  Self.CheckDebugGlobal() ; #DEBUG_LINE_NO:66
EndEvent

Event OnPlayerLoadGame()
  Self.Log("OnPlayerLoadGame triggered") ; #DEBUG_LINE_NO:72
  Self.CheckForUpdates() ; #DEBUG_LINE_NO:73
  Self.CheckDebugGlobal() ; #DEBUG_LINE_NO:75
EndEvent

Function CheckForUpdates()
  Self.Log("CheckForUpdates called") ; #DEBUG_LINE_NO:85
  Int iCurrentVersion = LPVersion_Major.GetValueInt() * 1000 + LPVersion_Minor.GetValueInt() ; #DEBUG_LINE_NO:88
  Self.Log("Current version number: " + iCurrentVersion as String) ; #DEBUG_LINE_NO:89
  Int iAppliedVersion = sUpdatesAppliedVersion as Int ; #DEBUG_LINE_NO:92
  Self.Log("Previously applied version: " + iAppliedVersion as String) ; #DEBUG_LINE_NO:93
  If iAppliedVersion < iCurrentVersion ; #DEBUG_LINE_NO:96
    Self.Log(("Updates needed. Applying updates from version " + iAppliedVersion as String) + " to " + iCurrentVersion as String) ; #DEBUG_LINE_NO:97
    If iAppliedVersion < 1001 ; #DEBUG_LINE_NO:101
      Self.UpdateStep_1001() ; #DEBUG_LINE_NO:102
      iAppliedVersion = 1001 ; #DEBUG_LINE_NO:103
    EndIf
    sUpdatesAppliedVersion = iCurrentVersion as String ; #DEBUG_LINE_NO:113
    Self.Log("Updates applied. New applied version: " + sUpdatesAppliedVersion) ; #DEBUG_LINE_NO:114
  Else
    Self.Log("No updates needed") ; #DEBUG_LINE_NO:116
  EndIf
EndFunction

Function UpdateStep_1001()
  Self.Log("Executing UpdateStep_1001: Adding missing perks") ; #DEBUG_LINE_NO:123
  Self.AddPerks() ; #DEBUG_LINE_NO:124
EndFunction

Function AddPerks()
  Self.Log("AddPerks called") ; #DEBUG_LINE_NO:130
  Int index = 0 ; #DEBUG_LINE_NO:131
  While index < LPSystem_Script_Perks.GetSize() ; #DEBUG_LINE_NO:132
    Perk currentPerk = LPSystem_Script_Perks.GetAt(index) as Perk ; #DEBUG_LINE_NO:133
    Self.Log("Checking perk: " + currentPerk as String) ; #DEBUG_LINE_NO:134
    If !Game.GetPlayer().HasPerk(currentPerk) ; #DEBUG_LINE_NO:135
      Self.Log("Adding perk: " + currentPerk as String) ; #DEBUG_LINE_NO:136
      Game.GetPlayer().AddPerk(currentPerk, False) ; #DEBUG_LINE_NO:137
    Else
      Self.Log("Player already has perk: " + currentPerk as String) ; #DEBUG_LINE_NO:139
    EndIf
    index += 1 ; #DEBUG_LINE_NO:141
  EndWhile
EndFunction
