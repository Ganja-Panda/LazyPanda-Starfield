ScriptName LZP:Looting:LootEffectScript Extends ActiveMagicEffect hidden

;-- Variables ---------------------------------------

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
  Keyword Property SpaceshipInventoryContainer Auto Const
  Armor Property LP_Skin_Naked_NOTPLAYABLE Auto Const mandatory
  Race Property HumanRace Auto Const mandatory
  Race Property SFBGS001_HumanRace Auto Const
  Race Property SFBGS003_HumanRace Auto Const
EndGroup

Group DestinationLocations
  ObjectReference Property PlayerRef Auto Const
  ObjectReference Property LodgeSafeRef Auto Const
  ObjectReference Property LPDummyHoldingRef Auto Const
  ReferenceAlias Property PlayerHomeShip Auto Const mandatory
EndGroup

Group NoLootLocations
  Location Property CityNewAtlantisLodgeLocation Auto Const mandatory
  Location Property CityAkilaCityPlayerHouseNiceLocation Auto Const mandatory
  Location Property CityAkilaCityPlayerHousePoorLocation Auto Const mandatory
  Location Property CityNeonTradeTowerPlayerHousingLocation Auto Const mandatory
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

Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
  Debug.Trace("[Lazy Panda] OnEffectStart triggered", 0) ; #DEBUG_LINE_NO:102
  Self.StartTimer(lootTimerDelay, lootTimerID) ; #DEBUG_LINE_NO:103
EndEvent

Event OnTimer(Int aiTimerID)
  Debug.Trace("[Lazy Panda] OnTimer triggered with TimerID: " + aiTimerID as String, 0) ; #DEBUG_LINE_NO:107
  If aiTimerID == lootTimerID && Game.GetPlayer().HasPerk(ActivePerk) ; #DEBUG_LINE_NO:108
    Self.ExecuteLooting() ; #DEBUG_LINE_NO:109
  EndIf
EndEvent

Function ExecuteLooting()
  Debug.Trace("[Lazy Panda] ExecuteLooting called", 0) ; #DEBUG_LINE_NO:114
  Self.LocateLoot(ActiveLootList) ; #DEBUG_LINE_NO:115
  Self.StartTimer(lootTimerDelay, lootTimerID) ; #DEBUG_LINE_NO:116
EndFunction

Function LocateLoot(FormList LootList)
  Debug.Trace("[Lazy Panda] LocateLoot called with LootList: " + LootList as String, 0) ; #DEBUG_LINE_NO:120
  ObjectReference[] lootArray = None ; #DEBUG_LINE_NO:121
  lootArray = new ObjectReference[0] ; #DEBUG_LINE_NO:122
  If bIsMultipleKeyword ; #DEBUG_LINE_NO:123
    Self.LocateLootByKeyword(LootList) ; #DEBUG_LINE_NO:124
  ElseIf bIsKeyword
    lootArray = PlayerRef.FindAllReferencesWithKeyword(LootList.GetAt(0), Self.GetRadius()) ; #DEBUG_LINE_NO:126
  Else
    lootArray = PlayerRef.FindAllReferencesOfType(LootList as Form, Self.GetRadius()) ; #DEBUG_LINE_NO:128
  EndIf
  If lootArray.Length > 0 ; #DEBUG_LINE_NO:130
    Self.ProcessLoot(lootArray) ; #DEBUG_LINE_NO:131
  EndIf
EndFunction

Function LocateLootByKeyword(FormList LootList)
  Debug.Trace("[Lazy Panda] LocateLootByKeyword called with LootList: " + LootList as String, 0) ; #DEBUG_LINE_NO:136
  ObjectReference[] lootArray = new ObjectReference[0] ; #DEBUG_LINE_NO:137
  Int index = 0 ; #DEBUG_LINE_NO:138
  While index < LootList.GetSize() ; #DEBUG_LINE_NO:139
    lootArray = PlayerRef.FindAllReferencesWithKeyword(LootList.GetAt(index), Self.GetRadius()) ; #DEBUG_LINE_NO:140
    If lootArray.Length > 0 && !(lootArray.Length == 1 && lootArray[0] == PlayerRef) ; #DEBUG_LINE_NO:141
      Self.ProcessLoot(lootArray) ; #DEBUG_LINE_NO:142
    EndIf
    index += 1 ; #DEBUG_LINE_NO:144
  EndWhile
