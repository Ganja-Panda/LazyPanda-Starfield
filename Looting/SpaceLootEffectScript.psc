ScriptName LZP:Looting:SpaceLootEffectScript Extends ObjectReference

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
Group EffectSpecific_Mandatory
  Perk Property ActivePerk Auto Const mandatory
  { The perk needed to loot from this list }
  GlobalVariable Property LPEnableCont_Space Auto Const mandatory
  { The global variable that enables looting space containers }
  GlobalVariable Property LPSystemUtil_ToggleLooting Auto Const mandatory
EndGroup

Group DestinationLocations
  ReferenceAlias Property PlayerHomeShip Auto Const
  { SQ_PlayerShip alias 016 HomeShip }
EndGroup

Group NoFill
  Int Property lootTimerID = 1 Auto
  Float Property lootTimerDelay = 1.0 Auto
EndGroup


;-- Functions ---------------------------------------

Event OnLoad()
  Debug.Trace("[Lazy Panda] OnLoad triggered", 0) ; #DEBUG_LINE_NO:22
  Self.StartTimer(Self.lootTimerDelay, Self.lootTimerID) ; #DEBUG_LINE_NO:23
EndEvent

Event OnTimer(Int aiTimerID)
  Debug.Trace("[Lazy Panda] OnTimer triggered with TimerID: " + aiTimerID as String, 0) ; #DEBUG_LINE_NO:27
  If aiTimerID == Self.lootTimerID ; #DEBUG_LINE_NO:28
    Self.ExecuteLooting() ; #DEBUG_LINE_NO:29
  EndIf
EndEvent

Function ExecuteLooting()
  Debug.Trace("[Lazy Panda] ExecuteLooting called", 0) ; #DEBUG_LINE_NO:34
  Self.StartTimer(Self.lootTimerDelay, Self.lootTimerID) ; #DEBUG_LINE_NO:35
  Float fSearchRadius = Game.GetGameSettingFloat("fMaxShipTransferDistance") ; #DEBUG_LINE_NO:36
  Debug.Trace("[Lazy Panda] fSearchRadius: " + fSearchRadius as String, 0) ; #DEBUG_LINE_NO:37
  If fSearchRadius > 0.0 && Self.LPSystemUtil_ToggleLooting.GetValue() == 1.0 && Self.LPEnableCont_Space.GetValue() == 1.0 && Game.GetPlayer().HasPerk(Self.ActivePerk) ; #DEBUG_LINE_NO:38
    Debug.Trace("[Lazy Panda] Looting enabled and within search radius", 0) ; #DEBUG_LINE_NO:39
    Self.RemoveAllItems(Self.PlayerHomeShip.GetRef(), False, False) ; #DEBUG_LINE_NO:40
    Debug.Trace("[Lazy Panda] Items removed and transferred to PlayerHomeShip", 0) ; #DEBUG_LINE_NO:41
  Else
    Debug.Trace("[Lazy Panda] Looting not enabled, you don't have the proper perk or out of search radius", 0) ; #DEBUG_LINE_NO:43
  EndIf
EndFunction
