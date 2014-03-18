package com.polymath.halloween.minions 
{
	import org.flixel.FlxG;
	import com.polymath.halloween.FloorElement;
	
	public class DeathsClutchHand extends Minion 
	{
		[Embed(source = "../../../../../data/gfx/deaths_clutch_hand.png")] private var Img:Class;
		private var _delay:Number;
		private var _timer:Number;
		private var _fired:Boolean;
		
		public function DeathsClutchHand(X:Number, Y:Number) 
		{
			super(X, Y - FloorElement.TILE_HEIGHT);
			loadGraphic(Img, true, false, 8, 16);
			
			_delay = Math.random() * 0.5;
			_timer = 0;
			_fired = false;
			
			addAnimation("play", [0, 1, 2, 3, 4, 3, 4, 3, 2, 1, 0], 7, false);
			visible = false;
		}
		
		override public function update():void
		{
			_timer += FlxG.elapsed;
			if (_timer > _delay && !_fired) {
				visible = true;
				_fired = true;
				play("play");
			}
			
			if (_fired && finished) {
				visible = false;
			}
			
			super.update();
		}
		
		public function done():Boolean
		{
			return (_fired && finished && !visible)
		}
	}

}