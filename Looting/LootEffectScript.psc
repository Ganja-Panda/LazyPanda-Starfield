ScriptName LZP:Looting:LootEffectScript Extends ActiveMagicEffect hidden

;-- Variables ---------------------------------------
Race SFBGS001_HumanRace
Race SFBGS003_HumanRace
Bool bIsShatteredSpaceLoaded
Bool bIsTrackerAllianceLoaded

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
  If LPSystemUtil_Debug.GetValue() as Bool ; #DEBUG_LINE_NO:127
    Debug.Trace(logMsg, 0) ; #DEBUG_LINE_NO:128
  EndIf
EndFunction

Event OnInit()
  Self.Log("[Lazy Panda] OnInit triggered") ; #DEBUG_LINE_NO:147
  bIsShatteredSpaceLoaded = Game.IsPluginInstalled("ShatteredSpace.esm") != (-1) as Bool ; #DEBUG_LINE_NO:148
  bIsTrackerAllianceLoaded = Game.IsPluginInstalled("TrackerAlliance.esm") != (-1) as Bool ; #DEBUG_LINE_NO:149
  If bIsShatteredSpaceLoaded ; #DEBUG_LINE_NO:150
    SFBGS001_HumanRace = Game.GetFormFromFile(16803113, "ShatteredSpace.esm") as Race ; #DEBUG_LINE_NO:151
  ElseIf bIsTrackerAllianceLoaded
    SFBGS003_HumanRace = Game.GetFormFromFile(157, "SFBGS003.esm") as Race ; #DEBUG_LINE_NO:153
  EndIf
EndEvent

Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
  Self.Log("[Lazy Panda] OnEffectStart triggered") ; #DEBUG_LINE_NO:160
  Self.StartTimer(lootTimerDelay, lootTimerID) ; #DEBUG_LINE_NO:161
EndEvent

Event OnTimer(Int aiTimerID)
  Self.Log("[Lazy Panda] OnTimer triggered with TimerID: " + aiTimerID as String) ; #DEBUG_LINE_NO:167
  If aiTimerID == lootTimerID && Game.GetPlayer().HasPerk(ActivePerk) ; #DEBUG_LINE_NO:168
    Self.ExecuteLooting() ; #DEBUG_LINE_NO:169
  EndIf
EndEvent

Function ExecuteLooting()
  Self.Log("[Lazy Panda] ExecuteLooting called") ; #DEBUG_LINE_NO:181
  Self.LocateLoot(ActiveLootList) ; #DEBUG_LINE_NO:182
  Self.StartTimer(lootTimerDelay, lootTimerID) ; #DEBUG_LINE_NO:183
EndFunction

Function LocateLoot(FormList LootList)
  Self.Log("[Lazy Panda] LocateLoot called with LootList: " + LootList as String) ; #DEBUG_LINE_NO:189
  ObjectReference[] lootArray = None ; #DEBUG_LINE_NO:190
  If bIsMultipleKeyword ; #DEBUG_LINE_NO:193
    Self.LocateLootByKeyword(LootList) ; #DEBUG_LINE_NO:194
  ElseIf bIsKeyword
    lootArray = PlayerRef.FindAllReferencesWithKeyword(LootList.GetAt(0), Self.GetRadius()) ; #DEBUG_LINE_NO:197
  ElseIf bIsContainerSpace
    lootArray = PlayerRef.FindAllReferencesOfType(LootList as Form, Self.GetRadius()) ; #DEBUG_LINE_NO:200
  Else
    lootArray = PlayerRef.FindAllReferencesOfType(LootList as Form, Self.GetRadius()) ; #DEBUG_LINE_NO:203
  EndIf
  If lootArray != None && lootArray.Length > 0 ; #DEBUG_LINE_NO:207
    Self.ProcessLoot(lootArray) ; #DEBUG_LINE_NO:208
  EndIf
EndFunction

