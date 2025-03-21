;======================================================================
; Script: LZP:DLC:Looting:LootEffectScript
; Description: This ActiveMagicEffect script manages the looting process.
; It locates loot based on various criteria (keywords, container types, etc.),
; processes the loot (including corpses, containers, and spell-activated objects),
; and handles container unlocking via keys or Digipick.
; Debug logging is integrated to assist with troubleshooting.
;======================================================================

ScriptName LZP:DLC:Looting:LootEffectScript Extends ActiveMagicEffect hidden

;======================================================================
; PROPERTY GROUPS
;======================================================================

;-- Effect-Specific Mandatory Properties --
Group EffectSpecific_Mandatory
    Perk Property ActivePerk Auto Const mandatory              ; Perk required for activating the loot effect
    FormList Property ActiveLootList Auto Const mandatory        ; List of forms representing potential loot targets
EndGroup

;-- Effect-Specific Optional Properties --
Group EffectSpecific_Optional
    Spell Property ActiveLootSpell Auto Const                    ; Optional spell used to trigger looting
EndGroup

;-- Loot Method Configuration --
Group EffectSpecific_LootMethod
    Bool Property bIsActivator = False Auto                        ; Is loot triggered by an activator?
    Bool Property bIsContainer = False Auto                        ; Is loot triggered by a container?
    Bool Property bLootDeadActor = False Auto                      ; Should the effect loot dead actors?
    Bool Property bIsActivatedBySpell = False Auto                 ; Is looting activated via a spell?
    Bool Property bIsContainerSpace = False Auto                   ; Is the loot coming from a spaceship container?
EndGroup

;-- Form Type Configuration --
Group EffectSpecific_FormType
    Bool Property bIsKeyword = False Auto                          ; Use a single keyword to locate loot?
    Bool Property bIsMultipleKeyword = False Auto                  ; Use multiple keywords to locate loot?
EndGroup

;-- Settings Autofill --
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
Group List_Autofill
    FormList Property LPSystem_Looting_Globals Auto Const          ; Global looting configuration list
    FormList Property LPSystem_Looting_Lists Auto Const             ; Loot filtering lists for containers
EndGroup

;-- Miscellaneous Properties --
Group Misc
    Keyword Property SpaceshipInventoryContainer Auto Const         ; Keyword for spaceship inventory containers
    Keyword Property SQ_ShipDebrisKeyword Auto Const                ; Keyword for spaceship debris objects
    Keyword Property LPKeyword_Asteroid  Auto Const                  ; Keyword for asteroid objects
    Armor Property LP_Skin_Naked_NOTPLAYABLE Auto Const mandatory       ; Armor for unequipping corpses (non-playable)
    Race Property HumanRace Auto Const mandatory                       ; Standard human race
    Race Property SFBGS001_HumanRace Auto Const mandatory               ; Shattered Space human
    Race Property SFBGS003_HumanRace Auto Const mandatory               ; Tracker Alliance human  
EndGroup

;-- Destination Locations --
Group DestinationLocations
    ObjectReference Property PlayerRef Auto Const                     ; Reference to the player
    ObjectReference Property LodgeSafeRef Auto Const                    ; Reference to the lodge safe container
    ObjectReference Property LPDummyHoldingRef Auto Const               ; Reference to a dummy holding container for loot
    ReferenceAlias Property PlayerHomeShip Auto Const mandatory           ; Alias for the player's home ship
EndGroup

;-- No Loot Locations --
Group NoLootLocations
    FormList Property LPFilter_NoLootLocations Auto Const               ; List of locations where looting is disabled
    LocationAlias Property playerShipInterior Auto Const mandatory        ; Alias for the player's ship interior location
EndGroup

;-- No Fill Settings --
Group NoFill
    Int Property lootTimerID = 1 Auto                                  ; Timer identifier for looting
    Float Property lootTimerDelay = 0.1 Auto                             ; Delay between loot cycles
    Bool Property bAllowStealing = False Auto                            ; Local flag to allow stealing
    Bool Property bStealingIsHostile = False Auto                         ; Local flag indicating hostile stealing
    Bool Property bTakeAll = False Auto                                   ; Local flag to loot all items from a container
    ObjectReference Property theLooterRef Auto                           ; Reference to the looter (typically the player)
