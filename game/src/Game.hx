package;

import math.AABB;
import resources.LvlDef;
import actor.Phase;
import js.html.WheelEvent;
import astar.Point;
import js.html.Element;
import actor.Player;
import astar.BspGrid;
import js.html.CanvasRenderingContext2D;

class Game{
	private var c:CanvasRenderingContext2D;

	private var viewX:Float = 0;
	private var viewY:Float = 0;
	private var viewZoom:Float = 1;
	private var viewAABB:AABB = new AABB();

	private var isMouseDown:Bool = false;
	private var mouseStart:Point = null;
	private var mouseX:Float = 0;
	private var mouseY:Float = 0;

	private var bsp:BspGrid;
	private var walls:Array<Wall>;
	private var player:Array<Player>;

	public function new(ele:Element, c:CanvasRenderingContext2D){
		this.c = c;

		var bsp:BspGrid = new BspGrid(100, 100);

		walls = new Array<Wall>();
		player = new Array<Player>();
	}

	public function update(s:Float){
		for(p in player){
			p.update(s);
		}

		c.fillStyle = "#AAA";
		c.fillRect(0, 0, c.canvas.width, c.canvas.height);

		c.save();
		c.translate(viewX, viewY);
		c.scale(viewZoom, viewZoom);
		viewAABB.x = -viewX / viewZoom;
		viewAABB.y = -viewY / viewZoom;
		viewAABB.w = c.canvas.width / viewZoom;
		viewAABB.h = c.canvas.height / viewZoom;

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

		for(w in walls){
			if(viewAABB.check(w.aabb)){
				w.render(c);
			}
		}

		for(p in player){
			p.render(c);
		}

		c.restore();
	}

	public function onMouseDown(x:Float, y:Float){
		isMouseDown = true;
	}

	public function onMouseUp(x:Float, y:Float){
		isMouseDown = false;
	}

	public function onMouseMove(x:Float, y:Float, dx:Float, dy:Float){
		mouseX = x;
		mouseY = y;

		if(isMouseDown){
			viewX += dx;
			viewY += dy;
		}
	}

	public function onMouseWheel(e:WheelEvent){
		var sx = (mouseX - viewX) / viewZoom;
		var sy = (mouseY - viewY) / viewZoom;

		viewZoom += e.deltaY * -0.1;

		viewX += (((mouseX - viewX) / viewZoom) - sx) * viewZoom;
		viewY += (((mouseY - viewY) / viewZoom) - sy) * viewZoom;
	}

	public function onClick(x:Float, y:Float){
		for(p in player){
			p.click((x - viewX) / viewZoom, (y - viewY) / viewZoom);
		}
	}

	public function loadLevel(d:LvlDef){
		bsp = new BspGrid(d.w, d.h);

		walls = new Array<Wall>();
		for(wd in d.wl){
			walls.push(new Wall(wd.c));
			// TODO add wall to bsp
		}

		player = new Array<Player>();
		for(p in d.pl){
			var pl = new Player(bsp, 32);
			pl.x = p.x;
			pl.y = p.y;
			pl.phase = Phase.IDLE;

			player.push(pl);
		}

		if(player.length > 0){
			player[0].phase = Phase.TURN_START;
		}

	}
}