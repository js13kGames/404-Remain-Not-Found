package;

import js.html.KeyboardEvent;
import js.html.URLSearchParams;
import js.html.URL;
import math.Vec;
import js.html.Touch;
import js.html.TouchEvent;
import resources.ResourceBuilder;
import js.html.WheelEvent;
import js.html.MouseEvent;
import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;
import js.Browser;

class Main{
	public static var r(default, null) = ResourceBuilder.build();

	private static var canvas:CanvasElement;

	public static var c:CanvasRenderingContext2D;
	public static var g:Game;
	public static var s:SoundManager;

	public static var lastFrame:Float = 0;

	private static var firstTouch:Int = -1;
	private static var touchStart:Float = 0;
	private static var pan:Vec = {x:0, y:0};
	private static var lastPinch:Float = 0;

	public static function main(){
		canvas = cast Browser.window.document.getElementById("c");
		Browser.window.document.body.onresize = onResize;
		
		onResize();

		c = canvas.getContext2d();
		g = new Game(c);
		s = new SoundManager(r.snd);

		Browser.window.onmousedown = onMouseDown;
		Browser.window.onmouseup = onMouseUp;
		Browser.window.onmousemove = onMouseMove;
		Browser.window.onwheel = onMouseWheel;
		Browser.window.onclick = onClick;
		Browser.window.ontouchstart = onTouchStart;
		Browser.window.ontouchmove = onTouchMove;
		Browser.window.ontouchend = onTouchEnd;

		Browser.window.onkeypress = function(e:KeyboardEvent){
			var id = Std.parseInt(e.key);
			if(id == 0){
				id = 10;
			}

			g.loadLevel(r.lvl[id]);
		}

		var p = new URLSearchParams(Browser.window.location.search);
		if(p.has("l")){
			g.loadLevel(r.lvl[Std.parseInt(p.get("l"))]);
		}

		Browser.window.requestAnimationFrame(update);
	}

	public static function update(s:Float){
		g.update((s - lastFrame) / 1000);
		lastFrame = s;
		Browser.window.requestAnimationFrame(update);
	}

	public static function onResize(){
		canvas.style.left = Std.string(Math.floor((Browser.window.document.body.clientWidth - canvas.clientWidth) / 2)) + "px";
		canvas.style.top = Std.string(Math.floor((Browser.window.document.body.clientHeight - canvas.clientHeight) / 2)) + "px";
	}

	private static inline function getX(clientX:Float):Float{
		return (clientX - canvas.offsetLeft) * (canvas.width / canvas.clientWidth);
	}

	private static inline function getY(clientY:Float):Float{
		return (clientY - canvas.offsetTop) * (canvas.height / canvas.clientHeight);
	}

	private static inline function scaleX(clientX:Float):Float{
		return clientX * (canvas.width / canvas.clientWidth);
	}

	private static inline function scaleY(clientY:Float):Float{
		return clientY * (canvas.height / canvas.clientHeight);
	}

	private static inline function touchDistance(a:Touch, b:Touch):Float{
		return Math.sqrt(Math.pow(scaleX(a.clientX - b.clientX), 2) + Math.pow(scaleY(a.clientY - b.clientY), 2));
	}

	private static function touchCenter(a:Touch, b:Touch):Vec{
		return {
			x: a.clientX + (b.clientX - a.clientX) / 2,
			y: a.clientY + (b.clientY - a.clientY) / 2
		};
	}

	private static function onMouseDown(e:MouseEvent){
		e.preventDefault();
		g.onMouseDown(getX(e.clientX), getY(e.clientY));
	}

	private static function onMouseUp(e:MouseEvent){
		e.preventDefault();
		g.onMouseUp(getX(e.clientX), getY(e.clientY));
	}

	private static function onMouseMove(e:MouseEvent){
		e.preventDefault();
		g.onMouseMove(getX(e.clientX), getY(e.clientY), scaleX(e.movementX), scaleY(e.movementY));
	}

	private static function onMouseWheel(e:WheelEvent){
		e.preventDefault();
		g.zoom(getX(e.clientX), getY(e.clientY), e.deltaY * -0.1);
	}

	private static function onClick(e:MouseEvent){
		g.onClick(getX(e.clientX), getY(e.clientY));
	}

	private static function onTouchStart(e:TouchEvent){
		if(e.touches.length == 1){
			firstTouch = e.touches[0].identifier;
			touchStart = e.timeStamp;

			pan.x = e.touches[0].clientX;
			pan.y = e.touches[0].clientY;
		}else{
			firstTouch = -1;
		}

		if(e.touches.length == 2){
			lastPinch = touchDistance(e.touches[0], e.touches[1]);
		}
	}

	private static function onTouchMove(e:TouchEvent){
		e.preventDefault();

		var pt = e.changedTouches[0];

		if(e.touches.length == 2){
			var d:Float = touchDistance(e.touches[0], e.touches[1]);
			var c:Vec = touchCenter(e.touches[0], e.touches[1]);

			g.zoom(c.x, c.y, (d - lastPinch) * 0.01);

			lastPinch = d;
		}else if(e.touches.length == 1 && pt.identifier == firstTouch){
			g.pan(scaleX(pt.clientX - pan.x), scaleY(pt.clientY - pan.y));
			pan.x = pt.clientX;
			pan.y = pt.clientY;
		}
	}

	private static function onTouchEnd(e:TouchEvent){
		e.preventDefault();

		var changed = e.changedTouches[0];

		if(changed.identifier == firstTouch){
			if(e.timeStamp - touchStart < 500){
				g.onClick(getX(changed.clientX), getY(changed.clientY));
			}

			firstTouch = -1;
		}
	}
}