package;

import js.html.CanvasWindingRule;
import js.html.CanvasRenderingContext2D;

class Wall extends Entity{
	private var cl:Array<Array<Int>>;

	public function new(cl:Array<Array<Int>>){
		super();
		this.cl = cl;

		aabb.x = cl[0][0];
		aabb.y = cl[0][1];
		var xx:Float = aabb.x;
		var yy:Float = aabb.y;
		for(c in cl){
			aabb.x = Math.min(c[0], aabb.x);
			aabb.y = Math.min(c[1], aabb.y);
			xx = Math.max(c[0], xx);
			yy = Math.max(c[1], yy);
		}
		aabb.w = xx - aabb.x;
		aabb.h = yy - aabb.y;
	}

	override function render(c:CanvasRenderingContext2D) {
		super.render(c);

		c.fillStyle = "#000";

		c.beginPath();
		c.moveTo(cl[0][0], cl[0][1]);
		var first:Bool = true;
		for(cnr in cl){
			if(first){
				first = false;
				continue;
			}

			c.lineTo(cnr[0], cnr[1]);
		}
		c.closePath();
		c.fill();
	}
}