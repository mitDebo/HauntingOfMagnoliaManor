package com.polymath.halloween.abilities 
{
	import com.polymath.halloween.FloorElement;
	import com.polymath.halloween.minions.ClosedDoor;
	import com.polymath.halloween.Node;
	import com.polymath.halloween.PathFinder;
	
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxU;
	
	import com.polymath.halloween.PlayState;
	
	public class SealDoor extends Ability 
	{
		[Embed(source = "../../../../../data/gfx/sealdoor_button.png")] private var ImgButton:Class;
		
		private var _buttonSprite:FlxSprite;
		
		private var _inventory:uint;
		private var _closedDoorPoints:FlxGroup;
		private var _doorImages:FlxGroup;
		
		public function SealDoor(X:uint, Y:uint, Callback:Function) 
		{
			super(X, Y, Callback);
			width = 32;
			height = 16;
		
			Enabled = true;
			_inventory = AbilityInfo.getInventory(this);
			
			_closedDoorPoints = new FlxGroup();
			_doorImages = new FlxGroup();
			
			_buttonSprite = new FlxSprite(0, 0);
			_buttonSprite.loadGraphic(ImgButton, true, false, 32, 16);
			_buttonSprite.addAnimation("up", [0]);
			_buttonSprite.addAnimation("down", [1]);
			loadGraphic(_buttonSprite);
			
			makeInventoryText(_inventory);
			makeTooltip("Seal Door", "Closes and barricades a doorway, forcing any intruders to find a different path through the rooms. However, all rooms must still remain completely accessable from each other.");
		}
		
		override public function update():void
		{
			if (state.CurrentLevel.HasStarted) {
				Enabled = false;
			} else {
				Enabled = true;
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
		
		override public function click():void
		{
			if (!inCooldown && Enabled) {
				state.SelectionMode = PlayState.SELECTION_CIRCLE;
			}
		}
		
		override public function makeSelectionWithGroup(sel:FlxGroup):void
		{
			// Before we see if we're laying down a door, let's make sure we're not already over one
			// If we are, we want to remove it
			var doorGraphic:ClosedDoor = getDoorGraphic(sel);
			if (doorGraphic != null) {
				unblockDoorwayy(sel);
				state.CurrentLevel.removeMinion(doorGraphic);
				_doorImages.remove(doorGraphic, true);
				_inventory++;
				updateInventoryText(_inventory);
				return;
			}
			
			if (_inventory == 0) {
				generateError("You have no more doors to place.");
				return;
			}
			
			// First, we need to see if this selection overlaps any of the rooms - if it does, we fail
			var rooms:FlxGroup = state.CurrentLevel.getRooms();
			var invalidPlacement:Boolean = true;
			// First, see if we're even on the board
			if (isValidPlacement(sel))
				invalidPlacement = false;
			
			// Then, see if we're overlapping any rooms - if so, we can't be a doorway
			if (!invalidPlacement && FlxU.overlap(rooms, sel, function(obj1:FlxObject, obj2:FlxObject):Boolean { return true; })) {
				invalidPlacement = true;
			}
			
			// Finally, see if we're overlapping any entrances - we can't close those off
			if (!invalidPlacement && FlxU.overlap(state.CurrentLevel.Entrances, sel, function(obj1:FlxObject, obj2:FlxObject):Boolean { return true; } )) {
				invalidPlacement = true;
			}
			
			if (!invalidPlacement) {
				blockOffDoorway(sel);
				if (!allRoomsStillAccessable()) {
					unblockDoorwayy(sel);
					generateError("All rooms must still remain completely accessable from each other.");
				} else {
					// Get the two previous closed door points
					var point1:FlxObject = _closedDoorPoints.members[_closedDoorPoints.members.length - 1] as FlxObject;
					var point2:FlxObject = _closedDoorPoints.members[_closedDoorPoints.members.length - 2] as FlxObject;
					
					var door:ClosedDoor;
					if (point1.x == point2.x) {
						door = new ClosedDoor(FloorElement.TILE_WIDTH * point1.x, FloorElement.TILE_HEIGHT * Math.min(point1.y, point2.y), true);
					} else {
						// Get the leftmost coord
						door = new ClosedDoor(FloorElement.TILE_WIDTH * (Math.min(point1.x, point2.x) + 1) , FloorElement.TILE_WIDTH * (point1.y - 1) - 1, false);
					}
					
					//door.createGraphic(16, 16, 0xFFFF0000);
					_doorImages.add(door);
					state.CurrentLevel.addMinion(door);
					_inventory--;
					updateInventoryText(_inventory);
				}
			} 
		}
		
		override public function get SelectionDiameter():uint
		{
			return 2;
		}
		
		override public function isReady():Boolean
		{
			return isFinishedSelecting();
		}
		
		override public function isFinishedSelecting():Boolean
		{
			return (_inventory <= 0);
		}
		
		private function blockOffDoorway(sel:FlxGroup):void
		{
			for each (var square:FlxObject in sel.members) {
				var tileX:uint = (square.x / FloorElement.TILE_WIDTH);
				var tileY:uint = (square.y / FloorElement.TILE_HEIGHT);
				var point:FlxObject;
				
				if (state.CurrentLevel.getValueAtWalkingGrid(tileX, tileY)) {
					point = new FlxObject(tileX, tileY);
					state.CurrentLevel.alterWalkingGrid(tileX, tileY, false);
					_closedDoorPoints.add(point);
				}
				// Also, check to see if one spot to the left is valid
				if (state.CurrentLevel.getValueAtWalkingGrid(tileX - 1, tileY)) {
					point = new FlxObject(tileX - 1, tileY);
					state.CurrentLevel.alterWalkingGrid(tileX - 1, tileY, false);
					_closedDoorPoints.add(point);
				}
			}
		}
		
		private function unblockDoorwayy(sel:FlxGroup):void
		{
			var gridSpace:FlxObject;
			for (var i:uint = _closedDoorPoints.members.length; i > 0; i--) {
				var point:FlxObject = _closedDoorPoints.members[i-1];
				gridSpace = new FlxObject(point.x * FloorElement.TILE_WIDTH, point.y * FloorElement.TILE_HEIGHT, FloorElement.TILE_WIDTH, FloorElement.TILE_HEIGHT);
				
				// See if this spot was a valid point
				if (FlxU.overlap(gridSpace, sel, function(obj1:FlxObject, obj2:FlxObject):Boolean { return true; } )) {
					_closedDoorPoints.remove(point, true);
					state.CurrentLevel.alterWalkingGrid(point.x, point.y, true);
					continue;
				}
				
				// Or see if this spot was a valid point and is next to our selection
				gridSpace = new FlxObject( (point.x + 1) * FloorElement.TILE_WIDTH, point.y * FloorElement.TILE_HEIGHT, FloorElement.TILE_WIDTH, FloorElement.TILE_HEIGHT);
				if (FlxU.overlap(gridSpace, sel, function(obj1:FlxObject, obj2:FlxObject):Boolean { return true; } )) {
					_closedDoorPoints.remove(point, true);
					state.CurrentLevel.alterWalkingGrid(point.x, point.y, true);
					continue;
				}
			}
		}
		
		private function allRoomsStillAccessable():Boolean
		{
			var allAccessable:Boolean = true;
			var rooms:FlxGroup = state.CurrentLevel.getRooms();
			
			for (var i:uint = 0; i < rooms.members.length; i++) {
				for (var k:uint = 0; k < rooms.members.length; k++) {
					var node1:Node = new Node(rooms.members[i].x / FloorElement.TILE_WIDTH, rooms.members[i].y / FloorElement.TILE_HEIGHT);
					var node2:Node = new Node(rooms.members[k].x / FloorElement.TILE_WIDTH, rooms.members[k].y / FloorElement.TILE_HEIGHT);
					if (PathFinder.determinePath(node1, node2) == null)
						allAccessable = false;
				}
			}
			return allAccessable;
		}
		
		private function getDoorGraphic(selection:FlxGroup):ClosedDoor
		{
			var door:ClosedDoor = null;
			FlxU.overlap(selection, _doorImages, function(obj1:FlxObject, obj2:FlxObject):void {
				door = obj2 as ClosedDoor;
			});
			return door;
		}
	}
}