Function LocateLootByKeyword(FormList LootList)
  Self.Log("[Lazy Panda] LocateLootByKeyword called with LootList: " + LootList as String) ; #DEBUG_LINE_NO:215
  ObjectReference[] lootArray = None ; #DEBUG_LINE_NO:216
  Int index = 0 ; #DEBUG_LINE_NO:217
  While index < LootList.GetSize() ; #DEBUG_LINE_NO:218
    lootArray = PlayerRef.FindAllReferencesWithKeyword(LootList.GetAt(index), Self.GetRadius()) ; #DEBUG_LINE_NO:219
    If lootArray != None && lootArray.Length > 0 && !(lootArray.Length == 1 && lootArray[0] == PlayerRef) ; #DEBUG_LINE_NO:221
      Self.ProcessLoot(lootArray) ; #DEBUG_LINE_NO:222
    EndIf
    index += 1 ; #DEBUG_LINE_NO:224
  EndWhile
EndFunction

Function ProcessLoot(ObjectReference[] theLootArray)
  Self.Log("[Lazy Panda] ProcessLoot called with lootArray of length: " + theLootArray.Length as String) ; #DEBUG_LINE_NO:229
  theLooterRef = PlayerRef ; #DEBUG_LINE_NO:230
  Int index = 0 ; #DEBUG_LINE_NO:231
  While index < theLootArray.Length && Self.IsPlayerAvailable() ; #DEBUG_LINE_NO:232
    ObjectReference currentLoot = theLootArray[index] ; #DEBUG_LINE_NO:233
    If currentLoot != None ; #DEBUG_LINE_NO:234
      Self.Log("[Lazy Panda] Processing loot: " + currentLoot as String) ; #DEBUG_LINE_NO:235
      If Self.IsCorpse(currentLoot) ; #DEBUG_LINE_NO:237
        Actor corpseActor = currentLoot as Actor ; #DEBUG_LINE_NO:238
        If bLootDeadActor && corpseActor.IsDead() && Self.CanTakeLoot(currentLoot) ; #DEBUG_LINE_NO:239
          Self.Log("[Lazy Panda] Looting Dead Actor") ; #DEBUG_LINE_NO:240
          Self.ProcessCorpse(currentLoot, theLooterRef) ; #DEBUG_LINE_NO:241
        EndIf
      ElseIf bIsContainer && Self.CanTakeLoot(currentLoot) ; #DEBUG_LINE_NO:243
        Self.Log("[Lazy Panda] Looting Container") ; #DEBUG_LINE_NO:244
        Self.ProcessContainer(currentLoot, theLooterRef) ; #DEBUG_LINE_NO:245
      ElseIf (bIsContainerSpace || currentLoot.HasKeyword(LPKeyword_Asteroid) || currentLoot.HasKeyword(SQ_ShipDebrisKeyword)) && Self.CanTakeLoot(currentLoot) ; #DEBUG_LINE_NO:246
        Self.Log("[Lazy Panda] Looting Spaceship Container") ; #DEBUG_LINE_NO:247
        theLooterRef = PlayerHomeShip.GetRef() ; #DEBUG_LINE_NO:248
        Self.ProcessContainer(currentLoot, theLooterRef) ; #DEBUG_LINE_NO:249
      ElseIf bIsActivatedBySpell && Self.CanTakeLoot(currentLoot) && ActiveLootSpell != None ; #DEBUG_LINE_NO:250
        Self.Log("[Lazy Panda] Looting Activated By Spell") ; #DEBUG_LINE_NO:251
        ActiveLootSpell.RemoteCast(PlayerRef, PlayerRef as Actor, currentLoot) ; #DEBUG_LINE_NO:252
      ElseIf bIsActivator && Self.CanTakeLoot(currentLoot) ; #DEBUG_LINE_NO:253
        Self.Log("[Lazy Panda] Looting Activator") ; #DEBUG_LINE_NO:254
        currentLoot.Activate(theLooterRef, False) ; #DEBUG_LINE_NO:255
      ElseIf Self.CanTakeLoot(currentLoot) ; #DEBUG_LINE_NO:256
        If currentLoot.IsQuestItem() ; #DEBUG_LINE_NO:258
          Self.Log("[Lazy Panda] Quest Item detected, sending to player") ; #DEBUG_LINE_NO:259
          PlayerRef.AddItem(currentLoot as Form, -1, False) ; #DEBUG_LINE_NO:260
        Else
          Self.GetDestRef().AddItem(currentLoot as Form, -1, False) ; #DEBUG_LINE_NO:262
        EndIf
      EndIf
    EndIf
    index += 1 ; #DEBUG_LINE_NO:266
  EndWhile
