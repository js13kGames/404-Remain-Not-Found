package;

import js.html.CanvasRenderingContext2D;

class Sound extends Entity{
	private static inline var VOLUME_SCALE:Float = 3;
	private var v:Float;

	private var t:Float;
	public var r(default, null):Float;
	public var alive(default, null):Bool;

	public function init(x:Float, y:Float, v:Float){
		this.x = x;
		this.y = y;
		this.v = v;

		this.t = 0;
		this.r = 0;
		this.alive = true;
	}

	override function update(s:Float) {
		super.update(s);

		if(alive){
			t += s;
			if(t > 1){
				kill();
				return;
			}

			r += (v * VOLUME_SCALE) * s;

			aabb.x = x - r;
			aabb.y = y - r;
			aabb.w = r * 2;
			aabb.h = r * 2;
		}
	}

	override function render(c:CanvasRenderingContext2D) {
		super.render(c);

		if(alive){
			c.strokeStyle = "#FFF";
			c.beginPath();
			c.arc(x, y, r, 0, Math.PI * 2);
			c.stroke();
		}
	}

	public function kill(){
		alive = false;
	}
}