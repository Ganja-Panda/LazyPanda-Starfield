;======================================================================
; Script: LZP:Looting:LootEffectScript
; Description: This ActiveMagicEffect script manages the looting process.
; It locates loot based on various criteria (keywords, container types, etc.),
; processes the loot (including corpses, containers, and spell-activated objects),
; and handles container unlocking via keys or Digipick.
; Debug logging is integrated to assist with troubleshooting.
;======================================================================

ScriptName LZP:Looting:LootEffectScript Extends ActiveMagicEffect hidden

;======================================================================
; PROPERTY GROUPS
;======================================================================

;-- Effect-Specific Mandatory Properties --
; Contains the essential properties needed for the loot effect.
Group EffectSpecific_Mandatory
    Perk Property ActivePerk Auto Const mandatory              ; Perk required for activating the loot effect
    FormList Property ActiveLootList Auto Const mandatory        ; List of forms representing potential loot targets
EndGroup

;-- Effect-Specific Optional Properties --
; Contains additional optional properties.
Group EffectSpecific_Optional
    Spell Property ActiveLootSpell Auto Const                    ; Optional spell used to trigger looting
EndGroup

;-- Loot Method Configuration --
; Booleans to define the method used for looting.
Group EffectSpecific_LootMethod
    Bool Property bIsActivator = False Auto                        ; Is loot triggered by an activator?
    Bool Property bIsContainer = False Auto                        ; Is loot triggered by a container?
    Bool Property bLootDeadActor = False Auto                      ; Should the effect loot dead actors?
    Bool Property bIsActivatedBySpell = False Auto                 ; Is looting activated via a spell?
    Bool Property bIsContainerSpace = False Auto                   ; Is the loot coming from a spaceship container?
EndGroup

;-- Form Type Configuration --
; Booleans to determine whether to use keyword-based searches.
Group EffectSpecific_FormType
    Bool Property bIsKeyword = False Auto                          ; Use a single keyword to locate loot?
    Bool Property bIsMultipleKeyword = False Auto                  ; Use multiple keywords to locate loot?
EndGroup

;-- Settings Autofill --
; Global variables that control looting settings such as search radius,
; stealing permissions, corpse removal, destination, and container behavior.
Group Settings_Autofill
    GlobalVariable Property LPSetting_Radius Auto Const          ; Global setting for loot search radius
    GlobalVariable Property LPSetting_AllowStealing Auto Const      ; Allow stealing items?
    GlobalVariable Property LPSetting_StealingIsHostile Auto Const    ; Is stealing considered hostile?
    GlobalVariable Property LPSetting_RemoveCorpses Auto Const        ; Remove corpses after looting?
    GlobalVariable Property LPSetting_SendTo Auto Const             ; Destination setting for looted items
    GlobalVariable Property LPSetting_ContTakeAll Auto Const          ; Loot all items from a container?
    GlobalVariable Property LPSetting_AllowLootingShip Auto Const       ; Allow looting from ships?
EndGroup

;-- Auto Unlock Autofill --
; Properties and variables for automatic unlocking features.
Group AutoUnlock_Autofill
    GlobalVariable Property LPSetting_AutoUnlock Auto Const        ; Enable automatic unlocking?
    GlobalVariable Property LPSetting_AutoUnlockSkillCheck Auto Const ; Require a skill check for auto unlocking?
    GlobalVariable Property LockLevel_Advanced Auto Const            ; Lock level value for advanced difficulty
    GlobalVariable Property LockLevel_Expert Auto Const              ; Lock level value for expert difficulty
    GlobalVariable Property LockLevel_Inaccessible Auto Const        ; Lock level value for inaccessible locks
    GlobalVariable Property LockLevel_Master Auto Const              ; Lock level value for master difficulty
    GlobalVariable Property LockLevel_Novice Auto Const              ; Lock level value for novice difficulty
    GlobalVariable Property LockLevel_RequiresKey Auto Const         ; Value indicating the lock requires a key
    Faction Property PlayerFaction Auto Const                        ; The player's faction
    conditionform Property Perk_CND_AdvancedLocksCheck Auto Const    ; Condition form for advanced locks perk check
    conditionform Property Perk_CND_ExpertLocksCheck Auto Const      ; Condition form for expert locks perk check
    conditionform Property Perk_CND_MasterLocksCheck Auto Const      ; Condition form for master locks perk check
    MiscObject Property Digipick Auto Const                          ; The Digipick item used for unlocking containers
