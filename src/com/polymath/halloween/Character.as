package com.polymath.halloween 
{
	import flash.display.Shape;
	import flash.geom.Point;
	import org.flixel.data.FlxAnim;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	
	public class Character extends FlxSprite 
	{
		[Embed(source = "../../../../data/gfx/male1.png")] protected var ImgMale1:Class;
		[Embed(source = "../../../../data/gfx/male2.png")] protected var ImgMale2:Class;
		[Embed(source = "../../../../data/gfx/female1.png")] protected var ImgFemale1:Class;
		
		public static const NORTH:uint = 0;
		public static const WEST:uint = 1;
		public static const SOUTH:uint = 2;
		public static const EAST:uint = 3;
		
		public static const MALE1:uint = 0;
		public static const MALE2:uint = 1;
		public static const FEMALE1:uint = 2;
		public var Model:uint;
		
		private var _indexX:uint;
		private var _indexY:uint;
		private var _level:Level;	// The level this character is in
		
		private var _direciton:uint;
		private var _isStopped:Boolean;
		private var _isScared:Boolean;
		private var _isFleeing:Boolean;
		private var _isTagged:Boolean;
		
		private var _goalNode:Node;
		private var _onGoalNode:Boolean;
		private var _path:Array;
		
		private var _isFadedIn:Boolean;
		
		private var _walkingSpeed:Number;
		private var _tempWalkingSpeed:Number;
		private var _tempWalkingSpeedMaxTime:Number;
		private var _tempWalkingSpeedTimer:Number;
		
		public function get IsScared():Boolean
		{
			return _isScared;
		}
		
		public function get IsFleeing():Boolean
		{
			return _isFleeing;
		}
		
		public function get IsTagged():Boolean
		{
			return _isTagged;
		}
		
		public function set IsTagged(tag:Boolean):void
		{
			_isTagged = tag;
		}
		
		public function get Direction():uint
		{
			return _direciton;
		}
		
		public function set Level(level:Level):void
		{
			_level = level;
		}
		
		public function set WalkingSpeed(speed:Number):void
		{
			_walkingSpeed = speed;
			_tempWalkingSpeed = _walkingSpeed;
			if (_goalNode != null) {
				var dir:Number = Math.atan2(_goalNode.y - _indexY, _goalNode.x - _indexX);
				velocity.x = Math.cos(dir) * _walkingSpeed;
				velocity.y = Math.sin(dir) * _walkingSpeed;
			}
		}
		
		public function Character(X:uint, Y:uint, L:Level) 
		{
			super();
			_indexX = X;
			_indexY = Y;
			_level = L;
			
			Model = Math.floor(Math.random() * 3);
			
			_onGoalNode = false;
			_goalNode = getNeighboringValidSquare(_indexX, _indexY);
			_path = new Array();
			_isScared = false;
			_isStopped = false;
			_isTagged = false;
			
			x = _indexX * FloorElement.TILE_WIDTH;
			y = (_indexY - 1) * FloorElement.TILE_HEIGHT;
			
			var Img:Class;
			if (Model == MALE1)
				Img = ImgMale1;
			if (Model == MALE2)
				Img = ImgMale2;
			if (Model == FEMALE1)
				Img = ImgFemale1;
			
			loadGraphic(Img, true, false, 16, 16);
			addAnimation("idle_north", [4]);
			addAnimation("idle_south", [0]);
			addAnimation("idle_east", [2]);
			addAnimation("idle_west", [6]);
			addAnimation("walk_south", [0, 1], 3);
			addAnimation("walk_east", [2, 3], 3);
			addAnimation("walk_north", [4, 5], 3);
			addAnimation("walk_west", [6, 7], 3);
			addAnimation("flee_south", [0, 1], 6);
			addAnimation("flee_east", [2, 3], 6);
			addAnimation("flee_north", [4, 5], 6);
			addAnimation("flee_west", [6, 7], 6);
			addAnimation("scared", [8, 0, 8, 0, 8, 0, 8, 0, 8, 0], 7, false);
			
			_isFadedIn = false;
		}
		
		override public function update():void
		{
			if (alpha < 1 && !_isFadedIn)
				alpha += FlxG.elapsed;
			if (alpha >= 1 && !_isFadedIn)
				_isFadedIn = true;
			
			if (!_onGoalNode && (!_isScared || _isFleeing)) {
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
			
			if (_onGoalNode && (!_isScared || _isFleeing)) {
				// We've found our destination gridsquare
				if (_path.length == 0) {
					if (!_isFleeing)
						_path = findPathToNextDestination();
					else {
						kill();
					}
				}
				
				_goalNode = _path.shift() as Node;
				_onGoalNode = false;
			}
			
			if (_tempWalkingSpeedTimer < _tempWalkingSpeedMaxTime) {
				_tempWalkingSpeedTimer += FlxG.elapsed;
				if (_tempWalkingSpeedTimer > _tempWalkingSpeedMaxTime)
					_tempWalkingSpeed = _walkingSpeed;
			}
			
			if (!_isScared || (_isFleeing && _goalNode != null)) {
				var dir:Number = Math.atan2(_goalNode.y - _indexY, _goalNode.x - _indexX);
				velocity.x = Math.cos(dir) * _tempWalkingSpeed;
				velocity.y = Math.sin(dir) * _tempWalkingSpeed;
			}
			
			if (_isStopped) {
				velocity.x = 0;
				velocity.y = 0;
			}
			
			if (Math.abs(velocity.y) < Math.abs(velocity.x)) {
				if (velocity.x < 0)
					_direciton = WEST;
				if (velocity.x > 0)
					_direciton = EAST;
			} else {
				if (velocity.y > 0)
					_direciton = SOUTH;
				if (velocity.y < 0)
					_direciton = NORTH;
			}
			
			if ( (!_isScared || _isFleeing) && !_isStopped) {
				if (_isFleeing) {
					if (_direciton == NORTH)
						play("flee_north");
					else if (_direciton == WEST)
						play("flee_west");
					else if (_direciton == SOUTH)
						play("flee_south");
					else if (_direciton == EAST)
						play("flee_east");
				} else {
					if (_direciton == NORTH)
						play("walk_north");
					else if (_direciton == WEST)
						play("walk_west");
					else if (_direciton == SOUTH)
						play("walk_south");
					else if (_direciton == EAST)
						play("walk_east");
				}
			} else if (_isStopped) {
				if (_direciton == NORTH)
					play("idle_north");
				else if (_direciton == WEST)
					play("idle_west");
				else if (_direciton == SOUTH)
					play("idle_south");
				else if (_direciton == EAST)
					play("idle_east");
			} else {
				if (!finished && !_isFleeing) {
					play("scared");
				} else if (!_isFleeing) {
					flee();
				}
			}
			
			super.update();
		}
		
		private function getNeighboringValidSquare(x:uint, y:uint):Node
		{
			if (_level.isValidSpace(x - 1, y))
				return new Node(x - 1, y);
			if (_level.isValidSpace(x + 1, y))
				return new Node(x + 1, y);
			if (_level.isValidSpace(x, y - 1))
				return new Node(x, y - 1);
			if (_level.isValidSpace(x, y + 1))
				return new Node(x, y + 1);
			
			FlxG.log("Couldn't find a valid square");
			return null;
		}
		
		private function findPathToNextDestination():Array
		{
			var destNode:Node = selectDestinationNode();
			return PathFinder.determinePath(new Node(_indexX, _indexY), destNode);
		}
		
		private function selectDestinationNode():Node
		{
			var room:FlxObject = _level.getRandomRoom(true);
			var xIndex:uint = Math.random() * Math.floor( (room.width - FloorElement.TILE_WIDTH) / FloorElement.TILE_WIDTH);
			var yIndex:uint = Math.random() * Math.floor(room.height / FloorElement.TILE_HEIGHT);
			
			return new Node( (room.x / FloorElement.TILE_WIDTH) + xIndex, (room.y / FloorElement.TILE_HEIGHT) + yIndex);
		}
		
		public function slow(Amount:Number, Duration:Number):void
		{
			_tempWalkingSpeed = _walkingSpeed * Amount;
			_tempWalkingSpeedMaxTime = Duration;
			_tempWalkingSpeedTimer = 0;
		}
		
		public function scare():void
		{
			if (!_isScared && !_level.TimesUp) {
				_isScared = true;
				finished = false;
				velocity.x = 0;
				velocity.y = 0;
				_level.incrementScared();
				_isStopped = false;
				
				var maleOrFemale:String;
				if (Model == MALE1 || Model == MALE2)
					maleOrFemale = "male";
				else
					maleOrFemale = "female";
				
				var scream:String = maleOrFemale + "_scream" + (1 + Math.floor(Math.random() * 3)).toString();
				FlxG.play(Assets.getResource(scream));
			}
		}
		
		public function stop():void
		{
			velocity.x = 0;
			velocity.y = 0;
			_isStopped = true;
		}
		
		private function flee():void
		{
			_isFleeing = true;
			var nearestEntrance:FlxObject;
			var nearestDistance:Number = NaN;
			var currentDistance:Number = NaN;
			for each (var ent:Entrance in _level.Entrances.members) {
				currentDistance = Point.distance(new Point(x, y), new Point(ent.x, ent.y));
				if (isNaN(nearestDistance) || currentDistance < nearestDistance) {
					nearestDistance = currentDistance;
					nearestEntrance = ent;
				}
			}
			
			WalkingSpeed = 75;
			var newXIndex:uint = Math.round(this.x / FloorElement.TILE_WIDTH);
			var newYIndex:uint = Math.round( (y + (height >> 1)) / FloorElement.TILE_HEIGHT);
			_path = PathFinder.determinePath(new Node(newXIndex, newYIndex), getNeighboringValidSquare(Math.floor(nearestEntrance.x / FloorElement.TILE_WIDTH), Math.floor(nearestEntrance.y / FloorElement.TILE_HEIGHT)));
			_goalNode = _path.shift() as Node;
			_onGoalNode = false;
		}
	}
}
