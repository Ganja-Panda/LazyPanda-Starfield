;======================================================================
; Script Name   : LZP:Looting:LootEffectScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Handles all looting scenarios for various object types
; Description   : Supports scanning, filtering, looting, stealing logic,
;                 quest item detection, ship container handling, and destination
;                 routing. Integrated with LoggerScript for event-level tracking.
;                 Verbosity Levels:
;                   1 = Info, 2 = Warning, 3 = Error
; Dependencies  : LazyPanda.esm, LoggerScript
; Usage         : Activated by radius scanning or loot spell effect triggers
;======================================================================

ScriptName LZP:Looting:LootEffectScript Extends ActiveMagicEffect hidden

;======================================================================
; PROPERTIES
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
;-- Settings
; Global variables that define looting behavior and permissions.
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

;-- Logger Property --
;-- Logger
; LoggerScript reference for runtime debugging.
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const                    ; Declared logger using the new logging system
EndGroup

;======================================================================
; SCRIPT VARIABLES
;======================================================================
Bool bIsLooting = False ; Flag indicating if the looting process is active

;======================================================================
; EVENT HANDLERS
;======================================================================

;-- OnInit Event Handler --
Event OnInit()
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: OnInit triggered")
    EndIf
EndEvent

;-- OnEffectStart Event Handler --
Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: OnEffectStart triggered")
    EndIf
    StartTimer(lootTimerDelay, lootTimerID)
EndEvent

;-- OnTimer Event Handler --
Event OnTimer(Int aiTimerID)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: OnTimer triggered with TimerID: " + aiTimerID as String)
    EndIf
    If aiTimerID == lootTimerID && Game.GetPlayer().HasPerk(ActivePerk)
        If !bIsLooting  ; Prevent stacking loot calls
            bIsLooting = True
            ExecuteLooting()
            bIsLooting = False
        Else
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Looting:LootEffectScript: Looting skipped, already running.")
            EndIf
        EndIf
    EndIf
EndEvent

;======================================================================
; MAIN FUNCTIONS
;======================================================================

;-- ExecuteLooting Function --
Function ExecuteLooting()
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: ExecuteLooting called")
    EndIf
    LocateLoot(ActiveLootList)
    StartTimer(lootTimerDelay, lootTimerID)
EndFunction

