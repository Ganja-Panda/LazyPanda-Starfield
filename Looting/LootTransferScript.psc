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

GlobalVariable Property LZP_Setting_SendTo Auto Const Mandatory       ; 1 = Player, 2 = Lodge Safe, 3 = Dummy, 4 = Ship
ObjectReference Property PlayerRef Auto Const Mandatory             ; Player reference
ObjectReference Property LodgeSafeRef Auto Const                    ; Lodge safe reference
ObjectReference Property LZP_Cont_StorageRef Auto Const               ; Dummy holding reference
ReferenceAlias Property PlayerHomeShip Auto Const                   ; Player home ship reference
LZP:Debug:LoggerScript Property Logger Auto Const                   ; Debug logger

;======================================================================
; GET DESTINATION LOGIC
;======================================================================
ObjectReference Function GetDestination()
    Int mode = LZP_Setting_SendTo.GetValueInt()

    If mode == 1
        Logger.LogAdv("Routing to [Player]", 1, "LootTransferScript")
        Return PlayerRef
    ElseIf mode == 2
        Logger.LogAdv("Routing to [Lodge Safe]", 1, "LootTransferScript")
        Return LodgeSafeRef
    ElseIf mode == 3
        Logger.LogAdv("Routing to [Dummy Holding]", 1, "LootTransferScript")
        Return LZP_Cont_StorageRef
    ElseIf mode == 4
        ObjectReference shipRef = PlayerHomeShip.GetRef()
        If shipRef
            Logger.LogAdv("Routing to [Player Ship]", 1, "LootTransferScript")
            Return shipRef
        Else
            Logger.LogAdv("Ship reference is None. Cannot route to ship.", 2, "LootTransferScript")
        EndIf
    Else
        Logger.LogAdv("Unknown routing mode.", 2, "LootTransferScript")
    EndIf

    Logger.LogAdv("Routing failed: No valid destination available. Defaulting to [Player]", 2, "LootTransferScript")
    Return PlayerRef
EndFunction

;======================================================================
; TRANSFER ITEM LOGIC
;======================================================================
Function TransferItem(Form itemForm, Int count, ObjectReference source)
    ObjectReference destination = GetDestination()

    If destination == None
        Logger.LogAdv("Transfer failed: No destination resolved.", 3, "LootTransferScript")
        Return
    EndIf

    If itemForm == None
        Logger.LogAdv("Transfer failed: itemForm is None.", 3, "LootTransferScript")
        Return
    EndIf

    If source == None
        Logger.LogAdv("Transfer failed: source is None.", 3, "LootTransferScript")
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

    Logger.LogAdv("Transferred: " + (itemForm as String) + " " + qtyString + " → " + destName, 1, "LootTransferScript")
EndFunction
