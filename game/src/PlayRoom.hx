package;

import menu.Button;
import menu.MenuPage;
import js.Browser;
import js.html.CanvasElement;
import math.Line;
import actor.Guard;
import resources.LvlDef;
import actor.Phase;
import js.html.CanvasRenderingContext2D;
import actor.Actor;
import actor.Player;
import astar.BspGrid;
import math.AABB;

class PlayRoom extends Room{
	private var c:CanvasRenderingContext2D;
	private var ec:Array<CanvasRenderingContext2D> = new Array<CanvasRenderingContext2D>();

	private var lvl:LvlDef = null;

	private var viewX:Float = 0;
	private var viewY:Float = 0;
	private var viewZoom:Float = 1;

	public var grid(default, null):Float;
	public var bsp(default, null):BspGrid = null;
	public var walls(default, null):Array<Wall>;
	public var goals(default, null):Array<Goal>;

	public var player(default, null):Array<Player>;
	private var actor:Array<Actor>;
	private var currentActor:Int = -1;

	public var snd(default, null):Array<Sound>;

	private var delay:Float = -1;
	private var delayAction:Void->Void;

	private var menu:MenuPage = null;

	private var distractBtn:Button;

	public function new(g:Game, c:CanvasRenderingContext2D){
		super(g);
		
		this.c = c;

		walls = new Array<Wall>();
		player = new Array<Player>();
		actor = new Array<Actor>();
		goals = new Array<Goal>();
		snd = new Array<Sound>();

		distractBtn = new Button(120, 0, "👏", distract, 120);
		distractBtn.y = c.canvas.height - (distractBtn.aabb.h - 20);
	}

	override function update(c:CanvasRenderingContext2D, s:Float) {
		super.update(c, s);

		if(delay != -1){
			delay -= s;
			if(delay <= 0){
				delay = -1;
				delayAction();
			}
		}

		for(g in goals){
			g.update(s);
		}

		if(currentActor != -1){
			if(actor[currentActor].phase == Phase.TURN_END){
				var l:Int = checkGoal();
				if(l == -1){
					actor[currentActor].phase = Phase.IDLE;
					currentActor = (currentActor + 1 >= actor.length) ? 0 : currentActor + 1;
		
					actor[currentActor].phase = Phase.TURN_START;
				}else if(l == -2){
					// game complete
					g.menu();
				}else{
					currentActor = -1;
					// TODO begin transition
					g.loadLevel(Main.r.lvl[l]);
				}
			}
		}
	
		for(a in actor){
			a.update(s);
		}

		for(sn in snd){
			sn.update(s);
		}
	
		c.fillStyle = "#AAA";
		c.fillRect(0, 0, c.canvas.width, c.canvas.height);
	
		c.save();
		c.translate(viewX, viewY);
		c.scale(viewZoom, viewZoom);
	
		for(i in ec){
			i.clearRect(0, 0, i.canvas.width, i.canvas.height);
		}

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
			w.render(c);
		}

		for(g in goals){
			g.render(c);
		}

		for(s in snd){
			s.render(c);
		}
	
		for(a in actor){
			a.render(c);
		}

		c.restore();

		if(menu != null){
			c.fillStyle = "#00000088";
			c.fillRect(c.canvas.width * 0.25, c.canvas.height * 0.125, c.canvas.width * 0.5, c.canvas.height * 0.75);

			menu.render(c);
		}
		else if(isPlayerTurn()){
			distractBtn.render(c);
		}
	}

	override function pan(dx:Float, dy:Float) {
		super.pan(dx, dy);

		viewX += dx;
		viewY += dy;
	}

	override function zoom(cx:Float, cy:Float, s:Float) {
		super.zoom(cx, cy, s);

		var sx = (cx - viewX) / viewZoom;
		var sy = (cy - viewY) / viewZoom;

		viewZoom += s;
		if(viewZoom <= 0){
			viewZoom = 0.1;
		}

		viewX += (((cx - viewX) / viewZoom) - sx) * viewZoom;
		viewY += (((cy - viewY) / viewZoom) - sy) * viewZoom;
	}

	override function click(x:Float, y:Float) {
		super.click(x, y);

		for(p in player){
			p.click((x - viewX) / viewZoom, (y - viewY) / viewZoom);
		}

		if(menu != null){
			menu.click(x, y);
		}else if(isPlayerTurn()){
			distractBtn.click(x, y);
		}
	}

	override function mouseMove(x:Float, y:Float) {
		super.mouseMove(x, y);

		if(menu != null){
			menu.mouseMove(x, y);
		}else if(currentActor != -1 && actor[currentActor].isPlayer()){
			distractBtn.mouseMove(x, y);
		}
	}

	public function loadLevel(d:LvlDef){
		this.lvl = d;
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
			var pl = new Player(this);
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
			en.dir = e.a;

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

		goals = new Array<Goal>();
		for(g in d.gl){
			goals.push(new Goal(g.x, g.y, g.w, g.h, g.l, this));
		}

		for(s in snd){
			s.kill();
		}

		var rw:Float = d.w * grid;
		var rh:Float = d.h * grid;

		viewX = (c.canvas.width / 2) - (rw / 2);
		viewY = (c.canvas.height / 2) - (rh / 2);
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

	public function spotted(a:Actor, b:Actor){
		if(currentActor != -1){
			currentActor = -1;

			delay = 1;
			delayAction = function(){
				showMenu("Found!");
			}
		}
	}

	private function showMenu(reason:String){
		var cw = c.canvas.width;
		var ch = c.canvas.height;

		menu = new MenuPage(reason);
		menu.x = cw / 2;
		menu.y = ch * 0.25;
		menu.add("Retry", cw / 2, ch / 2, function(){
			menu = null;
			loadLevel(lvl);
		});
		menu.add("Exit to menu", cw / 2, ch * 0.75, function(){
			g.menu();
		});
	}

	private function checkGoal(){
		for(g in goals){
			if(g.p == player.length){
				return g.l;
			}
		}

		return -1;
	}

	public function makeSnd(x:Float, y:Float, v:Float){
		var ns:Sound = null;
		for(s in snd){
			if(!s.alive){
				ns = s;
				break;
			}
		}

		if(ns == null){
			ns = new Sound();
			snd.push(ns);
		}

		ns.init(x, y, v);
	}

	private function distract(){
		var a = actor[currentActor];
		makeSnd(a.x, a.y, 50);
	}

	private inline function isPlayerTurn(){
		return currentActor != -1 && actor[currentActor].isPlayer();
	}
}