EndFunction

Function ProcessLoot(ObjectReference[] theLootArray)
  Debug.Trace("[Lazy Panda] ProcessLoot called with lootArray of length: " + theLootArray.Length as String, 0) ; #DEBUG_LINE_NO:149
  theLooterRef = PlayerRef ; #DEBUG_LINE_NO:150
  Int index = 0 ; #DEBUG_LINE_NO:151
  While index < theLootArray.Length && Self.IsPlayerAvailable() ; #DEBUG_LINE_NO:152
    ObjectReference currentLoot = theLootArray[index] ; #DEBUG_LINE_NO:153
    If currentLoot ; #DEBUG_LINE_NO:154
      Debug.Trace("[Lazy Panda] Processing loot: " + currentLoot as String, 0) ; #DEBUG_LINE_NO:155
      If Self.IsCorpse(currentLoot) ; #DEBUG_LINE_NO:156
        If bLootDeadActor && Self.CanTakeLoot(currentLoot) ; #DEBUG_LINE_NO:157
          Debug.Trace("[Lazy Panda] Looting Dead Actor", 0) ; #DEBUG_LINE_NO:158
          Self.ProcessCorpse(currentLoot, theLooterRef) ; #DEBUG_LINE_NO:159
        EndIf
      ElseIf bIsContainer && Self.CanTakeLoot(currentLoot) ; #DEBUG_LINE_NO:161
        Debug.Trace("[Lazy Panda] Looting Container", 0) ; #DEBUG_LINE_NO:162
        Self.ProcessContainer(currentLoot, theLooterRef) ; #DEBUG_LINE_NO:163
      ElseIf bIsContainerSpace && Self.CanTakeLoot(currentLoot) ; #DEBUG_LINE_NO:164
        Debug.Trace("[Lazy Panda] Looting Spaceship Container", 0) ; #DEBUG_LINE_NO:165
        If currentLoot.HasKeyword(SpaceshipInventoryContainer) ; #DEBUG_LINE_NO:166
          currentLoot = currentLoot.GetCurrentShipRef() as ObjectReference ; #DEBUG_LINE_NO:167
        EndIf
        theLooterRef = PlayerHomeShip.GetRef() ; #DEBUG_LINE_NO:169
        Self.ProcessContainer(currentLoot, theLooterRef) ; #DEBUG_LINE_NO:170
      ElseIf bIsActivatedBySpell && Self.CanTakeLoot(currentLoot) && ActiveLootSpell != None ; #DEBUG_LINE_NO:171
        Debug.Trace("[Lazy Panda] Looting Activated By Spell", 0) ; #DEBUG_LINE_NO:172
        ActiveLootSpell.RemoteCast(PlayerRef, PlayerRef as Actor, currentLoot) ; #DEBUG_LINE_NO:173
      ElseIf bIsActivator && Self.CanTakeLoot(currentLoot) ; #DEBUG_LINE_NO:174
        Debug.Trace("[Lazy Panda] Looting Activator", 0) ; #DEBUG_LINE_NO:175
        currentLoot.Activate(theLooterRef, False) ; #DEBUG_LINE_NO:176
      ElseIf Self.CanTakeLoot(currentLoot) ; #DEBUG_LINE_NO:177
        Self.GetDestRef().AddItem(currentLoot as Form, -1, False) ; #DEBUG_LINE_NO:178
      EndIf
    EndIf
    index += 1 ; #DEBUG_LINE_NO:181
  EndWhile
EndFunction

