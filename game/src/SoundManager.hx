package;

import js.Browser;
import resources.SoundDef;
import js.html.AudioElement;

@:initPackage
@:keep
class SoundManager {

	private var s:Map<String, AudioElement>;
	private var v:Float;

	@:keep
	public function new(soundDefList:Array<SoundDef>) {
		s = new Map<String, AudioElement>();
		v = 1;

		for (sd in soundDefList) {
			var url:String = untyped jsfxr(sd.d);

			var e:AudioElement = Browser.document.createAudioElement();
			e.src = url;
			s.set(sd.n, e);
		}
	}

	@:keep
	public function play(n:String, g:Float = 1):Void {
		s[n].currentTime = 0;
		s[n].volume = v * g;
		s[n].play();
	}

	@:keep
	private static function __init__(){
		haxe.macro.Compiler.includeFile("res/jsfxr.js");
	}
}