EndGroup

;-- List Autofill --
; Form lists used for looting system configuration and filtering.
Group List_Autofill
    FormList Property LPSystem_Looting_Globals Auto Const          ; Global looting configuration list
    FormList Property LPSystem_Looting_Lists Auto Const             ; Loot filtering lists for containers
EndGroup

;-- Miscellaneous Properties --
; Additional properties including keywords, races, and debug settings.
Group Misc
    Keyword Property SpaceshipInventoryContainer Auto Const         ; Keyword for spaceship inventory containers
    Keyword Property SQ_ShipDebrisKeyword Auto Const            ; Keyword for spaceship debris objects
    Keyword Property LPKeyword_Asteroid  Auto Const           ; Keyword for asteroid objects
    Armor Property LP_Skin_Naked_NOTPLAYABLE Auto Const mandatory       ; Armor for unequipping corpses (non-playable)
    Race Property HumanRace Auto Const mandatory                       ; Standard human race
    GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory         ; Global debug flag for logging
EndGroup

;-- Destination Locations --
; References for where looted items should be sent.
Group DestinationLocations
    ObjectReference Property PlayerRef Auto Const                     ; Reference to the player
    ObjectReference Property LodgeSafeRef Auto Const                    ; Reference to the lodge safe container
    ObjectReference Property LPDummyHoldingRef Auto Const               ; Reference to a dummy holding container for loot
    ReferenceAlias Property PlayerHomeShip Auto Const mandatory           ; Alias for the player's home ship
EndGroup

;-- No Loot Locations --
; Locations where loot should not be taken from.
Group NoLootLocations
    FormList Property LPFilter_NoLootLocations Auto Const               ; List of locations where looting is disabled
    LocationAlias Property playerShipInterior Auto Const mandatory        ; Alias for the player's ship interior location
EndGroup

;-- No Fill Settings --
; Timer and local flags for looting behavior.
Group NoFill
    Int Property lootTimerID = 1 Auto                                  ; Timer identifier for looting
    Float Property lootTimerDelay = 0.5 Auto                             ; Delay between loot cycles
    Bool Property bAllowStealing = False Auto                            ; Local flag to allow stealing
    Bool Property bStealingIsHostile = False Auto                         ; Local flag indicating hostile stealing
    Bool Property bTakeAll = False Auto                                   ; Local flag to loot all items from a container
    ObjectReference Property theLooterRef Auto                           ; Reference to the looter (typically the player)
EndGroup

;======================================================================
; DEBUG LOGGING HELPER FUNCTION
;======================================================================

; Logs a message if the global debug setting is enabled.
Function Log(String logMsg)
    If LPSystemUtil_Debug.GetValue() as Bool
        Debug.Trace(logMsg, 0)
    EndIf
EndFunction

;======================================================================
; SCRIPT VARIABLES
;======================================================================

Race SFBGS001_HumanRace
Race SFBGS003_HumanRace
Bool bIsShatteredSpaceLoaded
Bool bIsTrackerAllianceLoaded
;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnInit Event Handler --
; Called when the script is initialized. Initializes the Shattered Space and Tracker Alliance human races if the plugin is loaded.
Event OnInit()
    Log("[Lazy Panda] OnInit triggered")
    bIsShatteredSpaceLoaded = (Game.IsPluginInstalled("ShatteredSpace.esm") != (-1)) as Bool
    bIsTrackerAllianceLoaded = (Game.IsPluginInstalled("TrackerAlliance.esm") != (-1)) as Bool
    If bIsShatteredSpaceLoaded
        SFBGS001_HumanRace = Game.GetFormFromFile(0x01006529, "ShatteredSpace.esm") as Race
    ElseIf bIsTrackerAllianceLoaded
        SFBGS003_HumanRace = Game.GetFormFromFile(0x0000009D, "SFBGS003.esm") as Race  ; Replace 0x00067890 with the actual form ID
    EndIf