Function ProcessCorpse(ObjectReference theCorpse, ObjectReference theLooter)
  Debug.Trace("[Lazy Panda] ProcessCorpse called with corpse: " + theCorpse as String, 0) ; #DEBUG_LINE_NO:187
  Self.bTakeAll = Self.LPSetting_ContTakeAll.GetValue() as Bool ; #DEBUG_LINE_NO:188
  Actor corpseActor = theCorpse as Actor ; #DEBUG_LINE_NO:189
  If corpseActor ; #DEBUG_LINE_NO:190
    Race corpseRace = corpseActor.GetRace() ; #DEBUG_LINE_NO:191
    Bool bIsShatteredSpaceLoaded = Game.IsPluginInstalled("ShatteredSpace.esm") != (-1) as Bool ; #DEBUG_LINE_NO:192
    If bIsShatteredSpaceLoaded ; #DEBUG_LINE_NO:193
      If corpseRace == Self.HumanRace || corpseRace == Self.SFBGS001_HumanRace || corpseRace == Self.SFBGS003_HumanRace ; #DEBUG_LINE_NO:194
        corpseActor.UnequipAll() ; #DEBUG_LINE_NO:195
        corpseActor.EquipItem(Self.LP_Skin_Naked_NOTPLAYABLE as Form, False, False) ; #DEBUG_LINE_NO:196
      EndIf
    ElseIf corpseRace == Self.HumanRace ; #DEBUG_LINE_NO:198
      corpseActor.UnequipAll() ; #DEBUG_LINE_NO:199
      corpseActor.EquipItem(Self.LP_Skin_Naked_NOTPLAYABLE as Form, False, False) ; #DEBUG_LINE_NO:200
    EndIf
  EndIf
  Utility.Wait(0.5) ; #DEBUG_LINE_NO:203
  If Self.bTakeAll ; #DEBUG_LINE_NO:204
    theCorpse.RemoveAllItems(Self.GetDestRef(), False, False) ; #DEBUG_LINE_NO:205
  Else
    Self.ProcessFilteredContainerItems(theCorpse, theLooter) ; #DEBUG_LINE_NO:207
  EndIf
  Self.RemoveCorpse(theCorpse) ; #DEBUG_LINE_NO:209
EndFunction

Function RemoveCorpse(ObjectReference theCorpse)
  Debug.Trace("[Lazy Panda] RemoveCorpse called with corpse: " + theCorpse as String, 0) ; #DEBUG_LINE_NO:213
  Bool bRemoveCorpse = LPSetting_RemoveCorpses.GetValue() as Bool ; #DEBUG_LINE_NO:214
  If bRemoveCorpse ; #DEBUG_LINE_NO:215
    theCorpse.DisableNoWait(True) ; #DEBUG_LINE_NO:216
  EndIf
EndFunction

Function ProcessContainer(ObjectReference theContainer, ObjectReference theLooter)
  Debug.Trace("[Lazy Panda] ProcessContainer called with container: " + theContainer as String, 0) ; #DEBUG_LINE_NO:221
  bStealingIsHostile = LPSetting_StealingIsHostile.GetValue() as Bool ; #DEBUG_LINE_NO:222
  bTakeAll = LPSetting_ContTakeAll.GetValue() as Bool ; #DEBUG_LINE_NO:223
  Bool bAutoUnlock = LPSetting_AutoUnlock.GetValue() as Bool ; #DEBUG_LINE_NO:224
  If bAutoUnlock && theContainer.IsLocked() ; #DEBUG_LINE_NO:225
    Self.TryUnlock(theContainer) ; #DEBUG_LINE_NO:226
  ElseIf theContainer.IsLocked() && !bAutoUnlock ; #DEBUG_LINE_NO:227
    Debug.Trace("[Lazy Panda] Container Ignored: Locked, AutoUnlock is disabled", 0) ; #DEBUG_LINE_NO:228
    Return  ; #DEBUG_LINE_NO:229
  EndIf
  If bTakeAll ; #DEBUG_LINE_NO:231
    theContainer.RemoveAllItems(Self.GetDestRef(), False, bStealingIsHostile) ; #DEBUG_LINE_NO:232
  ElseIf !bTakeAll ; #DEBUG_LINE_NO:233
    Self.ProcessFilteredContainerItems(theContainer, theLooter) ; #DEBUG_LINE_NO:234
  EndIf
EndFunction

Function ProcessFilteredContainerItems(ObjectReference theContainer, ObjectReference theLooter)
  Debug.Trace("[Lazy Panda] ProcessFilteredContainerItems called with container: " + theContainer as String, 0) ; #DEBUG_LINE_NO:239
  Int index = 0 ; #DEBUG_LINE_NO:240
  While index < LPSystem_Looting_Lists.GetSize() ; #DEBUG_LINE_NO:241
    FormList currentList = LPSystem_Looting_Lists.GetAt(index) as FormList ; #DEBUG_LINE_NO:242
    GlobalVariable currentGlobal = LPSystem_Looting_Globals.GetAt(index) as GlobalVariable ; #DEBUG_LINE_NO:243
    If currentGlobal.GetValue() == 1.0 ; #DEBUG_LINE_NO:244
      theContainer.RemoveItem(currentList as Form, -1, True, Self.GetDestRef()) ; #DEBUG_LINE_NO:245
    EndIf
    index += 1 ; #DEBUG_LINE_NO:247
  EndWhile
