package menu;

import js.html.CanvasRenderingContext2D;

class MenuPage extends Entity{
	private var title:String;

	private var btn:Array<Button> = [];

	public function new(title:String){
		super();

		this.title = title;
	}

	public function add(txt:String, x:Float, y:Float, cbk:Void->Void){
		btn.push(new Button(x, y, txt, cbk));
	}

	override function render(c:CanvasRenderingContext2D) {
		super.render(c);

		c.strokeStyle = "#000";
		c.fillStyle = "#FFF";

		c.font = "60px arial";
		var tw:Float = c.measureText(title).width;
		c.fillText(title, x - tw / 2, y);
		c.strokeText(title, x - tw / 2, y);

		for(b in btn){
			b.render(c);
		}
	}

	public function mouseMove(x:Float, y:Float){
		for(b in btn){
			b.mouseMove(x, y);
		}
	}

	public function click(x:Float, y:Float){
		for(b in btn){
			b.click(x, y);
		}
	}
}