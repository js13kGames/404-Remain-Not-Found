package menu;

import js.html.TextMetrics;
import js.html.CanvasRenderingContext2D;

class Button extends Entity{
	private static inline var PADDING = 20;

	public var text(default, default):String;
	private var over:Bool;

	private var callback:Void->Void;
	private var size:Float;

	private var font:String;

	public function new(x:Float, y:Float, text:String, callback:Void->Void, size:Float = 30){
		super();

		this.x = x;
		this.y = y;
		this.text = text;
		this.callback = callback;
		this.size = size;

		over = false;

		aabb.h = size * 1.2 + PADDING * 2;

		font = Std.string(size) + "px arial";
	}

	override function render(c:CanvasRenderingContext2D) {
		super.render(c);

		c.font = font;

		var tw:Float= c.measureText(text).width;
		aabb.w = tw + PADDING * 2;
		aabb.x = x - tw / 2;
		aabb.y = y - size / 2;

		c.fillStyle = over ? "#888" : "#aaa";
		c.fillRect(aabb.x, aabb.y, aabb.w, aabb.h);

		c.fillStyle = "#000";
		c.fillText(text, aabb.x + PADDING, aabb.y + size + PADDING);
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