EndFunction

Function ProcessCorpse(ObjectReference theCorpse, ObjectReference theLooter)
  Self.Log("[Lazy Panda] ProcessCorpse called with corpse: " + theCorpse as String) ; #DEBUG_LINE_NO:273
  Bool takeAll = LPSetting_ContTakeAll.GetValue() as Bool ; #DEBUG_LINE_NO:274
  bTakeAll = takeAll ; #DEBUG_LINE_NO:275
  Actor corpseActor = theCorpse as Actor ; #DEBUG_LINE_NO:276
  If corpseActor != None ; #DEBUG_LINE_NO:277
    Race corpseRace = corpseActor.GetRace() ; #DEBUG_LINE_NO:278
    If bIsTrackerAllianceLoaded && (corpseRace == HumanRace || corpseRace == SFBGS003_HumanRace) ; #DEBUG_LINE_NO:280
      corpseActor.UnequipAll() ; #DEBUG_LINE_NO:281
      corpseActor.EquipItem(LP_Skin_Naked_NOTPLAYABLE as Form, False, False) ; #DEBUG_LINE_NO:282
    ElseIf bIsShatteredSpaceLoaded && (corpseRace == HumanRace || corpseRace == SFBGS001_HumanRace || corpseRace == SFBGS003_HumanRace) ; #DEBUG_LINE_NO:283
      corpseActor.UnequipAll() ; #DEBUG_LINE_NO:284
      corpseActor.EquipItem(LP_Skin_Naked_NOTPLAYABLE as Form, False, False) ; #DEBUG_LINE_NO:285
    ElseIf corpseRace == HumanRace ; #DEBUG_LINE_NO:286
      corpseActor.UnequipAll() ; #DEBUG_LINE_NO:287
      corpseActor.EquipItem(LP_Skin_Naked_NOTPLAYABLE as Form, False, False) ; #DEBUG_LINE_NO:288
    EndIf
  EndIf
  Utility.Wait(0.5) ; #DEBUG_LINE_NO:291
  If takeAll ; #DEBUG_LINE_NO:293
    theCorpse.RemoveAllItems(Self.GetDestRef(), False, False) ; #DEBUG_LINE_NO:294
  Else
    Self.ProcessFilteredContainerItems(theCorpse, theLooter) ; #DEBUG_LINE_NO:296
  EndIf
  Self.RemoveCorpse(theCorpse) ; #DEBUG_LINE_NO:298
EndFunction

Function RemoveCorpse(ObjectReference theCorpse)
  Self.Log("[Lazy Panda] RemoveCorpse called with corpse: " + theCorpse as String) ; #DEBUG_LINE_NO:304
  If LPSetting_RemoveCorpses.GetValue() as Bool ; #DEBUG_LINE_NO:305
    theCorpse.DisableNoWait(True) ; #DEBUG_LINE_NO:306
  EndIf
EndFunction

