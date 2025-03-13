ScriptName LZP:Looting:LootEffectScript Extends ActiveMagicEffect hidden

;-- Properties --------------------------------------
Group EffectSpecific_Mandatory
  Perk Property ActivePerk Auto Const mandatory
  FormList Property ActiveLootList Auto Const mandatory
EndGroup

Group EffectSpecific_Optional
  Spell Property ActiveLootSpell Auto Const
EndGroup

Group EffectSpecific_LootMethod
  Bool Property bIsActivator = False Auto
  Bool Property bIsContainer = False Auto
  Bool Property bLootDeadActor = False Auto
  Bool Property bIsActivatedBySpell = False Auto
  Bool Property bIsContainerSpace = False Auto
EndGroup

Group EffectSpecific_FormType
  Bool Property bIsKeyword = False Auto
  Bool Property bIsMultipleKeyword = False Auto
EndGroup

Group Settings_Autofill
  GlobalVariable Property LPSetting_Radius Auto Const
  GlobalVariable Property LPSetting_AllowStealing Auto Const
  GlobalVariable Property LPSetting_StealingIsHostile Auto Const
  GlobalVariable Property LPSetting_RemoveCorpses Auto Const
  GlobalVariable Property LPSetting_SendTo Auto Const
  GlobalVariable Property LPSetting_ContTakeAll Auto Const
  GlobalVariable Property LPSetting_AllowLootingShip Auto Const
EndGroup

Group AutoUnlock_Autofill
  GlobalVariable Property LPSetting_AutoUnlock Auto Const
  GlobalVariable Property LPSetting_AutoUnlockSkillCheck Auto Const
  GlobalVariable Property LockLevel_Advanced Auto Const
  GlobalVariable Property LockLevel_Expert Auto Const
  GlobalVariable Property LockLevel_Inaccessible Auto Const
  GlobalVariable Property LockLevel_Master Auto Const
  GlobalVariable Property LockLevel_Novice Auto Const
  GlobalVariable Property LockLevel_RequiresKey Auto Const
  Faction Property PlayerFaction Auto Const
  conditionform Property Perk_CND_AdvancedLocksCheck Auto Const
  conditionform Property Perk_CND_ExpertLocksCheck Auto Const
  conditionform Property Perk_CND_MasterLocksCheck Auto Const
  MiscObject Property Digipick Auto Const
EndGroup

Group List_Autofill
  FormList Property LPSystem_Looting_Globals Auto Const
  FormList Property LPSystem_Looting_Lists Auto Const
EndGroup

Group Misc
  Keyword Property SQ_ShipDebrisKeyword Auto Const
  Keyword Property LPKeyword_Asteroid Auto Const
  Armor Property LP_Skin_Naked_NOTPLAYABLE Auto Const mandatory
  Race Property HumanRace Auto Const mandatory
  GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory
EndGroup

Group DestinationLocations
  ObjectReference Property PlayerRef Auto Const
  ObjectReference Property LodgeSafeRef Auto Const
  ObjectReference Property LPDummyHoldingRef Auto Const
  ReferenceAlias Property PlayerHomeShip Auto Const mandatory
EndGroup

Group NoLootLocations
  FormList Property LPFilter_NoLootLocations Auto Const
  LocationAlias Property playerShipInterior Auto Const mandatory
EndGroup

Group NoFill
  Int Property lootTimerID = 1 Auto
  Float Property lootTimerDelay = 1.0 Auto
  Bool Property bAllowStealing = False Auto
  Bool Property bStealingIsHostile = False Auto
  Bool Property bTakeAll = False Auto
  ObjectReference Property theLooterRef Auto
EndGroup


;-- Functions ---------------------------------------

Function Log(String logMsg)
  If LPSystemUtil_Debug.GetValue() as Bool
    Debug.Trace(logMsg, 0)
  EndIf
EndFunction

Event OnInit()
  Log("[Lazy Panda] OnInit triggered")
EndEvent

Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
  Log("[Lazy Panda] OnEffectStart triggered")
  StartTimer(lootTimerDelay, lootTimerID)
EndEvent

Event OnTimer(Int aiTimerID)
  Log("[Lazy Panda] OnTimer triggered with TimerID: " + aiTimerID as String)
  If aiTimerID == lootTimerID && Game.GetPlayer().HasPerk(ActivePerk)
    ExecuteLooting()
  EndIf
