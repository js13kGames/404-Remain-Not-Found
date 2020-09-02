package astar;

class BspGrid{
	public var w(default, null):Int;
	public var h(default, null):Int;

	private var space:Array<Array<Bool>>;

	public function new(w:Int, h:Int){
		this.w = w;
		this.h = h;

		space = new Array<Array<Bool>>();
		for(x in 0...w){
			var col = new Array<Bool>();
			for(y in 0...h){
				col.push(false);
			}

			space.push(col);
		}
	}

	public function get(x:Int, y:Int):Bool{
		if(x < 0 || x + 1 > w || y < 0 || y + 1 > h){
			return true;
		}
		return space[x][y];
	}

	public function set(x:Int, y:Int, filled:Bool){
		if(x < 0 || x + 1 > w || y < 0 || y + 1 > h){
			return;
		}
		space[x][y] = filled;
	}
}