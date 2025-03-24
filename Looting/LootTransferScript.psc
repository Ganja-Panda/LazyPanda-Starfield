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
ObjectReference Property PlayerRef Auto Const Mandatory             ; Player reference
ObjectReference Property LodgeSafeRef Auto Const                    ; Lodge safe reference
ObjectReference Property LPDummyHoldingRef Auto Const               ; Dummy holding reference
ReferenceAlias Property PlayerHomeShip Auto Const                   ; Player home ship reference
LZP:Debug:LoggerScript Property Logger Auto Const                   ; Debug logger

;======================================================================
; GET DESTINATION LOGIC
;======================================================================
ObjectReference Function GetDestination()
    Int mode = LPSetting_SendTo.GetValueInt()

    If mode == 1
        Log("Routing to [Player]", 1)
        Return PlayerRef
    ElseIf mode == 2
        Log("Routing to [Lodge Safe]", 1)
        Return LodgeSafeRef
    ElseIf mode == 3
        Log("Routing to [Dummy Holding]", 1)
        Return LPDummyHoldingRef
    ElseIf mode == 4
        ObjectReference shipRef = PlayerHomeShip.GetRef()
        If shipRef
            Log("Routing to [Player Ship]", 1)
            Return shipRef
        Else
            Log("Ship reference is None. Cannot route to ship.", 2)
        EndIf
    Else
        Log("Unknown routing mode.", 2)
    EndIf

    Log("Routing failed: No valid destination available. Defaulting to [Player]", 2)
    Return PlayerRef
EndFunction

;======================================================================
; TRANSFER ITEM LOGIC
;======================================================================
Function TransferItem(Form itemForm, Int count, ObjectReference source)
    ObjectReference destination = GetDestination()

    If destination == None
        Log("Transfer failed: No destination resolved.", 3)
        Return
    EndIf

    If itemForm == None
        Log("Transfer failed: itemForm is None.", 3)
        Return
    EndIf

    If source == None
        Log("Transfer failed: source is None.", 3)
        Return
    EndIf

    source.RemoveItem(itemForm, count, True, destination)

    String qtyString
    If count == -1
        qtyString = "[ALL]"
    Else
        qtyString = "x" + (count as String)
    EndIf

    String destName = destination as String

    Log("Transferred: " + (itemForm as String) + " " + qtyString + " → " + destName, 1)
EndFunction

;======================================================================
; INTERNAL LOGGING WRAPPER WITH SEVERITY SUPPORT
;======================================================================
Function Log(String msg, Int severity = 1)
    If Logger && Logger.IsEnabled()
        String prefix = "[INFO] "
        If severity == 2
            prefix = "[WARN] "
        ElseIf severity == 3
            prefix = "[ERROR] "
        EndIf
        Logger.Log("LootTransfer: " + prefix + msg)
    EndIf
EndFunction