;-- LocateLoot Function --
Function LocateLoot(FormList LootList)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: LocateLoot called with LootList: " + LootList as String)
    EndIf
    ObjectReference[] lootArray = None

    ; If using multiple keywords, call the dedicated function.
    If bIsMultipleKeyword
        LocateLootByKeyword(LootList)
    ; If a single keyword is used, find references using the first form in the list.
    ElseIf bIsKeyword
        If LootList == None
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Looting:LootEffectScript: ERROR: LootList is NONE! The FormList might be uninitialized.")
            EndIf
            Return
        EndIf

        If LootList.GetSize() == 0
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Looting:LootEffectScript: ERROR: LootList is EMPTY! There are no entries to use for searching.")
            EndIf
            Return
        EndIf

        Form lootKeyword = LootList.GetAt(0)
        If lootKeyword == None
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Looting:LootEffectScript: ERROR: LootList.GetAt(0) returned NONE! The FormList might not be set properly in CK.")
            EndIf
            Return
        EndIf

        Keyword validKeyword = lootKeyword as Keyword
        If validKeyword
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Looting:LootEffectScript: lootKeyword is a valid Keyword: " + validKeyword)
            EndIf
            lootArray = PlayerRef.FindAllReferencesWithKeyword(validKeyword, GetRadius())
            If lootArray.Length > 0
                If Logger && Logger.IsEnabled()
                    Logger.Log("LZP:Looting:LootEffectScript: Found " + lootArray.Length + " objects with keyword " + validKeyword)
                EndIf
            Else
                If Logger && Logger.IsEnabled()
                    Logger.Log("LZP:Looting:LootEffectScript: WARNING: No objects found with keyword " + validKeyword + " in range.")
                EndIf
            EndIf
        Else
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Looting:LootEffectScript: ERROR: LootList.GetAt(0) is NOT a Keyword! It might be a different form type in CK.")
            EndIf
            Return
        EndIf
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
Function LocateLootByKeyword(FormList LootList)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: LocateLootByKeyword called with LootList: " + LootList as String)
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
Function ProcessLoot(ObjectReference[] theLootArray)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: ProcessLoot called with lootArray of length: " + theLootArray.Length as String)
    EndIf
    theLooterRef = PlayerRef   ; Default looter is the player
    Int index = 0
    While index < theLootArray.Length && IsPlayerAvailable()
        ObjectReference currentLoot = theLootArray[index]
        If currentLoot != None
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Looting:LootEffectScript: Processing loot: " + currentLoot as String)
            EndIf
            ; Determine how to process the loot based on its type:
            If IsCorpse(currentLoot)
                Actor corpseActor = currentLoot as Actor
                If bLootDeadActor && corpseActor.IsDead() && CanTakeLoot(currentLoot)
                    If Logger && Logger.IsEnabled()
                        Logger.Log("LZP:Looting:LootEffectScript: Looting Dead Actor")
                    EndIf
                    ProcessCorpse(currentLoot, theLooterRef)
                EndIf
            ElseIf bIsContainer && CanTakeLoot(currentLoot)
                If Logger && Logger.IsEnabled()
                    Logger.Log("LZP:Looting:LootEffectScript: Looting Container")
                EndIf
                ProcessContainer(currentLoot, theLooterRef)
            ElseIf bIsContainerSpace && CanTakeLoot(currentLoot)
                If Logger && Logger.IsEnabled()
                    Logger.Log("LZP:Looting:LootEffectScript: Looting Spaceship Container")
                EndIf
                ; For spaceship containers, get the associated ship reference.
                If currentLoot.HasKeyword(SQ_ShipDebrisKeyword) || currentLoot.HasKeyword(LPKeyword_Asteroid) || currentLoot.HasKeyword(SpaceshipInventoryContainer)
                    currentLoot = currentLoot.GetCurrentShipRef() as ObjectReference
                EndIf
                theLooterRef = PlayerHomeShip.GetRef()
                ProcessContainer(currentLoot, theLooterRef)
            ElseIf bIsActivatedBySpell && CanTakeLoot(currentLoot) && ActiveLootSpell != None
                If Logger && Logger.IsEnabled()
                    Logger.Log("LZP:Looting:LootEffectScript: Looting Activated By Spell")
                EndIf
                ActiveLootSpell.RemoteCast(PlayerRef, PlayerRef as Actor, currentLoot)
            ElseIf bIsActivator && CanTakeLoot(currentLoot)
                If Logger && Logger.IsEnabled()
                    Logger.Log("LZP:Looting:LootEffectScript: Looting Activator")
                EndIf
                currentLoot.Activate(theLooterRef, False)
            ElseIf CanTakeLoot(currentLoot)
                ; If the loot is marked as a quest item, add it directly to the player.
                If currentLoot.IsQuestItem()
                    If Logger && Logger.IsEnabled()
                        Logger.Log("LZP:Looting:LootEffectScript: Quest Item detected, sending to player")
                    EndIf
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
;-- ProcessCorpse Function --
; @param theCorpse: The corpse object to process
; @param theLooter: The entity performing the looting
; Handles looting and cleanup of a corpse.
Function ProcessCorpse(ObjectReference theCorpse, ObjectReference theLooter)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: ProcessCorpse called with corpse: " + theCorpse as String)
    EndIf
    Bool takeAll = LPSetting_ContTakeAll.GetValue() as Bool
    bTakeAll = takeAll
    Actor corpseActor = theCorpse as Actor
    If corpseActor != None
        Race corpseRace = corpseActor.GetRace()
        ; Check if the Shattered Space or Tracker Alliance plugin is installed to determine corpse processing.
        If corpseRace == HumanRace
            corpseActor.UnequipAll()
            corpseActor.EquipItem(LP_Skin_Naked_NOTPLAYABLE as Form, False, False)
        EndIf
    EndIf
    Utility.Wait(0.1)
    ; Loot the corpse based on the take-all setting.
    If takeAll
        theCorpse.RemoveAllItems(GetDestRef(), False, False)
    Else
        ProcessFilteredContainerItems(theCorpse, theLooter)
    EndIf
    RemoveCorpse(theCorpse)
EndFunction

;-- RemoveCorpse Function --
;-- RemoveCorpse Function --
; @param theCorpse: The corpse object to remove
; Disables the corpse if settings allow it.
Function RemoveCorpse(ObjectReference theCorpse)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: RemoveCorpse called with corpse: " + theCorpse as String)
    EndIf
    If LPSetting_RemoveCorpses.GetValue() as Bool
        theCorpse.DisableNoWait(True)
    EndIf
