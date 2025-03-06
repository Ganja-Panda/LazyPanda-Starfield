ScriptName LZP:SystemScript Extends ScriptObject

;====================================================================================
;                            LZP:SystemScript
;====================================================================================
; This script provides various utility functions for the Lazy Panda mod.
; It includes functions to report status for perks, magic effects, and globals;
; manage inventory (opening terminals, moving items between locations);
; and toggle looting functionality.
;
; NOTE: All forms are loaded from the "LazyPanda.esm" file using their FormIDs.
;
; The global debug flag (LPSystem_Debug) controls debug reporting. Since this script 
; is not attached to an object, we define its FormID in the OnInit event.
;====================================================================================

;-- Global Debug Flag -----------------------------------------------
; This global variable is used to control debug reporting. It is defined via its FormID.
GlobalVariable Property LPSystem_Debug Auto    ; Will be assigned in OnInit

;-- Other Properties -----------------------------------------------
Actor      Property PlayerRef            Auto Const Mandatory
FormList   Property LPSystem_Script_Perks  Auto Const Mandatory
GlobalVariable Property LPVersion_Major   Auto Const Mandatory
GlobalVariable Property LPVersion_Minor    Auto Const Mandatory

;-- Timer Properties -----------------------------------------------
Float Property checkInterval = 10.0 Auto ; Interval in seconds to check the debug flag

;====================================================================================
; Initialization
;====================================================================================

Event OnInit()
    ; Initialize LPSystem_Debug by loading it from LazyPanda.esm.
    ; Replace 0x123456 with the actual FormID for LPSystem_Debug.
    LPSystem_Debug = Game.GetFormFromFile(0x123456, "LazyPanda.esm") as GlobalVariable
    Log("[Lazy Panda] LPSystem_Debug initialized")
    StartTimer(checkInterval)
EndEvent

;====================================================================================
; Utility Functions
;====================================================================================

Function Log(String logMsg)
    If LPSystem_Debug.GetValue() as Bool
        Debug.Trace(logMsg, 0)
    EndIf
EndFunction

;====================================================================================
; Reporting Functions
;====================================================================================

Function ReportStatus() Global
    Log("[Lazy Panda] ReportStatus called")
    
    ; Report Perks
    FormList perksList = Game.GetFormFromFile(0x8C8, "LazyPanda.esm") as FormList
    Log("[Lazy Panda] Reporting Perks:")
    ReportFormList(perksList, "Perk", "hasPerk")
    
    ; Report Magic Effects
    FormList magicEffectsList = Game.GetFormFromFile(0x81E, "LazyPanda.esm") as FormList
    Log("[Lazy Panda] Reporting Magic Effects:")
    ReportFormList(magicEffectsList, "Magic Effect", "hasMagicEffect")
    
    ; Report Globals
    FormList globalsList = Game.GetFormFromFile(0x8B9, "LazyPanda.esm") as FormList
    Log("[Lazy Panda] Reporting Globals:")
    ReportFormList(globalsList, "Global", "GetValue")
EndFunction

Function ReportFormList(FormList list, String itemType, String checkFunction)
    Int itemCount = list.GetSize()
    Int index = 0
    While index < itemCount
        Form currentItem = list.GetAt(index)
        If currentItem
            Bool hasItem = CheckItem(currentItem, checkFunction)
            Log(("[Lazy Panda] " + itemType + ": " + currentItem as String) + " - Enabled: " + hasItem as String)
            If !hasItem
                Log("[Lazy Panda] WARNING: Player does not have " + itemType + ": " + currentItem as String)
            EndIf
        EndIf
        index += 1
    EndWhile
EndFunction

Bool Function CheckItem(Form item, String checkFunction)
    If checkFunction == "hasPerk"
        Return Game.GetPlayer().hasPerk(item as Perk)
    ElseIf checkFunction == "hasMagicEffect"
        Return Game.GetPlayer().hasMagicEffect(item as MagicEffect)
    ElseIf checkFunction == "GetValue"
        Return (item as GlobalVariable).GetValue() != 0.0
    EndIf
    Return False
EndFunction

;====================================================================================
; Timer Functions
;====================================================================================

Event OnTimer()
    If LPSystem_Debug.GetValue() as Bool
        ReportStatus()
    EndIf
    StartTimer(checkInterval)
EndEvent