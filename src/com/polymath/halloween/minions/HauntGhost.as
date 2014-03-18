package com.polymath.halloween.minions 
{
	import org.flixel.FlxG;
	import org.flixel.FlxObject;
	
	import com.polymath.halloween.Character;
	
	public class HauntGhost extends Minion 
	{
		[Embed(source = "../../../../../data/gfx/haunt_ghost.png")] private var ImgHauntGhost:Class;
		
		private const IDLE:uint = 0;
		private const FADE_OUT:uint = 1;
		private const FADE_IN:uint = 2;
		private const SCARE:uint = 3;
		
		private var _originalX:Number;
		private var _originalY:Number;
		private var _timer:Number;
		private var _occupiedRoom:FlxObject;
		private var _guestToHaunt:Character;
		private var _cooldownMax:Number;
		private var _mode:uint;
		
		public function set Cooldown(c:Number):void
		{
			_cooldownMax = c;
		}
		
		public function HauntGhost(X:Number, Y:Number, room:FlxObject) 
		{
			super(X, Y);
			_originalX = X;
			_originalY = Y;
			loadGraphic(ImgHauntGhost, true, false, 16, 16);
			
			addAnimation("idle", [0, 1], 2, true);
			addAnimation("north", [6]);
			addAnimation("south", [0]);
			addAnimation("east", [4]);
			addAnimation("west", [5]);
			addAnimation("scare_south", [0, 2, 0, 2, 0, 2, 0, 2, 0, 2], 7, false);
			addAnimation("scare_north", [6, 8, 6, 8, 6, 8, 6, 8, 6, 8], 7, false);
			addAnimation("scare_east", [4, 3, 4, 3, 4, 3, 4, 3, 4, 3], 7, false);
			addAnimation("scare_west", [5, 7, 5, 7, 5, 7, 5, 7, 5, 7], 7, false);
			
			_occupiedRoom = room;
			_timer = 0;
			alpha = 0.7;
			_mode = IDLE;
		}
		
		private function beginCooldown():void {
			_timer = _cooldownMax
		}
		
		public function ready():Boolean {
			return _timer <= 0;
		}
		
		override public function update():void
		{
			if (_timer > 0) {
				_timer -= FlxG.elapsed;
			} 
			
			if (_guestToHaunt != null) {
				if (_mode == FADE_OUT) {
					alpha -= FlxG.elapsed;
					if (alpha <= 0) {
						_mode = FADE_IN;
						_guestToHaunt.stop();
						setInFrontOfGuest();
					}
				}
				if (_mode == FADE_IN) {
					alpha += FlxG.elapsed;
					if (alpha >= 1) {
						_guestToHaunt.scare();
						_mode = SCARE;
					}
				}
				if (_mode == SCARE) {
					if (_guestToHaunt.Direction == Character.NORTH)
						play("scare_south", true);
					if (_guestToHaunt.Direction == Character.SOUTH)
						play("scare_north", true);
					if (_guestToHaunt.Direction == Character.EAST)
						play("scare_west", true);
					if (_guestToHaunt.Direction == Character.WEST)
						play("scare_east", true);
						
					_guestToHaunt = null;
				}
			} else {
				if (_mode == SCARE && finished)
						_mode = FADE_OUT;
				if (_mode == FADE_OUT) {
					alpha -= FlxG.elapsed;
					if (alpha <= 0) {
						_mode = FADE_IN
						returnToOrigin();
					}
				}
				if (_mode == FADE_IN) {
					play("idle");
					alpha += FlxG.elapsed;
					if (alpha >= 0.7) {
						alpha = 0.7;
						_mode = IDLE;
					}
				}
			}
			
			if (_mode == IDLE)
				play("idle");
			
			super.update();
		}
		
		public function haunt():void
		{
			_guestToHaunt = state.CurrentLevel.getRandomGuestInRoom(_occupiedRoom);
			if (_guestToHaunt != null) {
				_guestToHaunt.IsTagged = true;
				beginCooldown();
				_mode = FADE_OUT;
			}
		}
		
		private function setInFrontOfGuest():void
		{
			if (_guestToHaunt.Direction == Character.SOUTH) {
				x = _guestToHaunt.left;
				y = _guestToHaunt.bottom - 8;
				play("north");
			}
			if (_guestToHaunt.Direction == Character.NORTH) {
				x = _guestToHaunt.left;
				y = _guestToHaunt.top - 8;
				play("south");
			}
			if (_guestToHaunt.Direction == Character.EAST) {
				x = _guestToHaunt.right;
				y = _guestToHaunt.top;
				play("west");
			}
			if (_guestToHaunt.Direction == Character.WEST) {
				x = _guestToHaunt.left - width;
				y = _guestToHaunt.top;
				play("east");
			}
		}
		
		private function returnToOrigin():void
		{
			x = _originalX;
			y = _originalY;
		}
	}

}