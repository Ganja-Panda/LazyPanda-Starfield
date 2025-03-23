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

Group ModuleDependencies
	LZP:Debug:LoggerScript Property Logger Auto Const
EndGroup

Group ScannerFilters
	Keyword Property SQ_ShipDebrisKeyword Auto Const
	Keyword Property SpaceshipInventoryContainer Auto Const
	Keyword Property LPKeyword_Asteroid Auto Const
	FormList Property LPFilter_NoLootLocations Auto Const
	LocationAlias Property playerShipInterior Auto Const Mandatory
EndGroup

;======================================================================
; FUNCTIONS
;======================================================================

ObjectReference[] Function FindLootTargets(ObjectReference origin, Float radius, Int loopCap)
	If Logger && Logger.IsEnabled()
		Logger.Log("LootScanner: Entering FindLootTargets().")
	EndIf

	If origin == None
		If Logger && Logger.IsEnabled()
			Logger.Log("LootScanner: Origin reference is None.")
		EndIf
		Return None
	EndIf

	Location playerLoc = origin.GetCurrentLocation()
	If Logger && Logger.IsEnabled()
		Logger.Log("LootScanner: Scanning within radius: " + radius)
	EndIf

	ObjectReference[] foundRefs = origin.FindAllReferencesOfType("ObjectReference", radius)
	ObjectReference[] validRefs = new ObjectReference[0]

	If foundRefs == None || foundRefs.Length == 0
		If Logger && Logger.IsEnabled()
			Logger.Log("LootScanner: No nearby references found.")
		EndIf
		Return validRefs
	EndIf

	Int i = 0
	Int added = 0
	While i < foundRefs.Length && added < loopCap
		ObjectReference ref = foundRefs[i]
		If Logger && Logger.IsEnabled()
			Logger.Log("LootScanner: Evaluating reference at index " + i + ": " + ref)
		EndIf

		If ref != None && IsLootable(ref, playerLoc)
			validRefs.Add(ref)
			added += 1
		EndIf
		i += 1
	EndWhile

	If Logger && Logger.IsEnabled()
		Logger.Log("LootScanner: Found " + validRefs.Length + " valid lootable targets.")
	EndIf

	Return validRefs
EndFunction

Bool Function IsLootable(ObjectReference ref, Location playerLoc)
	If ref == None
		If Logger && Logger.IsEnabled()
			Logger.Log("LootScanner: Skipping null reference.")
		EndIf
		Return false
	EndIf

	Location loc = ref.GetCurrentLocation()
	If loc == playerShipInterior.GetLocation() || LPFilter_NoLootLocations.HasForm(loc)
		If Logger && Logger.IsEnabled()
			Logger.Log("LootScanner: Reference excluded due to restricted location.")
		EndIf
		Return false
	EndIf

	Form baseForm = ref.GetBaseObject()
	If baseForm == None
		If Logger && Logger.IsEnabled()
			Logger.Log("LootScanner: Skipping invalid base form.")
		EndIf
		Return false
	EndIf

	If ref.HasKeyword(SQ_ShipDebrisKeyword) || ref.HasKeyword(SpaceshipInventoryContainer) || ref.HasKeyword(LPKeyword_Asteroid)
		If Logger && Logger.IsEnabled()
			Logger.Log("LootScanner: Looting ship debris, container, or asteroid reference.")
		EndIf
		Return True
	EndIf

	Return True
EndFunction