EndFunction

Bool Function CanTakeLoot(ObjectReference theLoot)
  Debug.Trace("[Lazy Panda] CanTakeLoot called with loot: " + theLoot as String, 0) ; #DEBUG_LINE_NO:253
  Bool bCanTake = True ; #DEBUG_LINE_NO:254
  bAllowStealing = LPSetting_AllowStealing.GetValue() as Bool ; #DEBUG_LINE_NO:255
  ObjectReference theContainer = theLoot.GetContainer() ; #DEBUG_LINE_NO:256
  Self.TakeOwnership(theLoot) ; #DEBUG_LINE_NO:257
  Debug.Trace("[Lazy Panda] Container: " + theContainer as String, 0) ; #DEBUG_LINE_NO:258
  If theContainer != None ; #DEBUG_LINE_NO:259
    Debug.Trace("[Lazy Panda] Container Is Owned: " + Self.IsOwned(theContainer) as String, 0) ; #DEBUG_LINE_NO:260
    bCanTake = False ; #DEBUG_LINE_NO:261
  ElseIf !Self.IsLootLoaded(theLoot) ; #DEBUG_LINE_NO:262
    Debug.Trace("[Lazy Panda] Loot Not Loaded", 0) ; #DEBUG_LINE_NO:263
    bCanTake = False ; #DEBUG_LINE_NO:264
  ElseIf theLoot.IsQuestItem() ; #DEBUG_LINE_NO:265
    Debug.Trace("[Lazy Panda] Quest Item", 0) ; #DEBUG_LINE_NO:266
    bCanTake = False ; #DEBUG_LINE_NO:267
  ElseIf (PlayerRef as Actor).WouldBeStealing(theLoot) && !bAllowStealing ; #DEBUG_LINE_NO:268
    Debug.Trace("[Lazy Panda] Would Be Stealing", 0) ; #DEBUG_LINE_NO:269
    bCanTake = False ; #DEBUG_LINE_NO:270
  ElseIf Self.IsPlayerStealing(theLoot) && !bAllowStealing ; #DEBUG_LINE_NO:271
    Debug.Trace("[Lazy Panda] Is Stealing", 0) ; #DEBUG_LINE_NO:272
    bCanTake = False ; #DEBUG_LINE_NO:273
  ElseIf theLoot.IsInLocation(CityNewAtlantisLodgeLocation) ; #DEBUG_LINE_NO:274
    Debug.Trace("[Lazy Panda] In Lodge", 0) ; #DEBUG_LINE_NO:275
    bCanTake = False ; #DEBUG_LINE_NO:276
  ElseIf theLoot.IsInLocation(CityAkilaCityPlayerHouseNiceLocation) ; #DEBUG_LINE_NO:277
    Debug.Trace("[Lazy Panda] In Nice House", 0) ; #DEBUG_LINE_NO:278
    bCanTake = False ; #DEBUG_LINE_NO:279
  ElseIf theLoot.IsInLocation(CityAkilaCityPlayerHousePoorLocation) ; #DEBUG_LINE_NO:280
    Debug.Trace("[Lazy Panda] In Poor House", 0) ; #DEBUG_LINE_NO:281
    bCanTake = False ; #DEBUG_LINE_NO:282
  ElseIf theLoot.IsInLocation(CityNeonTradeTowerPlayerHousingLocation) ; #DEBUG_LINE_NO:283
    Debug.Trace("[Lazy Panda] In Tower", 0) ; #DEBUG_LINE_NO:284
    bCanTake = False ; #DEBUG_LINE_NO:285
  ElseIf theLoot.IsInLocation(playerShipInterior.GetLocation()) && !Self.CanLootShip() ; #DEBUG_LINE_NO:286
    Debug.Trace("[Lazy Panda] In Player Ship", 0) ; #DEBUG_LINE_NO:287
    bCanTake = False ; #DEBUG_LINE_NO:288
  EndIf
  If bCanTake == True ; #DEBUG_LINE_NO:290
    Debug.Trace("[Lazy Panda] Can Take: " + bCanTake as String, 0) ; #DEBUG_LINE_NO:291
    If theLoot.IsInLocation(CityNewAtlantisLodgeLocation) || theLoot.IsInLocation(CityAkilaCityPlayerHouseNiceLocation) || theLoot.IsInLocation(CityAkilaCityPlayerHousePoorLocation) || theLoot.IsInLocation(CityNeonTradeTowerPlayerHousingLocation) || theLoot.IsInLocation(playerShipInterior.GetLocation()) && !Self.CanLootShip() ; #DEBUG_LINE_NO:293
      theLoot.SetActorRefOwner(PlayerRef as Actor, True) ; #DEBUG_LINE_NO:294
    EndIf
  EndIf
  Debug.Trace("[Lazy Panda] Can Take: " + bCanTake as String, 0) ; #DEBUG_LINE_NO:297
  Return bCanTake ; #DEBUG_LINE_NO:298
