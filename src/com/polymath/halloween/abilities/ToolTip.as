package com.polymath.halloween.abilities 
{
	import flash.display.Shape;
	import org.flixel.FlxText;
	import org.flixel.FlxG;
	
	public class ToolTip extends FlxText 
	{
		public function ToolTip(X:Number, Y:Number, Width:uint, Text:String) 
		{
			super(X, Y, Width, Text);
			setFormat("8bit", 8, 0xFFFFFF, "left", 0xFF000000);
		}
		
		override public function render():void
		{
			var shape:Shape = new Shape();
			shape.graphics.beginFill(0xFF555555);
			shape.graphics.lineStyle(1, 0xFFA8A8A8);
			shape.graphics.drawRect(this.x, this.y, this.width, this.height);
			shape.graphics.endFill();
			FlxG.buffer.draw(shape);
			
			super.render();
		}
	}

}