EndGroup

;======================================================================
; SCRIPT VARIABLES
;======================================================================
Bool bIsLooting = False ; Flag indicating if the looting process is active

;======================================================================
; LOGGER PROPERTY
;======================================================================
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnInit Event Handler --
; Called when the script is initialized. Initializes the Shattered Space and Tracker Alliance human races if the plugin is loaded.
Event OnInit()
    If Logger && Logger.IsEnabled()
        Logger.Log("OnInit triggered")
    EndIf
EndEvent

;-- OnEffectStart Event Handler --
; Called when the magic effect starts. Begins the loot timer.
Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
    If Logger && Logger.IsEnabled()
        Logger.Log("OnEffectStart triggered")
    EndIf
    StartTimer(lootTimerDelay, lootTimerID)
EndEvent

;-- OnTimer Event Handler --
; Called when the loot timer expires. Checks if the player has the required perk before executing looting.
Event OnTimer(Int aiTimerID)
    If Logger && Logger.IsEnabled()
        Logger.Log("OnTimer triggered with TimerID: " + aiTimerID as String)
    EndIf
    
    If aiTimerID == lootTimerID && Game.GetPlayer().HasPerk(ActivePerk)
        If !bIsLooting  ; Prevent stacking loot calls
            bIsLooting = True
            ExecuteLooting()
            bIsLooting = False
        Else
            If Logger && Logger.IsEnabled()
                Logger.Log("OnTimer skipped: Looting process already running")
            EndIf
        EndIf
    EndIf
EndEvent

;======================================================================
; MAIN FUNCTIONS
;======================================================================

;-- ExecuteLooting Function --
; Main function that initiates the looting process and restarts the loot timer.
Function ExecuteLooting()
    If Logger && Logger.IsEnabled()
        Logger.Log("ExecuteLooting called")
    EndIf
    LocateLoot(ActiveLootList)
    StartTimer(lootTimerDelay, lootTimerID)
EndFunction

;-- LocateLoot Function --
; Determines the appropriate method for locating loot based on the form type.
Function LocateLoot(FormList LootList)
    If Logger && Logger.IsEnabled()
        Logger.Log("LocateLoot called with LootList: " + LootList as String)
    EndIf
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
    If Logger && Logger.IsEnabled()
        Logger.Log("LocateLootByKeyword called with LootList: " + LootList as String)
    EndIf
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
    If Logger && Logger.IsEnabled()
        Logger.Log("ProcessLoot called with lootArray of length: " + theLootArray.Length as String)
    EndIf
    theLooterRef = PlayerRef   ; Default looter is the player
    Int index = 0
    While index < theLootArray.Length && IsPlayerAvailable()
        ObjectReference currentLoot = theLootArray[index]
        If currentLoot != None
            If Logger && Logger.IsEnabled()
                Logger.Log("Processing loot: " + currentLoot as String)
            EndIf
            ; Determine how to process the loot based on its type:
            If IsCorpse(currentLoot)
                Actor corpseActor = currentLoot as Actor
                If bLootDeadActor && corpseActor.IsDead() && CanTakeLoot(currentLoot)
                    If Logger && Logger.IsEnabled()
                        Logger.Log("Looting Dead Actor")
                    EndIf
                    ProcessCorpse(currentLoot, theLooterRef)
                EndIf
            ElseIf bIsContainer && CanTakeLoot(currentLoot)
                If Logger && Logger.IsEnabled()
                    Logger.Log("Looting Container")
                EndIf
                ProcessContainer(currentLoot, theLooterRef)
            ElseIf bIsContainerSpace && CanTakeLoot(currentLoot)
                If Logger && Logger.IsEnabled()
                    Logger.Log("Looting Spaceship Container")
                EndIf
                ; For spaceship containers, get the associated ship reference.
                If currentLoot.HasKeyword(SQ_ShipDebrisKeyword) || currentLoot.HasKeyword(LPKeyword_Asteroid) || currentLoot.HasKeyword(SpaceshipInventoryContainer)
                    currentLoot = currentLoot.GetCurrentShipRef() as ObjectReference
                EndIf
                theLooterRef = PlayerHomeShip.GetRef()
                ProcessContainer(currentLoot, theLooterRef)
            ElseIf bIsActivatedBySpell && CanTakeLoot(currentLoot) && ActiveLootSpell != None
                If Logger && Logger.IsEnabled()
                    Logger.Log("Looting Activated By Spell")
                EndIf
                ActiveLootSpell.RemoteCast(PlayerRef, PlayerRef as Actor, currentLoot)
            ElseIf bIsActivator && CanTakeLoot(currentLoot)
                If Logger && Logger.IsEnabled()
                    Logger.Log("Looting Activator")
                EndIf
                currentLoot.Activate(theLooterRef, False)
            ElseIf CanTakeLoot(currentLoot)
                GetDestRef().AddItem(currentLoot as Form, -1, False)
            EndIf
        EndIf
        index += 1
    EndWhile
