package com.polymath.halloween.minions 
{
	/**
	 * ...
	 * @author Kelly Weaver
	 */
	public class ClosedDoor extends Minion 
	{
		[Embed(source = "../../../../../data/gfx/closed_door.png")] private var ImgClosedDoor:Class;
		[Embed(source = "../../../../../data/gfx/closed_door_vertical.png")] private var ImgClosedDoorVertical:Class;
		public function ClosedDoor(X:Number, Y:Number, Vertical:Boolean) 
		{
			super(X, Y);
			if (Vertical)
				loadGraphic(ImgClosedDoorVertical);
			else 
				loadGraphic(ImgClosedDoor);
		}
		
	}

}