Function ProcessContainer(ObjectReference theContainer, ObjectReference theLooter)
  Self.Log("[Lazy Panda] ProcessContainer called with container: " + theContainer as String) ; #DEBUG_LINE_NO:313
  Bool stealingIsHostile = LPSetting_StealingIsHostile.GetValue() as Bool ; #DEBUG_LINE_NO:314
  Bool takeAll = LPSetting_ContTakeAll.GetValue() as Bool ; #DEBUG_LINE_NO:315
  Bool autoUnlock = LPSetting_AutoUnlock.GetValue() as Bool ; #DEBUG_LINE_NO:316
  If theContainer.IsLocked() ; #DEBUG_LINE_NO:319
    If autoUnlock ; #DEBUG_LINE_NO:320
      Self.TryUnlock(theContainer) ; #DEBUG_LINE_NO:321
    Else
      Self.Log("[Lazy Panda] Container Ignored: Locked, AutoUnlock is disabled") ; #DEBUG_LINE_NO:323
      Return  ; #DEBUG_LINE_NO:324
    EndIf
  EndIf
  If takeAll ; #DEBUG_LINE_NO:329
    theContainer.RemoveAllItems(Self.GetDestRef(), False, stealingIsHostile) ; #DEBUG_LINE_NO:330
  Else
    Self.ProcessFilteredContainerItems(theContainer, theLooter) ; #DEBUG_LINE_NO:332
  EndIf
EndFunction

Function ProcessFilteredContainerItems(ObjectReference theContainer, ObjectReference theLooter)
  Self.Log("[Lazy Panda] ProcessFilteredContainerItems called with container: " + theContainer as String) ; #DEBUG_LINE_NO:339
  Int listSize = LPSystem_Looting_Lists.GetSize() ; #DEBUG_LINE_NO:340
  Int index = 0 ; #DEBUG_LINE_NO:341
  While index < listSize ; #DEBUG_LINE_NO:342
    FormList currentList = LPSystem_Looting_Lists.GetAt(index) as FormList ; #DEBUG_LINE_NO:343
    GlobalVariable currentGlobal = LPSystem_Looting_Globals.GetAt(index) as GlobalVariable ; #DEBUG_LINE_NO:344
    Float globalValue = currentGlobal.GetValue() ; #DEBUG_LINE_NO:345
    If globalValue == 1.0 ; #DEBUG_LINE_NO:347
      theContainer.RemoveItem(currentList as Form, -1, True, Self.GetDestRef()) ; #DEBUG_LINE_NO:348
    EndIf
    index += 1 ; #DEBUG_LINE_NO:350
  EndWhile
EndFunction

Bool Function CanTakeLoot(ObjectReference theLoot)
  Self.Log("[Lazy Panda] CanTakeLoot called with loot: " + theLoot as String) ; #DEBUG_LINE_NO:357
  Bool bCanTake = True ; #DEBUG_LINE_NO:358
  Bool allowStealing = LPSetting_AllowStealing.GetValue() as Bool ; #DEBUG_LINE_NO:359
  ObjectReference theContainer = theLoot.GetContainer() ; #DEBUG_LINE_NO:360
  Self.TakeOwnership(theLoot) ; #DEBUG_LINE_NO:361
  Self.Log("[Lazy Panda] Container: " + theContainer as String) ; #DEBUG_LINE_NO:362
  If theContainer != None ; #DEBUG_LINE_NO:365
    Self.Log("[Lazy Panda] Container Is Owned: " + Self.IsOwned(theContainer) as String) ; #DEBUG_LINE_NO:366
    bCanTake = False ; #DEBUG_LINE_NO:367
  ElseIf !Self.IsLootLoaded(theLoot) ; #DEBUG_LINE_NO:368
    Self.Log("[Lazy Panda] Loot Not Loaded") ; #DEBUG_LINE_NO:369
    bCanTake = False ; #DEBUG_LINE_NO:370
  ElseIf theLoot.IsQuestItem() ; #DEBUG_LINE_NO:371
    Self.Log("[Lazy Panda] Quest Item") ; #DEBUG_LINE_NO:372
    bCanTake = False ; #DEBUG_LINE_NO:373
  ElseIf (PlayerRef as Actor).WouldBeStealing(theLoot) && !allowStealing ; #DEBUG_LINE_NO:374
    Self.Log("[Lazy Panda] Would Be Stealing") ; #DEBUG_LINE_NO:375
    bCanTake = False ; #DEBUG_LINE_NO:376
  ElseIf Self.IsPlayerStealing(theLoot) && !allowStealing ; #DEBUG_LINE_NO:377
    Self.Log("[Lazy Panda] Is Stealing") ; #DEBUG_LINE_NO:378
    bCanTake = False ; #DEBUG_LINE_NO:379
  ElseIf Self.IsInRestrictedLocation() ; #DEBUG_LINE_NO:380
    Self.Log("[Lazy Panda] In Restricted Location") ; #DEBUG_LINE_NO:381
    bCanTake = False ; #DEBUG_LINE_NO:382
  EndIf
  Self.Log("[Lazy Panda] Can Take: " + bCanTake as String) ; #DEBUG_LINE_NO:385
  Return bCanTake ; #DEBUG_LINE_NO:386