EndFunction

;-- ProcessCorpse Function --
; Handles processing of a corpse object including unequipping, looting, and removal.
Function ProcessCorpse(ObjectReference theCorpse, ObjectReference theLooter)
    If Logger && Logger.IsEnabled()
        Logger.Log("ProcessCorpse called with corpse: " + theCorpse as String)
    EndIf
    Bool takeAll = LPSetting_ContTakeAll.GetValue() as Bool
    bTakeAll = takeAll
    Actor corpseActor = theCorpse as Actor
    If corpseActor != None
        Race corpseRace = corpseActor.GetRace()
        ; Check if the Shattered Space or Tracker Alliance plugin is installed to determine corpse processing.
        If corpseRace == HumanRace || corpseRace == SFBGS001_HumanRace || corpseRace == SFBGS003_HumanRace
            corpseActor.UnequipAll()
            corpseActor.EquipItem(LP_Skin_Naked_NOTPLAYABLE as Form, False, False)
        EndIf
    EndIf
    Utility.Wait(0.1)
    ; Loot the corpse based on the take-all setting.
    If takeAll
        If Logger && Logger.IsEnabled()
            Logger.Log("Removing all items from corpse")
        EndIf
        theCorpse.RemoveAllItems(GetDestRef(), False, False)
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("Processing filtered items from corpse")
        EndIf
        ProcessFilteredContainerItems(theCorpse, theLooter)
    EndIf
    If Logger && Logger.IsEnabled()
        Logger.Log("Removing corpse from world")
    EndIf
    RemoveCorpse(theCorpse)
EndFunction

;-- RemoveCorpse Function --
; Removes the corpse from the world if the setting is enabled.
Function RemoveCorpse(ObjectReference theCorpse)
    If Logger && Logger.IsEnabled()
        Logger.Log("RemoveCorpse called with corpse: " + theCorpse as String)
    EndIf
    If LPSetting_RemoveCorpses.GetValue() as Bool
        If Logger && Logger.IsEnabled()
            Logger.Log("Corpse removal enabled, disabling corpse")
        EndIf
        theCorpse.DisableNoWait(True)
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("Corpse removal disabled, leaving corpse in world")
        EndIf
    EndIf
EndFunction

;-- ProcessContainer Function --
; Processes a container by attempting to unlock it (if needed) and then looting its contents.
Function ProcessContainer(ObjectReference theContainer, ObjectReference theLooter)
    If Logger && Logger.IsEnabled()
        Logger.Log("ProcessContainer called with container: " + theContainer as String)
    EndIf
    Bool stealingIsHostile = LPSetting_StealingIsHostile.GetValue() as Bool
    Bool takeAll = LPSetting_ContTakeAll.GetValue() as Bool
    Bool autoUnlock = LPSetting_AutoUnlock.GetValue() as Bool

    ; If the container is locked, attempt to unlock it if auto-unlock is enabled.
    If theContainer.IsLocked()
        If autoUnlock
            If Logger && Logger.IsEnabled()
                Logger.Log("Attempting to unlock container")
            EndIf
            TryUnlock(theContainer)
        Else
            If Logger && Logger.IsEnabled()
                Logger.Log("Container Ignored: Locked, AutoUnlock is disabled")
            EndIf
            Return
        EndIf
    EndIf

    ; Loot the container: remove all items if take-all is enabled, otherwise process filtered items.
    If takeAll
        If Logger && Logger.IsEnabled()
            Logger.Log("Removing all items from container")
        EndIf
        theContainer.RemoveAllItems(GetDestRef(), False, stealingIsHostile)
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("Processing filtered items from container")
        EndIf
        ProcessFilteredContainerItems(theContainer, theLooter)
    EndIf
