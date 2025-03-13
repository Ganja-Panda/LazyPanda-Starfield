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
  If LPSystemUtil_Debug.GetValue() as Bool
    Debug.Trace(logMsg, 0)
  EndIf
EndFunction

Event OnLoad()
  Log("[Lazy Panda] OnLoad triggered")
  StartTimer(lootTimerDelay, lootTimerID)
EndEvent

Event OnTimer(Int aiTimerID)
  Log("[Lazy Panda] OnTimer triggered with TimerID: " + aiTimerID as String)
  If aiTimerID == lootTimerID
    ExecuteLooting()
  EndIf
EndEvent

Function ExecuteLooting()
  Log("[Lazy Panda] ExecuteLooting called")
  StartTimer(lootTimerDelay, lootTimerID)
  Float fSearchRadius = Game.GetGameSettingFloat("fMaxShipTransferDistance")
  Bool bToggleLooting = LPSystemUtil_ToggleLooting.GetValue() == 1.0
  Bool bEnableContSpace = LPEnableCont_Space.GetValue() == 1.0
  Bool bHasPerk = Game.GetPlayer().HasPerk(ActivePerk)
  Log("[Lazy Panda] fSearchRadius: " + fSearchRadius as String)
  If fSearchRadius > 0.0 && bToggleLooting && bEnableContSpace && bHasPerk
    Log("[Lazy Panda] Looting enabled and within search radius")
    ObjectReference homeShipRef = PlayerHomeShip.GetRef()
    If homeShipRef != None
      RemoveAllItems(homeShipRef, False, False)
      Log("[Lazy Panda] Items removed and transferred to PlayerHomeShip")
    Else
      Log("[Lazy Panda] PlayerHomeShip reference is None")
    EndIf
  Else
    Log("[Lazy Panda] Looting not enabled, you don't have the proper perk or out of search radius")
  EndIf
EndFunction
