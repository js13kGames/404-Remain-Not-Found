package menu;

import js.html.TextMetrics;
import js.html.CanvasRenderingContext2D;

class Button extends Entity{
	private static inline var PADDING = 20;
	private static inline var FONT_SIZE = 30;
	private static inline var FONT = Std.string(FONT_SIZE) + "px arial";

	private var text:String;
	private var over:Bool;

	private var callback:Void->Void;

	public function new(x:Float, y:Float, text:String, callback:Void->Void){
		super();

		this.x = x;
		this.y = y;
		this.text = text;
		this.callback = callback;

		over = false;

		aabb.h = FONT_SIZE + PADDING * 2;
	}

	override function render(c:CanvasRenderingContext2D) {
		super.render(c);

		c.font = FONT;

		var tw:Float= c.measureText(text).width;
		aabb.w = tw + PADDING * 2;
		aabb.x = x - tw / 2;
		aabb.y = y - FONT_SIZE / 2;

		c.fillStyle = over ? "#888" : "#aaa";
		c.fillRect(aabb.x, aabb.y, aabb.w, aabb.h);

		c.fillStyle = "#000";
		c.fillText(text, aabb.x + PADDING, aabb.y + FONT_SIZE + PADDING);
	}

	public function mouseMove(x:Float, y:Float){
		over = aabb.contains(x, y);
	}

	public function click(x:Float, y:Float){
		if(aabb.contains(x, y)){
			callback();
		}
	}
}