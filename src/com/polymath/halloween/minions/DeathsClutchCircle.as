package com.polymath.halloween.minions 
{
	import flash.display.Shape;
	import org.flixel.FlxG;
	import com.polymath.halloween.FloorElement;
	
	public class DeathsClutchCircle extends Minion 
	{
		private var _curRadius:Number = FloorElement.TILE_HEIGHT / 2;
		private var _increase:Boolean = false;
		private var _cx:Number;
		private var _cy:Number;
		
		public function DeathsClutchCircle(X:Number, Y:Number) 
		{
			super(X, Y);
			_cx = X + (FloorElement.TILE_WIDTH >> 1);
			_cy = Y + (FloorElement.TILE_HEIGHT >> 1);
		}
	
		override public function update():void
		{
			if (_increase) {
				_curRadius += FlxG.elapsed * 4;
				if (_curRadius > 3.5) {
					_curRadius = 3.5
					_increase = false;
				}
			} else {
				_curRadius -= FlxG.elapsed * 4;
				if (_curRadius < 0.5) {
					_curRadius = 0.5;
					_increase = true;
				}
			}
			super.update();
		}
		
		override public function render():void
		{
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xFF000000);
			shape.graphics.drawCircle(_cx, _cy, _curRadius);
			shape.graphics.endFill();
			FlxG.buffer.draw(shape);
		}
	}

}