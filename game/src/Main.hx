package;

import resources.ResourceBuilder;
import js.html.WheelEvent;
import js.html.MouseEvent;
import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;
import js.Browser;

class Main{
	private static var r = ResourceBuilder.build();

	private static var canvas:CanvasElement;

	public static var c:CanvasRenderingContext2D;
	public static var g:Game;

	public static var lastFrame:Float = 0;

	public static function main(){
		canvas = cast Browser.window.document.getElementById("c");
		Browser.window.document.body.onresize = onResize;
		
		onResize();

		c = canvas.getContext2d();
		g = new Game(canvas, c);

		Browser.window.onmousedown = onMouseDown;
		Browser.window.onmouseup = onMouseUp;
		Browser.window.onmousemove = onMouseMove;
		Browser.window.onwheel = onMouseWheel;
		Browser.window.onclick = onClick;

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

	private static inline function getX(e:MouseEvent):Float{
		return (e.clientX - canvas.offsetLeft) * (canvas.width / canvas.clientWidth);
	}

	private static inline function getY(e:MouseEvent):Float{
		return (e.clientY - canvas.offsetTop) * (canvas.height / canvas.clientHeight);
	}

	public static function onMouseDown(e:MouseEvent){
		g.onMouseDown(getX(e), getY(e));
	}

	public static function onMouseUp(e:MouseEvent){
		g.onMouseUp(getX(e), getY(e));
	}

	public static function onMouseMove(e:MouseEvent){
		g.onMouseMove(getX(e), getY(e), e.movementX * (canvas.width / canvas.clientWidth), e.movementY * (canvas.height / canvas.clientHeight));
	}

	public static function onMouseWheel(e:WheelEvent){
		e.preventDefault();
		g.onMouseWheel(e);
	}

	public static function onClick(e:MouseEvent){
		g.onClick(getX(e), getY(e));
	}
}