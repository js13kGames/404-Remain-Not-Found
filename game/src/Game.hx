package;

import actor.Phase;
import js.html.WheelEvent;
import astar.Point;
import js.html.MouseScrollEvent;
import js.html.MouseEvent;
import js.html.Element;
import actor.Player;
import astar.DistGrid;
import astar.BspGrid;
import js.html.CanvasRenderingContext2D;

class Game{
	private var c:CanvasRenderingContext2D;

	private var player:Player;
	private var viewX:Float = 0;
	private var viewY:Float = 0;
	private var viewZoom:Float = 1;

	private var isMouseDown:Bool = false;
	private var mouseStart:Point = null;

	public function new(ele:Element, c:CanvasRenderingContext2D){
		this.c = c;

		var bsp:BspGrid = new BspGrid(100, 100);
		bsp.set(1, 1, true);

		var roomSize:Float = 100 * 32;

		player = new Player(bsp, 32);
		player.x = 32 / 2;
		player.y = c.canvas.height / 2;
		player.phase = Phase.TURN_START;
	}

	public function update(s:Float){
		player.update(s);

		c.fillStyle = "#000";
		c.fillRect(0, 0, c.canvas.width, c.canvas.height);

		c.save();
		c.translate(viewX, viewY);
		c.scale(viewZoom, viewZoom);

		c.strokeStyle = "#FFF";

		for(x in 1...100){
			c.beginPath();
			c.moveTo(x * 32, 0);
			c.lineTo(x * 32, 100*32);
			c.stroke();
		}

		for(y in 1...100){
			c.beginPath();
			c.moveTo(0, y*32);
			c.lineTo(100*32, y*32);
			c.stroke();
		}

		player.render(c);

		c.restore();
	}

	public function onMouseDown(x:Float, y:Float){
		isMouseDown = true;
	}

	public function onMouseUp(x:Float, y:Float){
		isMouseDown = false;
	}

	public function onMouseMove(dx:Float, dy:Float){
		if(isMouseDown){
			viewX += dx;
			viewY += dy;
		}
	}

	public function onMouseWheel(e:WheelEvent){
		viewZoom += e.deltaY * -0.1;
		// shift view by mouse position
	}

	public function onClick(x:Float, y:Float){
		player.click((x - viewX) / viewZoom, (y - viewY) / viewZoom);
	}
}