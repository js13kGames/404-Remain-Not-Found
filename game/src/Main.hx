package;

import js.html.BodyElement;
import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;
import js.Browser;

class Main{
	private static var canvas:CanvasElement;

	public static var c:CanvasRenderingContext2D;
	public static var g:Game;

	public static function main(){
		canvas = cast Browser.window.document.getElementById("c");
		Browser.window.document.body.onresize = onResize;
		
		onResize();

		c = canvas.getContext2d();
		g = new Game(c);

		Browser.window.requestAnimationFrame(update);
	}

	public static function update(s:Float){
		g.update(s);
		Browser.window.requestAnimationFrame(update);
	}

	public static function onResize(){
		canvas.style.left = Std.string(Math.floor((Browser.window.document.body.clientWidth - canvas.clientWidth) / 2)) + "px";
		canvas.style.top = Std.string(Math.floor((Browser.window.document.body.clientHeight - canvas.clientHeight) / 2)) + "px";
	}
}