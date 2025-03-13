ScriptName LZP:Looting:SpaceLootEffectScript Extends ObjectReference

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
Group EffectSpecific_Mandatory
  Perk Property ActivePerk Auto Const mandatory
  GlobalVariable Property LPEnableCont_Space Auto Const mandatory
  GlobalVariable Property LPSystemUtil_ToggleLooting Auto Const mandatory
  GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory
EndGroup

Group DestinationLocations
  ReferenceAlias Property PlayerHomeShip Auto Const
EndGroup

Group NoFill
  Int Property lootTimerID = 1 Auto
  Float Property lootTimerDelay = 0.5 Auto
EndGroup


;-- Functions ---------------------------------------

Function Log(String logMsg)
  If LPSystemUtil_Debug.GetValue() as Bool ; #DEBUG_LINE_NO:35
    Debug.Trace(logMsg, 0) ; #DEBUG_LINE_NO:36
  EndIf
EndFunction

Event OnLoad()
  Self.Log("[Lazy Panda] OnLoad triggered") ; #DEBUG_LINE_NO:47
  Self.StartTimer(lootTimerDelay, lootTimerID) ; #DEBUG_LINE_NO:48
EndEvent

Event OnTimer(Int aiTimerID)
  Self.Log("[Lazy Panda] OnTimer triggered with TimerID: " + aiTimerID as String) ; #DEBUG_LINE_NO:54
  If aiTimerID == lootTimerID ; #DEBUG_LINE_NO:55
    Self.ExecuteLooting() ; #DEBUG_LINE_NO:56
  EndIf
EndEvent

Function ExecuteLooting()
  Self.Log("[Lazy Panda] ExecuteLooting called") ; #DEBUG_LINE_NO:67
  Self.StartTimer(lootTimerDelay, lootTimerID) ; #DEBUG_LINE_NO:68
  Float fSearchRadius = Game.GetGameSettingFloat("fMaxShipTransferDistance") ; #DEBUG_LINE_NO:71
  Bool bToggleLooting = LPSystemUtil_ToggleLooting.GetValue() == 1.0 ; #DEBUG_LINE_NO:72
  Bool bEnableContSpace = LPEnableCont_Space.GetValue() == 1.0 ; #DEBUG_LINE_NO:73
  Bool bHasPerk = Game.GetPlayer().HasPerk(ActivePerk) ; #DEBUG_LINE_NO:74
  Self.Log("[Lazy Panda] fSearchRadius: " + fSearchRadius as String) ; #DEBUG_LINE_NO:76
  If fSearchRadius > 0.0 && bToggleLooting && bEnableContSpace && bHasPerk ; #DEBUG_LINE_NO:79
    Self.Log("[Lazy Panda] Looting enabled and within search radius") ; #DEBUG_LINE_NO:80
    ObjectReference homeShipRef = PlayerHomeShip.GetRef() ; #DEBUG_LINE_NO:81
    If homeShipRef != None ; #DEBUG_LINE_NO:82
      Self.RemoveAllItems(homeShipRef, False, False) ; #DEBUG_LINE_NO:83
      Self.Log("[Lazy Panda] Items removed and transferred to PlayerHomeShip") ; #DEBUG_LINE_NO:84
    Else
      Self.Log("[Lazy Panda] PlayerHomeShip reference is None") ; #DEBUG_LINE_NO:86
    EndIf
  Else
    Self.Log("[Lazy Panda] Looting not enabled, you don't have the proper perk or out of search radius") ; #DEBUG_LINE_NO:90
  EndIf
EndFunction
