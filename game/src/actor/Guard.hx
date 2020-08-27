package actor;

import math.AABB;
import math.Line;
import math.LcMath;
import js.html.CanvasRenderingContext2D;
import path.Path;
import astar.Point;

class Guard extends Actor{
	private static inline var FOV:Float = 3.14159 * 0.175;
	private static inline var VIEW_DIST:Float = 512;

	private var g:Game;

	public var ptrl(default, null):Array<Point>;
	private var ptrlIdx:Int = -1;

	private var canSeePlayer:Bool = false;

	public function new(g:Game){
		super(g.bsp, g.grid);
		this.g = g;

		ptrl = new Array<Point>();
	}

	override function update(s:Float) {
		super.update(s);

		if(phase == Phase.TURN_START){
			if(ptrl.length == 0){
				phase = Phase.TURN_END;
			}

			var sx = Math.floor(this.x / gridSize);
			var sy = Math.floor(this.y / gridSize);

			ptrlIdx += 1;
			if(ptrlIdx >= ptrl.length){
				ptrlIdx = 0;
			}

			navNodes = Path.fromPoints(dst.route(sx, sy, ptrl[ptrlIdx].x, ptrl[ptrlIdx].y, 50), gridSize, true);
			navIndex = 0;
			navSpeed = 128;
			phase = Phase.MOVING;
		}

		canSeePlayer = false;
		for(p in g.player){
			canSeePlayer = canSeePlayer || canSee(p.x, p.y);
		}
	}

	private function canSee(px:Float, py:Float):Bool{
		var xd:Float = px - x;
		var yd:Float = py - y;

		if(Math.sqrt(Math.pow(xd, 2) + Math.pow(yd, 2)) > VIEW_DIST){
			return false;
		}

		var pdir:Float = LcMath.capAngle(Math.atan2(yd, xd));

		var from = dir - FOV;
		var to = dir + FOV;
		var offset:Float = from < 0 ? Math.abs(from) : Math.min(0, (Math.PI * 2) - to);
		var pdoff = LcMath.capAngle(pdir + offset);

		if(pdoff < from + offset || pdoff > to + offset){
			return false;
		}

		var ln:Line = new Line(x, y, px, py);
		for(w in g.walls){
			if(w.countIntersect(ln) > 0){
				return false;
			}
		}

		return true;
	}

	override function render(c:CanvasRenderingContext2D){
		super.render(c);

		c.fillStyle = "#F00";
		c.beginPath();
		c.arc(x, y, gridSize / 2, 0, Math.PI * 2);
		c.fill();

		c.fillStyle = canSeePlayer ? "#FF000055" : "#00FF0055";
		c.beginPath();
		c.moveTo(x, y);
		c.arc(x, y, VIEW_DIST, dir - FOV, dir + FOV);
		c.lineTo(x, y);
		c.fill();
	}
}