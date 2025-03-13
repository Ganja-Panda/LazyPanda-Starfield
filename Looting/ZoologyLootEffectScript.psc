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
  If LPSystemUtil_Debug.GetValue()
    Debug.Trace(logMsg, 0)
  EndIf
EndFunction

Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
  Log("OnEffectStart triggered")
  StartTimer(lootTimerDelay, lootTimerID)
EndEvent

Event OnTimer(Int aiTimerID)
  Log("OnTimer triggered with aiTimerID: " + aiTimerID as String)
  If aiTimerID == lootTimerID
    Log("lootTimerID matched")
    If Game.GetPlayer().HasPerk(ActivePerk)
      Log("Player has ActivePerk")
      ExecuteLooting()
    Else
      Log("Player does not have ActivePerk")
    EndIf
  EndIf
EndEvent

Function ExecuteLooting()
  Log("ExecuteLooting called")
  LocateLoot(ActiveLootList)
  StartTimer(lootTimerDelay, lootTimerID)
EndFunction

Function LocateLoot(FormList LootList)
  If LootList.GetSize() == 0
    Log("ActiveLootList is empty")
    Return
  EndIf
  Log("LocateLoot called with LootList: " + LootList as String)
  ObjectReference[] lootArray = new ObjectReference[0]
  If LootList.GetSize() > 0
    lootArray = PlayerRef.FindAllReferencesWithKeyword(LootList.GetAt(0), GetRadius())
  Else
    Log("LootList is empty, no references to find")
    Return
  EndIf
  Log(("Found " + lootArray.Length as String) + " loot items")
  If lootArray.Length > 0
    ProcessLoot(lootArray)
  EndIf
  Int index = 0
  Bool activateControlsEnabled = Game.IsActivateControlsEnabled()
  While index < lootArray.Length && activateControlsEnabled
    ProcessLoot(lootArray)
    index += 1
  EndWhile
EndFunction

Function ProcessLoot(ObjectReference[] theLootArray)
  Log(("ProcessLoot called with " + theLootArray.Length as String) + " items")
  Int index = 0
  While index < theLootArray.Length && Game.IsActivateControlsEnabled()
    ObjectReference currentLoot = theLootArray[index]
    Log("Processing loot at index: " + index as String)
    If currentLoot != None && IsLootLoaded(currentLoot)
      If Perk_CND_Zoology_NonLethalHarvest_Target.IsTrue(currentLoot, PlayerRef)
        Log("Condition is true for loot")
        If PlayerRef as Actor
          ActiveLootSpell.RemoteCast(PlayerRef, PlayerRef as Actor, currentLoot)
          currentLoot.Activate(PlayerRef, False)
        Else
          Log("PlayerRef is not an Actor")
        EndIf
      Else
        Log("Condition is false for loot")
      EndIf
    Else
      Log("Loot is not loaded or invalid")
    EndIf
    index += 1
  EndWhile
EndFunction

Bool Function IsLootLoaded(ObjectReference theLoot)
  Bool isLoaded = theLoot.Is3DLoaded() && !theLoot.IsDisabled() && !theLoot.IsDeleted()
  Log(("IsLootLoaded called for " + theLoot as String) + ": " + isLoaded as String)
  Return isLoaded
EndFunction

Float Function GetRadius()
  Float radius = LPSetting_Radius.GetValue()
  Log("GetRadius called: " + radius as String)
  Return radius
EndFunction
