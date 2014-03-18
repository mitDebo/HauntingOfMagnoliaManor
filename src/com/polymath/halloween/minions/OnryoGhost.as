package com.polymath.halloween.minions 
{
	import com.polymath.halloween.Character;
	import flash.geom.Point;
	import org.flixel.FlxG;
	import org.flixel.FlxObject;
	import org.flixel.FlxU;
	
	import com.polymath.halloween.FloorElement;
	import com.polymath.halloween.Node;
	import com.polymath.halloween.PathFinder;
	
	public class OnryoGhost extends Minion 
	{
		[Embed(source = "../../../../../data/gfx/onryo_ghost.png")] private var ImgOnryo:Class;
		
		private const WANDER:uint = 0;
		private const RUNNING_TO_SCARE:uint = 1;
		private const SCARE:uint = 2;
		private const MOVING_TO_NEW_ROOM:uint = 3;
		
		private var _room:FlxObject;
		private var _path:Array;
		private var _indexX:uint;
		private var _indexY:uint;
		
		private var _wanderSpeed:Number;
		private var _scareSpeed:Number;
		private var _roomTransferSpeed:Number;
		
		private var _mode:uint;
		private var _goalNode:Node;
		private var _onGoalNode:Boolean;
		
		private var _guestToScare:Character;
		
		private var _timer:Number;
		private var _cooldownMax:Number;
		
		public function set Cooldown(c:Number):void
		{
			_cooldownMax = c;
		}
	
		public function OnryoGhost(X:Number, Y:Number, room:FlxObject) 
		{
			super(X * FloorElement.TILE_WIDTH, (Y - 1) * FloorElement.TILE_HEIGHT);
			loadGraphic(ImgOnryo, true, false, 16, 16);
			alpha = 0.7;
			
			_indexX = X;
			_indexY = Y;
			
			_timer = 0;
			_guestToScare = null;
			
			_wanderSpeed = 10;
			_roomTransferSpeed = 45;
			_scareSpeed = 100;
			
			_room = room;
			_path = PathFinder.determinePath(new Node(_indexX, _indexY), getRandomNodeInRoom());
			_onGoalNode = true;
			
			_mode = WANDER;
			
			addAnimation("wander_south", [0, 1], 3);
			addAnimation("wander_east", [2, 3], 3);
			addAnimation("wander_north", [4, 5], 3);
			addAnimation("wander_west", [6, 7], 3);
			addAnimation("run_south", [0, 1], 6);
			addAnimation("run_east", [2, 3], 6);
			addAnimation("run_north", [4, 5], 6);
			addAnimation("run_west", [6, 7], 3);
			addAnimation("scare_south", [0, 8, 0, 8, 0, 8, 0, 8, 0, 8], 7, false);
			addAnimation("scare_north", [4, 9, 4, 9, 4, 9, 4, 9, 4, 9], 7, false);
			addAnimation("scare_west", [6, 10, 6, 10, 6, 10, 6, 10, 6, 10], 7, false);
			addAnimation("scare_east", [3, 11, 3, 11, 3, 11, 3, 11, 3, 11], 7, false);
		}
		
		public function set TransferSpeed(speed:Number):void
		{
			_roomTransferSpeed = speed;
		}
		
		override public function update():void
		{
			if (_timer >= 0) {
				_timer -= FlxG.elapsed;
			}
			
			if (_mode == SCARE) {
				if (_guestToScare != null) {
					_guestToScare.scare();
					_guestToScare = null;
				}
				if (finished)
					_mode = WANDER;
			}
			
			if (_mode == WANDER && _alpha > 0.7) {
				_alpha -= FlxG.elapsed;
				if (_alpha <= 0.7)
					_alpha = 0.7;
			}
			
			if (_mode == RUNNING_TO_SCARE && _alpha < 1) {
				_alpha += FlxG.elapsed;
				if (_alpha >= 1)
					_alpha = 1;
			}
			
			if (_mode == RUNNING_TO_SCARE) {
				if (_path.length <= 1) {
					_mode = SCARE;
					var dirX:Number = _guestToScare.x - this.x;
					var dirY:Number = _guestToScare.y - this.y;
					if (Math.abs(dirY) < Math.abs(dirX)) {
						if (dirX > 0)
							play("scare_east");
						if (dirX < 0)
							play("scare_west");
					} else {
						if (dirY > 0)
							play("scare_south");
						if (dirY < 0)
							play("scare_north");
					}
					_path.shift();
					_onGoalNode = true;
				}
			}
			
			if (!_onGoalNode) {
				var goalPoint:Point = new Point(_goalNode.x * FloorElement.TILE_WIDTH, _goalNode.y * FloorElement.TILE_HEIGHT);
				var currentPoint:Point = new Point(x, y + FloorElement.TILE_HEIGHT);
				var nextPoint:Point = new Point(x + velocity.x * FlxG.elapsed, (y + FloorElement.TILE_HEIGHT) + velocity.y * FlxG.elapsed);
				
				var curDistance:Number = Point.distance(goalPoint, currentPoint);
				var nextDistance:Number = Point.distance(goalPoint, nextPoint);
				if (curDistance < nextDistance) {
					_onGoalNode = true;
					_indexX = _goalNode.x;
					_indexY = _goalNode.y;
					
					x = _indexX * FloorElement.TILE_WIDTH;
					y = (_indexY - 1) * FloorElement.TILE_HEIGHT;
				}
			}
			
			if (_onGoalNode && _mode != SCARE) {
				if (_mode == MOVING_TO_NEW_ROOM) {
					if (overlaps(_room))
						_mode = WANDER;
				}
				
				if (_path.length == 0) {
					_path = PathFinder.determinePath(new Node(_indexX, _indexY), getRandomNodeInRoom());
				}
				_goalNode = _path.shift() as Node;
				_onGoalNode = false;
			}
			
			var _movingSpeed:Number;
			switch (_mode) {
				case (WANDER): _movingSpeed = _wanderSpeed; break;
				case (MOVING_TO_NEW_ROOM): _movingSpeed = _roomTransferSpeed; break;
				case (RUNNING_TO_SCARE): _movingSpeed = _scareSpeed; break;
			}
			
			if (_mode != SCARE) {
				var dir:Number = Math.atan2(_goalNode.y - _indexY, _goalNode.x - _indexX);
				velocity.x = Math.cos(dir) * _movingSpeed;
				velocity.y = Math.sin(dir) * _movingSpeed;
			} else {
				velocity.x = 0;
				velocity.y = 0;
			}
			
			if (_mode == WANDER) {
				if (Math.abs(velocity.y) < Math.abs(velocity.x)) {
					if (velocity.x > 0)
						play("wander_east");
					if (velocity.x < 0)
						play("wander_west");
				} else {
					if (velocity.y < 0)
						play("wander_north");
					if (velocity.y > 0)
						play("wander_south");
				}
			} else if (_mode != SCARE) {
				if (Math.abs(velocity.y) < Math.abs(velocity.x)) {
					if (velocity.x > 0)
						play("run_east");
					if (velocity.x < 0)
						play("run_west");
				} else {
					if (velocity.y < 0)
						play("run_north");
					if (velocity.y > 0)
						play("run_south");
				}
			}
			
			
			super.update();
		}
		
		private function beginCooldown():void
		{
			_timer = _cooldownMax;
		}
		
		public function ready():Boolean
		{
			return (_timer <= 0 && _mode == WANDER);
		}
		
		public function haunt():void
		{
			_guestToScare = state.CurrentLevel.getRandomGuestInRoom(_room);
			if (_guestToScare != null) {
				// First, let's see if there's a path to this guy - if not, we ignore him (for now!)
				var tempPath:Array = findPathToFrontOfGuest();
				if (tempPath != null) {
					// We got you, bastard!
					_mode = RUNNING_TO_SCARE;
					_guestToScare.IsTagged = true;
					_guestToScare.stop();
					
					_path = tempPath;
					_goalNode = _path.shift() as Node;
					_onGoalNode = false;
					
					beginCooldown();
				}				
			}
			
		}
		
		public function moveToNewRoom(obj:FlxObject):void
		{
			if (_mode == WANDER) {
				_room = obj;
			
				var newXIndex:uint = Math.round(this.x / FloorElement.TILE_WIDTH);
				var newYIndex:uint = Math.round( (y + (height >> 1)) / FloorElement.TILE_HEIGHT);
			
				_path = PathFinder.determinePath(new Node(newXIndex, newYIndex), getRandomNodeInRoom());
				_goalNode = _path.shift() as Node;
				_onGoalNode = false;
				_mode = MOVING_TO_NEW_ROOM;
			}
		}
		
		private function getRandomNodeInRoom():Node
		{
			var randX:uint = Math.floor((_room.x / FloorElement.TILE_WIDTH)) + Math.floor(Math.random() * ( (_room.width - FloorElement.TILE_WIDTH) / FloorElement.TILE_WIDTH));
			var randY:uint = Math.floor((_room.y / FloorElement.TILE_HEIGHT)) + Math.floor(Math.random() * (_room.height / FloorElement.TILE_HEIGHT));
			return new Node(randX, randY);
		}
		
		private function guestIsInNeighboringSquare():Boolean
		{
			return ( (_guestToScare.x == x && (bottom - 8 >= _guestToScare.top || top <= _guestToScare.bottom - 8)) ||
						(_guestToScare.y == y && (right >= _guestToScare.left || left <= _guestToScare.right)));
		}
		
		private function findPathToFrontOfGuest():Array
		{
			var guestX:uint = _guestToScare.left;
			var guestY:uint = _guestToScare.top + (_guestToScare.height >> 1);
			
			var newXIndex:uint = Math.round(this.x / FloorElement.TILE_WIDTH);
			var newYIndex:uint = Math.round( (y + (height >> 1)) / FloorElement.TILE_HEIGHT);
			var guestXIndex:uint = Math.floor(guestX / FloorElement.TILE_WIDTH);
			var guestYIndex:uint = Math.floor(guestY / FloorElement.TILE_HEIGHT);
			
			
			return PathFinder.determinePath(new Node(newXIndex, newYIndex), new Node(guestXIndex, guestYIndex));
		}
	}

}