EndFunction

;-- ProcessFilteredContainerItems Function --
; Processes container items using filtering lists to remove specific items.
Function ProcessFilteredContainerItems(ObjectReference theContainer, ObjectReference theLooter)
    If Logger && Logger.IsEnabled()
        Logger.Log("ProcessFilteredContainerItems called with container: " + theContainer as String)
    EndIf
    Int listSize = LPSystem_Looting_Lists.GetSize()
    Int index = 0
    While index < listSize
        FormList currentList = LPSystem_Looting_Lists.GetAt(index) as FormList
        GlobalVariable currentGlobal = LPSystem_Looting_Globals.GetAt(index) as GlobalVariable
        Float globalValue = currentGlobal.GetValue()
        ; Remove items matching the current list if the corresponding global value is enabled.
        If globalValue == 1.0
            If Logger && Logger.IsEnabled()
                Logger.Log("Removing items from container matching list index: " + index as String)
            EndIf
            theContainer.RemoveItem(currentList as Form, -1, True, GetDestRef())
        Else
            If Logger && Logger.IsEnabled()
                Logger.Log("Skipping item removal for list index: " + index as String)
            EndIf
        EndIf
        index += 1
    EndWhile
EndFunction

;-- CanTakeLoot Function --
; Determines whether a loot item can be taken based on ownership, load status, quest status, and location.
Bool Function CanTakeLoot(ObjectReference theLoot)
    If Logger && Logger.IsEnabled()
        Logger.Log("CanTakeLoot called with loot: " + theLoot as String)
    EndIf
    Bool bCanTake = True
    Bool allowStealing = LPSetting_AllowStealing.GetValue() as Bool
    ObjectReference theContainer = theLoot.GetContainer()
    TakeOwnership(theLoot)
    If Logger && Logger.IsEnabled()
        Logger.Log("Container: " + theContainer as String)
    EndIf

    ; Check conditions that prevent looting.
    If theContainer != None
        If Logger && Logger.IsEnabled()
            Logger.Log("Container Is Owned: " + IsOwned(theContainer) as String)
        EndIf
        bCanTake = False
    ElseIf !IsLootLoaded(theLoot)
        If Logger && Logger.IsEnabled()
            Logger.Log("Loot Not Loaded")
        EndIf
        bCanTake = False
    ElseIf theLoot.IsQuestItem()
        If Logger && Logger.IsEnabled()
            Logger.Log("Quest Item")
        EndIf
        bCanTake = False
    ElseIf (PlayerRef as Actor).WouldBeStealing(theLoot) && !allowStealing
        If Logger && Logger.IsEnabled()
            Logger.Log("Would Be Stealing")
        EndIf
        bCanTake = False
    ElseIf IsPlayerStealing(theLoot) && !allowStealing
        If Logger && Logger.IsEnabled()
            Logger.Log("Is Stealing")
        EndIf
        bCanTake = False
    ElseIf IsInRestrictedLocation()
        If Logger && Logger.IsEnabled()
            Logger.Log("In Restricted Location")
        EndIf
        bCanTake = False
    EndIf

    If Logger && Logger.IsEnabled()
        Logger.Log("Can Take: " + bCanTake as String)
    EndIf
    Return bCanTake
EndFunction

