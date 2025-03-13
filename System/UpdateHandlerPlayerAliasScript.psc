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
  If LPSystemUtil_Debug.GetValue() as Bool
    Debug.Trace(logMsg, 0)
  EndIf
EndFunction

Function CheckDebugGlobal()
  If LPSystemUtil_Debug.GetValue() as Bool
    Log("Debugging enabled")
  EndIf
  Utility.Wait(fDebugCheckInterval)
  CheckDebugGlobal()
EndFunction

Event OnAliasInit()
  Log("OnAliasInit triggered")
  CheckForUpdates()
  CheckDebugGlobal()
EndEvent

Event OnPlayerLoadGame()
  Log("OnPlayerLoadGame triggered")
  CheckForUpdates()
  CheckDebugGlobal()
EndEvent

Function CheckForUpdates()
  Log("CheckForUpdates called")
  Int iCurrentVersion = LPVersion_Major.GetValueInt() * 1000 + LPVersion_Minor.GetValueInt()
  Log("Current version number: " + iCurrentVersion as String)
  Int iAppliedVersion = sUpdatesAppliedVersion as Int
  Log("Previously applied version: " + iAppliedVersion as String)
  If iAppliedVersion < iCurrentVersion
    Log(("Updates needed. Applying updates from version " + iAppliedVersion as String) + " to " + iCurrentVersion as String)
    If iAppliedVersion < 1001
      UpdateStep_1001()
      iAppliedVersion = 1001
    EndIf
    sUpdatesAppliedVersion = iCurrentVersion as String
    Log("Updates applied. New applied version: " + sUpdatesAppliedVersion)
  Else
    Log("No updates needed")
  EndIf
EndFunction

Function UpdateStep_1001()
  Log("Executing UpdateStep_1001: Adding missing perks")
  AddPerks()
EndFunction

Function AddPerks()
  Log("AddPerks called")
  Int index = 0
  While index < LPSystem_Script_Perks.GetSize()
    Perk currentPerk = LPSystem_Script_Perks.GetAt(index) as Perk
    Log("Checking perk: " + currentPerk as String)
    If !Game.GetPlayer().HasPerk(currentPerk)
      Log("Adding perk: " + currentPerk as String)
      Game.GetPlayer().AddPerk(currentPerk, False)
    Else
      Log("Player already has perk: " + currentPerk as String)
    EndIf
    index += 1
  EndWhile
EndFunction
