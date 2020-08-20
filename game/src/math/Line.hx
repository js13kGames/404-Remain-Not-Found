package math;

class Line{
	public var a(default, null):Vec;
	public var b(default, null):Vec;

	public function new(ax:Float, ay:Float, bx:Float, by:Float){
		a = {
			x: ax,
			y: ay
		};

		b = {
			x: bx,
			y: by
		};
	}

	public function getVector():Vec{
		return {
			x: b.x - a.x,
			y: b.y - a.y
		};
	}

	public function getIntersect(o:Line):Vec{
		var aVector:Vec = getVector();
		var bVector:Vec = o.getVector();

		var divisor:Float = (aVector.x * bVector.y - bVector.x * aVector.y);
		if (divisor == 0)
		{
			return null;
		}

		var _aMultiplier:Float = (bVector.x * (a.y - o.a.y) - bVector.y * (a.x - o.a.x)) / divisor;
		var _bMultiplier:Float = 0;

		if (bVector.x != 0){
			_bMultiplier = (a.x - o.a.x + aVector.x * _aMultiplier) / bVector.x;
		}
		else if(bVector.y != 0){
			_bMultiplier = (a.y - o.a.y + aVector.y * _aMultiplier) / bVector.y;
		}
		else{
			return null;
		}

		if(_aMultiplier < 0 || _aMultiplier > 1){
			return null;
		}

		if(_bMultiplier < 0 || _bMultiplier > 1){
			return null;
		}

		return {
			x: a.x + aVector.x * _aMultiplier,
			y: a.y + aVector.y * _aMultiplier
		};
	}
}