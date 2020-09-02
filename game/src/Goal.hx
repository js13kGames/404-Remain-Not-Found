package;

import js.html.CanvasRenderingContext2D;

class Goal extends Entity{
	public var l(default, null):Int;
	public var p(default, null):Int;

	private var r:PlayRoom;

	public function new(x:Float, y:Float, w:Float, h:Float, l:Int, r:PlayRoom){
		super();

		this.aabb.x = x;
		this.aabb.y = y;
		this.aabb.w = w;
		this.aabb.h = h;

		this.l = l;
		this.r = r;
	}

	override function update(s:Float) {
		super.update(s);

		p = 0;
		for(pl in r.player){
			if(pl.aabb.check(this.aabb)){
				p++;
			}
		}
	}

	override function render(c:CanvasRenderingContext2D) {
		super.render(c);

		c.fillStyle = "#0000FF55";
		c.fillRect(aabb.x, aabb.y, aabb.w, aabb.h);
	}
}