EndFunction

Function TakeOwnership(ObjectReference theLoot)
  Debug.Trace("[Lazy Panda] TakeOwnership called with loot: " + theLoot as String, 0) ; #DEBUG_LINE_NO:303
  Self.bAllowStealing = Self.LPSetting_AllowStealing.GetValue() as Bool ; #DEBUG_LINE_NO:304
  Self.bStealingIsHostile = Self.LPSetting_StealingIsHostile.GetValue() as Bool ; #DEBUG_LINE_NO:305
  If Self.bAllowStealing ; #DEBUG_LINE_NO:306
    If !Self.bStealingIsHostile && Self.IsOwned(theLoot) ; #DEBUG_LINE_NO:307
      theLoot.SetActorRefOwner(PlayerRef as Actor, True) ; #DEBUG_LINE_NO:308
    EndIf
  EndIf
EndFunction

Bool Function CanLootShip()
  Debug.Trace("[Lazy Panda] CanLootShip called", 0) ; #DEBUG_LINE_NO:315
  Return Self.LPSetting_AllowLootingShip.GetValue() as Bool ; #DEBUG_LINE_NO:316
EndFunction

Bool Function IsOwned(ObjectReference theLoot)
  Debug.Trace("[Lazy Panda] IsOwned called with loot: " + theLoot as String, 0) ; #DEBUG_LINE_NO:321
  Return (PlayerRef as Actor).WouldBeStealing(theLoot) || Self.IsPlayerStealing(theLoot) || theLoot.HasOwner() ; #DEBUG_LINE_NO:322
EndFunction

Function TryUnlock(ObjectReference theContainer)
  Debug.Trace("[Lazy Panda] TryUnlock called with container: " + theContainer as String, 0) ; #DEBUG_LINE_NO:327
  Bool bLockSkillCheck = Self.LPSetting_AutoUnlockSkillCheck.GetValue() as Bool ; #DEBUG_LINE_NO:328
  Debug.Trace("[Lazy Panda] Lock Skill Check: " + bLockSkillCheck as String, 0) ; #DEBUG_LINE_NO:329
  Bool bIsOwned = theContainer.HasOwner() ; #DEBUG_LINE_NO:330
  Debug.Trace("[Lazy Panda] Is Owned: " + bIsOwned as String, 0) ; #DEBUG_LINE_NO:331
  Int iLockLevel = theContainer.GetLockLevel() ; #DEBUG_LINE_NO:332
  Debug.Trace("[Lazy Panda] Lock Level: " + iLockLevel as String, 0) ; #DEBUG_LINE_NO:333
  Int iRequiresKey = Self.LockLevel_RequiresKey.GetValue() as Int ; #DEBUG_LINE_NO:334
  Debug.Trace("[Lazy Panda] Requires Key: " + iRequiresKey as String, 0) ; #DEBUG_LINE_NO:335
  Int iInaccessible = Self.LockLevel_Inaccessible.GetValue() as Int ; #DEBUG_LINE_NO:336
  If iLockLevel == iInaccessible ; #DEBUG_LINE_NO:337
    Self.HandleInaccessibleLock() ; #DEBUG_LINE_NO:338
    Return  ; #DEBUG_LINE_NO:339
  EndIf
  If iLockLevel == iRequiresKey ; #DEBUG_LINE_NO:341
    Self.HandleRequiresKey(theContainer, bIsOwned) ; #DEBUG_LINE_NO:342
    Return  ; #DEBUG_LINE_NO:343
  EndIf
  Self.HandleDigipickUnlock(theContainer, bIsOwned, bLockSkillCheck) ; #DEBUG_LINE_NO:345
