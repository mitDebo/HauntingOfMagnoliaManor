package com.polymath.halloween 
{
	import org.flixel.FlxG;
	import org.flixel.FlxSprite
	
	public class Entrance extends FlxSprite
	{
		private var _level:Level;
		private var _numberOfGuests:uint;
		private var _minWalkingSpeed:Number;
		private var _maxWalkingSpeed:Number;		
		private var _interval:Number;
		
		private var _numLaunched:uint;
		private var _timer:Number;
		private var _on:Boolean;		
		
		public function Entrance(X:uint, Y:uint, level:Level, NumberOfGuests:uint, MinWalkingSpeed:Number, MaxWalkingSpeed:Number, Interval:Number) 
		{
			super(X, Y);
			_numberOfGuests = NumberOfGuests;
			_level = level;
			_minWalkingSpeed = MinWalkingSpeed;
			_maxWalkingSpeed = MaxWalkingSpeed;
			_interval = Interval;
			
			_on = false;
			_timer = 0;
			_numLaunched = 0;
			
			visible = false;
		}
		
		public function start():void
		{
			_on = true;
		}
		
		override public function update():void
		{
			if (_on) {
				_timer += FlxG.elapsed;
				if (_timer > _interval) {
					var guest:Character = new Character(this.x / FloorElement.TILE_WIDTH, this.y / FloorElement.TILE_HEIGHT, _level);
					guest.WalkingSpeed = _minWalkingSpeed + Math.floor(Math.random() * (_maxWalkingSpeed - _minWalkingSpeed));
					_level.addGuest(guest);
					guest.alpha = 0;
					
					_numLaunched++;
					
					if (_numLaunched >= _numberOfGuests)
						_on = false;
					
					_timer -= _interval;
				}
			}
			
			super.update();
		}
		
		public function restart():void
		{
			_on = false;
			_timer = 0;
			_numLaunched = 0;
		}
	}

}