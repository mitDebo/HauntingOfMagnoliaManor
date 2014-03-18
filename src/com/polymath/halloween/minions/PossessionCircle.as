package com.polymath.halloween.minions 
{
	import flash.display.Shape;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	
	import com.polymath.halloween.FloorElement;
	
	public class PossessionCircle extends FlxSprite 
	{
		private var _maxDiameter:Number;
		private var _radius:Number;
		
		public function PossessionCircle(CenterX:Number, CenterY:Number, MaxDiameter:Number) 
		{
			super(CenterX, CenterY);
			_maxDiameter = MaxDiameter * FloorElement.TILE_WIDTH;
			_radius = 0;
		}
		
		override public function update():void
		{
			_radius += FlxG.elapsed * 25;
			if (_radius * 2 > _maxDiameter)
				_radius = _radius - (_maxDiameter / 2);
				
			super.update();
		}
		
		override public function render():void
		{
			var shape:Shape = new Shape();;
			shape.graphics.lineStyle(0.5, 0xFF000000);
			shape.graphics.drawCircle(getScreenXY().x, getScreenXY().y, _radius);
			FlxG.buffer.draw(shape);
		}
		
	}

}