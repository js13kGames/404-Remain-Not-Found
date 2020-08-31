package;

import js.Browser;
import js.html.CanvasRenderingContext2D;

class MenuRoom extends Room{

	public function new(g:Game){
		super(g);

	}

	override function update(c:CanvasRenderingContext2D, s:Float) {
		super.update(c, s);

		c.fillStyle = "#FFF";
		c.fillRect(0, 0, c.canvas.width, c.canvas.height);

		c.strokeStyle = "#000";
		c.strokeText("Click to play", c.canvas.width / 2, c.canvas.height / 2);
	}

	override function click(x:Float, y:Float) {
		super.click(x, y);
		Browser.document.body.requestFullscreen();

		g.loadLevel(Main.r.lvl[0]);
	}
}