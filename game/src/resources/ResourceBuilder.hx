package resources;

#if macro
import haxe.macro.Context;
import haxe.io.Path;
import sys.FileSystem;
import haxe.Json;
import sys.io.File;
#end

class ResourceBuilder{
	private static inline var LEVEL_DIR:String = "res/level/";

	macro public static function build(){

		var lvl:Array<LvlDef> = buildLevels();
		var snd:Array<SoundDef> = buildSounds();

		var c = macro class R {
			public var lvl:Array<resources.LvlDef> = $v{lvl};
			public var snd:Array<resources.SoundDef> = $v{snd};
			public function new() {}
		}

		Context.defineType(c);

		return macro new R();
	}

	#if macro
	
	private static function buildLevels():Array<LvlDef>{
		var lvl:Array<LvlDef> = new Array<LvlDef>();

		for(f in FileSystem.readDirectory(LEVEL_DIR)){
			var path:Path = new Path(LEVEL_DIR + f);
			if(path.ext == "json"){
				lvl.push(buildLevel(path));
			}
		}

		return lvl;
	}

	private static function buildLevel(path:Path):LvlDef{
		var content:String = File.getContent(path.toString());
		var tiled = Json.parse(content);

		var wallLayer = findObject(tiled.layers, "wall");
		var playerLayer = findObject(tiled.layers, "player");
		var enemyLayer = findObject(tiled.layers, "enemy");
		var goalLayer = findObject(tiled.layers, "goal");

		return {
			g: tiled.tilewidth,
			w: tiled.width,
			h: tiled.height,
			wl: wallLayer == null ? [] : buildWalls(wallLayer.objects),
			en: enemyLayer == null ? [] : buildEnemies(enemyLayer.objects),
			pl: playerLayer == null ? [] : buildPlayers(playerLayer.objects),
			gl: goalLayer == null ? [] : buildGoals(goalLayer.objects)
		};
	}

	private static function findObject(list:Array<Dynamic>, name:String):Dynamic{
		for(c in list){
			if(c.name == name){
				return c;
			}
		}
		return null;
	}

	private static function buildWalls(wallObjects:Array<Dynamic>):Array<WallDef>{
		var res:Array<WallDef> = new Array<WallDef>();
		for(wo in wallObjects){
			res.push(makeWall(wo));
		}
		return res;
	}

	private static function makeWall(wallObj:Dynamic):WallDef{
		var corners:Array<Array<Int>> = new Array<Array<Int>>();
		var poly:Array<Dynamic> = wallObj.polygon;

		for(p in poly){
			corners.push([
				wallObj.x + p.x,
				wallObj.y + p.y
			]);
		}

		return {
			c: corners
		};
	}

	private static function buildPlayers(playerObj:Array<Dynamic>):Array<PlayerDef>{
		var res:Array<PlayerDef> = new Array<PlayerDef>();
		for(po in playerObj){
			res.push(makePlayer(po));
		}

		return res;
	}

	private static function makePlayer(playerObj:Dynamic):PlayerDef{
		return {
			x: playerObj.x + playerObj.width / 2,
			y: playerObj.y + playerObj.height / 2
		};
	}

	private static function buildEnemies(enemyObj:Array<Dynamic>):Array<EnemyDef>{
		var e:Map<String, EnemyDef> = new Map<String, EnemyDef>();

		for(i in enemyObj){
			var objName:String = i.name;
			var nameIndex:Array<String> = objName.split("-");
			var enemyName:String = nameIndex[0];

			var enemy:EnemyDef;
			if(e.exists(enemyName)){
				enemy = e[enemyName];
			}else{
				var angle = (getProperty(i.properties, "angle", 0) / 180) * Math.PI;
				enemy = {
					x: 0.0,
					y: 0.0,
					nav: new Array<Array<Float>>(),
					a: angle
				};
				e.set(enemyName, enemy);
			}

			if(nameIndex.length > 1){
				var idx:Int = Std.parseInt(nameIndex[1]) - 1;
				enemy.nav[idx] = [i.x, i.y];
			}else{
				// load position
				enemy.x = i.x + i.width / 2;
				enemy.y = i.y + i.height / 2;
			}
		}

		var res:Array<EnemyDef> = new Array<EnemyDef>();
		for(i in e){
			res.push(i);
		}

		return res;
	}

	private static function buildGoals(goalObjects:Array<Dynamic>):Array<GoalDef>{
		var res:Array<GoalDef> = new Array<GoalDef>();
		for(o in goalObjects){
			res.push(makeGoal(o));
		}

		return res;
	}

	private static function makeGoal(goalObject:Dynamic):GoalDef{
		return {
			x: goalObject.x,
			y: goalObject.y,
			w: goalObject.width,
			h: goalObject.height,
			l: getProperty(goalObject.properties, "level", -1)
		}
	}

	private static function getProperty<T>(props:Array<Dynamic>, name:String, def:T = null):T{
		if(props == null){
			return def;
		}

		for(p in props){
			if(p.name == name){
				return p.value;
			}
		}

		return def;
	}

	private static function buildSounds():Array<SoundDef>{
		var sounds:Array<SoundDef> = new Array<SoundDef>();
		var soundPath:String = "res/sound/";
		for (f in FileSystem.readDirectory(soundPath)) {
			var path:Path = new Path(soundPath + f);
			if (path.ext == "txt") {
				sounds.push(buildSound(path));
			}
		}

		return sounds;
	}

	private static function buildSound(path:Path):SoundDef {
		var txt = File.getContent(path.toString());

		var arr:Array<Float> = new Array<Float>();

		for (t in txt.split(",")) {
			arr.push(t.length > 0 ? Std.parseFloat(t) : 0);
		}

		return {
			n: path.file,
			d: arr
		}
	}

	#end



}