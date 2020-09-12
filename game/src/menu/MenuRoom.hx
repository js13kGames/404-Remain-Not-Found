package menu;

import js.Browser;
import js.html.CanvasRenderingContext2D;

class MenuRoom extends Room{
	private static inline var TITLE:String = "404";

	private var playBtn:Button;
	private var fsBtn:Button;

	public function new(g:Game, c:CanvasRenderingContext2D){
		super(g);

		playBtn = new Button(c.canvas.width / 2, c.canvas.height * 0.5, "Play", function(){
			g.loadLevel(Main.r.lvl[0]);
		});

		fsBtn = new Button(c.canvas.width / 2, c.canvas.height * 0.75, "Fullscreen", function(){
			Browser.document.body.requestFullscreen();
		});
	}

	override function update(c:CanvasRenderingContext2D, s:Float) {
		super.update(c, s);

		c.fillStyle = "#FFF";
		c.fillRect(0, 0, c.canvas.width, c.canvas.height);

		c.font = "200px arial";
		c.fillStyle = "#000";
		var tx = c.canvas.width / 2 - c.measureText(TITLE).width / 2;
		c.strokeText(TITLE, tx, c.canvas.height  * 0.25);

		playBtn.render(c);
		fsBtn.render(c);
	}

	override function click(x:Float, y:Float) {
		super.click(x, y);
		
		playBtn.click(x, y);
		fsBtn.click(x, y);
	}

	override function mouseMove(x:Float, y:Float) {
		super.mouseMove(x, y);

		playBtn.mouseMove(x, y);
		fsBtn.mouseMove(x, y);
	}
}