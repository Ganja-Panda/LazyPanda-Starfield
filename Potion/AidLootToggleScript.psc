ScriptName LZP:Potion:AidLootToggleScript Extends ActiveMagicEffect hidden

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
GlobalVariable Property LPSystemUtil_ToggleLooting Auto
Message Property LPLootingEnabledMsg Auto
Message Property LPLootingDisabledMsg Auto
Potion Property LP_Aid_ToggleLooting Auto

;-- Functions ---------------------------------------

Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
  If akTarget == Game.GetPlayer() as ObjectReference ; #DEBUG_LINE_NO:9
    Int toggleValue = Self.LPSystemUtil_ToggleLooting.GetValueInt() ; #DEBUG_LINE_NO:10
    If toggleValue == 1 ; #DEBUG_LINE_NO:11
      Self.LPLootingDisabledMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:12
      Self.LPSystemUtil_ToggleLooting.SetValue(0 as Float) ; #DEBUG_LINE_NO:13
    Else
      Self.LPLootingEnabledMsg.Show(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0) ; #DEBUG_LINE_NO:15
      Self.LPSystemUtil_ToggleLooting.SetValue(1 as Float) ; #DEBUG_LINE_NO:16
    EndIf
    akTarget.AddItem(Self.LP_Aid_ToggleLooting as Form, 1, True) ; #DEBUG_LINE_NO:19
  EndIf
EndEvent