EndFunction

Bool Function IsInRestrictedLocation()
  FormList restrictedLocations = LPFilter_NoLootLocations ; #DEBUG_LINE_NO:392
  Int index = 0 ; #DEBUG_LINE_NO:393
  While index < restrictedLocations.GetSize() ; #DEBUG_LINE_NO:394
    If PlayerRef.IsInLocation(restrictedLocations.GetAt(index) as Location) ; #DEBUG_LINE_NO:395
      Return True ; #DEBUG_LINE_NO:396
    EndIf
    index += 1 ; #DEBUG_LINE_NO:398
  EndWhile
  If PlayerRef.IsInLocation(playerShipInterior.GetLocation()) && !Self.CanLootShip() ; #DEBUG_LINE_NO:401
    Return True ; #DEBUG_LINE_NO:402
  EndIf
  Return False ; #DEBUG_LINE_NO:404
EndFunction

Function TakeOwnership(ObjectReference theLoot)
  Self.Log("[Lazy Panda] TakeOwnership called with loot: " + theLoot as String) ; #DEBUG_LINE_NO:410
  Bool allowStealing = LPSetting_AllowStealing.GetValue() as Bool ; #DEBUG_LINE_NO:411
  Bool stealingIsHostile = LPSetting_StealingIsHostile.GetValue() as Bool ; #DEBUG_LINE_NO:412
  If allowStealing && !stealingIsHostile && Self.IsOwned(theLoot) ; #DEBUG_LINE_NO:413
    theLoot.SetActorRefOwner(PlayerRef as Actor, True) ; #DEBUG_LINE_NO:414
  EndIf
EndFunction

Bool Function CanLootShip()
  Self.Log("[Lazy Panda] CanLootShip called") ; #DEBUG_LINE_NO:421
  Return LPSetting_AllowLootingShip.GetValue() as Bool ; #DEBUG_LINE_NO:422
EndFunction

Bool Function IsOwned(ObjectReference theLoot)
  Self.Log("[Lazy Panda] IsOwned called with loot: " + theLoot as String) ; #DEBUG_LINE_NO:428
  Return (PlayerRef as Actor).WouldBeStealing(theLoot) || Self.IsPlayerStealing(theLoot) || theLoot.HasOwner() ; #DEBUG_LINE_NO:429
EndFunction

Function TryUnlock(ObjectReference theContainer)
  Self.Log("[Lazy Panda] TryUnlock called with container: " + theContainer as String) ; #DEBUG_LINE_NO:435
  Bool bLockSkillCheck = LPSetting_AutoUnlockSkillCheck.GetValue() as Bool ; #DEBUG_LINE_NO:436
  Self.Log("[Lazy Panda] Lock Skill Check: " + bLockSkillCheck as String) ; #DEBUG_LINE_NO:437
  Bool bIsOwned = theContainer.HasOwner() ; #DEBUG_LINE_NO:438
  Self.Log("[Lazy Panda] Is Owned: " + bIsOwned as String) ; #DEBUG_LINE_NO:439
  Int iLockLevel = theContainer.GetLockLevel() ; #DEBUG_LINE_NO:440
  Self.Log("[Lazy Panda] Lock Level: " + iLockLevel as String) ; #DEBUG_LINE_NO:441
  Int iRequiresKey = LockLevel_RequiresKey.GetValue() as Int ; #DEBUG_LINE_NO:442
  Self.Log("[Lazy Panda] Requires Key: " + iRequiresKey as String) ; #DEBUG_LINE_NO:443
  Int iInaccessible = LockLevel_Inaccessible.GetValue() as Int ; #DEBUG_LINE_NO:444
  If iLockLevel == iInaccessible ; #DEBUG_LINE_NO:447
    Self.HandleInaccessibleLock() ; #DEBUG_LINE_NO:448
  ElseIf iLockLevel == iRequiresKey ; #DEBUG_LINE_NO:449
    Self.HandleRequiresKey(theContainer, bIsOwned) ; #DEBUG_LINE_NO:450
  Else
    Self.HandleDigipickUnlock(theContainer, bIsOwned, bLockSkillCheck) ; #DEBUG_LINE_NO:452
  EndIf