;-- IsInRestrictedLocation Function --
; Checks if the player is located within any restricted looting locations.
Bool Function IsInRestrictedLocation()
    If Logger && Logger.IsEnabled()
        Logger.Log("Checking if player is in a restricted location")
    EndIf
    FormList restrictedLocations = LPFilter_NoLootLocations
    Int index = 0
    While index < restrictedLocations.GetSize()
        If PlayerRef.IsInLocation(restrictedLocations.GetAt(index) as Location)
            If Logger && Logger.IsEnabled()
                Logger.Log("Player is in a restricted location")
            EndIf
            Return True
        EndIf
        index += 1
    EndWhile
    ; Additionally, check if the player is inside the player's ship interior and ship looting is disallowed.
    If PlayerRef.IsInLocation(playerShipInterior.GetLocation()) && !CanLootShip()
        If Logger && Logger.IsEnabled()
            Logger.Log("Player is inside ship interior where looting is disallowed")
        EndIf
        Return True
    EndIf
    If Logger && Logger.IsEnabled()
        Logger.Log("Player is not in a restricted location")
    EndIf
    Return False
EndFunction

;-- TakeOwnership Function --
; Attempts to assign loot ownership to the player if allowed.
Function TakeOwnership(ObjectReference theLoot)
    If Logger && Logger.IsEnabled()
        Logger.Log("TakeOwnership called with loot: " + theLoot as String)
    EndIf
    Bool allowStealing = LPSetting_AllowStealing.GetValue() as Bool
    Bool stealingIsHostile = LPSetting_StealingIsHostile.GetValue() as Bool
    If allowStealing && !stealingIsHostile && IsOwned(theLoot)
        If Logger && Logger.IsEnabled()
            Logger.Log("Setting player as loot owner")
        EndIf
        theLoot.SetActorRefOwner(PlayerRef as Actor, True)
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("Ownership unchanged")
        EndIf
    EndIf
EndFunction

;-- CanLootShip Function --
; Checks if looting from a ship is permitted.
Bool Function CanLootShip()
    If Logger && Logger.IsEnabled()
        Logger.Log("CanLootShip called")
    EndIf
    Return LPSetting_AllowLootingShip.GetValue() as Bool
EndFunction

;-- IsOwned Function --
; Checks if a loot item is considered owned by someone or would be flagged as stealing.
Bool Function IsOwned(ObjectReference theLoot)
    If Logger && Logger.IsEnabled()
        Logger.Log("IsOwned called with loot: " + theLoot as String)
    EndIf
    Return (PlayerRef as Actor).WouldBeStealing(theLoot) || IsPlayerStealing(theLoot) || theLoot.HasOwner()
EndFunction

;-- TryUnlock Function --
; Attempts to unlock a container using an appropriate method based on lock level.
Function TryUnlock(ObjectReference theContainer)
    If Logger && Logger.IsEnabled()
        Logger.Log("TryUnlock called with container: " + theContainer as String)
    EndIf
    Bool bLockSkillCheck = LPSetting_AutoUnlockSkillCheck.GetValue() as Bool
    If Logger && Logger.IsEnabled()
        Logger.Log("Lock Skill Check: " + bLockSkillCheck as String)
    EndIf
    Bool bIsOwned = theContainer.HasOwner()
    If Logger && Logger.IsEnabled()
        Logger.Log("Is Owned: " + bIsOwned as String)
    EndIf
    Int iLockLevel = theContainer.GetLockLevel()
    If Logger && Logger.IsEnabled()
        Logger.Log("Lock Level: " + iLockLevel as String)
    EndIf
    Int iRequiresKey = LockLevel_RequiresKey.GetValue() as Int
    If Logger && Logger.IsEnabled()
        Logger.Log("Requires Key: " + iRequiresKey as String)
    EndIf
    Int iInaccessible = LockLevel_Inaccessible.GetValue() as Int

    ; Choose the unlocking strategy based on the container's lock level.
    If iLockLevel == iInaccessible
        If Logger && Logger.IsEnabled()
            Logger.Log("Handling inaccessible lock")
        EndIf
        HandleInaccessibleLock()
    ElseIf iLockLevel == iRequiresKey
        If Logger && Logger.IsEnabled()
            Logger.Log("Handling requires key")
        EndIf
        HandleRequiresKey(theContainer, bIsOwned)
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("Handling digipick unlock")
        EndIf
        HandleDigipickUnlock(theContainer, bIsOwned, bLockSkillCheck)
    EndIf
