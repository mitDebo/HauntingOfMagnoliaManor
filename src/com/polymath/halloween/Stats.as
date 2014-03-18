package com.polymath.halloween 
{
	import org.flixel.FlxG;
	import org.flixel.FlxSave;
	
	public class Stats 
	{
		private static var _levelsCompleted:uint = 0;
		private static var _levelsMastered:Array = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
		private static var _needsTutorial:Boolean = true;
		
		private static var _loaded:Boolean = false;
		private static var _save:FlxSave;
	
		/** Levels completed **/
		public static function get LevelsComplete():uint
		{
			if (_loaded)
				return _save.data.levelsComplete;
			return _levelsCompleted;
		}
		public static function set LevelsComplete(num:uint):void
		{
			if (_loaded)
				_save.data.levelsComplete = num;
			else
				_levelsCompleted = num;
		}
		
		/** Levels mastered **/
		public static function get LevelsMastered():Array
		{
			if (_loaded)
				return _save.data.levelsMastered;
			return _levelsMastered;
		}
		
		public static function set LevelsMastered(ar:Array):void
		{
			if (_loaded)
				_save.data.levelsMastered = ar;
			else
				_levelsMastered = ar;
		}
		
		/** Needs tutorial **/
		public static function get NeedsTutorial():Boolean
		{
			if (_loaded)
				return _save.data.needsTutorial;
			return _needsTutorial;
		}
		
		public static function set NeedsTutorial(nt:Boolean):void
		{
			if (_loaded)
				_save.data.needsTutorial = nt;
			else
				_needsTutorial = nt;
		}
		
		public static function load():void
		{
			_save = new FlxSave();
			_loaded = _save.bind("statData");
			if (_loaded) {
				if (_save.data.levelsComplete == null)
					_save.data.levelsComplete = 0;
				if (_save.data.levelsMastered == null)
					_save.data.levelsMastered = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
				if (_save.data.needsTutorial == null)
					_save.data.needsTutorial = true;
			}
		}
		
		public static function clearData():void
		{
			_loaded = !_save.erase();
		}
	}

}