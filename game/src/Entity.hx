package;

import js.html.CanvasRenderingContext2D;

class Entity{
	public var x(default, default):Float;
	public var y(default, default):Float;

	public var xSpeed(default, default):Float;
	public var ySpeed(default, default):Float;

	public function new(){
		x = 0;
		y = 0;
		xSpeed = 0;
		ySpeed = 0;
	}

	public function update(s:Float){
		x += xSpeed * s;
		y += ySpeed * s;
	}

	public function render(c:CanvasRenderingContext2D){

	}

}