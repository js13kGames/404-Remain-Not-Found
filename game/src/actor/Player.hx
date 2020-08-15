package actor;

import path.Path;
import astar.BspGrid;
import js.html.CanvasRenderingContext2D;

class Player extends Actor{
	public function new(bsp:BspGrid, gridSize:Float){
		super(bsp, gridSize);
	}

	override function update(s:Float) {
		super.update(s);
		
		
	}

	override function render(c:CanvasRenderingContext2D){
		super.render(c);

		c.fillStyle = "#00F";
		c.beginPath();
		c.arc(x, y, gridSize / 2, 0, Math.PI * 2);
		c.fill();

		/*
		c.fillStyle="#0F0";
		for(x in 0...100){
			for(y in 0...100){
				c.fillText(Std.string(dst.get(x, y)), x * gridSize, y * gridSize + 20);
			}
		}
		*/
	}

	public function click(x:Float, y:Float){
		if(phase == Phase.TURN_START){
			var sx = Math.floor(this.x / gridSize);
			var sy = Math.floor(this.y / gridSize);

			var ex = Math.floor(x / gridSize);
			var ey = Math.floor(y / gridSize);

			navNodes = Path.fromPoints(dst.route(sx, sy, ex, ey, 20), gridSize, true);
			navIndex = 0;
			navSpeed = 128;
		}
	}
}