EndFunction

;-- ProcessContainer Function --
;-- ProcessContainer Function --
; @param theContainer: The container to loot
; @param theLooter: The looting entity
; Handles logic for unlocking and looting containers.
Function ProcessContainer(ObjectReference theContainer, ObjectReference theLooter)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: ProcessContainer called with container: " + theContainer as String)
    EndIf
    Bool stealingIsHostile = LPSetting_StealingIsHostile.GetValue() as Bool
    Bool takeAll = LPSetting_ContTakeAll.GetValue() as Bool
    Bool autoUnlock = LPSetting_AutoUnlock.GetValue() as Bool

    ; If the container is locked, attempt to unlock it if auto-unlock is enabled.
    If theContainer.IsLocked()
        If autoUnlock
            TryUnlock(theContainer)
        Else
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Looting:LootEffectScript: Container Ignored: Locked, AutoUnlock is disabled")
            EndIf
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
;-- ProcessFilteredContainerItems Function --
; @param theContainer: The container to process
; @param theLooter: The looting entity
; Removes items based on active filters.
Function ProcessFilteredContainerItems(ObjectReference theContainer, ObjectReference theLooter)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: ProcessFilteredContainerItems called with container: " + theContainer as String)
    EndIf
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
;-- CanTakeLoot Function --
; @param theLoot: The item or object to evaluate
; @return: True if the object can be safely looted
; Evaluates whether looting is safe, legal, and enabled.
Bool Function CanTakeLoot(ObjectReference theLoot)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: CanTakeLoot called with loot: " + theLoot as String)
    EndIf
    Bool bCanTake = True
    Bool allowStealing = LPSetting_AllowStealing.GetValue() as Bool
    ObjectReference theContainer = theLoot.GetContainer()
    TakeOwnership(theLoot)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: Container: " + theContainer as String)
    EndIf

    ; Check conditions that prevent looting.
    If theContainer != None
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:LootEffectScript: Container Is Owned: " + IsOwned(theContainer) as String)
        EndIf
        bCanTake = False
    ElseIf !IsLootLoaded(theLoot)
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:LootEffectScript: Loot Not Loaded")
        EndIf
        bCanTake = False
    ElseIf theLoot.IsQuestItem()
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:LootEffectScript: Quest Item")
        EndIf
        bCanTake = False
    ElseIf (PlayerRef as Actor).WouldBeStealing(theLoot) && !allowStealing
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:LootEffectScript: Would Be Stealing")
        EndIf
        bCanTake = False
    ElseIf IsPlayerStealing(theLoot) && !allowStealing
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:LootEffectScript: Is Stealing")
        EndIf
        bCanTake = False
    ElseIf IsInRestrictedLocation()
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:LootEffectScript: In Restricted Location")
        EndIf
        bCanTake = False
    EndIf

    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: Can Take: " + bCanTake as String)
    EndIf
    Return bCanTake
EndFunction

;-- IsInRestrictedLocation Function --
;-- IsInRestrictedLocation Function --
; @return: True if player is in a no-loot zone
; Checks if looting is disallowed in the current location.
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
;-- TakeOwnership Function --
; @param theLoot: The object to assume ownership of
; Forces ownership of loot if stealing is allowed.
Function TakeOwnership(ObjectReference theLoot)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: TakeOwnership called with loot: " + theLoot as String)
    EndIf
    Bool allowStealing = LPSetting_AllowStealing.GetValue() as Bool
    Bool stealingIsHostile = LPSetting_StealingIsHostile.GetValue() as Bool
    If allowStealing && !stealingIsHostile && IsOwned(theLoot)
        theLoot.SetActorRefOwner(PlayerRef as Actor, True)
    EndIf
EndFunction

;-- CanLootShip Function --
;-- CanLootShip Function --
; @return: True if ship containers can be looted
; Reads global setting to determine permission.
Bool Function CanLootShip()
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: CanLootShip called")
    EndIf
    Return LPSetting_AllowLootingShip.GetValue() as Bool
EndFunction

