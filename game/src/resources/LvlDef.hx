package resources;

import resources.GoalDef;

typedef LvlDef = {
	var g:Int;
	var w:Int;
	var h:Int;

	var wl:Array<WallDef>;
	var en:Array<EnemyDef>;
	var pl:Array<PlayerDef>;
	var gl:Array<GoalDef>;
}