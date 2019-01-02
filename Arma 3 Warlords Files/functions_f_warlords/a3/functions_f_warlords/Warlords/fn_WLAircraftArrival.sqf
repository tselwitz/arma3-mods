/*
WARLORDS-SPECIFIC FUNCTION

Author: Josef Zemánek

Description: Spawns a requested aircraft and makes it land properly.
*/

_class = _this # 0;
_cost = _this # 1;
_requirements = _this # 2;
_isUAV = if (getNumber (BIS_WL_cfgVehs >> _class >> "isUav") == 1) then {TRUE} else {FALSE};
_isPlane = if ((toLower getText (BIS_WL_cfgVehs >> _class >> "simulation")) == "airplanex" && !(_requirements isEqualTo ["H"])) then {TRUE} else {FALSE};
_dir = 0;

_owned = BIS_WL_sectorsArrayFriendly # 0;
_relevant = _owned select {_services = (_x getVariable "BIS_WL_sectorSpecial"); {!(_x in _services)} count _requirements == 0};
_nearestService = objNull;
if (count _relevant == 0) then {
	_nearestService = missionNamespace getVariable format ["BIS_WL_base_%1", side group player];
} else {
	_nearestService = _relevant # 0;
};
{if ((_x distance player) < (_nearestService distance player)) then {_nearestService = _x}} forEach _relevant;

_spawnPos = position _nearestService;
_closest = 0;
if (_isPlane) then {
	{
		_pos = _x # 0;
		_lastClosest = (BIS_WL_airstrips # _closest) # 0;
		if ((_pos distance _nearestService) < (_lastClosest distance _nearestService)) then {_closest = _forEachIndex};
	} forEach BIS_WL_airstrips;
	_spawnPos = (BIS_WL_airstrips # _closest) # 1;
	_spawnPos set [2, 100];
};

_item = createVehicle [_class, _spawnPos, [], 100, "FLY"];
_itemName = getText (BIS_WL_cfgVehs >> typeOf _item >> "displayName");
_item setVariable ["BIS_WL_iconText", _itemName];
BIS_WL_recentlyPurchasedAssets pushBack _item;
if (_isPlane) then {
	_item setDir ((BIS_WL_airstrips # _closest) # 2);
	_item setVelocity (([_spawnPos, (BIS_WL_airstrips # _closest) # 0] call BIS_fnc_vectorFromXToY) vectorMultiply 100);
} else {
	if !(_isUAV) then {
		_item setVelocity [0,0,0];
	};
};
[_item, BIS_WL_markerIndex, FALSE] spawn BIS_fnc_WLvehicleHandle;
BIS_WL_markerIndex = BIS_WL_markerIndex + 1;
if (_isUAV) then {createVehicleCrew _item; _item spawn {sleep 10; BIS_WL_recentlyPurchasedAssets = BIS_WL_recentlyPurchasedAssets - [_this]}} else {
	_newGrp = createGroup side group player;
	_pilot = _newGrp createUnit [(getArray (BIS_WL_cfgVehs >> _class >> "typicalCargo")) # 0, _spawnPos, [], 0, "NONE"];
	if (isNull _pilot) then {
		_pilot = _newGrp createUnit [typeOf player, _spawnPos, [], 0, "NONE"];
	};
	_pilot assignAsDriver _item;
	_pilot moveInDriver _item;
	_pilot setBehaviour "CARELESS";
	_pilot allowFleeing 0;
	_pilot setCombatMode "BLUE";
	[_pilot, _item] spawn {
		_item = _this select 1;
		_this = _this select 0;
		scriptName "WLAircraftArrival (landing)";
		waitUntil {((position vehicle _this) # 2 < 0.5 && abs speed vehicle _this < 50) || !alive _this || !alive vehicle _this || vehicle _this == _this};
		unassignVehicle _this;
		[_this] orderGetIn FALSE;
		waitUntil {vehicle _this == _this || !alive _this || !alive vehicle _this};
		_grp = group _this;
		_this setPos position _this;
		deleteVehicle _this;
		deleteGroup _grp;
		BIS_WL_recentlyPurchasedAssets = BIS_WL_recentlyPurchasedAssets - [_item];
	};
};
_item spawn {
	sleep 2;
	_this land "LAND";
};
(player getVariable "BIS_WL_pointer") setVariable ["BIS_WL_purchased", ((player getVariable "BIS_WL_pointer") getVariable "BIS_WL_purchased") + [_item], TRUE];
"close" call BIS_fnc_WLPurchaseMenu;
[toUpper localize "STR_A3_WL_asset_dispatched"] spawn BIS_fnc_WLSmoothText;