;-- IsOwned Function --
;-- IsOwned Function --
; @param theLoot: The item to evaluate
; @return: True if the item is owned by another
; Checks multiple conditions for ownership.
Bool Function IsOwned(ObjectReference theLoot)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: IsOwned called with loot: " + theLoot as String)
    EndIf
    Return (PlayerRef as Actor).WouldBeStealing(theLoot) || IsPlayerStealing(theLoot) || theLoot.HasOwner()
EndFunction

;-- TryUnlock Function --
;-- TryUnlock Function --
; @param theContainer: The container to unlock
; Attempts appropriate unlock strategy based on lock state.
Function TryUnlock(ObjectReference theContainer)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: TryUnlock called with container: " + theContainer as String)
    EndIf
    Bool bLockSkillCheck = LPSetting_AutoUnlockSkillCheck.GetValue() as Bool
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: Lock Skill Check: " + bLockSkillCheck as String)
    EndIf
    Bool bIsOwned = theContainer.HasOwner()
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: Is Owned: " + bIsOwned as String)
    EndIf
    Int iLockLevel = theContainer.GetLockLevel()
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: Lock Level: " + iLockLevel as String)
    EndIf
    Int iRequiresKey = LockLevel_RequiresKey.GetValue() as Int
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: Requires Key: " + iRequiresKey as String)
    EndIf
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
;-- HandleInaccessibleLock Function --
; Handles logic for containers marked as inaccessible.
Function HandleInaccessibleLock()
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: HandleInaccessibleLock called")
    EndIf
EndFunction

;-- HandleRequiresKey Function --
;-- HandleRequiresKey Function --
; @param theContainer: Locked container
; @param bIsOwned: Whether it's owned by someone
; Attempts to find and use a key.
Function HandleRequiresKey(ObjectReference theContainer, Bool bIsOwned)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: HandleRequiresKey called with container: " + theContainer as String)
    EndIf
    Key theKey = theContainer.GetKey()
    FindKey(theKey)
    If PlayerRef.GetItemCount(theKey as Form) > 0
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:LootEffectScript: Key Found")
        EndIf
        theContainer.Unlock(bIsOwned)
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:LootEffectScript: Container Unlocked: With Key")
        EndIf
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:LootEffectScript: Locked Container Ignored: Requires Key")
        EndIf
    EndIf
EndFunction

;-- HandleDigipickUnlock Function --
;-- HandleDigipickUnlock Function --
; @param theContainer: Locked container
; @param bIsOwned: Whether it's owned
; @param bLockSkillCheck: If skill checks are enforced
; Uses digipick logic with skill check validation.
Function HandleDigipickUnlock(ObjectReference theContainer, Bool bIsOwned, Bool bLockSkillCheck)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: HandleDigipickUnlock called with container: " + theContainer as String)
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
                    Logger.Log("LZP:Looting:LootEffectScript: Container Unlocked: With Digipick")
                EndIf
            EndIf
        Else
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Looting:LootEffectScript: Locked Container Ignored: Failed Skill Check")
            EndIf
        EndIf
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:LootEffectScript: Locked Container Ignored: No Digipick")
        EndIf
    EndIf
EndFunction

;-- FindDigipick Function --
;-- FindDigipick Function --
; Searches known locations for digipicks and gives to player.
Function FindDigipick()
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: FindDigipick called")
    EndIf
    ObjectReference[] searchLocations = new ObjectReference[2]
    searchLocations[0] = LPDummyHoldingRef
    searchLocations[1] = LodgeSafeRef
    Int index = 0
    While index < searchLocations.Length
        If searchLocations[index].GetItemCount(Digipick as Form) > 0
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Looting:LootEffectScript: Digipick Found: In " + searchLocations[index] as String)
            EndIf
            searchLocations[index].RemoveItem(Digipick as Form, -1, True, PlayerRef)
            Return
        EndIf
        index += 1
    EndWhile
EndFunction

;-- FindKey Function --
;-- FindKey Function --
; @param theKey: The key to find
; Looks in known stash locations for a specific key.
Function FindKey(Key theKey)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: FindKey called with key: " + theKey as String)
    EndIf
    ObjectReference[] searchLocations = new ObjectReference[2]
    searchLocations[0] = LPDummyHoldingRef
    searchLocations[1] = LodgeSafeRef
    Int index = 0
    While index < searchLocations.Length
        If searchLocations[index].GetItemCount(theKey as Form) > 0
            If Logger && Logger.IsEnabled()
                Logger.Log("LZP:Looting:LootEffectScript: Key Found: In " + searchLocations[index] as String)
            EndIf
            searchLocations[index].RemoveItem(theKey as Form, -1, True, PlayerRef)
            Return
        EndIf
        index += 1
    EndWhile
