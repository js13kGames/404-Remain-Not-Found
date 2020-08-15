package;

import astar.DistGrid;
import astar.BspGrid;
import js.html.CanvasRenderingContext2D;

class Game{
	private var c:CanvasRenderingContext2D;

	public function new(c:CanvasRenderingContext2D){
		this.c = c;

		var bsp:BspGrid = new BspGrid(4, 4);
		bsp.set(1, 1, true);

		var dst:DistGrid = new DistGrid(bsp);
		trace(dst.route(2,2, 1, 0));
	}

	public function update(s:Float){
		c.fillStyle = "#000";
		c.fillRect(0, 0, c.canvas.width, c.canvas.height);
		c.fillStyle = "#fff";
		c.fillText("Hello World!", 20, 20);
	}
}