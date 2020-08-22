package astar;

class DistGrid{
	private var dirty:Bool;
	private var space:Array<Array<Float>>;
	private var bsp:BspGrid;

	public function new(bsp:BspGrid){
		dirty = false;

		space = new Array<Array<Float>>();
		for(x in 0...bsp.w){
			var col = new Array<Float>();
			for(y in 0...bsp.h){
				col.push(-1);
			}

			space.push(col);
		}
		
		this.bsp = bsp;
	}

	public function clear(){
		if(dirty){
			for(x in space){
				for(y in 0...x.length){
					x[y] = -1;
				}
			}
			dirty = false;
		}
	}

	public function route(sx:Int, sy:Int, ex:Int, ey:Int, max:Int):Array<Point>{
		if(space[sx][sy] != 0){
			fillFrom(sx, sy, max);
		}

		if(space[ex][ey] == -1){
			return new Array<Point>();
		}

		function findNext(x:Int, y:Int):Point{
			var c:Float = space[x][y];

			// smallest
			var s:Float = -1;
			var sx:Int = 0;
			var sy:Int = 0;

			//next
			var n:Float = 0;
			var nx:Int = 0;
			var ny:Int = 0;

			for(xx in [-1,0,1]){
				for(yy in [-1,0,1]){
					nx = x + xx;
					ny = y + yy;

					if((xx == 0 && yy == 0) || (nx < 0 || nx + 1 > bsp.w || ny < 0 || ny + 1 > bsp.h)){
						continue;
					}

					n = space[nx][ny];

					if(c - n < 2 && n != -1 && (s == -1 || s > n)){
						s = n;
						sx = nx;
						sy = ny;
					}
				}
			}

			if(s != -1){
				return makePoint(sx, sy);
			}

			return null;
		}

		var nav:Array<Point> = new Array<Point>();
		nav.push({
			x: ex,
			y: ey
		});

		var next:Point = nav[0];
		while(next != null && !(next.x == sx && next.y == sy)){
			next = findNext(next.x, next.y);
			nav.push(next);
		}

		nav.reverse();
		return nav;
	}

	public function fillFrom(x:Int, y:Int, max:Int){
		clear();

		space[x][y] = 0;
		calculateNeighbors(x, y, max);

		dirty = true;
	}

	private function calculateNeighbors(x:Int, y:Int, max:Float){
		var me:Float = space[x][y];
		if(me >= max){
			return;
		}

		var nv:Float = 0;

		function calc(xx:Int, yy:Int, d:Float = 1):Bool{
			if(bsp.get(xx, yy)){
				return false;
			}

			nv = space[xx][yy];
			if(nv == -1 || nv > me + d){
				space[xx][yy] = me + d;
				calculateNeighbors(xx, yy, max);
			}

			return true;
		}

		var r:Bool = calc(x + 1, y);
		var l:Bool = calc(x - 1, y);
		var u:Bool = calc(x, y - 1);
		var d:Bool = calc(x, y + 1);

		if(r && u){
			calc(x + 1, y - 1, 1.4);
		}
		if(r && d){
			calc(x + 1, y + 1, 1.4);
		}
		if(l && u){
			calc(x - 1, y - 1, 1.4);
		}
		if(l && d){
			calc(x - 1, y + 1, 1.4);
		}
	}

	public function get(x:Int, y:Int):Float{
		if(x < 0 || x >= bsp.w || y < 0 || y >= bsp.h){
			return -1;
		}
		
		return space[x][y];
	}

	private inline function makePoint(xx:Int, yy:Int):Point{
		return {
			x: xx,
			y: yy
		};
	}
}