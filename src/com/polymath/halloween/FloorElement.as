package com.polymath.halloween 
{
	import org.flixel.FlxSprite;
	
	public class FloorElement extends FlxSprite 
	{
		[Embed(source = "../../../../data/gfx/floor_tiles.png")] private var Img:Class;
		public static const TILE_WIDTH:uint = 8;
		public static const TILE_HEIGHT:uint = 8;
		
		public function FloorElement(x:uint, y:uint, tile:String) 
		{
			super(x, y);
			loadGraphic(Img, true, false, TILE_WIDTH, TILE_HEIGHT, true);
			var index:uint = 0;
			for (var i:uint = 0; i < (pixels.height / TILE_HEIGHT); i++) {
				for (var k:uint = 0; k < (pixels.width / TILE_WIDTH); k++) {
					addAnimation(index.toString(), [index]);
					index++;
				}
			}
			play(tile);
		}		
	}

}