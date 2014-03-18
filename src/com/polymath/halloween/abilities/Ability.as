package com.polymath.halloween.abilities 
{
	import flash.display.Shader;
	import flash.display.Shape;
	
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	import org.flixel.FlxPoint;
	
	import com.polymath.halloween.PlayState;
	import com.polymath.halloween.FloorElement;
	
	public class Ability extends FlxButton 
	{
		public function get Enabled():Boolean
		{
			return _isEnabled;
		}
		public function set Enabled(en:Boolean):void
		{
			_isEnabled = en;
		}
		private var _isEnabled:Boolean;
				
		protected function get Cooldown():Number
		{
			return _cooldown;
		}
		protected function set Cooldown(cd:Number):void
		{
			_cooldown = cd;
		}
		private var _cooldown:Number;
		
		protected function get state():PlayState
		{
			return FlxG.state as PlayState;
		}
		
		public function get inCooldown():Boolean
		{
			return _cooldownTimer > 0;
		}
		
		public function get tooltip():ToolTip
		{
			return _tooltip;
		}
		public function set tooltip(tt:ToolTip):void
		{
			_tooltip = tt;
		}
		private var _tooltip:ToolTip
		
		public function get ShowToolTip():Boolean
		{
			return (_tooltip != null && _tooltip.visible);
		}
		public function set ShowToolTip(stt:Boolean):void
		{
			if (_tooltip != null) {
				if (stt)
					_tooltip.visible = true;
				else
					_tooltip.visible = false;
			}
		}
		private var _showTooltip:Boolean;
		
		public function get inventoryText():InventoryText
		{
			return _inventoryText;
		}
		private var _inventoryText:InventoryText;
		
		private var _cooldownTimer:Number;
		private var _cooldownImg:FlxSprite;
		
		public function Ability(X:uint, Y:uint, Callback:Function ) 
		{
			super(X, Y, Callback);
			_cooldown = 10;
			_cooldownTimer = 0;
			
			_cooldownImg = new FlxSprite(X, Y);
			_cooldownImg.createGraphic(32, 16, 0xFF000000);
			_cooldownImg.alpha = 0.5;
			
			_inventoryText = null;
		}
		
		override public function update():void
		{
			if (_isEnabled && _cooldownTimer > 0) {
				_cooldownTimer -= FlxG.elapsed;
			}
			super.update();
		}
		
		protected function beginCooldown():void
		{
			if (!inCooldown)
				_cooldownTimer = _cooldown;
		}
		
		protected function makeTooltip(title:String, text:String):void
		{
			var ttText:String = title + "\n\n" + text;
			_tooltip = new ToolTip(this.x,  0, 100, ttText);
			_tooltip.y = this.y - _tooltip.height - 7;
		}
		
		protected function makeInventoryText(InitialInventory:uint):void
		{
			_inventoryText = new InventoryText(right - 4, top - 4, 15, InitialInventory.toString());
		}
		
		protected function updateInventoryText(Inventory:uint):void
		{
			if (_inventoryText != null) {
				_inventoryText.text = Inventory.toString();
				if (Inventory <= 0) {
					_inventoryText = null;
				}
			} else {
				if (Inventory > 0)
					makeInventoryText(Inventory);
			}
		}
		
		public function click():void {}
		public function makeSelectionWithGroup(sel:FlxGroup):void {}
		public function makeSelectionWithObject(sel:FlxObject):void {}
		
		public function isFinishedSelecting():Boolean
		{
			return true;
		}
		
		public function get SelectionDiameter():uint
		{
			return 1;
		}
		
		public function isReady():Boolean
		{
			return true;
		}
		
		override public function render():void
		{
			super.render();
			var shape:Shape;
			if (inCooldown) {
				shape = new Shape();
				var percentDone:Number = _cooldownTimer / _cooldown;
				
				shape.graphics.beginFill(0xFF000000, 0.5);
				shape.graphics.drawRect(getScreenXY().x + width - (percentDone * width), getScreenXY().y, (percentDone * width), height);
				shape.graphics.endFill();
				FlxG.buffer.draw(shape);
			}
			
			if (ShowToolTip) {
				_tooltip.render();
			}
		}
		
		public function restart():void
		{
			_cooldownTimer = 0;
		}
		
		protected function getCenterOfSelection(selection:FlxGroup):FlxPoint
		{
			var topX:uint = FlxG.width;
			var bottomX:uint = 0;
			var topY:uint = FlxG.height;
			var bottomY:uint = 0;
			for each (var obj:FlxObject in selection.members) {
				if (obj.x < topX) topX = obj.x;
				if (obj.y < topY) topY = obj.y;
				if (bottomX < obj.right) bottomX = obj.right;
				if (bottomY < obj.bottom) bottomY = obj.bottom;
			}
		
			return new FlxPoint(topX + ( (bottomX - topX) / 2), topY + ( (bottomY - topY) / 2));
		}
		
		protected function isValidPlacement(selection:FlxGroup):Boolean
		{
			var valid:Boolean = false;
			for each (var square:FlxObject in selection.members) {
				if (state.CurrentLevel.isValidSpace(square.x / FloorElement.TILE_WIDTH, square.y / FloorElement.TILE_HEIGHT)) {
					valid = true;
				}
			}
			return valid;
		}
		
		protected function generateError(text:String):void
		{
			state.CurrentLevel.showErrorMessage(text);
		}
	}

}