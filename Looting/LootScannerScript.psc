;======================================================================
; Script Name   : LZP:Looting:LootScannerScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Scans surrounding area for lootable references based on
;                 player location, defined filters, and object types.
; Description   : Uses a FormList of lootable base forms to gather candidate
;                 objects within a radius and applies filter logic.
; Dependencies  : ActiveLootList, LoggerScript, Keyword filters, player ship alias
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

Group ScanTargetTypes
    FormList Property ActiveLootList Auto Const ; List of lootable base forms to scan for
EndGroup

;======================================================================
; FUNCTION: FindLootTargets
; Description : Scans for all object references in range based on loot types
;
; @param origin   - Reference from which to scan (e.g., player)
; @param radius   - Search distance
; @param loopCap  - Max entries to return
; @return         - Array of valid, filtered ObjectReferences
;======================================================================
ObjectReference[] Function FindLootTargets(ObjectReference origin, Float radius, Int loopCap)
    if Logger && Logger.IsEnabled()
        Logger.LogInfo("LootScanner: Entering FindLootTargets().")
    endif

    if origin == None
        if Logger && Logger.IsEnabled()
            Logger.LogError("LootScanner: Origin is None. Aborting scan.")
        endif
        return None
    endif

    ObjectReference[] foundRefs = new ObjectReference[0]
    ObjectReference[] validRefs = new ObjectReference[0]

    if Logger && Logger.IsEnabled()
        Logger.LogInfo("LootScanner: Beginning scan at radius " + (radius as String))
    endif

    int count = ActiveLootList.GetSize()
    int i = 0
    while i < count
        Form currentForm = ActiveLootList.GetAt(i)
        ObjectReference[] localRefs = origin.FindAllReferencesOfType(currentForm, radius)

        if localRefs != None
            int j = 0
            while j < localRefs.Length
                foundRefs.Add(localRefs[j])
                j += 1
            endwhile
            if Logger && Logger.IsEnabled()
                int foundCount = localRefs.Length
                Logger.LogInfo("LootScanner: Found " + (foundCount as String) + " refs for type index " + (i as String))
            endif
        endif
        i += 1
    endwhile

    if Logger && Logger.IsEnabled()
        int totalCount = foundRefs.Length
        Logger.LogInfo("LootScanner: Total found before filtering: " + (totalCount as String))
    endif

    if foundRefs == None || foundRefs.Length == 0
        if Logger && Logger.IsEnabled()
            Logger.LogInfo("LootScanner: No references detected in radius.")
        endif
        return validRefs
    endif

    Location playerLoc = origin.GetCurrentLocation()
    int added = 0
    int index = 0

    while index < foundRefs.Length && added < loopCap
        ObjectReference ref = foundRefs[index]

        if Logger && Logger.IsEnabled()
            Logger.LogInfo("LootScanner: Evaluating reference index " + (index as String) + ": " + ref)
        endif

        if ref != None && IsLootable(ref, playerLoc)
            validRefs.Add(ref)
            added += 1
        endif

        index += 1
    endwhile

    if Logger && Logger.IsEnabled()
        Logger.LogInfo("LootScanner: Final valid target count: " + (validRefs.Length as String))
    endif

    return validRefs
EndFunction

;======================================================================
; FUNCTION: IsLootable
; Description : Applies filters to determine whether a reference is lootable
;
; @param ref        - Reference being evaluated
; @param playerLoc  - Player's current location
; @return           - True if lootable, False if filtered
;======================================================================
Bool Function IsLootable(ObjectReference ref, Location playerLoc)
    if ref == None
        if Logger && Logger.IsEnabled()
            Logger.LogInfo("LootScanner: Skipping None reference.")
        endif
        return false
    endif

    Location loc = ref.GetCurrentLocation()
    if loc == playerShipInterior.GetLocation() || LPFilter_NoLootLocations.HasForm(loc)
        if Logger && Logger.IsEnabled()
            Logger.LogInfo("LootScanner: Excluded due to ship interior or restricted location.")
        endif
        return false
    endif

    Form baseForm = ref.GetBaseObject()
    if baseForm == None
        if Logger && Logger.IsEnabled()
            Logger.LogInfo("LootScanner: Skipping reference with invalid base form.")
        endif
        return false
    endif

    if ref.HasKeyword(SQ_ShipDebrisKeyword) || ref.HasKeyword(SpaceshipInventoryContainer) || ref.HasKeyword(LPKeyword_Asteroid)
        if Logger && Logger.IsEnabled()
            Logger.LogInfo("LootScanner: Reference accepted via special keyword.")
        endif
        return true
    endif

    return true
EndFunction