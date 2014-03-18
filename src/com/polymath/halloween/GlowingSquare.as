package com.polymath.halloween 
{
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	
	public class GlowingSquare extends FlxSprite 
	{	
		public function GlowingSquare(X:Number, Y:Number) 
		{
			super(X, Y);
			createGraphic(FloorElement.TILE_WIDTH, FloorElement.TILE_HEIGHT);
			visible = false;
		}
		
		public function on():void
		{
			visible = true;
		}
		
		public function off():void
		{
			visible = false;
		}
		
		override public function update():void
		{
			if (visible)
				alpha = PlayState.GlowingSquareAlpha;
			
			super.update();
		}
	}

}