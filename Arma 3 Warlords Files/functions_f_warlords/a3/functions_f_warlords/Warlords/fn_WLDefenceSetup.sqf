/*
WARLORDS-SPECIFIC FUNCTION

Author: Josef Zemánek

Description: Requested static weapon positionining routine.
*/

_class = _this # 0;
_cost = _this # 1;

BIS_WL_currentSelection = "defence";

if (visibleMap) then {
	titleCut ["", "BLACK IN", 0.5];
};
openMap [FALSE, FALSE];

_def = _class createVehicleLocal position player;
_def setPos position player;
_def setDir direction player;

_def lock TRUE;

player reveal [_def, 4];

_def attachTo [player, [0, 1, 0]];
_h = (position _def) # 2;
detach _def;
_def attachTo [player, [0, 1, -_h]];

[BIS_WL_hintPrio_deployDefence, format ["[%1]: %2", localize "STR_dik_space", localize "STR_A3_assemble"] + "%1" + format ["[%1]: %2", localize "STR_dik_back", localize "STR_ca_cancel"], -1] spawn BIS_fnc_WLshowInfo;
[toUpper format [localize "STR_A3_WL_deploy_tip", localize "STR_dik_space"]] spawn BIS_fnc_WLSmoothText;

BIS_WL_spacePressed = FALSE;
BIS_WL_backspacePressed = FALSE;

[] spawn {
	disableSerialization;
	_spaceEH = (findDisplay 46) displayAddEventHandler ["KeyDown", {
		if (_this # 1 == 57) then {
			BIS_WL_spacePressed = TRUE;
			(findDisplay 46) displayRemoveEventHandler ["KeyDown", uiNamespace getVariable "BIS_WL_spaceEH"];
			uiNamespace setVariable ['BIS_fnc_titlecard_spaceEH', nil];
		};
		if (_this # 1 == 14) then {
			BIS_WL_backspacePressed = TRUE;
			(findDisplay 46) displayRemoveEventHandler ["KeyDown", uiNamespace getVariable "BIS_WL_spaceEH"];
			uiNamespace setVariable ['BIS_fnc_titlecard_spaceEH', nil];
		};
	}];
	uiNamespace setVariable ["BIS_WL_spaceEH", _spaceEH];
};

[] spawn {
	scriptName "WLDefenceSetup (area check)";
	while {BIS_WL_currentSelection != ""} do {
		_owned = BIS_WL_sectorsArrayFriendly # 0;
		if (_owned findIf {[player, _x, TRUE] call BIS_fnc_WLInSectorArea} == -1) exitWith {BIS_WL_backspacePressed = TRUE};
		sleep 5;
	};
};

waitUntil {BIS_WL_spacePressed || BIS_WL_backspacePressed || (position _def) # 2 > 300 || vehicle player != player || !alive player || lifeState player == "INCAPACITATED"};

if (BIS_WL_spacePressed) then {
	_isFort = if (toLower getText (BIS_WL_cfgVehs >> _class >> "simulation") == "house") then {TRUE} else {FALSE};
	deleteVehicle _def;
	_def = _class createVehicle position player;
	_def setPos position player;
	_def setDir direction player;
	player reveal [_def, 4];
	_def attachTo [player, [0, 1, 0]];
	_h = (position _def) # 2;
	detach _def;
	_def attachTo [player, [0, 1, -_h]];
	detach _def;
	if !(_isFort) then {
		if (getNumber (BIS_WL_cfgVehs >> _class >> "isUav") == 1) then {createVehicleCrew _def; (effectiveCommander _def) setSkill 1};
		[_def, BIS_WL_markerIndex, FALSE] spawn BIS_fnc_WLvehicleHandle;
		BIS_WL_markerIndex = BIS_WL_markerIndex + 1;
	};
	[toUpper format [localize "STR_A3_WL_deploy_done", getText (BIS_WL_cfgVehs >> _class >> "displayName")]] spawn BIS_fnc_WLSmoothText;
	playSound "assemble_target"
} else {
	if ((position _def) # 2 > 300) then {
		{deleteVehicle _x} forEach (position player nearObjects ["GroundWeaponHolder", 2]);
	};
	deleteVehicle _def;
	player setVariable ["BIS_WL_funds", (player getVariable "BIS_WL_funds") + _cost, TRUE];
	[toUpper localize "STR_A3_WL_deploy_canceled"] spawn BIS_fnc_WLSmoothText;
	playSound "AddItemFailed";
	"Canceled" call BIS_fnc_WLSoundMsg;
};

BIS_WL_currentSelection = "";

sleep 0.1;

[BIS_WL_hintPrio_deployDefence, "", -1] spawn BIS_fnc_WLshowInfo;
showCommandingMenu "";