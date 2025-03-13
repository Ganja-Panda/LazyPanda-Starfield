ScriptName LZP:Looting:ZoologyLootEffectScript Extends ActiveMagicEffect hidden

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
Group EffectSpecific_Mandatory
  Perk Property ActivePerk Auto Const mandatory
  FormList Property ActiveLootList Auto Const mandatory
  conditionform Property Perk_CND_Zoology_NonLethalHarvest_Target Auto Const mandatory
  Spell Property ActiveLootSpell Auto Const
  ObjectReference Property PlayerRef Auto mandatory
EndGroup

Group Settings_Autofill
  GlobalVariable Property LPSetting_Radius Auto Const
  GlobalVariable Property LPSystemUtil_Debug Auto Const
EndGroup

Int Property lootTimerID = 1 Auto mandatory
Float Property lootTimerDelay = 0.5 Auto mandatory

;-- Functions ---------------------------------------

Function Log(String logMsg)
  If LPSystemUtil_Debug.GetValue() ; #DEBUG_LINE_NO:42
    Debug.Trace(logMsg, 0) ; #DEBUG_LINE_NO:43
  EndIf
EndFunction

Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
  Self.Log("OnEffectStart triggered") ; #DEBUG_LINE_NO:54
  Self.StartTimer(lootTimerDelay, lootTimerID) ; #DEBUG_LINE_NO:55
EndEvent

Event OnTimer(Int aiTimerID)
  Self.Log("OnTimer triggered with aiTimerID: " + aiTimerID as String) ; #DEBUG_LINE_NO:61
  If aiTimerID == lootTimerID ; #DEBUG_LINE_NO:62
    Self.Log("lootTimerID matched") ; #DEBUG_LINE_NO:63
    If Game.GetPlayer().HasPerk(ActivePerk) ; #DEBUG_LINE_NO:64
      Self.Log("Player has ActivePerk") ; #DEBUG_LINE_NO:65
      Self.ExecuteLooting() ; #DEBUG_LINE_NO:66
    Else
      Self.Log("Player does not have ActivePerk") ; #DEBUG_LINE_NO:68
    EndIf
  EndIf
EndEvent

Function ExecuteLooting()
  Self.Log("ExecuteLooting called") ; #DEBUG_LINE_NO:80
  Self.LocateLoot(ActiveLootList) ; #DEBUG_LINE_NO:81
  Self.StartTimer(lootTimerDelay, lootTimerID) ; #DEBUG_LINE_NO:82
EndFunction

Function LocateLoot(FormList LootList)
  If LootList.GetSize() == 0 ; #DEBUG_LINE_NO:88
    Self.Log("ActiveLootList is empty") ; #DEBUG_LINE_NO:89
    Return  ; #DEBUG_LINE_NO:90
  EndIf
  Self.Log("LocateLoot called with LootList: " + LootList as String) ; #DEBUG_LINE_NO:93
  ObjectReference[] lootArray = new ObjectReference[0] ; #DEBUG_LINE_NO:94
  If LootList.GetSize() > 0 ; #DEBUG_LINE_NO:95
    lootArray = PlayerRef.FindAllReferencesWithKeyword(LootList.GetAt(0), Self.GetRadius()) ; #DEBUG_LINE_NO:96
  Else
    Self.Log("LootList is empty, no references to find") ; #DEBUG_LINE_NO:98
    Return  ; #DEBUG_LINE_NO:99
  EndIf
  Self.Log(("Found " + lootArray.Length as String) + " loot items") ; #DEBUG_LINE_NO:101
  If lootArray.Length > 0 ; #DEBUG_LINE_NO:102
    Self.ProcessLoot(lootArray) ; #DEBUG_LINE_NO:103
  EndIf
  Int index = 0 ; #DEBUG_LINE_NO:105
  Bool activateControlsEnabled = Game.IsActivateControlsEnabled() ; #DEBUG_LINE_NO:106
  While index < lootArray.Length && activateControlsEnabled ; #DEBUG_LINE_NO:107
    Self.ProcessLoot(lootArray) ; #DEBUG_LINE_NO:108
    index += 1 ; #DEBUG_LINE_NO:109
  EndWhile
EndFunction

Function ProcessLoot(ObjectReference[] theLootArray)
  Self.Log(("ProcessLoot called with " + theLootArray.Length as String) + " items") ; #DEBUG_LINE_NO:116
  Int index = 0 ; #DEBUG_LINE_NO:117
  While index < theLootArray.Length && Game.IsActivateControlsEnabled() ; #DEBUG_LINE_NO:118
    ObjectReference currentLoot = theLootArray[index] ; #DEBUG_LINE_NO:119
    Self.Log("Processing loot at index: " + index as String) ; #DEBUG_LINE_NO:120
    If currentLoot != None && Self.IsLootLoaded(currentLoot) ; #DEBUG_LINE_NO:121
      If Perk_CND_Zoology_NonLethalHarvest_Target.IsTrue(currentLoot, PlayerRef) ; #DEBUG_LINE_NO:122
        Self.Log("Condition is true for loot") ; #DEBUG_LINE_NO:123
        If PlayerRef as Actor ; #DEBUG_LINE_NO:124
          ActiveLootSpell.RemoteCast(PlayerRef, PlayerRef as Actor, currentLoot) ; #DEBUG_LINE_NO:125
          currentLoot.Activate(PlayerRef, False) ; #DEBUG_LINE_NO:126
        Else
          Self.Log("PlayerRef is not an Actor") ; #DEBUG_LINE_NO:128
        EndIf
      Else
        Self.Log("Condition is false for loot") ; #DEBUG_LINE_NO:131
      EndIf
    Else
      Self.Log("Loot is not loaded or invalid") ; #DEBUG_LINE_NO:134
    EndIf
    index += 1 ; #DEBUG_LINE_NO:136
  EndWhile
EndFunction

Bool Function IsLootLoaded(ObjectReference theLoot)
  Bool isLoaded = theLoot.Is3DLoaded() && !theLoot.IsDisabled() && !theLoot.IsDeleted() ; #DEBUG_LINE_NO:143
  Self.Log(("IsLootLoaded called for " + theLoot as String) + ": " + isLoaded as String) ; #DEBUG_LINE_NO:144
  Return isLoaded ; #DEBUG_LINE_NO:145
EndFunction

Float Function GetRadius()
  Float radius = LPSetting_Radius.GetValue() ; #DEBUG_LINE_NO:151
  Self.Log("GetRadius called: " + radius as String) ; #DEBUG_LINE_NO:152
  Return radius ; #DEBUG_LINE_NO:153
EndFunction