EndFunction

;-- CanUnlock Function --
;-- CanUnlock Function --
; @param theContainer: The container to evaluate
; @return: True if the player meets perk unlock conditions
; Evaluates player unlock capabilities against lock level.
Bool Function CanUnlock(ObjectReference theContainer)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: CanUnlock called with container: " + theContainer as String)
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
                Logger.Log("LZP:Looting:LootEffectScript: Can Unlock: " + canUnlock[index] as String)
            EndIf
            Return canUnlock[index]
        EndIf
        index += 1
    EndWhile

    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: Can Unlock: False")
    EndIf
    Return False
EndFunction

;-- IsCorpse Function --
;-- IsCorpse Function --
; @param theCorpse: The reference to evaluate
; @return: True if the reference is an actor/corpse
; Checks if the reference is a valid corpse.
Bool Function IsCorpse(ObjectReference theCorpse)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: IsCorpse called with corpse: " + theCorpse as String)
    EndIf
    Actor theCorpseActor = theCorpse as Actor
    Bool isCorpse = (theCorpseActor != None)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: Is Corpse: " + isCorpse as String)
    EndIf
    Return isCorpse
EndFunction

;-- GetDestRef Function --
;-- GetDestRef Function --
; @return: The destination reference where items are sent
; Determines the loot destination based on user setting.
ObjectReference Function GetDestRef()
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: GetDestRef called")
    EndIf
    Int destination = LPSetting_SendTo.GetValue() as Int
    If destination == 1
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:LootEffectScript: Destination: Player")
        EndIf
        Return PlayerRef
    ElseIf destination == 2
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:LootEffectScript: Destination: Lodge Safe")
        EndIf
        Return LodgeSafeRef
    ElseIf destination == 3
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:LootEffectScript: Destination: Dummy Holding")
        EndIf
        Return LPDummyHoldingRef
    Else
        If Logger && Logger.IsEnabled()
            Logger.Log("LZP:Looting:LootEffectScript: Destination: Unknown")
        EndIf
        Return None
    EndIf
EndFunction

;-- IsPlayerStealing Function --
;-- IsPlayerStealing Function --
; @param theLoot: The item to evaluate
; @return: True if item would be considered stolen
; Checks faction ownership for theft validation.
Bool Function IsPlayerStealing(ObjectReference theLoot)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: IsPlayerStealing called with loot: " + theLoot as String)
    EndIf
    Faction currentOwner = theLoot.GetFactionOwner()
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: Current Owner: " + currentOwner as String)
    EndIf
    Return !(currentOwner == None || currentOwner == PlayerFaction)
EndFunction

;-- IsPlayerAvailable Function --
;-- IsPlayerAvailable Function --
; @return: True if player can perform activation
; Verifies player controls are enabled.
Bool Function IsPlayerAvailable()
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: IsPlayerAvailable called")
    EndIf
    Return Game.IsActivateControlsEnabled() || Game.IsLookingControlsEnabled()
EndFunction

;-- IsLootLoaded Function --
;-- IsLootLoaded Function --
; @param theLoot: The loot object
; @return: True if it's loaded and valid in-world
; Ensures the loot is loaded and not deleted/disabled.
Bool Function IsLootLoaded(ObjectReference theLoot)
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: IsLootLoaded called with loot: " + theLoot as String)
    EndIf
    Return theLoot.Is3DLoaded() && !theLoot.IsDisabled() && !theLoot.IsDeleted()
EndFunction

;-- GetRadius Function --
;-- GetRadius Function --
; @return: Loot scanning radius
; Determines the scan radius from context or setting.
Float Function GetRadius()
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: GetRadius called")
    EndIf
    Float fSearchRadius
    If bIsContainerSpace
        fSearchRadius = Game.GetGameSettingFloat("fMaxShipTransferDistance")
    Else
        fSearchRadius = LPSetting_Radius.GetValue()
    EndIf
    If Logger && Logger.IsEnabled()
        Logger.Log("LZP:Looting:LootEffectScript: Search Radius: " + fSearchRadius as String)
    EndIf
    Return fSearchRadius
EndFunction
