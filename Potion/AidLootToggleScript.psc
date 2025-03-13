ScriptName LZP:Potion:AidLootToggleScript Extends ActiveMagicEffect hidden

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
GlobalVariable Property LPSystemUtil_ToggleLooting Auto
GlobalVariable Property LPSystemUtil_Debug Auto
Message Property LPLootingEnabledMsg Auto
Message Property LPLootingDisabledMsg Auto
Potion Property LP_Aid_ToggleLooting Auto

;-- Functions ---------------------------------------

Function Log(String logMsg)
  If LPSystemUtil_Debug.GetValue() as Bool ; #DEBUG_LINE_NO:34
    Debug.Trace(logMsg, 0) ; #DEBUG_LINE_NO:35
  EndIf
EndFunction

Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
  ObjectReference playerRef = Game.GetPlayer() as ObjectReference ; #DEBUG_LINE_NO:46
  If akTarget != playerRef ; #DEBUG_LINE_NO:49
    Return  ; #DEBUG_LINE_NO:50
  EndIf
  If LPSystemUtil_ToggleLooting == None ; #DEBUG_LINE_NO:54
    Self.Log("Error: LPSystemUtil_ToggleLooting not set") ; #DEBUG_LINE_NO:55
    Return  ; #DEBUG_LINE_NO:56
  EndIf
  If LPLootingEnabledMsg == None || LPLootingDisabledMsg == None ; #DEBUG_LINE_NO:58
    Self.Log("Error: Message properties not set") ; #DEBUG_LINE_NO:59
    Return  ; #DEBUG_LINE_NO:60
  EndIf
  If LP_Aid_ToggleLooting == None ; #DEBUG_LINE_NO:62
    Self.Log("Error: LP_Aid_ToggleLooting not set") ; #DEBUG_LINE_NO:63
    Return  ; #DEBUG_LINE_NO:64
  EndIf
  Int toggleValue = LPSystemUtil_ToggleLooting.GetValueInt() ; #DEBUG_LINE_NO:68
  If toggleValue == 1 ; #DEBUG_LINE_NO:71
    LPLootingDisabledMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:72
    LPSystemUtil_ToggleLooting.SetValue(0 as Float) ; #DEBUG_LINE_NO:73
    Self.Log("Looting disabled") ; #DEBUG_LINE_NO:74
  Else
    LPLootingEnabledMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:76
    LPSystemUtil_ToggleLooting.SetValue(1 as Float) ; #DEBUG_LINE_NO:77
    Self.Log("Looting enabled") ; #DEBUG_LINE_NO:78
  EndIf
  akTarget.AddItem(LP_Aid_ToggleLooting as Form, 1, True) ; #DEBUG_LINE_NO:82
EndEvent