EndEvent

;-- OnEffectStart Event Handler --
; Called when the magic effect starts. Begins the loot timer.
Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
    Log("[Lazy Panda] OnEffectStart triggered")
    StartTimer(lootTimerDelay, lootTimerID)
EndEvent

;-- OnTimer Event Handler --
; Called when the loot timer expires. Checks if the player has the required perk before executing looting.
Event OnTimer(Int aiTimerID)
    Log("[Lazy Panda] OnTimer triggered with TimerID: " + aiTimerID as String)
    If aiTimerID == lootTimerID && Game.GetPlayer().HasPerk(ActivePerk)
        ExecuteLooting()
    EndIf
EndEvent

;======================================================================
; MAIN FUNCTIONS
;======================================================================

;-- ExecuteLooting Function --
; Main function that initiates the looting process and restarts the loot timer.
Function ExecuteLooting()
    Log("[Lazy Panda] ExecuteLooting called")
    LocateLoot(ActiveLootList)
    StartTimer(lootTimerDelay, lootTimerID)
EndFunction

;-- LocateLoot Function --
; Determines the appropriate method for locating loot based on the form type.
Function LocateLoot(FormList LootList)
    Log("[Lazy Panda] LocateLoot called with LootList: " + LootList as String)
    ObjectReference[] lootArray = None

    ; If using multiple keywords, call the dedicated function.
    If bIsMultipleKeyword
        LocateLootByKeyword(LootList)
    ; If a single keyword is used, find references using the first form in the list.
    ElseIf bIsKeyword
        lootArray = PlayerRef.FindAllReferencesWithKeyword(LootList.GetAt(0), GetRadius())
    ; Otherwise, find references by type.
    Else
        lootArray = PlayerRef.FindAllReferencesOfType(LootList as Form, GetRadius())
    EndIf

    ; If loot is found, process the loot array.
    If lootArray != None && lootArray.Length > 0
        ProcessLoot(lootArray)
    EndIf
EndFunction

;-- LocateLootByKeyword Function --
; Iterates through the loot list and finds references based on keywords.
Function LocateLootByKeyword(FormList LootList)
    Log("[Lazy Panda] LocateLootByKeyword called with LootList: " + LootList as String)
    ObjectReference[] lootArray
    Int index = 0
    While index < LootList.GetSize()
        lootArray = PlayerRef.FindAllReferencesWithKeyword(LootList.GetAt(index), GetRadius())
        ; Process loot if valid references are found and not just the player.
        If lootArray != None && lootArray.Length > 0 && !(lootArray.Length == 1 && lootArray[0] == PlayerRef)
            ProcessLoot(lootArray)
        EndIf
        index += 1
    EndWhile
EndFunction

