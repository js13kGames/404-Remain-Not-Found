package;

import js.html.CanvasRenderingContext2D;
import js.html.CanvasElement;
import js.Browser;

class Main{
	public static var c:CanvasRenderingContext2D;
	public static var g:Game;

	public static function main(){
		var canvas:CanvasElement = cast Browser.window.document.getElementById("c");
		c = canvas.getContext2d();

		g = new Game(c);

		Browser.window.requestAnimationFrame(update);
	}

	public static function update(s:Float){
		g.update(s);
		Browser.window.requestAnimationFrame(update);
	}
}