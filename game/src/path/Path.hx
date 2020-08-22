package path;

import astar.Point;

class Path{
	public static function fromPoints(points:Array<Point>, scale:Float, center:Bool = false):Array<Node>{
		var path:Array<Node> = new Array<Node>();

		if(points == null){
			return path;
		}

		var offset:Float = center ? scale / 2 : 0;

		for(p in points){
			path.push({
				x: p.x * scale + offset,
				y: p.y * scale + offset
			});
		}
		return path;
	}
}