EndFunction

;-- HandleInaccessibleLock Function --
; Handles containers with locks that cannot be unlocked.
Function HandleInaccessibleLock()
    If Logger && Logger.IsEnabled()
        Logger.Log("HandleInaccessibleLock called")
    EndIf
EndFunction

;-- HandleRequiresKey Function --
; Handles unlocking for containers that require a key.
Function HandleRequiresKey(ObjectReference theContainer, Bool bIsOwned)
    If Logger && Logger.IsEnabled()
        Logger.Log("HandleRequiresKey called with container: " + theContainer as String)
    EndIf
    Key theKey = theContainer.GetKey()
    FindKey(theKey)
    If PlayerRef.GetItemCount(theKey as Form) > 0
        If Logger && Logger.IsEnabled()
            Logger.Log("Key Found")
        EndIf
        theContainer.Unlock(bIsOwned)
        If Logger && Logger.IsEnabled()
            Logger.Log("Container Unlocked: With Key")
        EndIf
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("Locked Container Ignored: Requires Key")
        EndIf
    EndIf
EndFunction

;-- HandleDigipickUnlock Function --
; Handles unlocking using a Digipick item, including a skill check.
Function HandleDigipickUnlock(ObjectReference theContainer, Bool bIsOwned, Bool bLockSkillCheck)
    If Logger && Logger.IsEnabled()
        Logger.Log("HandleDigipickUnlock called with container: " + theContainer as String)
    EndIf
    If PlayerRef.GetItemCount(Digipick as Form) == 0
        FindDigipick()
    EndIf
    If PlayerRef.GetItemCount(Digipick as Form) > 0
        If !bLockSkillCheck || (bLockSkillCheck && CanUnlock(theContainer))
            theContainer.Unlock(bIsOwned)
            If !theContainer.IsLocked()
                Game.RewardPlayerXP(10, False)
                PlayerRef.RemoveItem(Digipick as Form, 1, False, None)
                If Logger && Logger.IsEnabled()
                    Logger.Log("Container Unlocked: With Digipick")
                EndIf
            EndIf
        Else
            If Logger && Logger.IsEnabled()
                Logger.Log("Locked Container Ignored: Failed Skill Check")
            EndIf
        EndIf
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("Locked Container Ignored: No Digipick")
        EndIf
    EndIf
EndFunction

;-- FindDigipick Function --
; Searches for a Digipick in designated holding locations and transfers it to the player.
Function FindDigipick()
    If Logger && Logger.IsEnabled()
        Logger.Log("FindDigipick called")
    EndIf
    ObjectReference[] searchLocations = new ObjectReference[2]
    searchLocations[0] = LPDummyHoldingRef
    searchLocations[1] = LodgeSafeRef
    Int index = 0
    While index < searchLocations.Length
        If searchLocations[index].GetItemCount(Digipick as Form) > 0
            If Logger && Logger.IsEnabled()
                Logger.Log("Digipick Found: In " + searchLocations[index] as String)
            EndIf
            searchLocations[index].RemoveItem(Digipick as Form, -1, True, PlayerRef)
            Return
        EndIf
        index += 1
    EndWhile
EndFunction

;-- FindKey Function --
; Searches for a key in designated holding locations and transfers it to the player.
Function FindKey(Key theKey)
    If Logger && Logger.IsEnabled()
        Logger.Log("FindKey called with key: " + theKey as String)
    EndIf
    ObjectReference[] searchLocations = new ObjectReference[2]
    searchLocations[0] = LPDummyHoldingRef
    searchLocations[1] = LodgeSafeRef
    Int index = 0
    While index < searchLocations.Length
        If searchLocations[index].GetItemCount(theKey as Form) > 0
            If Logger && Logger.IsEnabled()
                Logger.Log("Key Found: In " + searchLocations[index] as String)
            EndIf
            searchLocations[index].RemoveItem(theKey as Form, -1, True, PlayerRef)
            Return
        EndIf
        index += 1
    EndWhile
EndFunction