EndEvent

Function ExecuteLooting()
  Log("[Lazy Panda] ExecuteLooting called")
  LocateLoot(ActiveLootList)
  StartTimer(lootTimerDelay, lootTimerID)
EndFunction

Function LocateLoot(FormList LootList)
  Log("[Lazy Panda] LocateLoot called with LootList: " + LootList as String)
  ObjectReference[] lootArray = None
  If bIsMultipleKeyword
    LocateLootByKeyword(LootList)
  ElseIf bIsKeyword
    lootArray = PlayerRef.FindAllReferencesWithKeyword(LootList.GetAt(0), GetRadius())
  ElseIf bIsContainerSpace
    lootArray = PlayerRef.FindAllReferencesOfType(LootList as Form, GetRadius())
  Else
    lootArray = PlayerRef.FindAllReferencesOfType(LootList as Form, GetRadius())
  EndIf
  If lootArray != None && lootArray.Length > 0
    ProcessLoot(lootArray)
  EndIf
EndFunction

Function LocateLootByKeyword(FormList LootList)
  Log("[Lazy Panda] LocateLootByKeyword called with LootList: " + LootList as String)
  ObjectReference[] lootArray = None
  Int index = 0
  While index < LootList.GetSize()
    lootArray = PlayerRef.FindAllReferencesWithKeyword(LootList.GetAt(index), GetRadius())
    If lootArray != None && lootArray.Length > 0 && !(lootArray.Length == 1 && lootArray[0] == PlayerRef)
      ProcessLoot(lootArray)
    EndIf
    index += 1
  EndWhile
EndFunction

Function ProcessLoot(ObjectReference[] theLootArray)
  Log("[Lazy Panda] ProcessLoot called with lootArray of length: " + theLootArray.Length as String)
  theLooterRef = PlayerRef
  Int index = 0
  While index < theLootArray.Length && IsPlayerAvailable()
    ObjectReference currentLoot = theLootArray[index]
    If currentLoot != None
      Log("[Lazy Panda] Processing loot: " + currentLoot as String)
      If IsCorpse(currentLoot)
        Actor corpseActor = currentLoot as Actor
        If bLootDeadActor && corpseActor.IsDead() && CanTakeLoot(currentLoot)
          Log("[Lazy Panda] Looting Dead Actor")
          ProcessCorpse(currentLoot, theLooterRef)
        EndIf
      ElseIf bIsContainer && CanTakeLoot(currentLoot)
        Log("[Lazy Panda] Looting Container")
        ProcessContainer(currentLoot, theLooterRef)
      ElseIf (bIsContainerSpace || currentLoot.HasKeyword(LPKeyword_Asteroid) || currentLoot.HasKeyword(SQ_ShipDebrisKeyword)) && CanTakeLoot(currentLoot)
        Log("[Lazy Panda] Looting Spaceship Container")
        theLooterRef = PlayerHomeShip.GetRef()
        ProcessContainer(currentLoot, theLooterRef)
      ElseIf bIsActivatedBySpell && CanTakeLoot(currentLoot) && ActiveLootSpell != None
        Log("[Lazy Panda] Looting Activated By Spell")
        ActiveLootSpell.RemoteCast(PlayerRef, PlayerRef as Actor, currentLoot)
      ElseIf bIsActivator && CanTakeLoot(currentLoot)
        Log("[Lazy Panda] Looting Activator")
        currentLoot.Activate(theLooterRef, False)
      ElseIf CanTakeLoot(currentLoot)
        If currentLoot.IsQuestItem()
          Log("[Lazy Panda] Quest Item detected, sending to player")
          PlayerRef.AddItem(currentLoot as Form, -1, False)
        Else
          GetDestRef().AddItem(currentLoot as Form, -1, False)
        EndIf
      EndIf
    EndIf
    index += 1
  EndWhile
EndFunction

Function ProcessCorpse(ObjectReference theCorpse, ObjectReference theLooter)
  Log("[Lazy Panda] ProcessCorpse called with corpse: " + theCorpse as String)
  Bool takeAll = LPSetting_ContTakeAll.GetValue() as Bool
  bTakeAll = takeAll
  Actor corpseActor = theCorpse as Actor
  If corpseActor != None
    Race corpseRace = corpseActor.GetRace()
    If corpseRace == HumanRace
      corpseActor.UnequipAll()
      corpseActor.EquipItem(LP_Skin_Naked_NOTPLAYABLE as Form, False, False)
    EndIf
  EndIf
  Utility.Wait(0.5)
  If takeAll
    theCorpse.RemoveAllItems(GetDestRef(), False, False)
  Else
    ProcessFilteredContainerItems(theCorpse, theLooter)
  EndIf
  RemoveCorpse(theCorpse)
