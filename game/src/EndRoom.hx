package;

import menu.Button;
import js.html.CanvasRenderingContext2D;

class EndRoom extends Room{
	private static var TXT:String = "Thanks for playing!";

	private var rtn:Button;

	public function new(g:Game, c:CanvasRenderingContext2D){
		super(g);

		rtn = new Button(c.canvas.width / 2, c.canvas.height / 2, "Return to menu", function(){
			g.menu();
		});
	}

	override function update(c:CanvasRenderingContext2D, s:Float) {
		super.update(c, s);

		c.fillStyle = "#FFF";
		c.fillRect(0, 0, c.canvas.width, c.canvas.height);

		c.font = "200px arial";
		c.fillStyle = "#000";
		var tx = c.canvas.width / 2 - c.measureText(TXT).width / 2;
		c.fillText(TXT, tx, c.canvas.height * 0.25);

		rtn.render(c);
	}

	override function mouseMove(x:Float, y:Float) {
		super.mouseMove(x, y);

		rtn.mouseMove(x, y);
	}

	override function click(x:Float, y:Float) {
		super.click(x, y);

		rtn.click(x, y);
	}
}