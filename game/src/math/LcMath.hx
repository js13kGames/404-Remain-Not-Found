package math;

class LcMath{
	public static inline function capAngle(a:Float){
		return a < 0 ? (a + Math.PI * 2) : (a > Math.PI * 2 ? a - Math.PI * 2 : a);
	}
}