EndFunction

Function HandleInaccessibleLock()
  Self.Log("[Lazy Panda] HandleInaccessibleLock called") ; #DEBUG_LINE_NO:459
EndFunction

Function HandleRequiresKey(ObjectReference theContainer, Bool bIsOwned)
  Self.Log("[Lazy Panda] HandleRequiresKey called with container: " + theContainer as String) ; #DEBUG_LINE_NO:465
  Key theKey = theContainer.GetKey() ; #DEBUG_LINE_NO:466
  Self.FindKey(theKey) ; #DEBUG_LINE_NO:467
  If PlayerRef.GetItemCount(theKey as Form) > 0 ; #DEBUG_LINE_NO:468
    Self.Log("[Lazy Panda] Key Found") ; #DEBUG_LINE_NO:469
    theContainer.Unlock(bIsOwned) ; #DEBUG_LINE_NO:470
    Self.Log("[Lazy Panda] Container Unlocked: With Key") ; #DEBUG_LINE_NO:471
  Else
    Self.Log("[Lazy Panda] Locked Container Ignored: Requires Key") ; #DEBUG_LINE_NO:473
  EndIf
EndFunction

Function HandleDigipickUnlock(ObjectReference theContainer, Bool bIsOwned, Bool bLockSkillCheck)
  Self.Log("[Lazy Panda] HandleDigipickUnlock called with container: " + theContainer as String) ; #DEBUG_LINE_NO:480
  If PlayerRef.GetItemCount(Digipick as Form) == 0 ; #DEBUG_LINE_NO:481
    Self.FindDigipick() ; #DEBUG_LINE_NO:482
  EndIf
  If PlayerRef.GetItemCount(Digipick as Form) > 0 ; #DEBUG_LINE_NO:484
    If !bLockSkillCheck || bLockSkillCheck && Self.CanUnlock(theContainer) ; #DEBUG_LINE_NO:485
      theContainer.Unlock(bIsOwned) ; #DEBUG_LINE_NO:486
      If !theContainer.IsLocked() ; #DEBUG_LINE_NO:487
        Game.RewardPlayerXP(10, False) ; #DEBUG_LINE_NO:488
        PlayerRef.RemoveItem(Digipick as Form, 1, False, None) ; #DEBUG_LINE_NO:489
        Self.Log("[Lazy Panda] Container Unlocked: With Digipick") ; #DEBUG_LINE_NO:490
      EndIf
    Else
      Self.Log("[Lazy Panda] Locked Container Ignored: Failed Skill Check") ; #DEBUG_LINE_NO:493
    EndIf
  Else
    Self.Log("[Lazy Panda] Locked Container Ignored: No Digipick") ; #DEBUG_LINE_NO:496
  EndIf
EndFunction

