package;

import math.Vec;
import math.Line;
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

	private var grid:Float;
	private var bsp:BspGrid = null;
	private var walls:Array<Wall>;
	private var player:Array<Player>;

	public function new(ele:Element, c:CanvasRenderingContext2D){
		this.c = c;

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

		if(bsp != null){
			for(x in 1...bsp.w){
				c.beginPath();
				c.moveTo(x * grid, 0);
				c.lineTo(x * grid, bsp.h * grid);
				c.stroke();
			}

			for(y in 1...bsp.h){
				c.beginPath();
				c.moveTo(0, y * grid);
				c.lineTo(bsp.w * grid, y * grid);
				c.stroke();
			}
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
		grid = d.g;
		bsp = new BspGrid(d.w, d.h);

		walls = new Array<Wall>();
		for(wd in d.wl){
			var wl:Wall = new Wall(wd.c);
			walls.push(wl);
			addWallToBsp(bsp, wl);
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

	private inline function addWallToBsp(bsp:BspGrid, wall:Wall){
		var gx = Math.floor(wall.aabb.x / grid);
		var gy = Math.floor(wall.aabb.y / grid);
		var gw = Math.ceil(wall.aabb.w / grid);
		var gh = Math.ceil(wall.aabb.h / grid);

		var ln:Line = new Line(wall.aabb.x - 2, wall.aabb.y - 1, 0, 0);

		for(xx in 0...gw){
			ln.b.x = wall.aabb.x + (xx * grid) + (grid / 2);

			for(yy in 0...gh){
				ln.b.y = wall.aabb.y + (yy * grid) + (grid / 2);

				var ic = wall.countIntersect(ln);
				if(ic % 2 != 0){
					bsp.set(gx + xx, gy + yy, true);
				}
			}
		}

	}
}