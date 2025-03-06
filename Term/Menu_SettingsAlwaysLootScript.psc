ScriptName LZP:Term:Menu_SettingsAlwaysLootScript Extends TerminalMenu hidden

;==============================
; Properties
;==============================
TerminalMenu Property CurrentTerminalMenu Auto Const mandatory
Form[] Property SettingsGlobals Auto Const mandatory
Message Property LPOffMsg Auto Const mandatory
Message Property LPOnMsg Auto Const mandatory

;==============================
; Helper Function
;==============================
Function UpdateSettingDisplay(Int index, ObjectReference akTerminalRef)
    GlobalVariable setting = SettingsGlobals[index] as GlobalVariable
    If setting
        Float value = setting.GetValue()
        Message replacementMsg
        If value == 1.0
            replacementMsg = LPOnMsg
        Else
            replacementMsg = LPOffMsg
        EndIf
        akTerminalRef.AddTextReplacementData("State" + index as String, replacementMsg as Form)
    Else
        Debug.Trace("UpdateSettingDisplay: Setting at index " + index as String + " not found", 0)
    EndIf
EndFunction

;==============================
; Events
;==============================
Event OnTerminalMenuEnter(TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    Int index = 0
    While index < SettingsGlobals.Length
        UpdateSettingDisplay(index, akTerminalRef)
        index += 1
    EndWhile
EndEvent

Event OnTerminalMenuItemRun(Int auiMenuItemID, TerminalMenu akTerminalBase, ObjectReference akTerminalRef)
    If akTerminalBase == CurrentTerminalMenu
        GlobalVariable setting = SettingsGlobals[auiMenuItemID] as GlobalVariable
        If setting
            Float value = setting.GetValue()
            If value == 1.0
                setting.SetValue(0.0)
            Else
                setting.SetValue(1.0)
            EndIf
            UpdateSettingDisplay(auiMenuItemID, akTerminalRef)
        Else
            Debug.Trace("OnTerminalMenuItemRun: Setting at index " + auiMenuItemID as String + " not found", 0)
        EndIf
    EndIf
EndEvent