EndFunction

Function HandleInaccessibleLock()
  Debug.Trace("[Lazy Panda] HandleInaccessibleLock called", 0) ; #DEBUG_LINE_NO:350
EndFunction

Function HandleRequiresKey(ObjectReference theContainer, Bool bIsOwned)
  Debug.Trace("[Lazy Panda] HandleRequiresKey called with container: " + theContainer as String, 0) ; #DEBUG_LINE_NO:355
  Key theKey = theContainer.GetKey() ; #DEBUG_LINE_NO:356
  Self.FindKey(theKey) ; #DEBUG_LINE_NO:357
  If PlayerRef.GetItemCount(theKey as Form) == 0 ; #DEBUG_LINE_NO:358
    Debug.Trace("[Lazy Panda] Key Found", 0) ; #DEBUG_LINE_NO:359
    Debug.Trace("[Lazy Panda] Locked Container Ignored: Requires Key", 0) ; #DEBUG_LINE_NO:360
  ElseIf PlayerRef.GetItemCount(theKey as Form) > 0 ; #DEBUG_LINE_NO:361
    Debug.Trace("[Lazy Panda] Key Found", 0) ; #DEBUG_LINE_NO:362
    theContainer.Unlock(bIsOwned) ; #DEBUG_LINE_NO:363
    Debug.Trace("[Lazy Panda] Container Unlocked: With Key", 0) ; #DEBUG_LINE_NO:364
  EndIf
EndFunction

Function HandleDigipickUnlock(ObjectReference theContainer, Bool bIsOwned, Bool bLockSkillCheck)
  Debug.Trace("[Lazy Panda] HandleDigipickUnlock called with container: " + theContainer as String, 0) ; #DEBUG_LINE_NO:370
  If PlayerRef.GetItemCount(Self.Digipick as Form) == 0 ; #DEBUG_LINE_NO:371
    Self.FindDigipick() ; #DEBUG_LINE_NO:372
  EndIf
  If PlayerRef.GetItemCount(Self.Digipick as Form) > 0 ; #DEBUG_LINE_NO:374
    If !bLockSkillCheck ; #DEBUG_LINE_NO:375
      theContainer.Unlock(bIsOwned) ; #DEBUG_LINE_NO:376
    ElseIf bLockSkillCheck && Self.CanUnlock(theContainer) ; #DEBUG_LINE_NO:377
      theContainer.Unlock(bIsOwned) ; #DEBUG_LINE_NO:378
    ElseIf bLockSkillCheck && !Self.CanUnlock(theContainer) ; #DEBUG_LINE_NO:379
      Debug.Trace("[Lazy Panda] Locked Container Ignored: Failed Skill Check", 0) ; #DEBUG_LINE_NO:380
    EndIf
    If !theContainer.IsLocked() ; #DEBUG_LINE_NO:382
      Game.RewardPlayerXP(10, False) ; #DEBUG_LINE_NO:383
      PlayerRef.RemoveItem(Self.Digipick as Form, 1, False, None) ; #DEBUG_LINE_NO:384
      Debug.Trace("[Lazy Panda] Container Unlocked: With Digipick", 0) ; #DEBUG_LINE_NO:385
    EndIf
  Else
    Debug.Trace("[Lazy Panda] Locked Container Ignored: No Digipick", 0) ; #DEBUG_LINE_NO:388
  EndIf
EndFunction

Function FindDigipick()
  Debug.Trace("[Lazy Panda] FindDigipick called", 0) ; #DEBUG_LINE_NO:394
  If Self.LPDummyHoldingRef.GetItemCount(Self.Digipick as Form) > 0 ; #DEBUG_LINE_NO:395
    Debug.Trace("[Lazy Panda] Digipick Found: In Dummy Holding", 0) ; #DEBUG_LINE_NO:396
    Self.LPDummyHoldingRef.RemoveItem(Self.Digipick as Form, -1, True, PlayerRef) ; #DEBUG_LINE_NO:397
  ElseIf Self.LodgeSafeRef.GetItemCount(Self.Digipick as Form) > 0 ; #DEBUG_LINE_NO:398
    Debug.Trace("[Lazy Panda] Digipick Found: In Lodge Safe", 0) ; #DEBUG_LINE_NO:399
    Self.LodgeSafeRef.RemoveItem(Self.Digipick as Form, -1, True, PlayerRef) ; #DEBUG_LINE_NO:400
  EndIf