EndFunction

Function RemoveCorpse(ObjectReference theCorpse)
  Log("[Lazy Panda] RemoveCorpse called with corpse: " + theCorpse as String)
  If LPSetting_RemoveCorpses.GetValue() as Bool
    theCorpse.DisableNoWait(True)
  EndIf
EndFunction

Function ProcessContainer(ObjectReference theContainer, ObjectReference theLooter)
  Log("[Lazy Panda] ProcessContainer called with container: " + theContainer as String)
  Bool stealingIsHostile = LPSetting_StealingIsHostile.GetValue() as Bool
  Bool takeAll = LPSetting_ContTakeAll.GetValue() as Bool
  Bool autoUnlock = LPSetting_AutoUnlock.GetValue() as Bool
  If theContainer.IsLocked()
    If autoUnlock
      TryUnlock(theContainer)
    Else
      Log("[Lazy Panda] Container Ignored: Locked, AutoUnlock is disabled")
      Return
    EndIf
  EndIf
  If takeAll
    theContainer.RemoveAllItems(GetDestRef(), False, stealingIsHostile)
  Else
    ProcessFilteredContainerItems(theContainer, theLooter)
  EndIf
EndFunction

Function ProcessFilteredContainerItems(ObjectReference theContainer, ObjectReference theLooter)
  Log("[Lazy Panda] ProcessFilteredContainerItems called with container: " + theContainer as String)
  Int listSize = LPSystem_Looting_Lists.GetSize()
  Int index = 0
  While index < listSize
    FormList currentList = LPSystem_Looting_Lists.GetAt(index) as FormList
    GlobalVariable currentGlobal = LPSystem_Looting_Globals.GetAt(index) as GlobalVariable
    Float globalValue = currentGlobal.GetValue()
    If globalValue == 1.0
      theContainer.RemoveItem(currentList as Form, -1, True, GetDestRef())
    EndIf
    index += 1
  EndWhile
EndFunction

Bool Function CanTakeLoot(ObjectReference theLoot)
  Log("[Lazy Panda] CanTakeLoot called with loot: " + theLoot as String)
  Bool bCanTake = True
  Bool allowStealing = LPSetting_AllowStealing.GetValue() as Bool
  ObjectReference theContainer = theLoot.GetContainer()
  TakeOwnership(theLoot)
  Log("[Lazy Panda] Container: " + theContainer as String)
  If theContainer != None
    Log("[Lazy Panda] Container Is Owned: " + IsOwned(theContainer) as String)
    bCanTake = False
  ElseIf !IsLootLoaded(theLoot)
    Log("[Lazy Panda] Loot Not Loaded")
    bCanTake = False
  ElseIf theLoot.IsQuestItem()
    Log("[Lazy Panda] Quest Item")
    bCanTake = False
  ElseIf (PlayerRef as Actor).WouldBeStealing(theLoot) && !allowStealing
    Log("[Lazy Panda] Would Be Stealing")
    bCanTake = False
  ElseIf IsPlayerStealing(theLoot) && !allowStealing
    Log("[Lazy Panda] Is Stealing")
    bCanTake = False
  ElseIf IsInRestrictedLocation()
    Log("[Lazy Panda] In Restricted Location")
    bCanTake = False
  EndIf
  Log("[Lazy Panda] Can Take: " + bCanTake as String)
  Return bCanTake
EndFunction

Bool Function IsInRestrictedLocation()
  FormList restrictedLocations = LPFilter_NoLootLocations
  Int index = 0
  While index < restrictedLocations.GetSize()
    If PlayerRef.IsInLocation(restrictedLocations.GetAt(index) as Location)
      Return True
    EndIf
    index += 1
  EndWhile
  If PlayerRef.IsInLocation(playerShipInterior.GetLocation()) && !CanLootShip()
    Return True
  EndIf
  Return False
EndFunction

