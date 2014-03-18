package com.polymath.halloween
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	
	public class NearClouds extends FlxSprite
	{
		[Embed(source = "../../../../data/gfx/near_clouds.png")] private var Img:Class;
		private var _localX:Number;
		private var _speed:Number;
		
		public function set Speed(s:Number):void
		{
			_speed = s;
		}
		
		public function NearClouds(Y:Number, Speed:Number) 
		{
			super(0, Y, Img);
			scrollFactor.y = 1;
			scrollFactor.x = 0;
			_speed = Speed;
			_localX = 0;
		}
		
		override public function update():void
		{
			_localX += _speed;
			if (_localX > frameWidth)
				_localX -= frameWidth;
		}
		
		override public function render():void
		{
			var rect:Rectangle;
		
			var _x:Number = Math.floor(_localX - FlxG.scroll.x);
			if (_x > 0)
				_x = _x % frameWidth;
			else
				_x = frameWidth - Math.abs(_x % frameWidth);
			
			rect = new Rectangle(_x, 0, frameWidth - _x, frameHeight);
			FlxG.buffer.copyPixels(_pixels, rect, new Point(getScreenXY().x, getScreenXY().y), null, null, true);
			rect = new Rectangle(0, 0, _x, frameHeight);
			FlxG.buffer.copyPixels(_pixels, rect, new Point(getScreenXY().x + frameWidth - _x, getScreenXY().y), null, null, true);
		}
	}

}