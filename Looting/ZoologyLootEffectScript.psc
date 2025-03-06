ScriptName LZP:Looting:ZoologyLootEffectScript Extends ActiveMagicEffect hidden

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
Group EffectSpecific_Mandatory
  Perk Property ActivePerk Auto Const mandatory
  { The perk needed to loot from this list }
  FormList Property ActiveLootList Auto Const mandatory
  { LootList specific to this MGEF. i.e. LPMagic_Aid MGEF would use LPFilter_Aid FLST }
  conditionform Property Perk_CND_Zoology_NonLethalHarvest_Target Auto Const mandatory
  Spell Property ActiveLootSpell Auto Const
  ObjectReference Property PlayerRef Auto
EndGroup

Group Settings_Autofill
{ None of these settings are changed by this script, so all are const }
  GlobalVariable Property LPSetting_Radius Auto Const
EndGroup

Int Property lootTimerID = 1 Auto mandatory
Float Property lootTimerDelay = 1.0 Auto mandatory

;-- Functions ---------------------------------------

Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
  Debug.Trace("OnEffectStart triggered", 0) ; #DEBUG_LINE_NO:26
  Self.StartTimer(Self.lootTimerDelay, Self.lootTimerID) ; #DEBUG_LINE_NO:27
EndEvent

Event OnTimer(Int aiTimerID)
  Debug.Trace("OnTimer triggered with aiTimerID: " + aiTimerID as String, 0) ; #DEBUG_LINE_NO:32
  If aiTimerID == Self.lootTimerID ; #DEBUG_LINE_NO:33
    Debug.Trace("lootTimerID matched", 0) ; #DEBUG_LINE_NO:34
    If Game.GetPlayer().HasPerk(Self.ActivePerk) ; #DEBUG_LINE_NO:35
      Debug.Trace("Player has ActivePerk", 0) ; #DEBUG_LINE_NO:36
      Self.ExecuteLooting() ; #DEBUG_LINE_NO:37
    Else
      Debug.Trace("Player does not have ActivePerk", 0) ; #DEBUG_LINE_NO:39
    EndIf
  EndIf
EndEvent

Function ExecuteLooting()
  Debug.Trace("ExecuteLooting called", 0) ; #DEBUG_LINE_NO:46
  Self.LocateLoot(Self.ActiveLootList) ; #DEBUG_LINE_NO:47
  Self.StartTimer(Self.lootTimerDelay, Self.lootTimerID) ; #DEBUG_LINE_NO:48
EndFunction

Function LocateLoot(FormList LootList)
  Debug.Trace("LocateLoot called with LootList: " + LootList as String, 0) ; #DEBUG_LINE_NO:53
  ObjectReference[] lootArray = new ObjectReference[0] ; #DEBUG_LINE_NO:54
  lootArray = Self.PlayerRef.FindAllReferencesWithKeyword(LootList.GetAt(0), Self.GetRadius()) ; #DEBUG_LINE_NO:55
  Debug.Trace(("Found " + lootArray.Length as String) + " loot items", 0) ; #DEBUG_LINE_NO:56
  If lootArray.Length > 0 ; #DEBUG_LINE_NO:57
    Self.ProcessLoot(lootArray) ; #DEBUG_LINE_NO:58
  EndIf
EndFunction

Function ProcessLoot(ObjectReference[] theLootArray)
  Debug.Trace(("ProcessLoot called with " + theLootArray.Length as String) + " items", 0) ; #DEBUG_LINE_NO:64
  Int index = 0 ; #DEBUG_LINE_NO:65
  While index < theLootArray.Length && Game.IsActivateControlsEnabled() ; #DEBUG_LINE_NO:66
    ObjectReference currentLoot = theLootArray[index] ; #DEBUG_LINE_NO:67
    Debug.Trace("Processing loot at index: " + index as String, 0) ; #DEBUG_LINE_NO:68
    If currentLoot as Bool && Self.IsLootLoaded(currentLoot) ; #DEBUG_LINE_NO:69
      Debug.Trace("Loot is loaded and valid", 0) ; #DEBUG_LINE_NO:70
      If Self.Perk_CND_Zoology_NonLethalHarvest_Target.IsTrue(currentLoot, Self.PlayerRef) ; #DEBUG_LINE_NO:71
        Debug.Trace("Condition is true for loot", 0) ; #DEBUG_LINE_NO:72
        Self.ActiveLootSpell.RemoteCast(Self.PlayerRef, Self.PlayerRef as Actor, currentLoot) ; #DEBUG_LINE_NO:73
        currentLoot.Activate(Self.PlayerRef, False) ; #DEBUG_LINE_NO:74
      Else
        Debug.Trace("Condition is false for loot", 0) ; #DEBUG_LINE_NO:76
      EndIf
    Else
      Debug.Trace("Loot is not loaded or invalid", 0) ; #DEBUG_LINE_NO:79
    EndIf
    index += 1 ; #DEBUG_LINE_NO:81
  EndWhile
EndFunction

Bool Function IsLootLoaded(ObjectReference theLoot)
  Bool isLoaded = theLoot.Is3DLoaded() && !theLoot.IsDisabled() && !theLoot.IsDeleted() ; #DEBUG_LINE_NO:87
  Debug.Trace(("IsLootLoaded called for " + theLoot as String) + ": " + isLoaded as String, 0) ; #DEBUG_LINE_NO:88
  Return isLoaded ; #DEBUG_LINE_NO:89
EndFunction

Float Function GetRadius()
  Float radius = Self.LPSetting_Radius.GetValue() ; #DEBUG_LINE_NO:94
  Debug.Trace("GetRadius called: " + radius as String, 0) ; #DEBUG_LINE_NO:95
  Return radius ; #DEBUG_LINE_NO:96
EndFunction
