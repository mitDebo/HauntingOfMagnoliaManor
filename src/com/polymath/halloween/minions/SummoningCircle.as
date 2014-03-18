package com.polymath.halloween.minions 
{
	import flash.display.Shape;
	import flash.geom.Matrix;
	
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	
	import com.polymath.halloween.FloorElement;
	
	public class SummoningCircle extends FlxSprite 
	{
		private var rotation:Number;
		private var c:uint;
		private var _increase:Boolean;
		private var _radius:Number;
		
		public function SummoningCircle(X:Number, Y:Number, Diameter:uint) 
		{
			super(X, Y);
			rotation = 0;
			c = 0xFF000000;
			_increase = true;
			_radius = (Diameter * FloorElement.TILE_WIDTH) / 2;
		}
		
		override public function update():void
		{
			rotation += FlxG.elapsed;
			
			var previousC:uint = c;
			var changeInColor:uint = 0xFF * FlxG.elapsed / 2;
			if (_increase) {
				c += (changeInColor << 32) + (changeInColor << 16) + (changeInColor << 8) ;
				if (c > 0x555555) {
					c = 0xFF555555;
					_increase = false;
				}
			} else {
				c -= (changeInColor << 32) + (changeInColor << 16) + (changeInColor << 8) ;
				if (c < 0xFF000000) {
					c = 0xFF000000;
					_increase = true;
				}
			}
			super.update();
		}
		
		override public function render():void
		{
			var shape:Shape = new Shape();
			var pyth:Number = Math.sqrt( _radius * _radius / 2);
			
			shape.graphics.lineStyle(1, c);
			shape.graphics.drawCircle(0, 0, _radius);
			shape.graphics.drawRect( -pyth, -pyth, pyth * 2, pyth * 2);
			shape.graphics.moveTo(0, -_radius);
			shape.graphics.lineTo(_radius, 0);
			shape.graphics.lineTo(0, _radius);
			shape.graphics.lineTo( -_radius, 0);
			shape.graphics.lineTo(0, -_radius);
			var matrix:Matrix = new Matrix();
			matrix.rotate(rotation);
			matrix.translate(getScreenXY().x, getScreenXY().y);
			FlxG.buffer.draw(shape, matrix);
		}
		
	}

}