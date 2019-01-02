/*
WARLORDS-SPECIFIC FUNCTION

Author: Josef Zemánek

Description: Spawns a requested naval asset.
*/

_class = _this # 0;
_cost = _this # 1;

_isUAV = if (getNumber (BIS_WL_cfgVehs >> _class >> "isUav") == 1) then {TRUE} else {FALSE};
[toUpper localize "STR_A3_WL_popup_airdrop_selection_water"] spawn BIS_fnc_WLSmoothText;
processDiaryLink createDiaryLink ["Map", player, ""];
BIS_WL_waterDropPos = [];
onMapSingleClick {if (surfaceIsWater _pos) then {BIS_WL_waterDropPos = _pos} else {playSound "AddItemFailed"}};

waitUntil {count BIS_WL_waterDropPos > 0 || !visibleMap};

onMapSingleClick {};

if (count BIS_WL_waterDropPos == 0) exitWith {
	player setVariable ["BIS_WL_funds", (player getVariable "BIS_WL_funds") + _cost, TRUE];
	[toUpper localize "STR_A3_WL_airdrop_canceled"] spawn BIS_fnc_WLSmoothText;
	playSound "AddItemFailed";
	"Canceled" call BIS_fnc_WLSoundMsg;
};

BIS_WL_waterDropPos set [2, 0];
[toUpper localize "STR_A3_WL_airdrop_underway"] spawn BIS_fnc_WLSmoothText;
playSound "AddItemOK";

_item = createVehicle [_class, BIS_WL_waterDropPos, [], 0, "NONE"];
_itemName = getText (BIS_WL_cfgVehs >> typeOf _item >> "displayName");
_item setVariable ["BIS_WL_iconText", _itemName];
BIS_WL_recentlyPurchasedAssets pushBack _item;
_item setPos (BIS_WL_waterDropPos vectorAdd [0,0,3]);
if (_isUAV) then {createVehicleCrew _item};
[_item, BIS_WL_markerIndex, FALSE] spawn BIS_fnc_WLvehicleHandle;
BIS_WL_markerIndex = BIS_WL_markerIndex + 1;
(player getVariable "BIS_WL_pointer") setVariable ["BIS_WL_purchased", ((player getVariable "BIS_WL_pointer") getVariable "BIS_WL_purchased") + [_item], TRUE];
_item spawn {
	sleep 10;
	BIS_WL_recentlyPurchasedAssets = BIS_WL_recentlyPurchasedAssets - [_this];
};

if !(BIS_WL_waterDropPos distance player > 300) then {
	playSound3D ["A3\Data_F_Warlords\sfx\flyby.wss", objNull, FALSE, BIS_WL_waterDropPos vectorAdd [0, 0, 100]];
};