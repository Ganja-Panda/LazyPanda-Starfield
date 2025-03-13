;======================================================================
; Script: LZP:SystemScript
; Description: This script provides various utility functions for the Lazy Panda mod.
; It includes functions for opening inventories, moving items, and reporting status.
; Debug logging is integrated to assist with troubleshooting.
;======================================================================

ScriptName LZP:SystemScript Extends ScriptObject

;======================================================================
; HELPER FUNCTIONS
;======================================================================

;-- Log Function --
; Logs a message if the global debug setting is enabled.
Function Log(String logMsg) Global
    GlobalVariable LPSystemUtil_Debug = Game.GetFormFromFile(0x0ABC, "LazyPanda.esm") as GlobalVariable

    If LPSystemUtil_Debug.GetValue() == 1.0
        Debug.Trace(logMsg, 0)
        ReportStatus()
    EndIf
EndFunction

;======================================================================
; MAIN FUNCTIONS
;======================================================================

;-- OpenHoldingInventory Function --
; Opens the inventory of the dummy holding container.
; cgf "LZP:SystemScript.OpenHoldingInventory"
Function OpenHoldingInventory() Global
    Log("[Lazy Panda] OpenHoldingInventory called")
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x09C1, "LazyPanda.esm") as ObjectReference
    (LPDummyHoldingRef as Actor).OpenInventory(True, None, False)
EndFunction

;-- OpenLodgeSafe Function --
; Opens the lodge safe container.
; cgf "LZP:SystemScript.OpenLodgeSafe"
Function OpenLodgeSafe() Global
    Log("[Lazy Panda] OpenLodgeSafe called")
    ObjectReference LodgeSafeRef = Game.GetForm(0x269A1) as ObjectReference
    LodgeSafeRef.Activate(Game.GetPlayer() as ObjectReference, False)
EndFunction

;-- OpenShipCargo Function --
; Opens the inventory of the player's ship.
; cgf "LZP:SystemScript.OpenShipCargo"
Function OpenShipCargo() Global
    Log("[Lazy Panda] OpenShipCargo called")
    Quest SQ_PlayerShip = Game.GetForm(0x17452) as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    spaceshipreference PlayerShip = PlayerHomeShip.GetRef() as spaceshipreference
    PlayerShip.OpenInventory()
EndFunction

;-- MoveAllToShip Function --
; Moves all items from the dummy holding container to the player's ship.
; cgf "LZP:SystemScript.MoveAllToShip"
Function MoveAllToShip() Global
    Log("[Lazy Panda] MoveAllToShip called")
    Message LPAllItemsToShipMsg = Game.GetFormFromFile(0x091D, "LazyPanda.esm") as Message
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x09C1, "LazyPanda.esm") as ObjectReference
    Quest SQ_PlayerShip = Game.GetForm(0x17452) as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    ObjectReference PlayerShip = PlayerHomeShip.GetRef()
    LPDummyHoldingRef.RemoveAllItems(PlayerShip, False, False)
    LPAllItemsToShipMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction

;-- MoveResourcesToShip Function --
; Moves resources from both the dummy holding container and the player to the ship.
; cgf "LZP:SystemScript.MoveResourcesToShip"
Function MoveResourcesToShip() Global
    Log("[Lazy Panda] MoveResourcesToShip called")
    Message LPResourcesToShipMsg = Game.GetFormFromFile(0x091E, "LazyPanda.esm") as Message
    FormList LPSystem_Script_Resources = Game.GetFormFromFile(0x08C9, "LazyPanda.esm") as FormList
    Quest SQ_PlayerShip = Game.GetForm(0x17452) as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    ObjectReference PlayerShip = PlayerHomeShip.GetRef()
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x09C1, "LazyPanda.esm") as ObjectReference
    LPDummyHoldingRef.RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
    Game.GetPlayer().RemoveItem(LPSystem_Script_Resources as Form, -1, True, PlayerShip)
    LPResourcesToShipMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction

