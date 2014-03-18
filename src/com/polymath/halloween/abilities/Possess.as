package com.polymath.halloween.abilities 
{
	import com.polymath.halloween.minions.PossessionCircle;
	import com.polymath.halloween.minions.PossessionGhost;
	import flash.display.Shape;
	import org.flixel.FlxGroup;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxObject;
	import org.flixel.FlxG;
	
	import com.polymath.halloween.Character;	
	import com.polymath.halloween.PlayState;
	
	public class Possess extends Ability 
	{
		[Embed(source = "../../../../../data/gfx/possess_button.png")] private var ImgButton:Class;
		private var _buttonSprite:FlxSprite;
		private var _possessedGuest:Character;
		private var _possessedTimer:Number;
		private var _possessedTimeLimit:Number;
		private var _explodeDiameter:uint;
		private var _possessionCircle:PossessionCircle;
		private var _possessionGhost:PossessionGhost;
		
		private var _teleportAnimationFinished:Boolean;
		
		public function Possess(X:uint, Y:uint, Callback:Function)
		{
			super(X, Y, Callback);
			width = 32;
			height = 16;
			
			Cooldown = AbilityInfo.getCooldown(this);
			_possessedTimeLimit = AbilityInfo.getDuration(this);
			_explodeDiameter = AbilityInfo.getDiameter(this);
			
			_possessionCircle = new PossessionCircle(0, 0, _explodeDiameter);
			
			_buttonSprite = new FlxSprite(0, 0);
			_buttonSprite.loadGraphic(ImgButton, true, false, 32, 16);
			_buttonSprite.addAnimation("up", [0]);
			_buttonSprite.addAnimation("down", [1]);
			loadGraphic(_buttonSprite);
			
			_possessionGhost = new PossessionGhost(0, 0);
			_possessionGhost.alpha = 0.8;
			_possessionGhost.visible = false;
			_teleportAnimationFinished = false;
			
			makeTooltip("Possess", "Possess a visitor, who will scare others around him after a few seconds.");
		}
		
		override public function click():void
		{
			if (Enabled && !inCooldown) {
				state.SelectionMode = PlayState.SELECTION_CHARACTER;
			}
		}
		
		override public function makeSelectionWithObject(obj:FlxObject):void {
			_possessedGuest = obj as Character;
			_possessedGuest.IsTagged = true;
			state.CurrentLevel.addAboveFloorElement(_possessionCircle);
			_possessedTimer = 0;
			beginCooldown();
		}
		
		override public function update():void
		{
			if (state.CurrentLevel.HasStarted) {
				if (Enabled == false) {
					beginCooldown();
				}
				Enabled = true;
			} else {
				Enabled = false;
			}
			
			if (!_teleportAnimationFinished && _possessionGhost.visible && _possessionGhost.finished) {
				_possessionGhost.play("scare", true);
				_teleportAnimationFinished = true;
				scareGuests();
			}
			
			if (_teleportAnimationFinished && _possessionGhost.visible && _possessionGhost.finished) {
				_possessionGhost.alpha -= FlxG.elapsed * 2;
				if (_possessionGhost.alpha <= 0) {
					_possessionGhost.visible = false;
					_possessionGhost.alpha = 0.8;
					state.CurrentLevel.removeMinion(_possessionGhost);
				}
			}
			
			if (_possessedGuest != null && _possessedTimer < _possessedTimeLimit) {
				_possessionCircle.x = _possessedGuest.x + (_possessedGuest.width >> 1);
				_possessionCircle.y = _possessedGuest.y + (_possessedGuest.height * 0.75);
				_possessedTimer += FlxG.elapsed;
				if (_possessedTimer > _possessedTimeLimit) {
					state.CurrentLevel.removeAboveFloorElement(_possessionCircle);
					if (!state.CurrentLevel.TimesUp)
						beginScare();
				}
			}
			
			if (Enabled) {
				if (_pressed && !inCooldown)
					_buttonSprite.play("down");
				else
					_buttonSprite.play("up");
				
			} else {
				_buttonSprite.play("down");
			}	
			
			super.update();
		}
		
		private function beginScare():void
		{
			var center:FlxPoint = new FlxPoint(_possessedGuest.x + (_possessedGuest.width >> 1), _possessedGuest.y + (_possessedGuest.height * 0.75));
			var surroundingGuests:FlxGroup = state.CurrentLevel.getAllGuestsInCircle(center.x, center.y, _explodeDiameter);
			for each (var guest:Character in surroundingGuests.members)
				guest.stop();
			
			_possessedGuest.scare();
			_possessionGhost.x = _possessedGuest.x;
			_possessionGhost.y = _possessedGuest.y;
			_possessedGuest.kill();
			
			_possessionGhost.visible = true;
			state.CurrentLevel.addMinion(_possessionGhost);
			_possessionGhost.play("teleport");
			_teleportAnimationFinished = false;
		}
		
		override public function restart():void
		{
			super.restart();
			state.CurrentLevel.removeAboveFloorElement(_possessionCircle);
			_possessedGuest = null;
			_possessedTimer = 0;
			
			state.CurrentLevel.removeMinion(_possessionGhost);
			_possessionGhost.alpha = 0.8;
			_possessionGhost.visible = false;
			_teleportAnimationFinished = false;
		}
		
		private function scareGuests():void
		{
			var center:FlxPoint = new FlxPoint(_possessedGuest.x + (_possessedGuest.width >> 1), _possessedGuest.y + (_possessedGuest.height * 0.75));
			var surroundingGuests:FlxGroup = state.CurrentLevel.getAllGuestsInCircle(center.x, center.y, _explodeDiameter);
			for each (var guest:Character in surroundingGuests.members)
				guest.scare();
		}
	}

}