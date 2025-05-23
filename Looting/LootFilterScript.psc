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
FormList Property LZP_System_Looting_Lists Auto Const Mandatory       ; Each list contains lootable items
FormList Property LZP_System_Looting_Globals Auto Const Mandatory     ; Each Global (1.0 = enabled) matches list index
GlobalVariable Property LZP_System_LoopCap Auto Const Mandatory       ; Maximum number of lists to check
LZP:Debug:LoggerScript Property Logger Auto Const                     ; Debug logger

;======================================================================
; FUNCTION: ShouldLoot
; @param targetForm : The form (item) being considered for looting
; @return           : True if the item should be taken
;======================================================================
Bool Function ShouldLoot(Form targetForm)
    Int cap = LZP_System_LoopCap.GetValueInt()
    Int listSize = LZP_System_Looting_Lists.GetSize()
    Int index = 0

    While index < listSize && index < cap
        FormList itemList = LZP_System_Looting_Lists.GetAt(index) as FormList
        GlobalVariable flag = LZP_System_Looting_Globals.GetAt(index) as GlobalVariable

        If itemList && flag
            Float enabled = flag.GetValue()
            If enabled == 1.0 && itemList.HasForm(targetForm)
                LogAdv("Filter: Loot allowed for form: " + targetForm, 1)
                Return True
            EndIf
        EndIf
        index += 1
    EndWhile

    LogAdv("Filter: Loot denied for form: " + targetForm, 2)
    Return False
EndFunction

;======================================================================
; FUNCTION: LogAdv
; Purpose : Logs messages with severity and tagging
;======================================================================
Function LogAdv(String msg, Int severity = 1)
    If Logger && Logger.IsEnabled()
        Logger.LogAdv(msg, severity, "LootFilterScript")
    EndIf
EndFunction