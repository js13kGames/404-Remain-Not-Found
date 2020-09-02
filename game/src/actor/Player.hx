package actor;

import path.Path;
import astar.BspGrid;
import js.html.CanvasRenderingContext2D;

class Player extends Actor{
	private static inline var MAX_MOVE:Int = 10;
	private var dstFillCurrent:Bool = false;

	public function new(g:PlayRoom){
		super(g);
	}

	override function update(s:Float) {
		super.update(s);
		
		if(phase == Phase.TURN_START && !dstFillCurrent){
			dst.fillFrom(Math.floor(x / gridSize), Math.floor(y / gridSize), MAX_MOVE);
			dstFillCurrent = true;
		}
		
		aabb.x = x - gridSize / 2;
		aabb.y = y - gridSize / 2;
		aabb.w = gridSize;
		aabb.h = gridSize;
	}

	override function render(c:CanvasRenderingContext2D){
		super.render(c);

		c.fillStyle = "#00F";
		c.beginPath();
		c.arc(x, y, gridSize / 2, 0, Math.PI * 2);
		c.fill();

		if(phase == Phase.TURN_START){
			c.strokeStyle = "#FF0";
			c.beginPath();
			c.arc(x, y, gridSize / 1.5, 0, Math.PI * 2);
			c.stroke();

			renderMoveGrid(c);
		}

		/*
		c.fillStyle="#0F0";
		for(x in 0...100){
			for(y in 0...100){
				c.fillText(Std.string(dst.get(x, y)), x * gridSize, y * gridSize + 20);
			}
		}
		*/
	}

	private inline function renderMoveGrid(c:CanvasRenderingContext2D){
		var gx:Int = Math.floor(x / gridSize);
		var gy:Int = Math.floor(y / gridSize);

		inline function drawMoveNode(xx:Int, yy:Int, d:Float){
			var r:Float = 255 * (d / MAX_MOVE);
			var g:Float = 255 * (1 - d / MAX_MOVE);
			c.fillStyle = 'rgba($r, $g, 0, 0.3)';

			c.fillRect(xx * gridSize, yy * gridSize, gridSize, gridSize);
		}

		for(xx in (gx - MAX_MOVE)...(gx + MAX_MOVE)){
			for(yy in (gy - MAX_MOVE)...(gy + MAX_MOVE)){
				var d:Float = dst.get(xx, yy);
				if(d > 0 && d <= MAX_MOVE){
					drawMoveNode(xx, yy, d);
				}
			}
		}
	}

	public function click(x:Float, y:Float){
		if(phase == Phase.TURN_START){
			var sx = Math.floor(this.x / gridSize);
			var sy = Math.floor(this.y / gridSize);

			var ex = Math.floor(x / gridSize);
			var ey = Math.floor(y / gridSize);

			navNodes = Path.fromPoints(dst.route(sx, sy, ex, ey, MAX_MOVE), gridSize, true);
			navIndex = 0;
			navSpeed = 128;

			if(navNodes.length > 0)
			{
				phase = Phase.MOVING;
				dstFillCurrent = false;
			}
		}
	}

	override function step() {
		super.step();

		g.makeSnd(x, y, 10);
	}
}