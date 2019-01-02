/*
WARLORDS-SPECIFIC FUNCTION

Author: Josef Zemánek

Description: Evaluates which sector was most voted for.
*/

_voteArr = [];

{
	_voteArr set [_forEachIndex, 0];
} forEach BIS_WL_sectors;

{
	if (side _x == _this && !isNull (_x getVariable "BIS_WL_selectedSector")) then {
		_id = BIS_WL_sectors find (_x getVariable "BIS_WL_selectedSector");
		_voteArr set [_id, (_voteArr # _id) + 1];
	};
} forEach BIS_WL_allWarlords;

BIS_WL_sectors # (_voteArr find (([_voteArr,[],{_x},"DESCEND"] call BIS_fnc_sortBy) # 0))