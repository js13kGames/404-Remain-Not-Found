package math;

class LcMath{
	public static inline function capAngle(a:Float):Float{
		return a < 0 ? (a + Math.PI * 2) : (a > Math.PI * 2 ? a - Math.PI * 2 : a);
	}

	public static inline function dist(ax:Float, ay:Float, bx:Float, by:Float):Float{
		return Math.sqrt(Math.pow(ax - bx, 2) + Math.pow(ay - by, 2));
	}
}