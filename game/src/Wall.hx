package;

import math.Vec;
import math.Line;
import js.html.CanvasRenderingContext2D;

class Wall extends Entity{
	private var e:Array<Line>;

	public function new(cl:Array<Array<Int>>){
		super();

		e = new Array<Line>();

		aabb.x = cl[0][0];
		aabb.y = cl[0][1];
		var xx:Float = aabb.x;
		var yy:Float = aabb.y;
		var lx:Float = 0;
		var ly:Float = 0;

		for(i in 0...cl.length){
			var x = cl[i][0];
			var y = cl[i][1];

			aabb.x = Math.min(x, aabb.x);
			aabb.y = Math.min(y, aabb.y);
			xx = Math.max(x, xx);
			yy = Math.max(y, yy);

			if(i > 0){
				e.push(new Line(lx, ly, x, y));
			}

			lx = x;
			ly = y;
		}
		aabb.w = xx - aabb.x;
		aabb.h = yy - aabb.y;

		e.push(new Line(lx, ly, cl[0][0], cl[0][1]));
	}

	override function render(c:CanvasRenderingContext2D) {
		super.render(c);

		c.fillStyle = "#000";

		c.beginPath();
		c.moveTo(e[0].a.x, e[0].a.y);
		c.lineTo(e[0].b.x, e[0].b.y);

		for(i in 1...e.length-1){
			c.lineTo(e[i].b.x, e[i].b.y);
		}
		c.closePath();
		c.fill();
	}

	/**
	 * @param c 
	 * @param lx Light source X
	 * @param ly Light source Y
	 * @param d Shadow cast distance
	 */
	public function renderShadow(c:CanvasRenderingContext2D, lx:Float, ly:Float, d:Float){

		for(w in e){
			var da:Float = Math.atan2(w.a.y - ly, w.a.x - lx);
			var db:Float = Math.atan2(w.b.y - ly, w.b.x - lx);

			c.beginPath();
			c.moveTo(w.a.x, w.a.y);
			c.lineTo(w.b.x, w.b.y);
			c.lineTo(w.b.x + Math.cos(db) * d, w.b.y + Math.sin(db) * d);
			c.lineTo(w.a.x + Math.cos(da) * d, w.a.y + Math.sin(da) * d);
			c.lineTo(w.a.x, w.a.y);
			c.fill();
		}
	}

	public function countIntersect(line:Line):Int{
		var r:Int = 0;
		for(l in e){
			if(line.getIntersect(l) != null){
				r++;
			}
		}
		return r;
	}

	public function getIntersect(line:Line):Array<Vec>{
		var r:Array<Vec> = new Array<Vec>();

		for(l in e){
			var i = line.getIntersect(l);
			if(i != null){
				r.push(i);
			}
		}

		return r;
	}
}