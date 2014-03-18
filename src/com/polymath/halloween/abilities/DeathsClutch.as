package com.polymath.halloween.abilities 
{
	import com.polymath.halloween.minions.DeathsClutchCircle;
	import com.polymath.halloween.minions.DeathsClutchHand;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import org.flixel.FlxU;
	
	import com.polymath.halloween.Character;
	import com.polymath.halloween.PlayState;
	import com.polymath.halloween.FloorElement;
	
	public class DeathsClutch extends Ability 
	{
		[Embed(source = "../../../../../data/gfx/deathscluth_button.png")] private var ImgButton:Class;
		private var _buttonSprite:FlxSprite;
		
		private var _numberToLay:uint;
		private var _deathsDiameter:uint;
		private var _floorCircles:FlxGroup;
		private var _blastZones:FlxGroup;
		private var _hands:FlxGroup;
		private var _hasFired:Boolean;
		private var _index:uint;
		
		private var _timeBetweenFires:Number;
		private var _timer:Number;
		
		public function DeathsClutch(X:uint, Y:uint, Callback:Function) 
		{
			super(X, Y, Callback);
			width = 32;
			height = 16;
			
			Enabled = true;
			_index = 0;
			
			_numberToLay = AbilityInfo.getInventory(this);
			_deathsDiameter = AbilityInfo.getDiameter(this);
			
			_numberToLay = 2;
			_deathsDiameter = 4;
			_hasFired = false;
			_blastZones = new FlxGroup();
			_floorCircles = new FlxGroup();
			_hands = new FlxGroup();
			
			_timeBetweenFires = 0.50;
			
			_buttonSprite = new FlxSprite(0, 0);
			_buttonSprite.loadGraphic(ImgButton, true, false, 32, 16);
			_buttonSprite.addAnimation("up", [0]);
			_buttonSprite.addAnimation("down", [1]);
			
			makeInventoryText(_numberToLay);
			loadGraphic(_buttonSprite);
			makeTooltip("Death's Clutch", "The many hands of death lie in wait for your signal. Once triggered, they spring from the ground, frightening anyone in its grasp.");
		}
		
		override public function click():void
		{
			if (!state.CurrentLevel.HasStarted && Enabled)
				state.SelectionMode = PlayState.SELECTION_CIRCLE;
			else {
				fire();
			}
		}
		
		override public function makeSelectionWithGroup(sel:FlxGroup):void
		{
			if (sel != null && isValidPlacement(sel)) {
				var blastzone:FlxGroup = new FlxGroup();
				
				for each (var obj:FlxObject in sel.members) {
					if (state.CurrentLevel.isValidSquare(obj.x, obj.y)) {
						var dc:DeathsClutchCircle = new DeathsClutchCircle(obj.x, obj.y);
						blastzone.add(dc);
						_blastZones.add(blastzone);
						_floorCircles.add(blastzone);
						state.CurrentLevel.addAboveFloorElement(blastzone);
					}
				}
				
				_numberToLay--;
				updateInventoryText(_numberToLay);
			}
		}
		
		override public function get SelectionDiameter():uint
		{
			return _deathsDiameter;
		}
		
		override public function isFinishedSelecting():Boolean
		{
			if (_numberToLay > 0)
				return false;
			return true;
		}
		
		override public function isReady():Boolean
		{
			if (_numberToLay > 0)
				return false;
			return true;
		}
		
		private function fire():void
		{
			_hasFired = true;
			_timer = _timeBetweenFires;
		}
		
		override public function update():void
		{
			for each (var _dch:DeathsClutchHand in _hands.members) {
				if (_dch.done()) {
					state.CurrentLevel.removeMinion(_dch);
				}
			}
			
			if (state.CurrentLevel.HasStarted && _hasFired && _blastZones.members.length > 0) {
				_timer -= FlxG.elapsed;
				if (_timer < 0 && _index < _blastZones.members.length) {
					var sel:FlxGroup = _blastZones.members[_index] as FlxGroup;
					_index++;
					scareGroup(sel);
					if (_floorCircles.members.length > 0) {
						var fc:FlxGroup = _floorCircles.members.shift() as FlxGroup;
						state.CurrentLevel.removeAboveFloorElement(fc);
						for each (var dcc:DeathsClutchCircle in fc.members) {
							var dch:DeathsClutchHand = new DeathsClutchHand(dcc.x, dcc.y);
							_hands.add(dch);
							state.CurrentLevel.addMinion(dch);
						}
					}
					_timer = _timeBetweenFires;
				}
			}
			
			if (!state.CurrentLevel.HasStarted) {
				if (_numberToLay > 0)
					Enabled = true;
				else
					Enabled = false;
			} else {
				if (!_hasFired)
					Enabled = true;
				else
					Enabled = false;
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
		
		private function scareGroup(group:FlxGroup):void
		{
			var guests:FlxGroup = state.CurrentLevel.getGuests();
			FlxU.overlap(group, guests, function(obj1:FlxObject, obj2:FlxObject):void {
				if (obj1.bottom > obj2.top + (obj2.height >> 1))
					(obj2 as Character).scare();
			});
		}
		
		override public function restart():void
		{
			_hasFired = false;
			for each (var _dch:DeathsClutchHand in _hands.members)
				state.CurrentLevel.removeMinion(_dch);
			_hands = new FlxGroup();
			_index = 0;
			_floorCircles = new FlxGroup();
			var dc:FlxGroup;
			for each (dc in _blastZones.members) {
				state.CurrentLevel.removeAboveFloorElement(dc);
				_floorCircles.add(dc);
				state.CurrentLevel.addAboveFloorElement(dc);
			}
			
			super.restart();
		}
	}

}