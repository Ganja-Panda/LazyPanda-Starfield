;======================================================================
; Script Name   : LZP:Looting:LootScannerScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Scans surrounding area for valid loot targets based on
;                 distance, keywords, and actor/container filters.
;======================================================================

ScriptName LZP:Looting:LootScannerScript Extends Quest Hidden

;======================================================================
; PROPERTIES
;======================================================================

;-- Logger
Group ModuleDependencies
	LZP:Debug:LoggerScript Property Logger Auto Const                           ; Logger module for debug tracking
EndGroup

;-- Filtering Settings
Group ScannerFilters
	Keyword Property SQ_ShipDebrisKeyword Auto Const                            ; Keyword to detect ship debris
	Keyword Property SpaceshipInventoryContainer Auto Const                     ; Keyword for ship inventory containers
	Keyword Property LPKeyword_Asteroid Auto Const                              ; Keyword for asteroid targets
	FormList Property LPFilter_NoLootLocations Auto Const                       ; List of location types to ignore
	LocationAlias Property playerShipInterior Auto Const Mandatory              ; Player's ship interior to exclude from scanning
EndGroup

;======================================================================
; FUNCTIONS
;======================================================================

;======================================================================
; FUNCTION: FindLootTargets
; Purpose : Gathers all lootable ObjectReferences near the player
; Params  : origin - starting reference (typically the player)
;         : radius - search distance
;         : loopCap - max targets to evaluate
;======================================================================
ObjectReference[] Function FindLootTargets(ObjectReference origin, Float radius, Int loopCap)
	If origin == None
		If Logger && Logger.IsEnabled()
	Logger.Log("LootScanner: Entering function.")
			Logger.Log("LootScanner: Origin reference is None.")
		EndIf
		Logger.Log("LootScanner: No references found.")
	Return None
	EndIf

	Location playerLoc = origin.GetCurrentLocation()
	Logger.Log("LootScanner: Scanning for references within radius: " + radius + " units.")
	ObjectReference[] foundRefs = origin.FindAllReferencesOfType("ObjectReference", radius)
	ObjectReference[] validRefs = new ObjectReference[0]

	If foundRefs == None || foundRefs.Length == 0
		If Logger && Logger.IsEnabled()
	Logger.Log("LootScanner: Entering function.")
			Logger.Log("LootScanner: No nearby references found.")
		EndIf
		Logger.Log("LootScanner: Found " + validRefs.Length + " valid lootable targets.")
	Return validRefs
	EndIf

	Int i = 0
	Int added = 0
	While i < foundRefs.Length && added < loopCap
		Logger.Log("LootScanner: Evaluating reference at index " + i + ": " + ref)
	ObjectReference ref = foundRefs[i]
		If ref != None && IsLootable(ref, playerLoc)
			validRefs.Add(ref)
			added += 1
		EndIf
		i += 1
	EndWhile

	If Logger && Logger.IsEnabled()
	Logger.Log("LootScanner: Entering function.")
		Logger.Log("LootScanner: Found " + validRefs.Length + " valid lootable targets.")
	EndIf

	Logger.Log("LootScanner: Found " + validRefs.Length + " valid lootable targets.")
	Return validRefs
EndFunction

;======================================================================
; FUNCTION: IsLootable
; Purpose : Checks if the reference is valid for looting
;======================================================================
Bool Function IsLootable(ObjectReference ref, Location playerLoc)
	If ref == None
	Logger.Log("LootScanner: Skipping null reference.")
		Return false
	EndIf

	; Exclude if in restricted location
	Location loc = ref.GetCurrentLocation()
	If loc == playerShipInterior.GetLocation() || LPFilter_NoLootLocations.HasForm(loc)
	Logger.Log("LootScanner: Reference excluded due to restricted location.")
		Return false
	EndIf

	Form baseForm = ref.GetBaseObject()

	If baseForm == None
	Logger.Log("LootScanner: Skipping invalid base form.")
		Return false
	EndIf

	; Skip if tagged as ship debris or non-lootable
	If ref.HasKeyword(SQ_ShipDebrisKeyword) || ref.HasKeyword(SpaceshipInventoryContainer) || ref.HasKeyword(LPKeyword_Asteroid)
	Logger.Log("LootScanner: Looting ship debris, container, or asteroid reference.")
		Return True
	EndIf

	Return True
EndFunction