Function FindDigipick()
  Self.Log("[Lazy Panda] FindDigipick called") ; #DEBUG_LINE_NO:503
  ObjectReference[] searchLocations = new ObjectReference[2] ; #DEBUG_LINE_NO:504
  searchLocations[0] = LPDummyHoldingRef ; #DEBUG_LINE_NO:505
  searchLocations[1] = LodgeSafeRef ; #DEBUG_LINE_NO:506
  Int index = 0 ; #DEBUG_LINE_NO:507
  While index < searchLocations.Length ; #DEBUG_LINE_NO:508
    If searchLocations[index].GetItemCount(Digipick as Form) > 0 ; #DEBUG_LINE_NO:509
      Self.Log("[Lazy Panda] Digipick Found: In " + searchLocations[index] as String) ; #DEBUG_LINE_NO:510
      searchLocations[index].RemoveItem(Digipick as Form, -1, True, PlayerRef) ; #DEBUG_LINE_NO:511
      Return  ; #DEBUG_LINE_NO:512
    EndIf
    index += 1 ; #DEBUG_LINE_NO:514
  EndWhile
EndFunction

Function FindKey(Key theKey)
  Self.Log("[Lazy Panda] FindKey called with key: " + theKey as String) ; #DEBUG_LINE_NO:521
  ObjectReference[] searchLocations = new ObjectReference[2] ; #DEBUG_LINE_NO:522
  searchLocations[0] = LPDummyHoldingRef ; #DEBUG_LINE_NO:523
  searchLocations[1] = LodgeSafeRef ; #DEBUG_LINE_NO:524
  Int index = 0 ; #DEBUG_LINE_NO:525
  While index < searchLocations.Length ; #DEBUG_LINE_NO:526
    If searchLocations[index].GetItemCount(theKey as Form) > 0 ; #DEBUG_LINE_NO:527
      Self.Log("[Lazy Panda] Key Found: In " + searchLocations[index] as String) ; #DEBUG_LINE_NO:528
      searchLocations[index].RemoveItem(theKey as Form, -1, True, PlayerRef) ; #DEBUG_LINE_NO:529
      Return  ; #DEBUG_LINE_NO:530
    EndIf
    index += 1 ; #DEBUG_LINE_NO:532
  EndWhile
EndFunction

Bool Function CanUnlock(ObjectReference theContainer)
  Self.Log("[Lazy Panda] CanUnlock called with container: " + theContainer as String) ; #DEBUG_LINE_NO:539
  Int iLockLevel = theContainer.GetLockLevel() ; #DEBUG_LINE_NO:540
  Int[] lockLevels = new Int[4] ; #DEBUG_LINE_NO:542
  lockLevels[0] = LockLevel_Novice.GetValue() as Int ; #DEBUG_LINE_NO:543
  lockLevels[1] = LockLevel_Advanced.GetValue() as Int ; #DEBUG_LINE_NO:544
  lockLevels[2] = LockLevel_Expert.GetValue() as Int ; #DEBUG_LINE_NO:545
  lockLevels[3] = LockLevel_Master.GetValue() as Int ; #DEBUG_LINE_NO:546
  Bool[] CanUnlock = new Bool[4] ; #DEBUG_LINE_NO:549
  CanUnlock[0] = True ; #DEBUG_LINE_NO:550
  CanUnlock[1] = Perk_CND_AdvancedLocksCheck.IsTrue(PlayerRef, None) ; #DEBUG_LINE_NO:551
  CanUnlock[2] = Perk_CND_ExpertLocksCheck.IsTrue(PlayerRef, None) ; #DEBUG_LINE_NO:552
  CanUnlock[3] = Perk_CND_MasterLocksCheck.IsTrue(PlayerRef, None) ; #DEBUG_LINE_NO:553
  Int index = 0 ; #DEBUG_LINE_NO:555
  While index < lockLevels.Length ; #DEBUG_LINE_NO:556
    If iLockLevel == lockLevels[index] ; #DEBUG_LINE_NO:557
      Self.Log("[Lazy Panda] Can Unlock: " + CanUnlock[index] as String) ; #DEBUG_LINE_NO:558
      Return CanUnlock[index] ; #DEBUG_LINE_NO:559
    EndIf
    index += 1 ; #DEBUG_LINE_NO:561
  EndWhile
  Self.Log("[Lazy Panda] Can Unlock: False") ; #DEBUG_LINE_NO:564
  Return False ; #DEBUG_LINE_NO:565
