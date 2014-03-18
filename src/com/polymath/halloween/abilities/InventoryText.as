package com.polymath.halloween.abilities 
{
	import flash.display.Shape;
	import org.flixel.FlxText;
	import org.flixel.FlxG;
	
	public class InventoryText extends FlxText 
	{
		public function InventoryText(X:Number, Y:Number, Width:uint, Text:String)
		{
			super(X, Y, Width, Text, true);
		}
		
		override public function render():void
		{
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xFF555555);
			shape.graphics.lineStyle(1, 0xFF000000);
			shape.graphics.drawCircle(getScreenXY().x + (this.width >> 1) - 3, getScreenXY().y + (this.height >> 1), 6);
			shape.graphics.endFill();
			FlxG.buffer.draw(shape);
			
			super.render();
		}
	}

}