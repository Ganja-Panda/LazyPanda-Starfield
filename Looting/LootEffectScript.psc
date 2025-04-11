;======================================================================
; Script Name   : LZP:Looting:LootEffectScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Controls lifecycle of the loot effect and delegates
;                 scanning and processing to modular systems.
; Description   : Triggered by an ability, scans nearby targets, and
;                 routes to processors for container/corpse handling.
; Dependencies  : LootScannerScript, LootProcessorScript, UnlockHelperScript
; Usage         : Apply to an ability used via terminal menu system.
;======================================================================

ScriptName LZP:Looting:LootEffectScript Extends ActiveMagicEffect Hidden

;======================================================================
; PROPERTIES
;======================================================================

;-- Framework Modules
Group ModuleDependencies
	LZP:Looting:LootScannerScript Property LootScanner Auto Const Mandatory          ; Scans for lootable references in radius
	LZP:Looting:LootProcessorScript Property LootProcessor Auto Const Mandatory      ; Handles loot routing and processing
	LZP:Looting:UnlockHelperScript Property UnlockHelper Auto Const Mandatory        ; Unlock handler used if lockpicking enabled
	LZP:Debug:LoggerScript Property Logger Auto Const Mandatory                      ; Logging module for debug output
EndGroup

;-- Effect-Specific Mandatory Properties --
Group EffectSpecific_Mandatory
	Perk Property ActivePerk Auto Const Mandatory                                     ; Required perk to enable loot effect
	FormList Property ActiveLootList Auto Const Mandatory                            ; FormList of lootable entries configured via terminal
EndGroup

;-- Effect-Specific Optional Properties --
Group EffectSpecific_Optional
	Spell Property ActiveLootSpell Auto Const                                        ; Optional spell that can activate the looting event
EndGroup

;-- Loot Method Configuration --
Group EffectSpecific_LootMethod
	Bool Property bIsActivator = False Auto                                          ; True if target is an activator
	Bool Property bIsContainer = False Auto                                          ; True if looting a container
	Bool Property bLootDeadActor = False Auto                                        ; True if looting dead NPCs
	Bool Property bIsActivatedBySpell = False Auto                                   ; Indicates if activation came from a spell
	Bool Property bIsContainerSpace = False Auto                                     ; True if targeting ship containers
EndGroup

;-- Form Type Configuration --
Group EffectSpecific_FormType
	Bool Property bIsKeyword = False Auto                                            ; True if using a single keyword to find loot
	Bool Property bIsMultipleKeyword = False Auto                                    ; True if scanning with multiple keywords
EndGroup

;-- Settings Autofill --
Group Settings_Autofill
	GlobalVariable Property LPSetting_Radius Auto Const                              ; Search radius for lootable objects
	GlobalVariable Property LPSystemUtil_LoopCap Auto Const                          ; Loop limiter for safe iteration
	GlobalVariable Property LPSetting_AllowStealing Auto Const                         ; Global toggle to allow looting of owned items
	GlobalVariable Property LPSetting_StealingIsHostile Auto Const                     ; Determines if stealing triggers hostility
	GlobalVariable Property LPSetting_RemoveCorpses Auto Const                         ; Toggle corpse cleanup after looting
	GlobalVariable Property LPSetting_SendTo Auto Const                                ; Global destination mode for looted items
	GlobalVariable Property LPSetting_ContTakeAll Auto Const                           ; Loot all container items regardless of filter
	GlobalVariable Property LPSetting_AllowLootingShip Auto Const                      ; Allow looting from ship-related containers
EndGroup

;-- Auto Unlock Autofill --
Group AutoUnlock_Autofill
	GlobalVariable Property LPSetting_AutoUnlock Auto Const                            ; Toggle automatic unlocking of locked containers
	GlobalVariable Property LPSetting_AutoUnlockSkillCheck Auto Const                  ; Requires perk checks for unlock to proceed
	GlobalVariable Property LockLevel_Advanced Auto Const                              ; Lock level threshold: Advanced
	GlobalVariable Property LockLevel_Expert Auto Const                                ; Lock level threshold: Expert
	GlobalVariable Property LockLevel_Inaccessible Auto Const                          ; Lock level: Inaccessible (never unlock)
	GlobalVariable Property LockLevel_Master Auto Const                                ; Lock level threshold: Master
	GlobalVariable Property LockLevel_Novice Auto Const                                ; Lock level threshold: Novice
	GlobalVariable Property LockLevel_RequiresKey Auto Const                           ; Lock cannot be picked, key required
	Faction Property PlayerFaction Auto Const                                          ; Used to evaluate ownership and faction rules
	ConditionForm Property Perk_CND_AdvancedLocksCheck Auto Const                      ; Condition: Advanced lockpicking perk
	ConditionForm Property Perk_CND_ExpertLocksCheck Auto Const                        ; Condition: Expert lockpicking perk
	ConditionForm Property Perk_CND_MasterLocksCheck Auto Const                        ; Condition: Master lockpicking perk
	MiscObject Property Digipick Auto Const                                            ; Digipick item used in unlocking logic
