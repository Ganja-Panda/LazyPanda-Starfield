;======================================================================
; Script Name   : LZP:Looting:LootFilterScript
; Author        : Ganja Panda
; Description   : Evaluates whether specific items should be looted
;                 based on FormList + GlobalVariable control pairs.
;======================================================================

ScriptName LZP:Looting:LootFilterScript Extends Quest Hidden

;======================================================================
; PROPERTIES
;======================================================================
FormList Property LPSystem_Looting_Lists Auto Const Mandatory      ; Each list contains lootable items
FormList Property LPSystem_Looting_Globals Auto Const Mandatory    ; Each Global (1.0 = enabled) matches list index
GlobalVariable Property LPSystemUtil_LoopCap Auto Const Mandatory
LZP:Debug:LoggerScript Property Logger Auto Const

;======================================================================
; FUNCTION: ShouldLoot
; @param targetForm : The form (item) being considered for looting
; @return           : True if the item should be taken
;======================================================================
Bool Function ShouldLoot(Form targetForm)
    Int cap = LPSystemUtil_LoopCap.GetValueInt()
    Int listSize = LPSystem_Looting_Lists.GetSize()
    Int index = 0

    While index < listSize && index < cap
        FormList itemList = LPSystem_Looting_Lists.GetAt(index) as FormList
        GlobalVariable flag = LPSystem_Looting_Globals.GetAt(index) as GlobalVariable

        If itemList && flag
            Float enabled = flag.GetValue()
            If enabled == 1.0 && itemList.HasForm(targetForm)
                Log("Filter: Loot allowed for form: " + targetForm)
                Return True
            EndIf
        EndIf
        index += 1
    EndWhile

    Log("Filter: Loot denied for form: " + targetForm)
    Return False
EndFunction

;======================================================================
; FUNCTION: Log
;======================================================================
Function Log(String msg)
    If Logger && Logger.IsEnabled()
        Logger.Log("LootFilter: " + msg)
    EndIf
EndFunction
