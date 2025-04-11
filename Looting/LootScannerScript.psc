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
    LZP:Debug:LoggerScript Property Logger Auto Const               ; Debug logger
EndGroup

Group ScannerFilters
    Keyword Property SQ_ShipDebrisKeyword Auto Const                ; Keyword for ship debris
    Keyword Property SpaceshipInventoryContainer Auto Const         ; Keyword for spaceship inventory
    Keyword Property LPKeyword_Asteroid Auto Const                  ; Keyword for asteroid
    FormList Property LPFilter_NoLootLocations Auto Const           ; List of locations to exclude
    LocationAlias Property playerShipInterior Auto Const Mandatory  ; Player's ship interior location
EndGroup

Group ScanTargetTypes
    FormList Property ActiveLootList Auto Const                     ; List of lootable base forms to scan for
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
    If Logger && Logger.IsEnabled()
        Logger.LogAdv("LootScanner: Entering FindLootTargets().", 1, "LootScannerScript")
    EndIf

    If origin == None
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("LootScanner: Origin is None. Aborting scan.", 3, "LootScannerScript")
        EndIf
        Return None
    EndIf

    ObjectReference[] foundRefs = new ObjectReference[0]
    ObjectReference[] validRefs = new ObjectReference[0]

    If Logger && Logger.IsEnabled()
        Logger.LogAdv("LootScanner: Beginning scan at radius " + (radius as String), 1, "LootScannerScript")
    EndIf

    Int count = ActiveLootList.GetSize()
    Int i = 0
    While i < count
        Form currentForm = ActiveLootList.GetAt(i)
        ObjectReference[] localRefs = origin.FindAllReferencesOfType(currentForm, radius)

        If localRefs != None
            Int j = 0
            While j < localRefs.Length
                foundRefs.Add(localRefs[j])
                j += 1
            EndWhile
            If Logger && Logger.IsEnabled()
                Int foundCount = localRefs.Length
                Logger.LogAdv("LootScanner: Found " + (foundCount as String) + " refs for type index " + (i as String), 1, "LootScannerScript")
            EndIf
        EndIf
        i += 1
    EndWhile

    If Logger && Logger.IsEnabled()
        Int totalCount = foundRefs.Length
        Logger.LogAdv("LootScanner: Total found before filtering: " + (totalCount as String), 1, "LootScannerScript")
    EndIf

    If foundRefs == None || foundRefs.Length == 0
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("LootScanner: No references detected in radius.", 2, "LootScannerScript")
        EndIf
        Return validRefs
    EndIf

    Location playerLoc = origin.GetCurrentLocation()
    Int added = 0
    Int index = 0

    While index < foundRefs.Length && added < loopCap
        ObjectReference ref = foundRefs[index]

        If Logger && Logger.IsEnabled()
            Logger.LogAdv("LootScanner: Evaluating reference index " + (index as String) + ": " + ref, 1, "LootScannerScript")
        EndIf

        If ref != None && IsLootable(ref, playerLoc)
            validRefs.Add(ref)
            added += 1
        EndIf

        index += 1
    EndWhile

    If Logger && Logger.IsEnabled()
        Logger.LogAdv("LootScanner: Final valid target count: " + (validRefs.Length as String), 1, "LootScannerScript")
    EndIf

    Return validRefs
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
    If ref == None
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("LootScanner: Skipping None reference.", 2, "LootScannerScript")
        EndIf
        Return False
    EndIf

    Location loc = ref.GetCurrentLocation()
    If loc == playerShipInterior.GetLocation() || LPFilter_NoLootLocations.HasForm(loc)
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("LootScanner: Excluded due to ship interior or restricted location.", 2, "LootScannerScript")
        EndIf
        Return False
    EndIf

    Form baseForm = ref.GetBaseObject()
    If baseForm == None
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("LootScanner: Skipping reference with invalid base form.", 2, "LootScannerScript")
        EndIf
        Return False
    EndIf

    If ref.HasKeyword(SQ_ShipDebrisKeyword) || ref.HasKeyword(SpaceshipInventoryContainer) || ref.HasKeyword(LPKeyword_Asteroid)
        If Logger && Logger.IsEnabled()
            Logger.LogAdv("LootScanner: Reference accepted via special keyword.", 1, "LootScannerScript")
        EndIf
        Return True
    EndIf

    Return True
EndFunction