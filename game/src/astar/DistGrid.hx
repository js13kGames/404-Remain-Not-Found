package astar;

class DistGrid{
	private var dirty:Bool;
	private var space:Array<Array<Int>>;
	private var bsp:BspGrid;

	public function new(bsp:BspGrid){
		dirty = false;

		space = new Array<Array<Int>>();
		for(x in 0...bsp.w){
			var col = new Array<Int>();
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

	public function route(sx:Int, sy:Int, ex:Int, ey:Int):Array<Point>{
		if(space[sx][sy] != 0){
			fillFrom(sx, sy);
		}

		if(space[ex][ey] == -1){
			return new Array<Point>();
		}

		function findNext(x:Int, y:Int):Point{
			var c:Int = space[x][y];
			var n:Int = 0;

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
					if(n != -1 && n < c){
						return makePoint(nx, ny);
					}
				}
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

	public function fillFrom(x:Int, y:Int){
		clear();

		space[x][y] = 0;
		calculateNeighbors(x, y);
	}

	private function calculateNeighbors(x:Int, y:Int){
		var me:Int = space[x][y];
		var nv:Int = 0;

		function calc(xx:Int, yy:Int):Bool{
			if(bsp.get(xx, yy)){
				return false;
			}

			nv = space[xx][yy];
			if(nv == -1 || nv > me + 1){
				space[xx][yy] = me + 1;
				calculateNeighbors(xx, yy);
			}

			return true;
		}

		var r:Bool = calc(x + 1, y);
		var l:Bool = calc(x - 1, y);
		var u:Bool = calc(x, y - 1);
		var d:Bool = calc(x, y + 1);

		if(r && u){
			calc(x + 1, y - 1);
		}
		if(r && d){
			calc(x + 1, y + 1);
		}
		if(l && u){
			calc(x - 1, y - 1);
		}
		if(l && d){
			calc(x - 1, y + 1);
		}
	}

	private inline function makePoint(xx:Int, yy:Int):Point{
		return {
			x: xx,
			y: yy
		};
	}
}