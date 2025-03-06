ScriptName LZP:System:UpdateHandlerPlayerAliasScript Extends ReferenceAlias hidden

;-- Variables ---------------------------------------
String sUpdatesAppliedVersion = ""

;-- Properties --------------------------------------
Actor Property PlayerRef Auto Const mandatory
FormList Property LPSystem_Script_Perks Auto Const mandatory
GlobalVariable Property LPVersion_Major Auto Const mandatory
GlobalVariable Property LPVersion_Minor Auto Const mandatory

;-- Functions ---------------------------------------

Event OnAliasInit()
  Debug.Trace("OnAliasInit triggered", 0) ; #DEBUG_LINE_NO:14
  Self.CheckForUpdates() ; #DEBUG_LINE_NO:15
EndEvent

Event OnPlayerLoadGame()
  Debug.Trace("OnPlayerLoadGame triggered", 0) ; #DEBUG_LINE_NO:20
  Self.CheckForUpdates() ; #DEBUG_LINE_NO:21
EndEvent

Function CheckForUpdates()
  Debug.Trace("CheckForUpdates called", 0) ; #DEBUG_LINE_NO:26
  String sCurrentVersion = ((Self.LPVersion_Major.GetValue() as Int) as String + ".") + (Self.LPVersion_Minor.GetValue() as Int) as String ; #DEBUG_LINE_NO:28
  Debug.Trace("Current version: " + sCurrentVersion, 0) ; #DEBUG_LINE_NO:29
  If sUpdatesAppliedVersion == "" || sUpdatesAppliedVersion != sCurrentVersion ; #DEBUG_LINE_NO:31
    Debug.Trace("Applying updates", 0) ; #DEBUG_LINE_NO:32
    Self.AddPerks() ; #DEBUG_LINE_NO:33
    sUpdatesAppliedVersion = sCurrentVersion ; #DEBUG_LINE_NO:34
  Else
    Debug.Trace("No updates needed", 0) ; #DEBUG_LINE_NO:36
  EndIf
EndFunction

Function AddPerks()
  Debug.Trace("AddPerks called", 0) ; #DEBUG_LINE_NO:42
  Int index = 0 ; #DEBUG_LINE_NO:43
  While index < Self.LPSystem_Script_Perks.GetSize() ; #DEBUG_LINE_NO:45
    Perk currentPerk = Self.LPSystem_Script_Perks.GetAt(index) as Perk ; #DEBUG_LINE_NO:46
    Debug.Trace("Checking perk: " + currentPerk as String, 0) ; #DEBUG_LINE_NO:47
    If !Game.GetPlayer().HasPerk(currentPerk) ; #DEBUG_LINE_NO:48
      Debug.Trace("Adding perk: " + currentPerk as String, 0) ; #DEBUG_LINE_NO:49
      Game.GetPlayer().AddPerk(currentPerk, False) ; #DEBUG_LINE_NO:50
    Else
      Debug.Trace("Player already has perk: " + currentPerk as String, 0) ; #DEBUG_LINE_NO:52
    EndIf
    index += 1 ; #DEBUG_LINE_NO:54
  EndWhile
EndFunction
