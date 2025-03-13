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
  If LPSystemUtil_Debug.GetValue() as Bool
    Debug.Trace(logMsg, 0)
  EndIf
EndFunction

Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
  ObjectReference playerRef = Game.GetPlayer() as ObjectReference
  If akTarget != playerRef
    Return
  EndIf
  If LPSystemUtil_ToggleLooting == None
    Log("Error: LPSystemUtil_ToggleLooting not set")
    Return
  EndIf
  If LPLootingEnabledMsg == None || LPLootingDisabledMsg == None
    Log("Error: Message properties not set")
    Return
  EndIf
  If LP_Aid_ToggleLooting == None
    Log("Error: LP_Aid_ToggleLooting not set")
    Return
  EndIf
  Int toggleValue = LPSystemUtil_ToggleLooting.GetValueInt()
  If toggleValue == 1
    LPLootingDisabledMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    LPSystemUtil_ToggleLooting.SetValue(0 as Float)
    Log("Looting disabled")
  Else
    LPLootingEnabledMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    LPSystemUtil_ToggleLooting.SetValue(1 as Float)
    Log("Looting enabled")
  EndIf
  akTarget.AddItem(LP_Aid_ToggleLooting as Form, 1, True)
EndEvent
