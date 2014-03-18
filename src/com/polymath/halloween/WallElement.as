package com.polymath.halloween 
{
	import org.flixel.FlxSprite;
	
	public class WallElement extends FlxSprite 
	{
		[Embed(source = "../../../../data/gfx/wall_tiles.png")] private var Img:Class;
		public static const TILE_WIDTH:uint = 16;
		public static const TILE_HEIGHT:uint = 16;
		
		public function WallElement(x:uint, y:uint, tile:String) 
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