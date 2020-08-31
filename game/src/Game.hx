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

	private var isMouseDown:Bool = false;
	private var panning:Bool = false;
	private var mouseStart:Vec = null;

	private var r:Room = null;

	public function new(c:CanvasRenderingContext2D){
		this.c = c;
	}

	public function update(s:Float){
		if(r != null){
			r.update(c, s);
		}
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
		if(r != null){
			r.mouseMove(x, y);
		}

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
		if(r != null){
			r.pan(dx, dy);
		}
	}

	public function zoom(cx:Float, cy:Float, s:Float){
		if(r != null){
			r.zoom(cx, cy, s);
		}
	}

	public function onClick(x:Float, y:Float){
		if(r != null && !panning){
			r.click(x, y);
		}
	}

	public function loadLevel(d:LvlDef){
		var lr:PlayRoom = new PlayRoom(c);
		lr.loadLevel(d);

		r = lr;
	}
}