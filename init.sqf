enableSaving [FALSE, FALSE];
0 setFog [0.1, 0.12, 22];

[] execVM "Vcom\VcomInit.sqf";

if (isServer) then {
	10e10 setOvercast 0.5;
};