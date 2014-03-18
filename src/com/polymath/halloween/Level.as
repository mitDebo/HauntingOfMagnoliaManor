package com.polymath.halloween 
{
	import com.polymath.halloween.abilities.Onryo;
	import com.polymath.halloween.abilities.SealDoor;
	import com.polymath.halloween.minions.Minion;
	import flash.events.TextEvent;
	import flash.utils.ByteArray;
	import flash.xml.*;
	import Playtomic.Log;
	
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;	
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	import org.flixel.FlxU;
	
	import com.polymath.halloween.abilities.Ability;
	import com.polymath.halloween.abilities.DeathsClutch;
	import com.polymath.halloween.abilities.Demon;
	import com.polymath.halloween.abilities.Ectoplasm;
	import com.polymath.halloween.abilities.Haunt;
	import com.polymath.halloween.abilities.Possess;
	import com.polymath.halloween.abilities.Scare;
	
	public class Level extends FlxGroup 
	{
		[Embed(source = "../../../../data/gfx/time_box.png")] private var ImgTimeBox:Class;
		[Embed(source = "../../../../data/gfx/clock.png")] private var ImgClock:Class;
		[Embed(source = "../../../../data/gfx/returntomenu_button.png")] private var ImgReturnToMenuButton:Class;
		[Embed(source = "../../../../data/gfx/hotbar.png")] private var ImgHotbar:Class;
		[Embed(source = "../../../../data/gfx/button_highlight.png")] private var ImgButtonHighlight:Class;
		[Embed(source = "../../../../data/gfx/go_button.png")] private var ImgGoButton:Class;
		
		// Graphical elements
		private var _floor:FlxGroup;
		private var _aboveFloorElements:FlxGroup;
		private var _nonFloor:FlxGroup;	// Black squares for covering up the areas that are drawn outside of floors
		private var _walls:FlxGroup;
		private var _wallTops:FlxGroup;
		private var _guests:FlxGroup;
		private var _minions:FlxGroup;
		private var _wallsGuestsAndMinions:FlxGroup;
		
		private var _walkingGrid:Array;
		private var _rooms:FlxGroup;
		private var _entrances:FlxGroup;
		private var _selectionSquares:FlxGroup;
		private var _currentSelectionDiameter:uint;
		
		private var _abilities:FlxGroup;
		
		private var _isRunning:Boolean;
		private var _timeLimit:Number;
		private var _timeLeft:Number;
		
		private var _timerClockGraphic:FlxSprite;
		private var _timerText:FlxText;
		private var _goalText:FlxText;
		private var _menuButton:FlxButton;
		private var _timerFrame:FlxSprite;
		private var _goButton:FlxButton;
		private var _goButtonSprite:FlxSprite;
		private var _notReadyTextBox:NotReadyTextBox;
		
		private var _pressedAbility:Ability;
		private var _abilityHighlight:FlxSprite;
		private var _hotbar:FlxSprite;
		
		private var _goalScared:uint;
		private var _currentScared:uint;
		
		private var _tutorial:Tutorial;
		private var _errorMessage:ErrorMessage;
		private var _levelInfo:LevelInfo;
		
		private var _playedWarning:Boolean;
		
		public function get TimesUp():Boolean 
		{
			return _timesUp;
		}
		private var _timesUp:Boolean;
		
		public function get HasStarted():Boolean 
		{
			return _isRunning || _timesUp;
		}
		
		public function get Entrances():FlxGroup 
		{
			return _entrances;
		}
				
		public function Level(levelname:String) 
		{
			FlxG.log("Processing " + levelname);
			_floor = new FlxGroup();
			_nonFloor = new FlxGroup();
			_aboveFloorElements = new FlxGroup();
			_walls = new FlxGroup();
			_wallTops = new FlxGroup();
			_guests = new FlxGroup();
			_minions = new FlxGroup();			
			
			_currentScared = 0;
			
			_abilities = new FlxGroup();
			
			// The walking grid - for pathfinding for the guests
			_walkingGrid = new Array();
			
			_rooms = new FlxGroup();
			_entrances = new FlxGroup();
			_selectionSquares = new FlxGroup();
			
			/** Graphical stuff **/
			_timerText = new FlxText((FlxG.width >> 1) - 50, 0, 100);			
			_timerText.setFormat(null, 8, 0xFFFFFFFF, "center", 0xFF000000);
			_timerFrame = new FlxSprite(10, 0, ImgTimeBox);
			_timerClockGraphic = new FlxSprite(137, 3, ImgClock);
			
			_goalText = new FlxText(230, 0, 60);
			_goalText.setFormat(null, 8, 0xFFFFFFFF, "right", 0xFF000000);
			
			_menuButton = new FlxButton(16, 0, returnToMenu);
			_menuButton.loadText(new FlxText(8, 0, 32, "Menu").setFormat(null, 8, 0xFFFFFFFF, "left", 0xFF000000));
			_menuButton.loadGraphic(new FlxSprite(0, 1, ImgReturnToMenuButton));
			
			_hotbar = new FlxSprite(37, 208, ImgHotbar);
			_abilityHighlight = new FlxSprite(42,221);
			_abilityHighlight.loadGraphic(ImgButtonHighlight, true, false, 34, 18);
			_abilityHighlight.addAnimation("play", [0, 1, 2, 3], 6);
			_abilityHighlight.play("play");	
			
			_goButton = new FlxButton(253, 210, start);
			_goButtonSprite = new FlxSprite(0, 0);
			_goButtonSprite.loadGraphic(ImgGoButton, true, false, 28, 28);
			_goButtonSprite.addAnimation("up", [0]);
			_goButtonSprite.addAnimation("down", [1]);
			_goButtonSprite.play("up");
			_goButton.loadGraphic(_goButtonSprite);
			
			_notReadyTextBox = new NotReadyTextBox();
			_notReadyTextBox.visible = false;
			
			_isRunning = false;
			_timesUp = false;
			
			_playedWarning = false;
			
			// Begin processing the xml
			var file:ByteArray;
			var classInstance:Class;
			classInstance = Assets.getResource(levelname);
			file = new classInstance() as ByteArray;
						
			var str:String = file.readUTFBytes(file.length);			
			var data:XML = new XML(str);
			
			// Indicies for keeping track of where in the CSV string we are
			var h:uint;
			var w:uint;
			
			var csv:String;
			var lines:Array;
			var cells:Array;
			
			_goalScared = data.@goal;
			_goalText.text = "0 / " + _goalScared;
			_timeLimit = data.@time_limit;
			_timeLeft = _timeLimit;
			
			// Our level is now stored in an XML object
			// Get the floors
			if (data.floor.length() > 0) {
				// Get the floor string
				csv = data.floor.text();
				lines = csv.split("\n");
				for (h = 0; h < lines.length; h++) {
					cells = lines[h].split(",");
					var gridLine:Array = new Array();
					for (w = 0; w < cells.length; w++) {
						if (parseInt(cells[w]) >= 0) {
							_floor.add(new FloorElement(FloorElement.TILE_WIDTH * w, FloorElement.TILE_HEIGHT * h, cells[w]));
							
							// Add this as a valid spot to walk on our walking grid
							gridLine.push(1);
						} else {
							_nonFloor.add(new FlxSprite(FloorElement.TILE_WIDTH * w, FloorElement.TILE_HEIGHT * h).createGraphic(FloorElement.TILE_WIDTH, FloorElement.TILE_HEIGHT, 0xFF000000));
							// Not a valid walking spot
							gridLine.push(0);
						}
					}
					
					// Add the grid line to the walking grid
					_walkingGrid.push(gridLine);
				}
			}
			
			// Then the walls
			if (data.walls.length() > 0) {
				// Get the wall string
				csv = data.walls.text();
				lines = csv.split("\n");
				for (h = 0; h < lines.length; h++) {
					cells = lines[h].split(",");
					for (w = 0; w < cells.length; w++) {
						if (parseInt(cells[w]) >= 0) {
							_walls.add(new WallElement(WallElement.TILE_WIDTH * w, WallElement.TILE_HEIGHT * h, cells[w]));
						}
					}
				}
			}
			
			// Then the wall tops
			if (data.wall_tops.length() > 0) {
				// Get the wall tops string
				csv = data.wall_tops.text();
				lines = csv.split("\n");
				for (h = 0; h < lines.length; h++) {
					cells = lines[h].split(",");
					for (w = 0; w < cells.length; w++) {
						if (parseInt(cells[w]) >= 0) {
							_wallTops.add(new WallTopElement(WallTopElement.TILE_WIDTH * w, WallTopElement.TILE_HEIGHT * h, cells[w]));
						}
					}
				}
			}
			
			// Now, let's grab the rooms
			var list:XMLList;
			list = data.rooms.room;
			for each (var room:XML in list) {
				var roomBounds:FlxObject = new FlxObject(room.@x, room.@y);
				roomBounds.width = room.node.@x - room.@x + FloorElement.TILE_WIDTH;
				roomBounds.height = room.node.@y - room.@y + FloorElement.TILE_HEIGHT;
				_rooms.add(roomBounds);
			}
			
			// And our entrances
			list = data.entrances.entrance;
			for each (var ent:XML in list) {
				var entrance:Entrance = new Entrance(ent.@x, ent.@y, this, ent.@numOfGuests, ent.@minWalkingSpeed, ent.@maxWalkingSpeed, ent.@interval);
				_entrances.add(entrance);
			}
			
			cleanUpWalkingGrid();
			populateSelectionSquares();
			
			var buttonX:uint;
			var button:FlxButton;
			var buttonName:String;
			
			// Get all the abilities
			buttonX = 43;
			buttonName = data.@ability1;
			if (buttonName.length > 0) {
				button = getButton(buttonName, buttonX);
				_abilities.add(button);
			}
			
			buttonX += 35;
			buttonName = data.@ability2;
			if (buttonName.length > 0) {
				button = getButton(buttonName, buttonX);
				_abilities.add(button);
			}
			
			buttonX += 35;
			buttonName = data.@ability3;
			if (buttonName.length > 0) {
				button = getButton(buttonName, buttonX);
				_abilities.add(button);
			}
			
			buttonX += 35;
			buttonName = data.@ability4;
			if (buttonName.length > 0) {
				button = getButton(buttonName, buttonX);
				_abilities.add(button);
			}
			
			buttonX += 35;
			buttonName = data.@ability5;
			if (buttonName.length > 0) {
				button = getButton(buttonName, buttonX);
				_abilities.add(button);
			}
			
			buttonX += 35;
			buttonName = data.@ability6;
			if (buttonName.length > 0) {
				button = getButton(buttonName, buttonX);
				_abilities.add(button);
			}
			
			_tutorial = new Tutorial();
			_errorMessage = new ErrorMessage();
			_levelInfo = new LevelInfo();
			if (Stats.LevelsComplete < FlxG.level)
				_levelInfo.show();
			else
				_levelInfo.hide();
			
			if (Stats.NeedsTutorial)
				_tutorial.visible = true;
			
			add(_aboveFloorElements);
			add(_guests);
			add(_minions);
			add(_selectionSquares);
			add(_entrances);
			add(_abilities);
			add(_abilityHighlight);
			add(_goButton);
			add(_menuButton);
			add(_notReadyTextBox);
			add(_tutorial);
			add(_errorMessage);
			add(_levelInfo);
		}
		
		override public function update():void
		{
			sortGuestsAndWalls();
			
			// Do we display button tooltips?
			for each (var ability:Ability in _abilities.members) {
				ability.ShowToolTip = false;
				if (ability != _pressedAbility && ability.overlapsPoint(FlxG.mouse.x, FlxG.mouse.y) && !TimesUp)
					ability.ShowToolTip = true;
			}
			
			if (_isRunning && _timeLeft > 0) {
				_timeLeft -= FlxG.elapsed;
				
				if (_timeLeft < 0) {
					_isRunning = false;
					_timesUp = true;
				}
				
				if (_timeLeft < 4) {
					if (Math.round(_timeLeft) < _timeLeft && !_playedWarning) {
						FlxG.play(Assets.getResource("warning"));
						_playedWarning = true;
					} else if (Math.round(_timeLeft) > _timeLeft) {
						_playedWarning = false;
					}
				}
			}
			if (!HasStarted) {
				_timerText.text = "Planning Phase";
				_timerClockGraphic.alpha = 0;
			}
			else {
				_timerText.text = formatTime(_timeLeft);
				_timerClockGraphic.alpha = 1;
			}
			
			if (_pressedAbility != null && !_pressedAbility.Enabled)
				_pressedAbility = null;
				
			if (_pressedAbility == null)
				_abilityHighlight.visible = false;
			else {
				_abilityHighlight.visible = true;
				_abilityHighlight.x = _pressedAbility.x - 1;
				_abilityHighlight.y = _pressedAbility.y - 1;
			}
			
			super.update();
		}
		
		public function start():void
		{
			if (Stats.NeedsTutorial && _tutorial.Index < 5)
				return;
			if (_tutorial.Index == 7) {
				_tutorial.nextStep();
			}
			
			var allReady:Boolean = true;
			_notReadyTextBox.hide();
			_errorMessage.hide();
			_levelInfo.hide();
			for each (var ability:Ability in _abilities.members) {
				if (!ability.isReady()) {
					allReady = false;
					_notReadyTextBox.addUnit(getAbilityName(ability));
				}
			}
			
			if (!allReady) {
				_notReadyTextBox.show();
				return;
			}
			
			if (!_timesUp && !_isRunning) {
				_goButtonSprite.play("down");
				_isRunning = true;
				for each (var ent:Entrance in _entrances.members) {
					ent.start();
				}
			}
		}
		
		public function addGuest(c:Character):void
		{
			_guests.add(c);
			c.Level = this;
		}
		
		public function addMinion(m:Minion):void
		{
			_minions.add(m);
		}
		
		public function removeMinion(m:Minion):void
		{
			_minions.remove(m, true);
		}
		
		public function addAboveFloorElement(obj:FlxObject):void
		{
			_aboveFloorElements.add(obj);
		}
		
		public function removeAboveFloorElement(obj:FlxObject):FlxObject
		{
			return _aboveFloorElements.remove(obj, true);
		}
		
		public function isValidSpace(x:uint, y:uint):Boolean
		{
			if (x >= 0 && y >= 0 && y < _walkingGrid.length && x < _walkingGrid[y].length && _walkingGrid[y][x] == 1)
				return true;
			return false;
		}
		
		public function getGuests():FlxGroup
		{
			return _guests;
		}
		
		public function getGuestAt(x:int, y:int):Character
		{
			var possibleGuest:Character = null;
			for each (var guest:Character in _guests.members) {
				if (guest.overlapsPoint(x, y) && !guest.IsScared && !guest.IsTagged) {
					if (possibleGuest != null && guest.y > possibleGuest.y)
						possibleGuest = guest;
					else
						possibleGuest = guest;
				}
			}
			return possibleGuest;
		}
		
		
		public function highlightGuest(guest:Character):void
		{
			guest.alpha = 0.5;
		}
		
		public function unhighlightGuest(guest:Character):void
		{
			guest.alpha = 1;
		}
		
		public function getRoomAt(x:int, y:int):FlxObject
		{
			for each (var room:FlxObject in _rooms.members) {
				if (room.overlapsPoint(x, y))
					return room;
			}
			return null;
		}
		
		public function getRooms():FlxGroup
		{
			return _rooms;
		}
		
		public function getRandomRoom(weighted:Boolean = false):FlxObject
		{
			if (_rooms.members.length == 0)
				return null;
			if (weighted) {
				// We want the rooms to have a probablity of being selected that is determined by their size - that is, larger rooms are more likely to be selected
				var rand:Number = Math.random();
				var totalArea:Number = 0;
				var areaPercentage:Number = 0;
				var room:FlxObject
				for each (room in _rooms.members) {
					totalArea += (room.bottom - room.top) * (room.right - room.left);
				}
				
				for each (room in _rooms.members) {
					areaPercentage += ( (room.bottom - room.top) * (room.right - room.left) / totalArea);
					if (areaPercentage > rand)
						return room;
				}
			} else {
				// Pick between the rooms evenly
				var index:uint = Math.random() * _rooms.members.length;
				return _rooms.members[index] as FlxObject;	
			}
			
			return null;
		}
		
		public function highlightRoom(room:FlxObject):void
		{
			FlxU.overlap(room, _selectionSquares, function(obj1:FlxObject, obj2:FlxObject):void {
				(obj2 as GlowingSquare).on();
			});
		}
		
		public function unhighlightRoom(room:FlxObject):void
		{
			FlxU.overlap(room, _selectionSquares, function(obj1:FlxObject, obj2:FlxObject):void {
				(obj2 as GlowingSquare).off();
			});
		}
		
		public function getCircleCenter(x:int, y:int):FlxPoint
		{
			var circle:FlxPoint = null;
			if (_pressedAbility != null)
				_currentSelectionDiameter = _pressedAbility.SelectionDiameter;
			else
				_currentSelectionDiameter = 1;
			
			if ( _currentSelectionDiameter % 2 == 0) {
				// The circle is of even width; the center lies between tiles
				circle = new FlxPoint();
				circle.x = Math.round(x / FloorElement.TILE_WIDTH) * FloorElement.TILE_WIDTH;
				circle.y = Math.round(y / FloorElement.TILE_HEIGHT) * FloorElement.TILE_HEIGHT;
			} else {
				// The circle is of odd width; the center is in the middle of a tile
				circle = new FlxPoint();
				circle.x = Math.floor(x / FloorElement.TILE_WIDTH) * FloorElement.TILE_WIDTH + (FloorElement.TILE_WIDTH >> 1);
				circle.y = Math.floor(y / FloorElement.TILE_HEIGHT) * FloorElement.TILE_HEIGHT + (FloorElement.TILE_HEIGHT >> 1);
			}
			
			return circle;
		}
		
		public function highlightCircle(x:int, y:int):void
		{
			var circle:FlxGroup = getCircle(x, y, _currentSelectionDiameter);
			FlxU.overlap(circle, _selectionSquares, function(obj1:FlxObject, obj2:FlxObject):void {
				(obj2 as GlowingSquare).on();
			});
		}
		
		public function unhighlightCircle(x:int, y:int):void
		{
			var circle:FlxGroup = getCircle(x, y, _currentSelectionDiameter);
			FlxU.overlap(circle, _selectionSquares, function(obj1:FlxObject, obj2:FlxObject):void {
				(obj2 as GlowingSquare).off();
			});
		}
		
		private function getCircle(x:int, y:int, radius:uint):FlxGroup
		{
			var circle:FlxGroup = new FlxGroup();
			
			var topLeft:FlxPoint = new FlxPoint();
			
			if (radius % 2 == 0) {
				topLeft.x = Math.round(x / FloorElement.TILE_WIDTH) * FloorElement.TILE_WIDTH - (radius / 2) * FloorElement.TILE_WIDTH;
				topLeft.y = Math.round(y / FloorElement.TILE_HEIGHT) * FloorElement.TILE_HEIGHT - (radius / 2) * FloorElement.TILE_HEIGHT;
			} else {
				topLeft.x = Math.floor(x / FloorElement.TILE_WIDTH) * FloorElement.TILE_WIDTH - ((radius - 1) / 2) * FloorElement.TILE_WIDTH;
				topLeft.y = Math.floor(y / FloorElement.TILE_HEIGHT) * FloorElement.TILE_HEIGHT - ((radius - 1) / 2) * FloorElement.TILE_HEIGHT;
			}
			
			var foo:uint = 0;
			for (var i:uint = 0; i < radius; i++) {
				for (var k:uint = 0; k < radius; k++) {
					// Sorry for the spaghetti code here; I tried very long to generalize this, but kept banging my head against the wall
					// Eventually, I just decided that the best option is just to have a bunch of if statements
					// It's not elegant, but it gets the job done
					if (radius >= 4) {
						// Just lopping off the corners
						if ( (i == 0 || i == radius - 1) && (k == 0 || k == radius - 1))
							continue;
					}
					if (radius >= 7) {
						// Take off a little more...
						if ( (i == 0 || i == radius - 1) && (k == 1 || k == radius - 2))
							continue;
						if ( (i == 1 || i == radius - 2) && (k == 0 || k == radius - 1))
							continue;
					}
					if (radius >= 10) {
						// And just a bit more
						if ( (i == 0 || i == radius - 1) && (k == 2 || k == radius - 3))
							continue;
						if ( (i == 2 || i == radius -3) && (k == 0 || k == radius - 1))
							continue;
					}
					
					var obj:FlxObject = new FlxObject(0, 0, FloorElement.TILE_WIDTH, FloorElement.TILE_HEIGHT);
					obj.x = topLeft.x + k * FloorElement.TILE_WIDTH;
					obj.y = topLeft.y + i * FloorElement.TILE_HEIGHT;
					circle.add(obj);
				}
			}
			return circle;
		}
		
		public function getAllGuestsInRoom(room:FlxObject):FlxGroup
		{
			var allGuests:FlxGroup = new FlxGroup();
			if (room != null) {
				FlxU.overlap(room, _guests, function(obj1:FlxObject, obj2:FlxObject):Boolean {
					if (obj1.bottom > obj2.top + (obj2.height >> 1) && !(obj2 as Character).IsScared && !(obj2 as Character).IsTagged)
						allGuests.add(obj2);
					return true;
					});
			}
			
			if (allGuests.members.length == 0)
				return null;
			return allGuests;
		}
		
		public function getRandomGuestInRoom(room:FlxObject):Character
		{
			var allGuests:FlxGroup = getAllGuestsInRoom(room);
			if (allGuests == null)
				return null;
			
			var index:uint = Math.floor(Math.random() * allGuests.members.length);
			return allGuests.members[index] as Character;
		}
		
		public function getAllGuestsInCircle(x:int, y:int, radius:uint):FlxGroup
		{
			var allGuests:FlxGroup = new FlxGroup();
			var circle:FlxGroup = getCircle(x, y, radius);
			FlxU.overlap(circle, _guests, function(obj1:FlxObject, obj2:FlxObject):Boolean {
				// We actually don't want to know if they just overlap - we actually want to know if the guest is STANDING in the circle
				// As such, we make sure that the overlapping is not just their head
				if (obj1.bottom > obj2.top + (obj2.height >> 1) && !(obj2 as Character).IsScared && !(obj2 as Character).IsTagged)
					allGuests.add(obj2);
				return true;
			});
			return allGuests;
		}
		
		/**
		 * Puts both guests and walls into the _wallsAndGuests FlxGroup, sorted so that they'll draw correctly
		 */
		private function sortGuestsAndWalls():void
		{
			var guestsAndMinions:FlxGroup = new FlxGroup();
			
			guestsAndMinions.members = _guests.members.concat(_minions.members);
			guestsAndMinions.sort();
			
			_wallsGuestsAndMinions = new FlxGroup();
			var wallIndex:uint = 0;
			var guestIndex:uint = 0;
			
			while (wallIndex < _walls.members.length && guestIndex < guestsAndMinions.members.length) {
				var wall:FlxSprite = _walls.members[wallIndex] as FlxSprite;
				var guest:FlxSprite = guestsAndMinions.members[guestIndex] as FlxSprite;
				
				if (wall.y <= guest.y) {
					_wallsGuestsAndMinions.add(wall);
					wallIndex++;
				} else {
					_wallsGuestsAndMinions.add(guest);
					guestIndex++;
				}
			} 
			
			while (wallIndex < _walls.members.length) {
				_wallsGuestsAndMinions.add(_walls.members[wallIndex]);
				wallIndex++;
			}
			
			while (guestIndex < guestsAndMinions.members.length) {
				_wallsGuestsAndMinions.add(guestsAndMinions.members[guestIndex]);
				guestIndex++;
			}
		}
		
		/**
		 * Takes the walking grid and identifies doors, removing the additional tiles they produce
		 */
		private function cleanUpWalkingGrid():void
		{
			// Because the character is twice as wide as the tile, we need to remove all right-most tiles
			var inRoom:Boolean = false;
			var i:uint;
			var k:uint;
			
			// First, let's remove all possible bottom parts of the horizontal doors
			for (i = 0; i < _walkingGrid.length; i++) {
				for (k = 0; k < _walkingGrid[i].length; k++) {
					if (i > 0 && i + 1 < _walkingGrid.length && _walkingGrid[i - 1][k] == 1 && _walkingGrid[i + 1][k] == 0) {
						// Make a FlxObject the size of the two of us, and see if we're both in a room
						var possibleDoor:FlxObject = new FlxObject(k * FloorElement.TILE_WIDTH, (i - 1) * FloorElement.TILE_HEIGHT, FloorElement.TILE_WIDTH, FloorElement.TILE_HEIGHT * 2);
						if (!FlxU.overlap(_rooms, possibleDoor, function(f:FlxObject, t:FlxObject):Boolean
							{ return true; }
							)) {
							_walkingGrid[i][k] = 0;
						}
					}
				}
			}
			
			// Next, we loop through again, removing all right-most portions of the grid, with the exception of those that neighbor an entrance
			for (i = 0; i < _walkingGrid.length; i++) {
				for (k = 0; k < _walkingGrid[i].length; k++) {
					if (_walkingGrid[i][k] == 1) {
						inRoom = true;
					} else {
						if (k > 0 && inRoom) {
							// We just left a room - if our right neighbor isn't an entrance, we need to go
							var foundEntrance:Boolean = false;
							for each (var ent:Entrance in _entrances.members) {
								if (ent.x == k * FloorElement.TILE_WIDTH && ent.y == i * FloorElement.TILE_HEIGHT) {
									foundEntrance = true;
								}
							}
							if (!foundEntrance) {
								_walkingGrid[i][k - 1] = 0;
							}
							inRoom = false;
						}
					}
				}
			}
		}
		
		public function getValueAtWalkingGrid(x:uint, y:uint):Boolean
		{
			if (_walkingGrid[y][x] == 1)
				return true;
			return false;
		}
		
		public function alterWalkingGrid(x:uint, y:uint, value:Boolean):void
		{
			if (value)
				_walkingGrid[y][x] = 1;
			else
				_walkingGrid[y][x] = 0;
		}
		
		private function populateSelectionSquares():void
		{
			var inRoom:Boolean = false;
			for (var i:uint = 0; i < _walkingGrid.length; i++) {
				for (var k:uint = 0; k < _walkingGrid[i].length; k++) {
					if (_walkingGrid[i][k] == 1) {
						_selectionSquares.add(new GlowingSquare(k * FloorElement.TILE_WIDTH, i * FloorElement.TILE_HEIGHT));
						inRoom = true;
					} else if (_walkingGrid[i][k] == 0 && inRoom) {
						_selectionSquares.add(new GlowingSquare(k * FloorElement.TILE_WIDTH, i * FloorElement.TILE_HEIGHT));
						inRoom = false;
					}
				}
			}
		}		
		
		public function makeCircleSelection(x:int, y:int):void
		{
			if (!_errorMessage.visible) {
				var sel:FlxGroup = getCircle(x, y, _currentSelectionDiameter);
				_pressedAbility.makeSelectionWithGroup(sel);
			}
		}
		
		public function makeRoomSelection(sel:FlxObject):void
		{
			if (!_errorMessage.visible) {
				_pressedAbility.makeSelectionWithObject(sel);
				if (Stats.NeedsTutorial && _tutorial.Index == 2) {
					_tutorial.nextStep();
				}
			}
		}
		
		public function makeCharacterSelection(sel:Character):void
		{
			if (!_errorMessage.visible)
				_pressedAbility.makeSelectionWithObject(sel);
		}
		
		public function doneWithSelections():Boolean
		{
			var done:Boolean = _pressedAbility.isFinishedSelecting();
			if (done)
				_pressedAbility = null;
			return done;
		}
		
		public function fireAbility(index:uint):void
		{
			if (index > 0 && index < _abilities.members.length + 1) {
				fireButton(_abilities.members[index - 1]);
			}
		}
		
		private function fireButton(button:Ability):void
		{
			if (!button.inCooldown && button.Enabled && !TimesUp) {
				_errorMessage.hide();
				_levelInfo.hide();
				_pressedAbility = button;
				button.click();
				if (Stats.NeedsTutorial && _tutorial.Index == 1)
					_tutorial.nextStep();
			}
		}
		
		private function formatTime(time:Number):String
		{
			var minutes:uint = (Math.round(time) / 60);
			var seconds:uint = (Math.round(time) % 60);
			
			return ((minutes < 10) ? "0" + minutes : minutes.toString()) + ":" + ((seconds < 10) ? "0" + seconds : seconds.toString());
		}
		
		private function getButton(name:String, x:uint):FlxButton
		{
			switch (name) {
				case ("haunt"): return new Haunt(x, 222, function():void { fireButton(this); } );
				case ("scare"): return new Scare(x, 222, function():void { fireButton(this); } );
				case ("possess"): return new Possess(x, 222, function():void { fireButton(this); } );
				case ("ectoplasm"): return new Ectoplasm(x, 222, function():void { fireButton(this); } );
				case ("demon"): return new Demon(x, 222, function():void { fireButton(this); } );
				case ("deathsclutch"): return new DeathsClutch(x, 222, function():void { fireButton(this); } );
				case ("sealdoor"): return new SealDoor(x, 222, function():void { fireButton(this); } );
				case ("onryo"): return new Onryo(x, 222, function():void { fireButton(this); } );
			}
			return null;
		}
		
		public function incrementScared():void
		{
			_currentScared++;
			_goalText.text = _currentScared.toString() + " / " + _goalScared.toString();
		}
		
		public function wasGoalMet():Boolean
		{
			return (_currentScared >= _goalScared);
		}
		
		public function isEveryoneScared():Boolean
		{
			return (_currentScared >= _goalScared && _currentScared == _guests.members.length);
		}
		
		public function restart():void
		{
			_currentScared = 0;
			_timeLeft = _timeLimit;
			_playedWarning = true;
			_isRunning = false;
			_timesUp = false;
			_pressedAbility = null;
			
			_goalText.text = "0 / " + _goalScared;
			_goButtonSprite.play("up");
			
			/** Clear out the guests **/
			_guests.destroy();
			remove(_guests);
			_guests = new FlxGroup();
			add(_guests);
			
			/** Reset the entrances **/
			for each (var ent:Entrance in _entrances.members)
				ent.restart();
				
			for each (var ability:Ability in _abilities.members)
				ability.restart();
		}
		
		private function returnToMenu():void
		{
			Assets.InitialStartUp = false;
			if (FlxG.music != null)
				FlxG.music.stop();
			FlxG.state = new MenuState();
		}
		
		public function printLevel():void
		{
			var line:String = "";
			for (var i:uint = 0; i < _walkingGrid.length; i++) {
				for (var k:uint = 0; k < _walkingGrid[i].length; k++) {
					if (_walkingGrid[i][k] == 1)
						line += "0";
					else
						line += " ";
				}
				FlxG.log(line);
				line = "";
			}
		}
		
		override public function render():void
		{
			_floor.render();
			_selectionSquares.render();
			_aboveFloorElements.render();
			_nonFloor.render();
			if (_wallsGuestsAndMinions != null) {
				_wallsGuestsAndMinions.render();
			}
			_timerFrame.render();
			_timerClockGraphic.render();
			_wallTops.render();
			_menuButton.render();
			_timerText.render();
			_goalText.render();
			_hotbar.render();
			if (_abilityHighlight.visible)
				_abilityHighlight.render();
			_goButton.render();
			if (_tutorial.visible)
				_tutorial.render();
			if (_errorMessage.visible)
				_errorMessage.render();
			if (_levelInfo.visible)
				_levelInfo.render();
			_abilities.render();
			for each (var ability:Ability in _abilities.members) {
				if (ability.inventoryText != null) {
					ability.inventoryText.render();
				}
			}
			if (_notReadyTextBox.visible)
				_notReadyTextBox.render();
		}
		
		override public function destroy():void
		{
			destroyMembers();
		}
		
		private function getAbilityName(ability:Ability):String
		{
			if (ability is DeathsClutch) return "Death's Cluth";
			if (ability is Demon) return "Demon";			
			if (ability is Ectoplasm) return "Ectoplasm";
			if (ability is Haunt) return "Haunt";
			if (ability is Onryo) return "Onryo";
			if (ability is Possess) return "Possess";
			if (ability is SealDoor) return "Seal Door";
			if (ability is Scare) return "Scare";
			
			return "";
		}
		
		public function showErrorMessage(text:String):void
		{
			_errorMessage.show(text);
		}
		
		private function hideErrorMessage():void
		{
			_errorMessage.hide();
		}
		
		public function isValidSquare(x:Number, y:Number):Boolean
		{
			var valid:Boolean = false;
			var obj:FlxObject = new FlxObject(x, y, FloorElement.TILE_WIDTH, FloorElement.TILE_HEIGHT);
			FlxU.overlap(obj, _selectionSquares, function():void {
				valid = true;
			});
			
			return valid;
		}
	}

}
