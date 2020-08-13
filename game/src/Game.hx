package;

import js.html.CanvasRenderingContext2D;

class Game{
	private var c:CanvasRenderingContext2D;

	public function new(c:CanvasRenderingContext2D){
		this.c = c;
	}

	public function update(s:Float){
		c.fillStyle = "#000";
		c.fillRect(0, 0, c.canvas.width, c.canvas.height);
		c.fillStyle = "#fff";
		c.fillText("Hello World!", 20, 20);
	}
}