package com.polymath.halloween.abilities 
{
	import com.polymath.halloween.minions.HauntGhost;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import org.flixel.FlxText;
	import org.flixel.FlxU;
	
	import com.polymath.halloween.Character;
	import com.polymath.halloween.PlayState;
	import com.polymath.halloween.FloorElement;
	
	public class Haunt extends Ability 
	{
		[Embed (source = "../../../../../data/gfx/haunt_button.png")] private var ImgButton:Class;
		private var _buttonSprite:FlxSprite;
		
		private var _inventory:uint;
		private var _hauntFrequency:Number;
		
		private var _hauntedRooms:FlxGroup;
		private var _ghosts:FlxGroup;
		
		public function Haunt(X:uint, Y:uint, Callback:Function) 
		{
			super(X, Y, Callback);
			width = 32;
			height = 16;
			
			_buttonSprite = new FlxSprite(0, 0);
			_buttonSprite.loadGraphic(ImgButton, true, false, 32, 16);
			_buttonSprite.addAnimation("up", [0]);
			_buttonSprite.addAnimation("down", [1]);
			
			_inventory = AbilityInfo.getInventory(this);
			_hauntFrequency = AbilityInfo.getCooldown(this);
			
			_hauntedRooms = new FlxGroup();
			_ghosts = new FlxGroup();
			
			loadGraphic(_buttonSprite);			
			
			Enabled = true;
			
			if (_inventory > 1)
				makeInventoryText(_inventory);
			
			makeTooltip("Haunt", "Places a ghost in a room, which will frighten a single visitor every few seconds. Once the level begins, the ghost cannot move to a different room.");
		}
		
		override public function click():void
		{
			if (Enabled && !inCooldown) {
				state.SelectionMode = PlayState.SELECTION_ROOM;
			}
		}
		
		override public function makeSelectionWithObject(sel:FlxObject):void
		{
			if (sel != null) {
				var ghost:HauntGhost;
				if (_hauntedRooms.members.indexOf(sel) == -1) {
					// This is a new room
					if (_inventory > 0) {
						_hauntedRooms.add(sel);
						_inventory--;
						updateInventoryText(_inventory);
						ghost = new HauntGhost( (sel.left + sel.right) / 2 - 8, (sel.top + sel.bottom) / 2 - 16, sel);
						ghost.Cooldown = Cooldown;
						_ghosts.add(ghost);
						state.CurrentLevel.addMinion(ghost);
					} else {
						generateError("You have no more haunts to place. You can always take a haunt back into your inventory by selecting a room that has a haunt already placed in it.");
					}
				} else {
					// This room already is set - remove it
					FlxU.overlap(sel, _ghosts, function(obj1:FlxObject, obj2:FlxObject):void {
						ghost = obj2 as HauntGhost;
					});
					_ghosts.remove(ghost, true);
					_hauntedRooms.remove(sel);
					state.CurrentLevel.removeMinion(ghost);
					_inventory++;
					updateInventoryText(_inventory);
				}
			}
		}
		
		override public function isReady():Boolean
		{
			return isFinishedSelecting();
		}
		
		override public function isFinishedSelecting():Boolean
		{
			return _inventory == 0;
		}
		
		override public function update():void
		{
			if (state.CurrentLevel.HasStarted) {
				Enabled = false;
			} else {
				Enabled = true;
			}
			
			if (state.CurrentLevel.HasStarted) {
				for each (var ghost:HauntGhost in _ghosts.members) {
					if (ghost.ready() && !state.CurrentLevel.TimesUp) {
						ghost.haunt();
					}
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
	}

}