;-- CanUnlock Function --
; Determines if the container can be unlocked based on its lock level and the player's perks.
Bool Function CanUnlock(ObjectReference theContainer)
    If Logger && Logger.IsEnabled()
        Logger.Log("CanUnlock called with container: " + theContainer as String)
    EndIf
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
            If Logger && Logger.IsEnabled()
                Logger.Log("Can Unlock: " + canUnlock[index] as String)
            EndIf
            Return canUnlock[index]
        EndIf
        index += 1
    EndWhile

    If Logger && Logger.IsEnabled()
        Logger.Log("Can Unlock: False")
    EndIf
    Return False
EndFunction

;-- IsCorpse Function --
; Checks whether the given object reference is a corpse (an Actor).
Bool Function IsCorpse(ObjectReference theCorpse)
    If Logger && Logger.IsEnabled()
        Logger.Log("IsCorpse called with corpse: " + theCorpse as String)
    EndIf
    Actor theCorpseActor = theCorpse as Actor
    Bool isCorpse = (theCorpseActor != None)
    If Logger && Logger.IsEnabled()
        Logger.Log("Is Corpse: " + isCorpse as String)
    EndIf
    Return isCorpse
EndFunction

;-- GetDestRef Function --
; Determines the destination reference for looted items based on the global "Send To" setting.
ObjectReference Function GetDestRef()
    If Logger && Logger.IsEnabled()
        Logger.Log("GetDestRef called")
    EndIf
    Int destination = LPSetting_SendTo.GetValue() as Int
    If destination == 1
        If Logger && Logger.IsEnabled()
            Logger.Log("Destination: Player")
        EndIf
        Return PlayerRef
    ElseIf destination == 2
        If Logger && Logger.IsEnabled()
            Logger.Log("Destination: Lodge Safe")
        EndIf
        Return LodgeSafeRef
    ElseIf destination == 3
        If Logger && Logger.IsEnabled()
            Logger.Log("Destination: Dummy Holding")
        EndIf
        Return LPDummyHoldingRef
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("Destination: Unknown")
        EndIf
        Return None
    EndIf
EndFunction

;-- IsPlayerStealing Function --
; Checks if the player is considered to be stealing the given loot based on its faction ownership.
Bool Function IsPlayerStealing(ObjectReference theLoot)
    If Logger && Logger.IsEnabled()
        Logger.Log("IsPlayerStealing called with loot: " + theLoot as String)
    EndIf
    Faction currentOwner = theLoot.GetFactionOwner()
    If Logger && Logger.IsEnabled()
        Logger.Log("Current Owner: " + currentOwner as String)
    EndIf
    Return !(currentOwner == None || currentOwner == PlayerFaction)
EndFunction

;-- IsPlayerAvailable Function --
; Returns whether the player controls (activate/looking) are enabled.
Bool Function IsPlayerAvailable()
    If Logger && Logger.IsEnabled()
        Logger.Log("IsPlayerAvailable called")
    EndIf
    Return Game.IsActivateControlsEnabled() || Game.IsLookingControlsEnabled()
EndFunction

;-- IsLootLoaded Function --
; Determines if the loot object is currently loaded in the game (and not disabled or deleted).
Bool Function IsLootLoaded(ObjectReference theLoot)
    If Logger && Logger.IsEnabled()
        Logger.Log("IsLootLoaded called with loot: " + theLoot as String)
    EndIf
    Return theLoot.Is3DLoaded() && !theLoot.IsDisabled() && !theLoot.IsDeleted()
EndFunction

;-- GetRadius Function --
; Returns the search radius for loot detection. Uses a different radius if the loot is in a container space.
Float Function GetRadius()
    If Logger && Logger.IsEnabled()
        Logger.Log("GetRadius called")
    EndIf
    Float fSearchRadius
    If bIsContainerSpace
        fSearchRadius = Game.GetGameSettingFloat("fMaxShipTransferDistance")
    Else
        fSearchRadius = LPSetting_Radius.GetValue()
    EndIf
    If Logger && Logger.IsEnabled()
        Logger.Log("Search Radius: " + fSearchRadius as String)
    EndIf
    Return fSearchRadius
EndFunction
