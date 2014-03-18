package {
	import org.flixel.*;
	import com.polymath.halloween.MenuState;
	import com.polymath.halloween.PlayState;
	import com.polymath.halloween.Stats;
	import com.polymath.halloween.Assets;
	import Playtomic.*;
	
	[SWF(width = "640", height = "480", backgroundColor = "#000000")]
	[Frame(factoryClass="Preloader")]
	
	public class Main extends FlxGame
	{
		public function Main():void
		{
			super(320, 240, MenuState, 2);
			FlxState.bgColor = 0xFF000000;
			Stats.load();
		}
	}
}