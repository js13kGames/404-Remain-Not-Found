package math;

class AABB{
	public var x:Float;
	public var y:Float;
	public var w:Float;
	public var h:Float;

	public function new(x:Float = 0, y:Float = 0, w:Float = 0, h:Float = 0){
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}

	public inline function contains(x:Float, y:Float):Bool{
		return !(x < this.x || x > this.x + w
			|| y < this.y || y > this.y + h);
	}

	public function check(o:AABB):Bool{
		return o.contains(x, y) || o.contains(x + w, y) || o.contains(x, y + h) || o.contains(x + w, y + h)
		|| contains(o.x, o.y) || contains(o.x + o.w, o.y) || contains(o.x, o.y + o.h) || contains(o.x + o.w, o.y + o.h);
	}
}