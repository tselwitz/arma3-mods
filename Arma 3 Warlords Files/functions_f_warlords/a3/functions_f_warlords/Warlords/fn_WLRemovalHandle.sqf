/*
WARLORDS-SPECIFIC FUNCTION

Author: Josef Zemánek

Description: Units & vehicles garbage collector.
*/

private ["_item", "_sector"];

_item = _this # 0;
_sector = _this # 1;

_item setVariable ["BIS_WL_parentSector", _sector];

if (_item isKindOf "Man") then {
	_item addEventHandler ["Killed", {
		(_this # 0) spawn {
			scriptName "WLRemovalHandle (man)";
			_side = side group _this;
			_grp = group _this;
			waitUntil {(((_this getVariable "BIS_WL_parentSector") getVariable "BIS_WL_sectorSide") != _side)};
			sleep BIS_WL_spawnedRemovalTime;
			if !(isNull _this) then {
				["Deleting %3 (%1) in %2", typeOf _this, (_this getVariable "BIS_WL_parentSector") getVariable "Name", _this] call BIS_fnc_WLdebug;
				if (vehicle _this == _this) then {
					deleteVehicle _this;
				} else {
					(vehicle _this) deleteVehicleCrew _this;
				};
			};
			if (count units _grp == 0 && !isNull _grp) then {["Deleting group %1", _grp] call BIS_fnc_WLdebug; deleteGroup _grp};
		};
	}];
} else {
	{[_x, _sector] call BIS_fnc_WLremovalHandle} forEach crew _item;
	[_item, -1, TRUE] spawn BIS_fnc_WLvehicleHandle;
};