;-- ProcessLoot Function --
; Processes an array of loot references, determining how to handle each based on its type.
Function ProcessLoot(ObjectReference[] theLootArray)
    Log("[Lazy Panda] ProcessLoot called with lootArray of length: " + theLootArray.Length as String)
    theLooterRef = PlayerRef   ; Default looter is the player
    Int index = 0
    While index < theLootArray.Length && IsPlayerAvailable()
        ObjectReference currentLoot = theLootArray[index]
        If currentLoot != None
            Log("[Lazy Panda] Processing loot: " + currentLoot as String)
            ; Determine how to process the loot based on its type:
            If IsCorpse(currentLoot)
               Actor corpseActor = currentLoot as Actor
                If bLootDeadActor && corpseActor.IsDead() && CanTakeLoot(currentLoot)
                    Log("[Lazy Panda] Looting Dead Actor")
                    ProcessCorpse(currentLoot, theLooterRef)
                EndIf
            ElseIf bIsContainer && CanTakeLoot(currentLoot)
                Log("[Lazy Panda] Looting Container")
                ProcessContainer(currentLoot, theLooterRef)
            ElseIf bIsContainerSpace && CanTakeLoot(currentLoot)
                Log("[Lazy Panda] Looting Spaceship Container")
                ; For spaceship containers, get the associated ship reference.
                If currentLoot.HasKeyword(SQ_ShipDebrisKeyword) || currentLoot.HasKeyword(LPKeyword_Asteroid) || currentLoot.HasKeyword(SpaceshipInventoryContainer)
                    currentLoot = currentLoot.GetCurrentShipRef() as ObjectReference
                EndIf
                theLooterRef = PlayerHomeShip.GetRef()
                ProcessContainer(currentLoot, theLooterRef)
            ElseIf bIsActivatedBySpell && CanTakeLoot(currentLoot) && ActiveLootSpell != None
                Log("[Lazy Panda] Looting Activated By Spell")
                ActiveLootSpell.RemoteCast(PlayerRef, PlayerRef as Actor, currentLoot)
            ElseIf bIsActivator && CanTakeLoot(currentLoot)
                Log("[Lazy Panda] Looting Activator")
                currentLoot.Activate(theLooterRef, False)
            ElseIf CanTakeLoot(currentLoot)
                ; If the loot is marked as a quest item, add it directly to the player.
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

;-- ProcessCorpse Function --
; Handles processing of a corpse object including unequipping, looting, and removal.
Function ProcessCorpse(ObjectReference theCorpse, ObjectReference theLooter)
    Log("[Lazy Panda] ProcessCorpse called with corpse: " + theCorpse as String)
    Bool takeAll = LPSetting_ContTakeAll.GetValue() as Bool
    bTakeAll = takeAll
    Actor corpseActor = theCorpse as Actor
    If corpseActor != None
        Race corpseRace = corpseActor.GetRace()
        ; Check if the Shattered Space or Tracker Alliance plugin is installed to determine corpse processing.
        If bIsShatteredSpaceLoaded && (corpseRace == HumanRace || corpseRace == SFBGS001_HumanRace)
            corpseActor.UnequipAll()
            corpseActor.EquipItem(LP_Skin_Naked_NOTPLAYABLE as Form, False, False)
        ElseIf bIsTrackerAllianceLoaded && corpseRace == SFBGS003_HumanRace
            corpseActor.UnequipAll()
            corpseActor.EquipItem(LP_Skin_Naked_NOTPLAYABLE as Form, False, False)
        ElseIf corpseRace == HumanRace
            corpseActor.UnequipAll()
            corpseActor.EquipItem(LP_Skin_Naked_NOTPLAYABLE as Form, False, False)
        EndIf
    EndIf
    Utility.Wait(0.5)
    ; Loot the corpse based on the take-all setting.
    If takeAll
        theCorpse.RemoveAllItems(GetDestRef(), False, False)
    Else
        ProcessFilteredContainerItems(theCorpse, theLooter)
    EndIf
    RemoveCorpse(theCorpse)
EndFunction

;-- RemoveCorpse Function --
; Removes the corpse from the world if the setting is enabled.
Function RemoveCorpse(ObjectReference theCorpse)
    Log("[Lazy Panda] RemoveCorpse called with corpse: " + theCorpse as String)
    If LPSetting_RemoveCorpses.GetValue() as Bool
        theCorpse.DisableNoWait(True)
    EndIf
EndFunction

;-- ProcessContainer Function --
; Processes a container by attempting to unlock it (if needed) and then looting its contents.
Function ProcessContainer(ObjectReference theContainer, ObjectReference theLooter)
    Log("[Lazy Panda] ProcessContainer called with container: " + theContainer as String)
    Bool stealingIsHostile = LPSetting_StealingIsHostile.GetValue() as Bool
    Bool takeAll = LPSetting_ContTakeAll.GetValue() as Bool
    Bool autoUnlock = LPSetting_AutoUnlock.GetValue() as Bool

    ; If the container is locked, attempt to unlock it if auto-unlock is enabled.
    If theContainer.IsLocked()
        If autoUnlock
            TryUnlock(theContainer)
        Else
            Log("[Lazy Panda] Container Ignored: Locked, AutoUnlock is disabled")
            Return
        EndIf
    EndIf

    ; Loot the container: remove all items if take-all is enabled, otherwise process filtered items.
    If takeAll
        theContainer.RemoveAllItems(GetDestRef(), False, stealingIsHostile)
    Else
        ProcessFilteredContainerItems(theContainer, theLooter)
    EndIf