EndFunction

Bool Function IsCorpse(ObjectReference theCorpse)
  Self.Log("[Lazy Panda] IsCorpse called with corpse: " + theCorpse as String) ; #DEBUG_LINE_NO:571
  Actor theCorpseActor = theCorpse as Actor ; #DEBUG_LINE_NO:572
  Bool IsCorpse = theCorpseActor != None ; #DEBUG_LINE_NO:573
  Self.Log("[Lazy Panda] Is Corpse: " + IsCorpse as String) ; #DEBUG_LINE_NO:574
  Return IsCorpse ; #DEBUG_LINE_NO:575
EndFunction

ObjectReference Function GetDestRef()
  Self.Log("[Lazy Panda] GetDestRef called") ; #DEBUG_LINE_NO:581
  Int destination = LPSetting_SendTo.GetValue() as Int ; #DEBUG_LINE_NO:582
  If destination == 1 ; #DEBUG_LINE_NO:583
    Self.Log("[Lazy Panda] Destination: Player") ; #DEBUG_LINE_NO:584
    Return PlayerRef ; #DEBUG_LINE_NO:585
  ElseIf destination == 2 ; #DEBUG_LINE_NO:586
    Self.Log("[Lazy Panda] Destination: Lodge Safe") ; #DEBUG_LINE_NO:587
    Return LodgeSafeRef ; #DEBUG_LINE_NO:588
  ElseIf destination == 3 ; #DEBUG_LINE_NO:589
    Self.Log("[Lazy Panda] Destination: Dummy Holding") ; #DEBUG_LINE_NO:590
    Return LPDummyHoldingRef ; #DEBUG_LINE_NO:591
  Else
    Self.Log("[Lazy Panda] Destination: Unknown") ; #DEBUG_LINE_NO:593
    Return None ; #DEBUG_LINE_NO:594
  EndIf
EndFunction

Bool Function IsPlayerStealing(ObjectReference theLoot)
  Self.Log("[Lazy Panda] IsPlayerStealing called with loot: " + theLoot as String) ; #DEBUG_LINE_NO:601
  Faction currentOwner = theLoot.GetFactionOwner() ; #DEBUG_LINE_NO:602
  Self.Log("[Lazy Panda] Current Owner: " + currentOwner as String) ; #DEBUG_LINE_NO:603
  Return !(currentOwner == None || currentOwner == PlayerFaction) ; #DEBUG_LINE_NO:604
EndFunction

Bool Function IsPlayerAvailable()
  Self.Log("[Lazy Panda] IsPlayerAvailable called") ; #DEBUG_LINE_NO:610
  Return Game.IsActivateControlsEnabled() || Game.IsLookingControlsEnabled() ; #DEBUG_LINE_NO:611
EndFunction

Bool Function IsLootLoaded(ObjectReference theLoot)
  Self.Log("[Lazy Panda] IsLootLoaded called with loot: " + theLoot as String) ; #DEBUG_LINE_NO:617
  Return theLoot.Is3DLoaded() && !theLoot.IsDisabled() && !theLoot.IsDeleted() ; #DEBUG_LINE_NO:618
EndFunction

Float Function GetRadius()
  Self.Log("[Lazy Panda] GetRadius called") ; #DEBUG_LINE_NO:624
  Float fSearchRadius = 0.0 ; #DEBUG_LINE_NO:625
  If bIsContainerSpace ; #DEBUG_LINE_NO:626
    fSearchRadius = Game.GetGameSettingFloat("fMaxShipTransferDistance") ; #DEBUG_LINE_NO:627
  Else
    fSearchRadius = LPSetting_Radius.GetValue() ; #DEBUG_LINE_NO:629
  EndIf
  Self.Log("[Lazy Panda] Search Radius: " + fSearchRadius as String) ; #DEBUG_LINE_NO:631
  Return fSearchRadius ; #DEBUG_LINE_NO:632
EndFunction