EndGroup

;-- List Autofill --
Group List_Autofill
	FormList Property LPSystem_Looting_Globals Auto Const                              ; Central config list for looting rules
	FormList Property LPSystem_Looting_Lists Auto Const                                ; List of filterable loot categories
EndGroup

;-- Miscellaneous Properties --
Group Misc
	Keyword Property SpaceshipInventoryContainer Auto Const                            ; Keyword identifying ship inventory containers
	Keyword Property SQ_ShipDebrisKeyword Auto Const                                   ; Keyword for identifying debris-based loot targets
	Keyword Property LPKeyword_Asteroid Auto Const                                     ; Keyword for asteroid-related loot references
	Armor Property LP_Skin_Naked_NOTPLAYABLE Auto Const Mandatory
	Keyword Property LPKeyword_LootedCorpse Auto Const
	Race Property HumanRace Auto Const Mandatory
EndGroup

;-- Destination Locations --
Group DestinationLocations
	ObjectReference Property PlayerRef Auto Const                                      ; Reference to the player actor
	ObjectReference Property LodgeSafeRef Auto Const                                   ; Optional storage safe (e.g., Lodge)
	ObjectReference Property LPDummyHoldingRef Auto Const                              ; Dummy holding container used for staging transfers
	ReferenceAlias Property PlayerHomeShip Auto Const Mandatory                        ; Reference to the player's home ship alias
EndGroup

;-- No Loot Locations --
Group NoLootLocations
	FormList Property LPFilter_NoLootLocations Auto Const                              ; Locations where looting is explicitly disallowed
	LocationAlias Property playerShipInterior Auto Const Mandatory                     ; Alias for the player ship interior space
EndGroup

;-- No Fill Settings --
Group NoFill
	Int Property lootTimerID = 1 Auto                                                  ; Timer index for loop execution
	Float Property lootTimerDelay = 0.1 Auto                                           ; Interval delay between loot scans
	Bool Property bAllowStealing = False Auto                                          ; Local override to allow stealing
	Bool Property bStealingIsHostile = False Auto                                      ; Local override for hostile response to theft
	Bool Property bTakeAll = False Auto                                                ; Overrides filter and loots everything
	ObjectReference Property theLooterRef Auto                                         ; Reference to the active looter (e.g., player or activator)
EndGroup

;======================================================================
; VARIABLES
;======================================================================

Bool bIsLooting = False

;======================================================================
; EVENTS
;======================================================================

;======================================================================
; EVENT: OnInit
; Purpose : Logs initialization when script loads
;======================================================================
Event OnInit()
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("LootEffectScript: OnInit triggered.", 1, "LootEffectScript")
    EndIf
EndEvent

;======================================================================
; EVENT: OnEffectStart
; Purpose : Triggered by the magic effect; starts loot scan timer
;======================================================================
Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("LootEffectScript: OnEffectStart triggered.", 1, "LootEffectScript")
    EndIf
    StartTimer(lootTimerDelay, lootTimerID)
EndEvent

;======================================================================
; EVENT: OnTimer
; Purpose : Timer-based scan execution. If loot targets found,
;           passes them and the active loot list to the processor.
;======================================================================
Event OnTimer(Int aiTimerID)
    If aiTimerID == lootTimerID && !bIsLooting
        bIsLooting = True

        If Logger && Logger.IsEnabled()
            Logger.LogAdv("LootEffectScript: Timer triggered. Beginning scan.", 1, "LootEffectScript")
        EndIf

        ; Ensure valid list is assigned
        If ActiveLootList != None
            ObjectReference[] lootTargets = LootScanner.FindLootTargets(PlayerRef, LPSetting_Radius.GetValue(), LPSystemUtil_LoopCap.GetValueInt())

            If lootTargets != None && lootTargets.Length > 0
                If Logger && Logger.IsEnabled()
                    Logger.LogAdv("LootEffectScript: Loot targets found. Processing.", 1, "LootEffectScript")
                EndIf
                LootProcessor.ProcessTargets(lootTargets, PlayerRef, ActiveLootList)
            Else
                If Logger && Logger.IsEnabled()
                    Logger.LogAdv("LootEffectScript: No loot targets found.", 2, "LootEffectScript")
                EndIf
            EndIf
        Else
            If Logger && Logger.IsEnabled()
                Logger.LogAdv("LootEffectScript: ActiveLootList is None. Aborting.", 3, "LootEffectScript")
            EndIf
        EndIf

        bIsLooting = False
    EndIf

    StartTimer(lootTimerDelay, lootTimerID)
EndEvent