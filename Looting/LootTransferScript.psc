;======================================================================
; Script Name   : LZP:Looting:LootTransferScript
; Author        : Ganja Panda
; Description   : Handles destination routing of looted items based on
;                 configuration. Routes to player, safe, ship, or dummy.
;======================================================================

ScriptName LZP:Looting:LootTransferScript Extends Quest Hidden

;======================================================================
; PROPERTIES
;======================================================================
GlobalVariable Property LPSetting_SendTo Auto Const Mandatory       ; 1 = Player, 2 = Lodge Safe, 3 = Dummy, 4 = Ship
ObjectReference Property PlayerRef Auto Const Mandatory
ObjectReference Property LodgeSafeRef Auto Const
ObjectReference Property LPDummyHoldingRef Auto Const
ReferenceAlias Property PlayerHomeShip Auto Const
LZP:Debug:LoggerScript Property Logger Auto Const

;======================================================================
; FUNCTION: GetDestination
; @return : Reference to destination container or player
;======================================================================
ObjectReference Function GetDestination()
    Int mode = LPSetting_SendTo.GetValue() as Int

    If mode == 1
        Log("Routing to Player")
        Return PlayerRef
    ElseIf mode == 2
        Log("Routing to Lodge Safe")
        Return LodgeSafeRef
    ElseIf mode == 3
        Log("Routing to Dummy Holding")
        Return LPDummyHoldingRef
    ElseIf mode == 4
        ObjectReference shipRef = PlayerHomeShip.GetRef()
        If shipRef
            Log("Routing to Player Ship")
            Return shipRef
        EndIf
    EndIf

    Log("Routing failed: No valid destination.")
    Return None
EndFunction

;======================================================================
; FUNCTION: TransferItem
; @param itemForm : Item to transfer
; @param count    : Quantity to transfer (-1 = all)
; @param source   : Source container or ref
;======================================================================
Function TransferItem(Form itemForm, Int count, ObjectReference source)
    ObjectReference destination = GetDestination()
    If destination && itemForm && source
        source.RemoveItem(itemForm, count, True, destination)
        Log("Transferred: " + itemForm + " x" + count as String)
    Else
        Log("Transfer failed: Invalid source or destination")
    EndIf
EndFunction

;======================================================================
; FUNCTION: Log
;======================================================================
Function Log(String msg)
    If Logger && Logger.IsEnabled()
        Logger.Log("LootTransfer: " + msg)
    EndIf
EndFunction
