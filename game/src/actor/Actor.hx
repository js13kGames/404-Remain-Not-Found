package actor;

import math.Vec;
import astar.DistGrid;
import js.html.CanvasRenderingContext2D;
import astar.BspGrid;

class Actor extends Entity{
	private var bsp:BspGrid;
	private var gridSize:Float;

	public var phase(default, default):Phase;
	private var dst:DistGrid;

	private var navNodes:Array<Vec> = [];
	private var navIndex:Int = 0;
	private var navSpeed:Float = 0;

	public function new(bsp:BspGrid, gridSize:Float){
		super();
		this.bsp = bsp;
		this.gridSize = gridSize;

		this.phase = Phase.IDLE;
		this.dst = new DistGrid(bsp);
	}

	override function update(s:Float) {
		super.update(s);

		if(navNodes.length > navIndex){
			var node:Vec = navNodes[navIndex];

			// calculate distance
			var dist = Math.sqrt(Math.pow(x - node.x, 2) + Math.pow(y - node.y, 2));
			
			if(dist < navSpeed * s){
				x = node.x;
				y = node.y;
				navIndex += 1;
				xSpeed = 0;
				ySpeed = 0;
			}else{
				// calc speed
				var dir:Float = Math.atan2(node.y - y, node.x - x);
				xSpeed = Math.cos(dir) * navSpeed;
				ySpeed = Math.sin(dir) * navSpeed;
			}
		}else if(phase == Phase.MOVING){
			phase = Phase.TURN_END;
		}
	}

	override function render(c:CanvasRenderingContext2D){
		super.render(c);
	}

	public function resetNav(){
		navNodes = [];
		navIndex = 0;
		navSpeed = 0;
		xSpeed = 0;
		ySpeed = 0;
	}
}