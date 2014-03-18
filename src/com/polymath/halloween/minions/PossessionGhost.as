package com.polymath.halloween.minions 
{
	import org.flixel.FlxSprite;

	public class PossessionGhost extends Minion 
	{
		[Embed (source = "../../../../../data/gfx/possession_ghost.png")] private var ImgPossessionGhost:Class;
		
		public function PossessionGhost(X:Number, Y:Number) 
		{
			super(X, Y);
			loadGraphic(ImgPossessionGhost, true, false, 16, 16);
			
			addAnimation("teleport", [0, 1, 0, 2, 2, 2], 12, false);
			addAnimation("scare", [3, 4, 5, 6, 3, 4, 5, 6, 3], 8, false);
		}
		
	}

}