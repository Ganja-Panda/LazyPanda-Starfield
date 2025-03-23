;======================================================================
; Script Name   : LZP:Looting:LootScannerScript
; Author        : Ganja Panda
; Description   : Scans for lootable references based on keyword or
;                 reference type. Designed to be called from external
;                 controller (LootEffectScript).
;======================================================================

ScriptName LZP:Looting:LootScannerScript Extends Quest Hidden

;======================================================================
; PROPERTIES
;======================================================================
FormList Property LootKeywords Auto Const Mandatory
Keyword Property DefaultLootKeyword Auto Const
LZP:Debug:LoggerScript Property Logger Auto Const

;======================================================================
; FUNCTION: FindLootTargets
; @param originRef   : Player or center reference
; @param radius      : Max search radius
; @param loopCap     : Max iterations (safety)
; @return            : Array of ObjectReferences found
;======================================================================
ObjectReference[] Function FindLootTargets(ObjectReference originRef, Float radius, Int loopCap)
    If Logger && Logger.IsEnabled()
        Logger.Log("LootScanner: Scanning started with radius: " + radius as String)
    EndIf

    ObjectReference[] foundRefs = new ObjectReference[0]
    Int i = 0

    While i < LootKeywords.GetSize() && i < loopCap
        Keyword lootTag = LootKeywords.GetAt(i) as Keyword
        If lootTag
            ObjectReference[] batch = originRef.FindAllReferencesWithKeyword(lootTag, radius)
            If batch && batch.Length > 0
                foundRefs += batch
            EndIf
        EndIf
        i += 1
    EndWhile

    If foundRefs.Length == 0 && DefaultLootKeyword
        foundRefs = originRef.FindAllReferencesWithKeyword(DefaultLootKeyword, radius)
    EndIf

    If Logger && Logger.IsEnabled()
        Logger.Log("LootScanner: Total references found: " + foundRefs.Length as String)
    EndIf
    Return foundRefs
EndFunction