EndFunction

Function FindKey(Key theKey)
  Debug.Trace("[Lazy Panda] FindKey called with key: " + theKey as String, 0) ; #DEBUG_LINE_NO:406
  If Self.LPDummyHoldingRef.GetItemCount(theKey as Form) > 0 ; #DEBUG_LINE_NO:407
    Debug.Trace("[Lazy Panda] Key Found: In Dummy Holding", 0) ; #DEBUG_LINE_NO:408
    Self.LPDummyHoldingRef.RemoveItem(theKey as Form, -1, True, PlayerRef) ; #DEBUG_LINE_NO:409
  ElseIf Self.LodgeSafeRef.GetItemCount(theKey as Form) > 0 ; #DEBUG_LINE_NO:410
    Debug.Trace("[Lazy Panda] Key Found: In Lodge Safe", 0) ; #DEBUG_LINE_NO:411
    Self.LodgeSafeRef.RemoveItem(theKey as Form, -1, True, PlayerRef) ; #DEBUG_LINE_NO:412
  EndIf
EndFunction

Bool Function CanUnlock(ObjectReference theContainer)
  Debug.Trace("[Lazy Panda] CanUnlock called with container: " + theContainer as String, 0) ; #DEBUG_LINE_NO:418
  Bool bCanUnlock = False ; #DEBUG_LINE_NO:419
  Bool bCanUnlockAdvanced = Self.Perk_CND_AdvancedLocksCheck.IsTrue(PlayerRef, None) ; #DEBUG_LINE_NO:420
  Bool bCanUnlockExpert = Self.Perk_CND_ExpertLocksCheck.IsTrue(PlayerRef, None) ; #DEBUG_LINE_NO:421
  Bool bCanUnlockMaster = Self.Perk_CND_MasterLocksCheck.IsTrue(PlayerRef, None) ; #DEBUG_LINE_NO:422
  Int iLockLevel = theContainer.GetLockLevel() ; #DEBUG_LINE_NO:423
  Int iNovice = Self.LockLevel_Novice.GetValue() as Int ; #DEBUG_LINE_NO:424
  Int iAdvanced = Self.LockLevel_Advanced.GetValue() as Int ; #DEBUG_LINE_NO:425
  Int iExpert = Self.LockLevel_Expert.GetValue() as Int ; #DEBUG_LINE_NO:426
  Int iMaster = Self.LockLevel_Master.GetValue() as Int ; #DEBUG_LINE_NO:427
  Debug.Trace("[Lazy Panda] Lock Level: " + iLockLevel as String, 0) ; #DEBUG_LINE_NO:428
  Debug.Trace("[Lazy Panda] Can Unlock Advanced: " + bCanUnlockAdvanced as String, 0) ; #DEBUG_LINE_NO:429
  Debug.Trace("[Lazy Panda] Can Unlock Expert: " + bCanUnlockExpert as String, 0) ; #DEBUG_LINE_NO:430
  Debug.Trace("[Lazy Panda] Can Unlock Master: " + bCanUnlockMaster as String, 0) ; #DEBUG_LINE_NO:431
  If iLockLevel == iNovice ; #DEBUG_LINE_NO:432
    bCanUnlock = True ; #DEBUG_LINE_NO:433
  ElseIf iLockLevel == iAdvanced && bCanUnlockAdvanced ; #DEBUG_LINE_NO:434
    bCanUnlock = True ; #DEBUG_LINE_NO:435
  ElseIf iLockLevel == iExpert && bCanUnlockExpert ; #DEBUG_LINE_NO:436
    bCanUnlock = True ; #DEBUG_LINE_NO:437
  ElseIf iLockLevel == iMaster && bCanUnlockMaster ; #DEBUG_LINE_NO:438
    bCanUnlock = True ; #DEBUG_LINE_NO:439
  EndIf
  Debug.Trace("[Lazy Panda] Can Unlock: " + bCanUnlock as String, 0) ; #DEBUG_LINE_NO:441
  Return bCanUnlock ; #DEBUG_LINE_NO:442
EndFunction