Function TakeOwnership(ObjectReference theLoot)
  Log("[Lazy Panda] TakeOwnership called with loot: " + theLoot as String)
  Bool allowStealing = LPSetting_AllowStealing.GetValue() as Bool
  Bool stealingIsHostile = LPSetting_StealingIsHostile.GetValue() as Bool
  If allowStealing && !stealingIsHostile && IsOwned(theLoot)
    theLoot.SetActorRefOwner(PlayerRef as Actor, True)
  EndIf
EndFunction

Bool Function CanLootShip()
  Log("[Lazy Panda] CanLootShip called")
  Return LPSetting_AllowLootingShip.GetValue() as Bool
EndFunction

Bool Function IsOwned(ObjectReference theLoot)
  Log("[Lazy Panda] IsOwned called with loot: " + theLoot as String)
  Return (PlayerRef as Actor).WouldBeStealing(theLoot) || IsPlayerStealing(theLoot) || theLoot.HasOwner()
EndFunction

Function TryUnlock(ObjectReference theContainer)
  Log("[Lazy Panda] TryUnlock called with container: " + theContainer as String)
  Bool bLockSkillCheck = LPSetting_AutoUnlockSkillCheck.GetValue() as Bool
  Log("[Lazy Panda] Lock Skill Check: " + bLockSkillCheck as String)
  Bool bIsOwned = theContainer.HasOwner()
  Log("[Lazy Panda] Is Owned: " + bIsOwned as String)
  Int iLockLevel = theContainer.GetLockLevel()
  Log("[Lazy Panda] Lock Level: " + iLockLevel as String)
  Int iRequiresKey = LockLevel_RequiresKey.GetValue() as Int
  Log("[Lazy Panda] Requires Key: " + iRequiresKey as String)
  Int iInaccessible = LockLevel_Inaccessible.GetValue() as Int
  If iLockLevel == iInaccessible
    HandleInaccessibleLock()
  ElseIf iLockLevel == iRequiresKey
    HandleRequiresKey(theContainer, bIsOwned)
  Else
    HandleDigipickUnlock(theContainer, bIsOwned, bLockSkillCheck)
  EndIf
EndFunction

Function HandleInaccessibleLock()
  Log("[Lazy Panda] HandleInaccessibleLock called")
EndFunction

Function HandleRequiresKey(ObjectReference theContainer, Bool bIsOwned)
  Log("[Lazy Panda] HandleRequiresKey called with container: " + theContainer as String)
  Key theKey = theContainer.GetKey()
  FindKey(theKey)
  If PlayerRef.GetItemCount(theKey as Form) > 0
    Log("[Lazy Panda] Key Found")
    theContainer.Unlock(bIsOwned)
    Log("[Lazy Panda] Container Unlocked: With Key")
  Else
    Log("[Lazy Panda] Locked Container Ignored: Requires Key")
  EndIf
EndFunction

Function HandleDigipickUnlock(ObjectReference theContainer, Bool bIsOwned, Bool bLockSkillCheck)
  Log("[Lazy Panda] HandleDigipickUnlock called with container: " + theContainer as String)
  If PlayerRef.GetItemCount(Digipick as Form) == 0
    FindDigipick()
  EndIf
  If PlayerRef.GetItemCount(Digipick as Form) > 0
    If !bLockSkillCheck || (bLockSkillCheck && CanUnlock(theContainer))
      theContainer.Unlock(bIsOwned)
      If !theContainer.IsLocked()
        Game.RewardPlayerXP(10, False)
        PlayerRef.RemoveItem(Digipick as Form, 1, False, None)
        Log("[Lazy Panda] Container Unlocked: With Digipick")
      EndIf
    Else
      Log("[Lazy Panda] Locked Container Ignored: Failed Skill Check")
    EndIf
  Else
    Log("[Lazy Panda] Locked Container Ignored: No Digipick")
  EndIf
EndFunction

Function FindDigipick()
  Log("[Lazy Panda] FindDigipick called")
  ObjectReference[] searchLocations = new ObjectReference[2]
  searchLocations[0] = LPDummyHoldingRef
  searchLocations[1] = LodgeSafeRef
  Int index = 0
  While index < searchLocations.Length
    If searchLocations[index].GetItemCount(Digipick as Form) > 0
      Log("[Lazy Panda] Digipick Found: In " + searchLocations[index] as String)
      searchLocations[index].RemoveItem(Digipick as Form, -1, True, PlayerRef)
      Return
    EndIf
    index += 1
  EndWhile
