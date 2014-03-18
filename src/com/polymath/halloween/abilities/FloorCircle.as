package com.polymath.halloween.abilities 
{
	import flash.display.Shape;
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	
	import com.polymath.halloween.FloorElement;
	
	public class FloorCircle extends FlxSprite 
	{
		private var _radius:Number;
		
		public function FloorCircle(X:Number, Y:Number, diameterInTiles:uint) 
		{
			super(X, Y, null);
			_radius = (diameterInTiles * FloorElement.TILE_WIDTH) >> 1;
		}
		
		override public function render():void
		{
			var shape:Shape = new Shape();
			shape.graphics.lineStyle(1, 0xFF000000);
			shape.graphics.drawCircle(getScreenXY().x, getScreenXY().y, _radius + 1 );
			shape.graphics.lineStyle(1, 0xFFFFFFFF);
			shape.graphics.drawCircle(getScreenXY().x, getScreenXY().y, _radius );
			shape.graphics.lineStyle(1, 0xFF000000);
			shape.graphics.drawCircle(getScreenXY().x, getScreenXY().y, _radius - 1);
			FlxG.buffer.draw(shape);
		}
	}

}