Bool Function IsCorpse(ObjectReference theCorpse)
  Debug.Trace("[Lazy Panda] IsCorpse called with corpse: " + theCorpse as String, 0) ; #DEBUG_LINE_NO:447
  Bool IsCorpse = False ; #DEBUG_LINE_NO:448
  Actor theCorpseActor = theCorpse as Actor ; #DEBUG_LINE_NO:449
  If theCorpse as Bool && theCorpseActor.IsDead() ; #DEBUG_LINE_NO:450
    Debug.Trace("[Lazy Panda] Is Dead: " + theCorpseActor.IsDead() as String, 0) ; #DEBUG_LINE_NO:451
    IsCorpse = True ; #DEBUG_LINE_NO:452
  EndIf
  Debug.Trace("[Lazy Panda] Is Corpse: " + IsCorpse as String, 0) ; #DEBUG_LINE_NO:454
  Return IsCorpse ; #DEBUG_LINE_NO:455
EndFunction

ObjectReference Function GetDestRef()
  Debug.Trace("[Lazy Panda] GetDestRef called", 0) ; #DEBUG_LINE_NO:460
  Int currentDest = Self.LPSetting_SendTo.GetValue() as Int ; #DEBUG_LINE_NO:461
  If currentDest == 1 ; #DEBUG_LINE_NO:462
    Debug.Trace("[Lazy Panda] Destination: Player", 0) ; #DEBUG_LINE_NO:463
    Return PlayerRef ; #DEBUG_LINE_NO:464
  ElseIf currentDest == 2 ; #DEBUG_LINE_NO:465
    Debug.Trace("[Lazy Panda] Destination: Lodge Safe", 0) ; #DEBUG_LINE_NO:466
    Return Self.LodgeSafeRef ; #DEBUG_LINE_NO:467
  ElseIf currentDest == 3 ; #DEBUG_LINE_NO:468
    Debug.Trace("[Lazy Panda] Destination: Dummy Holding", 0) ; #DEBUG_LINE_NO:469
    Return Self.LPDummyHoldingRef ; #DEBUG_LINE_NO:470
  EndIf
EndFunction

Bool Function IsPlayerStealing(ObjectReference theLoot)
  Debug.Trace("[Lazy Panda] IsPlayerStealing called with loot: " + theLoot as String, 0) ; #DEBUG_LINE_NO:476
  Faction currentOwner = theLoot.GetFactionOwner() ; #DEBUG_LINE_NO:477
  Debug.Trace("[Lazy Panda] Current Owner: " + currentOwner as String, 0) ; #DEBUG_LINE_NO:478
  Return !(currentOwner == None || currentOwner == Self.PlayerFaction) ; #DEBUG_LINE_NO:479
EndFunction

Bool Function IsPlayerAvailable()
  Debug.Trace("[Lazy Panda] IsPlayerAvailable called", 0) ; #DEBUG_LINE_NO:484
  Return Game.IsActivateControlsEnabled() || Game.IsLookingControlsEnabled() ; #DEBUG_LINE_NO:485
EndFunction

Bool Function IsLootLoaded(ObjectReference theLoot)
  Debug.Trace("[Lazy Panda] IsLootLoaded called with loot: " + theLoot as String, 0) ; #DEBUG_LINE_NO:490
  Return theLoot.Is3DLoaded() && !theLoot.IsDisabled() && !theLoot.IsDeleted() ; #DEBUG_LINE_NO:491
EndFunction

Float Function GetRadius()
  Debug.Trace("[Lazy Panda] GetRadius called", 0) ; #DEBUG_LINE_NO:496
  Float fSearchRadius = 0.0 ; #DEBUG_LINE_NO:497
  Debug.Trace("[Lazy Panda] Is Container Space: " + Self.bIsContainerSpace as String, 0) ; #DEBUG_LINE_NO:498
  If Self.bIsContainerSpace ; #DEBUG_LINE_NO:499
    fSearchRadius = Game.GetGameSettingFloat("fMaxShipTransferDistance") ; #DEBUG_LINE_NO:500
  Else
    fSearchRadius = Self.LPSetting_Radius.GetValue() ; #DEBUG_LINE_NO:502
  EndIf
  Debug.Trace("[Lazy Panda] Search Radius: " + fSearchRadius as String, 0) ; #DEBUG_LINE_NO:504
  Return fSearchRadius ; #DEBUG_LINE_NO:505
EndFunction