EndFunction

;-- ProcessFilteredContainerItems Function --
; Processes container items using filtering lists to remove specific items.
Function ProcessFilteredContainerItems(ObjectReference theContainer, ObjectReference theLooter)
    Log("[Lazy Panda] ProcessFilteredContainerItems called with container: " + theContainer as String)
    Int listSize = LPSystem_Looting_Lists.GetSize()
    Int index = 0
    While index < listSize
        FormList currentList = LPSystem_Looting_Lists.GetAt(index) as FormList
        GlobalVariable currentGlobal = LPSystem_Looting_Globals.GetAt(index) as GlobalVariable
        Float globalValue = currentGlobal.GetValue()
        ; Remove items matching the current list if the corresponding global value is enabled.
        If globalValue == 1.0
            theContainer.RemoveItem(currentList as Form, -1, True, GetDestRef())
        EndIf
        index += 1
    EndWhile
EndFunction

;-- CanTakeLoot Function --
; Determines whether a loot item can be taken based on ownership, load status, quest status, and location.
Bool Function CanTakeLoot(ObjectReference theLoot)
    Log("[Lazy Panda] CanTakeLoot called with loot: " + theLoot as String)
    Bool bCanTake = True
    Bool allowStealing = LPSetting_AllowStealing.GetValue() as Bool
    ObjectReference theContainer = theLoot.GetContainer()
    TakeOwnership(theLoot)
    Log("[Lazy Panda] Container: " + theContainer as String)

    ; Check conditions that prevent looting.
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

;-- IsInRestrictedLocation Function --
; Checks if the player is located within any restricted looting locations.
Bool Function IsInRestrictedLocation()
    FormList restrictedLocations = LPFilter_NoLootLocations
    Int index = 0
    While index < restrictedLocations.GetSize()
        If PlayerRef.IsInLocation(restrictedLocations.GetAt(index) as Location)
            Return True
        EndIf
        index += 1
    EndWhile
    ; Additionally, check if the player is inside the player's ship interior and ship looting is disallowed.
    If PlayerRef.IsInLocation(playerShipInterior.GetLocation()) && !CanLootShip()
        Return True
    EndIf
    Return False
EndFunction

;-- TakeOwnership Function --
; Attempts to assign loot ownership to the player if allowed.
Function TakeOwnership(ObjectReference theLoot)
    Log("[Lazy Panda] TakeOwnership called with loot: " + theLoot as String)
    Bool allowStealing = LPSetting_AllowStealing.GetValue() as Bool
    Bool stealingIsHostile = LPSetting_StealingIsHostile.GetValue() as Bool
    If allowStealing && !stealingIsHostile && IsOwned(theLoot)
        theLoot.SetActorRefOwner(PlayerRef as Actor, True)
    EndIf
EndFunction

;-- CanLootShip Function --
; Checks if looting from a ship is permitted.
Bool Function CanLootShip()
    Log("[Lazy Panda] CanLootShip called")
    Return LPSetting_AllowLootingShip.GetValue() as Bool
EndFunction

;-- IsOwned Function --
; Checks if a loot item is considered owned by someone or would be flagged as stealing.
Bool Function IsOwned(ObjectReference theLoot)
    Log("[Lazy Panda] IsOwned called with loot: " + theLoot as String)
    Return (PlayerRef as Actor).WouldBeStealing(theLoot) || IsPlayerStealing(theLoot) || theLoot.HasOwner()
EndFunction

