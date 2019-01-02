/*
WARLORDS-SPECIFIC FUNCTION

Author: Josef Zem�nek

Description: Spawns sector garrison based on its size, sends a patrolling vehicle if feasible.
*/

[_this, (_this getVariable "Size") / 2, (_this getVariable "Size") / 2, _this getVariable "BIS_WL_sectorSide"] spawn BIS_fnc_WLsectorPopulate;

_this spawn {
	if ((_this getVariable "BIS_WL_sectorSide") == RESISTANCE) then {
		_neighbors = (synchronizedObjects _this) select {typeOf _x == typeOf _this && (_x getVariable "BIS_WL_sectorSide") == RESISTANCE && !(_x in [BIS_WL_currentSector_WEST, BIS_WL_currentSector_EAST])};
		if (count _neighbors > 0) then {
			_roads = _this nearRoads ((_this getVariable "Size") / 2);
			{
				_neighbor = _x;
				if (random 1 >= 0.5) then {
					waitUntil {_this getVariable ["BIS_WL_vehiclesSpawned", FALSE]};
					_emptyRoads = _roads select {count (_x nearObjects ["LandVehicle", 20]) == 0};
					if (count _emptyRoads > 0) then {
						_road = selectRandom _emptyRoads;
						_pos = position _road;
						_dir = _road getDir selectRandom roadsConnectedTo _road;
						_grpPool = ("TRUE" configClasses (BIS_WL_cfgIndepGrps >> BIS_WL_factionsPool # 2 >> "Mechanized")) + ("TRUE" configClasses (BIS_WL_cfgIndepGrps >> BIS_WL_factionsPool # 2 >> "Motorized"));
						if (count _grpPool > 0) then {
							_grp = selectRandom _grpPool;
							["Sending patrol (%1) from %2 to %3", getText (_grp >> "name"), _this getVariable "Name", _x getVariable "Name"] call BIS_fnc_WLdebug;
							_grp = [_pos, RESISTANCE, _grp, nil, nil, nil, nil, nil, _dir] call BIS_fnc_spawnGroup;
							[_grp, 0] setWaypointPosition [_pos, 0];
							_grp setBehaviour "SAFE";
							_grp setSpeedMode "LIMITED";
							_veh = vehicle leader _grp;
							{
								if (vehicle _x == _x) then {
									_x assignAsCargo _veh;
									_x moveInCargo _veh;
								};
							} forEach units _grp;
							_wp1 = _grp addWaypoint [position _neighbor, (_neighbor getVariable "Size") / 2];
							_wp2 = _grp addWaypoint [position _this, (_this getVariable "Size") / 2];
							_wp2 setWaypointType "CYCLE";
							[_veh, -1, TRUE] spawn BIS_fnc_WLvehicleHandle;
							{
								_x addEventHandler ["Killed", {_null = (_this # 0) spawn {_grp = group _this; sleep BIS_WL_spawnedRemovalTime; if !(isNull _this) then {["Deleting dead patrol %1", _this] call BIS_fnc_WLdebug; deleteVehicle _this}; if (count units _grp == 0) then {deleteGroup _grp}}}];
							} forEach units _grp;
						};
					};
				};
			} forEach _neighbors;
		};
	};
};