package com.polymath.halloween.minions 
{
	public class DemonSprite extends Minion 
	{
		[Embed(source = "../../../../../data/gfx/demon.png")] private var ImgDemon:Class;
		
		public function DemonSprite(X:Number, Y:Number) 
		{
			super(X, Y);
			loadGraphic(ImgDemon, true, false, 16, 16);
			addAnimation("teleport", [0, 1, 2, 3, 3, 3], 12, false);
			addAnimation("scare", [3, 4, 3, 4, 3, 4, 3, 4, 3, 4, ], 8, false);
		}
		
	}

}