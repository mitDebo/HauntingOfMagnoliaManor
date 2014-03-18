package com.polymath.halloween.abilities 
{
	import com.polymath.halloween.minions.DemonSprite;
	import com.polymath.halloween.minions.SummoningCircle;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import org.flixel.FlxU;
	
	import com.polymath.halloween.Character;
	import com.polymath.halloween.PlayState;
	
	public class Demon extends Ability 
	{
		[Embed(source = "../../../../../data/gfx/demon_button.png")] private var ImgButton:Class;
		private var _buttonSprite:FlxSprite;
		private var _diameter:uint;
		private var _timerMax:Number;
		private var _timer:Number = 0;
		private var _scareGroup:FlxGroup;
		private var _floorCircle:SummoningCircle;
		private var _demon:DemonSprite;
		private var _teleportAnimationFinished:Boolean;
		
		public function Demon(X:uint, Y:uint, Callback:Function ) 
		{
			super(X, Y, Callback);
			width = 32;
			height = 16;
			
			Cooldown = AbilityInfo.getCooldown(this);
			_diameter = AbilityInfo.getDiameter(this);
			_timerMax = AbilityInfo.getDuration(this);
			
			_floorCircle = new SummoningCircle(0, 0, _diameter);
			
			_buttonSprite = new FlxSprite(0, 0);
			_buttonSprite.loadGraphic(ImgButton, true, false, 32, 16);
			_buttonSprite.addAnimation("up", [0]);
			_buttonSprite.addAnimation("down", [1]);
			loadGraphic(_buttonSprite);
			
			_demon = new DemonSprite(0, 0);
			_demon.visible = false;
			_teleportAnimationFinished = false;
			
			makeTooltip("Demon", "Places a summoning circle on the ground, calling forth a demon after a brief period. The demon then horrifies anyone nearby.");
		}
		
		override public function click():void
		{
			if (!inCooldown && Enabled) {
				state.SelectionMode = PlayState.SELECTION_CIRCLE;
			}
		}
		
		override public function makeSelectionWithGroup(sel:FlxGroup):void
		{
			if (sel != null && isValidPlacement(sel)) {
				_scareGroup = sel;
				_timer = 0;
				beginCooldown();
				var point:FlxPoint = getCenterOfSelection(sel);
				_floorCircle.x = point.x;
				_floorCircle.y = point.y;
				state.CurrentLevel.addAboveFloorElement(_floorCircle);
			}
		}
		
		override public function get SelectionDiameter():uint
		{
			return _diameter;
		}
		
		override public function update():void
		{
			if (state.CurrentLevel.HasStarted) {
				if (Enabled == false)
					beginCooldown();
				Enabled = true;
			} else {
				Enabled = false;
			}
			
			if (_scareGroup != null && _timer < _timerMax) {
				_timer += FlxG.elapsed;
				if (_timer > _timerMax) {
					beginScare();
				}
			}
			
			if (_demon.visible && !_teleportAnimationFinished && _demon.finished) {
				scareGroup();
				_teleportAnimationFinished = true;
			}
			
			if (_demon.visible && _teleportAnimationFinished && _demon.finished) {
				state.CurrentLevel.removeAboveFloorElement(_floorCircle);
				_demon.alpha -= FlxG.elapsed;
				if (_demon.alpha <= 0) {
					_demon.visible = false;
					_demon.alpha = 1;
					_teleportAnimationFinished = false;
					state.CurrentLevel.removeMinion(_demon);
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
			_demon.x = _floorCircle.x - (_demon.width >> 1);
			_demon.y = _floorCircle.y - (_demon.height);
			_demon.visible = true;
			_demon.play("teleport", true);
			state.CurrentLevel.addMinion(_demon);
		}
		
		private function scareGroup():void
		{
			_demon.play("scare", true);
			var guests:FlxGroup = state.CurrentLevel.getGuests();
			FlxU.overlap(_scareGroup, guests, function(obj1:FlxObject, obj2:FlxObject):void {
				if (obj1.bottom > obj2.top + (obj2.height >> 1))
					(obj2 as Character).scare();
			});
			_scareGroup = null;
		}
	}

}