;-- MoveValuablesToPlayer Function --
; Moves valuables from the player's ship and the dummy holding container to the player.
; cgf "LZP:SystemScript.MoveValuablesToPlayer"
Function MoveValuablesToPlayer() Global
    Log("[Lazy Panda] MoveValuablesToPlayer called")
    Message LPValuablesToPlayerMsg = Game.GetFormFromFile(0x091F, "LazyPanda.esm") as Message
    FormList LPSystem_Script_Valuables = Game.GetFormFromFile(0x08CA, "LazyPanda.esm") as FormList
    Quest SQ_PlayerShip = Game.GetForm(0x17452) as Quest
    ReferenceAlias PlayerHomeShip = SQ_PlayerShip.GetAlias(16) as ReferenceAlias
    ObjectReference PlayerShip = PlayerHomeShip.GetRef()
    ObjectReference LPDummyHoldingRef = Game.GetFormFromFile(0x09C1, "LazyPanda.esm") as ObjectReference
    PlayerShip.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference)
    LPDummyHoldingRef.RemoveItem(LPSystem_Script_Valuables as Form, -1, True, Game.GetPlayer() as ObjectReference)
    LPValuablesToPlayerMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
EndFunction

;-- OpenTerminal Function --
; Opens the terminal object.
; cgf "LZP:SystemScript.OpenTerminal"
Function OpenTerminal() Global
    Log("[Lazy Panda] OpenTerminal called")
    ObjectReference TerminalRef = Game.GetFormFromFile(0x08CD, "LazyPanda.esm") as ObjectReference
    
    If TerminalRef
        TerminalRef.Activate(Game.GetPlayer() as ObjectReference, False)
    Else
        Log("[Lazy Panda] TerminalRef is invalid")
    EndIf
EndFunction

;-- ReportStatus Function --
; Reports the status of various perks, magic effects, and global variables.
; cgf "LZP:SystemScript.ReportStatus"
Function ReportStatus() Global
    GlobalVariable LPSystemUtil_Debug = Game.GetFormFromFile(0x0ABC, "LazyPanda.esm") as GlobalVariable
    Log("[Lazy Panda] ReportStatus called")
    FormList LPSystem_Script_Perks = Game.GetFormFromFile(0x08C8, "LazyPanda.esm") as FormList
    Int perkCount = LPSystem_Script_Perks.GetSize()
    Log("[Lazy Panda] Reporting Perks:")
    Int I = 0
    
    While I < perkCount
        Perk currentPerk = LPSystem_Script_Perks.GetAt(I) as Perk
        If currentPerk
            Bool hasPerk = Game.GetPlayer().hasPerk(currentPerk)
            If hasPerk
                Log(("[Lazy Panda] Perk: " + currentPerk as String) + " - Enabled: " + hasPerk as String)
            Else
                Log(("[Lazy Panda] Perk: " + currentPerk as String) + " - Disabled")
            EndIf
        EndIf
        I += 1
    EndWhile
    
    FormList LPSystemUtil_Debug_MagicEffects = Game.GetFormFromFile(0x08E1, "LazyPanda.esm") as FormList
    Int magicEffectCount = LPSystemUtil_Debug_MagicEffects.GetSize()
    Log("[Lazy Panda] Reporting Magic Effects:")
    Int j = 0
    
    While j < magicEffectCount
        MagicEffect currentMagicEffect = LPSystemUtil_Debug_MagicEffects.GetAt(j) as MagicEffect
        If currentMagicEffect
            Bool hasMagicEffect = Game.GetPlayer().hasMagicEffect(currentMagicEffect)
            If hasMagicEffect
                Log(("[Lazy Panda] Magic Effect: " + currentMagicEffect as String) + " - Enabled: " + hasMagicEffect as String)
            Else
                Log(("[Lazy Panda] Magic Effect: " + currentMagicEffect as String) + " - Disabled")
            EndIf
        EndIf
        j += 1
    EndWhile
    
    FormList LPSystem_Loot_Globals = Game.GetFormFromFile(0x08B9, "LazyPanda.esm") as FormList
    Int globalCount = LPSystem_Loot_Globals.GetSize()
    Log("[Lazy Panda] Reporting Globals:")
    Int k = 0
    
    While k < globalCount
        GlobalVariable currentGlobal = LPSystem_Loot_Globals.GetAt(k) as GlobalVariable
        If currentGlobal
            Log(("[Lazy Panda] Global: " + currentGlobal as String) + " - Value: " + currentGlobal.GetValue() as String)
        EndIf
        k += 1
    EndWhile
EndFunction