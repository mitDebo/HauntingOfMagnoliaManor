package com.polymath.halloween.abilities 
{
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxGroup;
	import org.flixel.FlxText;
	import org.flixel.FlxU;
	
	import com.polymath.halloween.Character;
	import com.polymath.halloween.PlayState;
	import com.polymath.halloween.FloorElement;
	
	public class Ectoplasm extends Ability 
	{
		[Embed(source = "../../../../../data/gfx/ectoplasm_button.png")] private var ImgButton:Class;
		[Embed(source = "../../../../../data/gfx/ectoplasm.png")] private var ImgEctoplasm:Class;
		
		private var _buttonSprite:FlxSprite;
		
		private var _laidEctoplasms:FlxGroup;
		private var _numberToLay:uint;
		private var _slowDuration:Number;
		private var _slowAmount:Number;
		private var _inventoryText:InventoryText;
		
		public function Ectoplasm(X:uint, Y:uint, Callback:Function) 
		{
			super(X, Y, Callback);
			width = 32;
			height = 16;
			
			_numberToLay = AbilityInfo.getInventory(this);
			_laidEctoplasms = new FlxGroup();
			
			_slowDuration = AbilityInfo.getDuration(this);
			_slowAmount = AbilityInfo.getAmount(this);
			
			_buttonSprite = new FlxSprite(0, 0);
			_buttonSprite.loadGraphic(ImgButton, true, false, 32, 16);
			_buttonSprite.addAnimation("up", [0]);
			_buttonSprite.addAnimation("down", [1]);
			
			makeInventoryText(_numberToLay);
			
			loadGraphic(_buttonSprite);
			makeTooltip("Ectoplasm", "Places a mysterious goo lies on the floor, slowing anyone who dares step in it.");
		}
		
		override public function click():void
		{
			if (!inCooldown && Enabled) {
				state.SelectionMode = PlayState.SELECTION_CIRCLE;
			}
		}
		
		override public function makeSelectionWithGroup(sel:FlxGroup):void
		{
			if (isValidPlacement(sel)) {
			// Find the top left most member of sel
				if (sel != null && sel.members.length > 0 && _numberToLay > 0) {
					var point:FlxPoint = new FlxPoint( (sel.members[0] as FlxObject).x, (sel.members[0] as FlxObject).y);
					for each (var obj:FlxObject in sel.members) {
						if (obj.x <= point.x)
							point.x = obj.x;
						if (obj.y <= point.y)
							point.y = obj.y;
					}
					var ecto:FlxSprite = new FlxSprite(point.x, point.y, ImgEctoplasm);
					_laidEctoplasms.add(ecto);
					state.CurrentLevel.addAboveFloorElement(ecto);
					_numberToLay--;
					updateInventoryText(_numberToLay);
				}
			}
		}
		
		override public function get SelectionDiameter():uint
		{
			return 2;
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
		
		override public function update():void
		{
			if (state.CurrentLevel.HasStarted) {
				Enabled = false;
			} else {
				Enabled = true;
			}
			
			if (_numberToLay <= 0)
				Enabled = false;
			
			if (_laidEctoplasms.members.length > 0 && state.CurrentLevel.HasStarted) {
				FlxU.overlap(_laidEctoplasms, state.CurrentLevel.getGuests(), function(obj1:FlxObject, obj2:FlxObject):void {
					if (obj1.top < obj2.y + (obj2.height >> 2) && obj1.bottom >= obj2.bottom && !(obj2 as Character).IsScared) {
						(obj2 as Character).slow(_slowAmount, _slowDuration);
					}
				});
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