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

		var c = macro class R {
			public var lvl:Array<resources.LvlDef> = $v{lvl};
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

		return {
			g: tiled.tilewidth,
			w: tiled.width,
			h: tiled.height,
			wl: buildWalls(wallLayer.objects),
			en: [],
			pl: []
		}
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
		var corners:Array<Point> = new Array<Point>();
		var poly:Array<Dynamic> = wallObj.polygon;

		for(p in poly){
			corners.push({
				x: wallObj.x + p.x,
				y: wallObj.y + p.y
			});
		}

		return {
			c: corners
		};
	}


	#end



}