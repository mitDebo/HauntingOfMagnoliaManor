package com.polymath.halloween.abilities 
{
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	
	import com.polymath.halloween.FloorElement;
	import com.polymath.halloween.PlayState;
	import com.polymath.halloween.minions.OnryoGhost;
	
	public class Onryo extends Ability 
	{
		[Embed(source = "../../../../../data/gfx/onryo_button.png")] private var ImgButton:Class;
		private var _buttonSprite:FlxSprite;
		
		private var _onryoGhost:OnryoGhost;
		private var _occupiedRoom:FlxObject;
		private var _transferSpeed:Number;
		private var _originalRoom:FlxObject;
		
		public function Onryo(X:uint, Y:uint, Callback:Function) 
		{
			super(X, Y, Callback);
			width = 32;
			height = 16;
			
			_buttonSprite = new FlxSprite(0, 0);
			_buttonSprite.loadGraphic(ImgButton, true, false, 32, 16);
			_buttonSprite.addAnimation("up", [0]);
			_buttonSprite.addAnimation("down", [1]);
			
			loadGraphic(_buttonSprite);
			
			_onryoGhost = null;
			_occupiedRoom = null;
			_transferSpeed = AbilityInfo.getAmount(this);
			_originalRoom = null;
			
			Enabled = true;
			Cooldown = AbilityInfo.getCooldown(this);
			
			makeTooltip("Onryo", "A vengeful spirit wanders a room, scaring intruders intermittently. After the level has begun, you can command the Onryo to move to a different room.");
		}
		
		override public function click():void
		{
			if (Enabled && !inCooldown) {
				state.SelectionMode = PlayState.SELECTION_ROOM;
			}
		}
		
		override public function makeSelectionWithObject(obj:FlxObject):void 
		{
			if (obj != null) {
				if (_onryoGhost == null) {
					_occupiedRoom = obj;
					if (_originalRoom == null)
						_originalRoom = _occupiedRoom;
					var randX:uint = Math.floor((obj.x / FloorElement.TILE_WIDTH)) + Math.floor(Math.random() * ( (obj.width - FloorElement.TILE_WIDTH) / FloorElement.TILE_WIDTH));
					var randY:uint = Math.floor((obj.y / FloorElement.TILE_HEIGHT)) + Math.floor(Math.random() * (obj.height / FloorElement.TILE_HEIGHT));
					_onryoGhost = new OnryoGhost(randX, randY, _occupiedRoom);
					_onryoGhost.TransferSpeed = _transferSpeed;
					_onryoGhost.Cooldown = Cooldown;
					
					state.CurrentLevel.addMinion(_onryoGhost);
				} else {
					_onryoGhost.moveToNewRoom(obj);
				}
			}
			
		}
		
		override public function update():void
		{
			if (state.CurrentLevel.HasStarted) {
				if (_onryoGhost.ready() && !state.CurrentLevel.TimesUp) {
					_onryoGhost.haunt();
				}
			}
			
			super.update();
		}
		
		override public function isReady():Boolean
		{
			return _onryoGhost != null;
		}
		
		override public function restart():void
		{
			if (_onryoGhost != null) {
				state.CurrentLevel.removeMinion(_onryoGhost);
				_onryoGhost.destroy();
				var randX:uint = Math.floor((_originalRoom.x / FloorElement.TILE_WIDTH)) + Math.floor(Math.random() * ( (_originalRoom.width - FloorElement.TILE_WIDTH) / FloorElement.TILE_WIDTH));
				var randY:uint = Math.floor((_originalRoom.y / FloorElement.TILE_HEIGHT)) + Math.floor(Math.random() * (_originalRoom.height / FloorElement.TILE_HEIGHT));
				_onryoGhost = new OnryoGhost(randX, randY, _originalRoom);
				_onryoGhost.TransferSpeed = _transferSpeed;
				_onryoGhost.Cooldown = Cooldown;
					
				state.CurrentLevel.addMinion(_onryoGhost);
			}
		}
	}

}