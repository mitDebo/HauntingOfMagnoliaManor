package com.polymath.halloween.minions 
{
	import com.polymath.halloween.PlayState;
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	
	public class Minion extends FlxSprite 
	{
		
		public function get state():PlayState
		{
			return (FlxG.state as PlayState);
		}
		
		public function Minion(X:Number, Y:Number) 
		{
			super(X, Y);
		}
		
	}

}