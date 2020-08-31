package;

import math.Vec;
import js.Browser;
import js.html.CanvasElement;
import actor.Guard;
import actor.Actor;
import math.Line;
import math.AABB;
import resources.LvlDef;
import actor.Phase;
import js.html.Element;
import actor.Player;
import astar.BspGrid;
import js.html.CanvasRenderingContext2D;

class Game{
	private static inline var PAN_START_DISTANCE:Float = 10;

	private var c:CanvasRenderingContext2D;
	private var ec:Array<CanvasRenderingContext2D>;

	private var viewX:Float = 0;
	private var viewY:Float = 0;
	private var viewZoom:Float = 1;
	private var viewAABB:AABB = new AABB();

	private var isMouseDown:Bool = false;
	private var panning:Bool = false;
	private var mouseStart:Vec = null;
	private var mousePos:Vec;

	public var grid(default, null):Float;
	public var bsp(default, null):BspGrid = null;
	public var walls(default, null):Array<Wall>;

	public var player(default, null):Array<Player>;
	private var actor:Array<Actor>;
	private var currentActor:Int = -1;

	public function new(ele:Element, c:CanvasRenderingContext2D){
		this.c = c;
		ec = new Array<CanvasRenderingContext2D>();

		walls = new Array<Wall>();
		player = new Array<Player>();
		actor = new Array<Actor>();

		mousePos = {
			x: 0.0,
			y: 0.0
		}
	}

	public function update(s:Float){
		if(currentActor != -1){
			if(actor[currentActor].phase == Phase.TURN_END){
				actor[currentActor].phase = Phase.IDLE;
				currentActor = (currentActor + 1 >= actor.length) ? 0 : currentActor + 1;

				actor[currentActor].phase = Phase.TURN_START;
			}
		}

		for(a in actor){
			a.update(s);
		}

		c.fillStyle = "#AAA";
		c.fillRect(0, 0, c.canvas.width, c.canvas.height);

		c.save();
		c.translate(viewX, viewY);
		c.scale(viewZoom, viewZoom);

		for(i in ec){
			i.clearRect(0, 0, i.canvas.width, i.canvas.height);
		}

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

		for(a in actor){
			a.render(c);
		}

		c.restore();
	}

	public function onMouseDown(x:Float, y:Float){
		isMouseDown = true;
		panning = false;

		mouseStart = {
			x: x,
			y: y
		};
	}

	public function onMouseUp(x:Float, y:Float){
		isMouseDown = false;
	}

	public function onMouseMove(x:Float, y:Float, dx:Float, dy:Float){
		if(isMouseDown){
			if(Math.sqrt(Math.pow(x - mouseStart.x, 2) + Math.pow(y - mouseStart.y, 2)) > PAN_START_DISTANCE){
				panning = true;
			}

			if(panning){
				pan(dx, dy);
			}
		}
	}

	public function pan(dx:Float, dy:Float){
		viewX += dx;
		viewY += dy;
	}

	public function zoom(cx:Float, cy:Float, s:Float){
		var sx = (cx - viewX) / viewZoom;
		var sy = (cy - viewY) / viewZoom;

		viewZoom += s;
		if(viewZoom <= 0){
			viewZoom = 0.1;
		}

		viewX += (((cx - viewX) / viewZoom) - sx) * viewZoom;
		viewY += (((cy - viewY) / viewZoom) - sy) * viewZoom;
	}

	public function onClick(x:Float, y:Float){
		if(!panning){
			for(p in player){
				p.click((x - viewX) / viewZoom, (y - viewY) / viewZoom);
			}
		}
	}

	public function loadLevel(d:LvlDef){
		ec = new Array<CanvasRenderingContext2D>();

		grid = d.g;
		bsp = new BspGrid(d.w, d.h);

		walls = new Array<Wall>();
		for(wd in d.wl){
			var wl:Wall = new Wall(wd.c);
			walls.push(wl);
			addWallToBsp(bsp, wl);
		}

		actor = new Array<Actor>();

		player = new Array<Player>();
		for(p in d.pl){
			var pl = new Player(bsp, grid);
			pl.x = p.x;
			pl.y = p.y;
			pl.phase = Phase.IDLE;

			player.push(pl);
			actor.push(pl);
		}

		for(e in d.en){
			var en = new Guard(this);
			en.x = e.x;
			en.y = e.y;

			for(n in e.nav){
				en.ptrl.push({
					x: Math.floor(n[0] / grid),
					y: Math.floor(n[1] / grid)
				});
			}

			actor.push(en);
		}

		if(actor.length > 0){
			currentActor = 0;
			actor[0].phase = Phase.TURN_START;
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

	public function newCanvas():CanvasRenderingContext2D{
		var ele:CanvasElement = Browser.document.createCanvasElement();
		ele.width = c.canvas.width;
		ele.height = c.canvas.height;

		var cc = ele.getContext2d();
		ec.push(cc);

		return cc;
	}
}