;-- TryUnlock Function --
; Attempts to unlock a container using an appropriate method based on lock level.
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

    ; Choose the unlocking strategy based on the container's lock level.
    If iLockLevel == iInaccessible
        HandleInaccessibleLock()
    ElseIf iLockLevel == iRequiresKey
        HandleRequiresKey(theContainer, bIsOwned)
    Else
        HandleDigipickUnlock(theContainer, bIsOwned, bLockSkillCheck)
    EndIf
EndFunction

;-- HandleInaccessibleLock Function --
; Handles containers with locks that cannot be unlocked.
Function HandleInaccessibleLock()
    Log("[Lazy Panda] HandleInaccessibleLock called")
EndFunction

;-- HandleRequiresKey Function --
; Handles unlocking for containers that require a key.
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

;-- HandleDigipickUnlock Function --
; Handles unlocking using a Digipick item, including a skill check.
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

;-- FindDigipick Function --
; Searches for a Digipick in designated holding locations and transfers it to the player.
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

;-- FindKey Function --
; Searches for a key in designated holding locations and transfers it to the player.
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

;-- CanUnlock Function --
; Determines if the container can be unlocked based on its lock level and the player's perks.
Bool Function CanUnlock(ObjectReference theContainer)
    Log("[Lazy Panda] CanUnlock called with container: " + theContainer as String)
    Int iLockLevel = theContainer.GetLockLevel()
    ; Build an array of lock level thresholds.
    Int[] lockLevels = new Int[4]
    lockLevels[0] = LockLevel_Novice.GetValue() as Int
    lockLevels[1] = LockLevel_Advanced.GetValue() as Int
    lockLevels[2] = LockLevel_Expert.GetValue() as Int
    lockLevels[3] = LockLevel_Master.GetValue() as Int

    ; Build a corresponding array indicating if the player can unlock at that level.
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

;-- IsCorpse Function --
; Checks whether the given object reference is a corpse (an Actor).
Bool Function IsCorpse(ObjectReference theCorpse)
    Log("[Lazy Panda] IsCorpse called with corpse: " + theCorpse as String)
    Actor theCorpseActor = theCorpse as Actor
    Bool isCorpse = (theCorpseActor != None)
    Log("[Lazy Panda] Is Corpse: " + isCorpse as String)
    Return isCorpse
EndFunction

;-- GetDestRef Function --
; Determines the destination reference for looted items based on the global "Send To" setting.
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

;-- IsPlayerStealing Function --
; Checks if the player is considered to be stealing the given loot based on its faction ownership.
Bool Function IsPlayerStealing(ObjectReference theLoot)
    Log("[Lazy Panda] IsPlayerStealing called with loot: " + theLoot as String)
    Faction currentOwner = theLoot.GetFactionOwner()
    Log("[Lazy Panda] Current Owner: " + currentOwner as String)
    Return !(currentOwner == None || currentOwner == PlayerFaction)
EndFunction

;-- IsPlayerAvailable Function --
; Returns whether the player controls (activate/looking) are enabled.
Bool Function IsPlayerAvailable()
    Log("[Lazy Panda] IsPlayerAvailable called")
    Return Game.IsActivateControlsEnabled() || Game.IsLookingControlsEnabled()
EndFunction

;-- IsLootLoaded Function --
; Determines if the loot object is currently loaded in the game (and not disabled or deleted).
Bool Function IsLootLoaded(ObjectReference theLoot)
    Log("[Lazy Panda] IsLootLoaded called with loot: " + theLoot as String)
    Return theLoot.Is3DLoaded() && !theLoot.IsDisabled() && !theLoot.IsDeleted()
EndFunction

;-- GetRadius Function --
; Returns the search radius for loot detection. Uses a different radius if the loot is in a container space.
Float Function GetRadius()
    Log("[Lazy Panda] GetRadius called")
    Float fSearchRadius
    If bIsContainerSpace
        fSearchRadius = Game.GetGameSettingFloat("fMaxShipTransferDistance")
    Else
        fSearchRadius = LPSetting_Radius.GetValue()
    EndIf
    Log("[Lazy Panda] Search Radius: " + fSearchRadius as String)
    Return fSearchRadius
EndFunction