EndFunction

Function FindKey(Key theKey)
  Log("[Lazy Panda] FindKey called with key: " + theKey as String)
  ObjectReference[] searchLocations = new ObjectReference[2]
  searchLocations[0] = LPDummyHoldingRef
  searchLocations[1] = LodgeSafeRef
  Int index = 0
  While index < searchLocations.Length
    If searchLocations[index].GetItemCount(theKey as Form) > 0
      Log("[Lazy Panda] Key Found: In " + searchLocations[index] as String)
      searchLocations[index].RemoveItem(theKey as Form, -1, True, PlayerRef)
      Return
    EndIf
    index += 1
  EndWhile
EndFunction

Bool Function CanUnlock(ObjectReference theContainer)
  Log("[Lazy Panda] CanUnlock called with container: " + theContainer as String)
  Int iLockLevel = theContainer.GetLockLevel()
  Int[] lockLevels = new Int[4]
  lockLevels[0] = LockLevel_Novice.GetValue() as Int
  lockLevels[1] = LockLevel_Advanced.GetValue() as Int
  lockLevels[2] = LockLevel_Expert.GetValue() as Int
  lockLevels[3] = LockLevel_Master.GetValue() as Int
  Bool[] canUnlock = new Bool[4]
  canUnlock[0] = True
  canUnlock[1] = Perk_CND_AdvancedLocksCheck.IsTrue(PlayerRef, None)
  canUnlock[2] = Perk_CND_ExpertLocksCheck.IsTrue(PlayerRef, None)
  canUnlock[3] = Perk_CND_MasterLocksCheck.IsTrue(PlayerRef, None)
  Int index = 0
  While index < lockLevels.Length
    If iLockLevel == lockLevels[index]
      Log("[Lazy Panda] Can Unlock: " + canUnlock[index] as String)
      Return canUnlock[index]
    EndIf
    index += 1
  EndWhile
  Log("[Lazy Panda] Can Unlock: False")
  Return False
EndFunction

Bool Function IsCorpse(ObjectReference theCorpse)
  Log("[Lazy Panda] IsCorpse called with corpse: " + theCorpse as String)
  Actor theCorpseActor = theCorpse as Actor
  Bool isCorpse = theCorpseActor != None
  Log("[Lazy Panda] Is Corpse: " + isCorpse as String)
  Return isCorpse
EndFunction

ObjectReference Function GetDestRef()
  Log("[Lazy Panda] GetDestRef called")
  Int destination = LPSetting_SendTo.GetValue() as Int
  If destination == 1
    Log("[Lazy Panda] Destination: Player")
    Return PlayerRef
  ElseIf destination == 2
    Log("[Lazy Panda] Destination: Lodge Safe")
    Return LodgeSafeRef
  ElseIf destination == 3
    Log("[Lazy Panda] Destination: Dummy Holding")
    Return LPDummyHoldingRef
  Else
    Log("[Lazy Panda] Destination: Unknown")
    Return None
  EndIf
EndFunction

Bool Function IsPlayerStealing(ObjectReference theLoot)
  Log("[Lazy Panda] IsPlayerStealing called with loot: " + theLoot as String)
  Faction currentOwner = theLoot.GetFactionOwner()
  Log("[Lazy Panda] Current Owner: " + currentOwner as String)
  Return !(currentOwner == None || currentOwner == PlayerFaction)
EndFunction

Bool Function IsPlayerAvailable()
  Log("[Lazy Panda] IsPlayerAvailable called")
  Return Game.IsActivateControlsEnabled() || Game.IsLookingControlsEnabled()
EndFunction

Bool Function IsLootLoaded(ObjectReference theLoot)
  Log("[Lazy Panda] IsLootLoaded called with loot: " + theLoot as String)
  Return theLoot.Is3DLoaded() && !theLoot.IsDisabled() && !theLoot.IsDeleted()
EndFunction

Float Function GetRadius()
  Log("[Lazy Panda] GetRadius called")
  Float fSearchRadius = 0.0
  If bIsContainerSpace
    fSearchRadius = Game.GetGameSettingFloat("fMaxShipTransferDistance")
  Else
    fSearchRadius = LPSetting_Radius.GetValue()
  EndIf
  Log("[Lazy Panda] Search Radius: " + fSearchRadius as String)
  Return fSearchRadius
EndFunction
