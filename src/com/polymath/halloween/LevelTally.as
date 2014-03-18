package com.polymath.halloween 
{
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSave;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	
	public class LevelTally extends FlxGroup 
	{
		[Embed(source = "../../../../data/gfx/total_intruders_scared_away.png")] private var ImgTotalScared:Class;
		[Embed(source = "../../../../data/gfx/full_scare_award.png")] private var ImgFullScareAward:Class;
		[Embed(source = "../../../../data/gfx/full_scare_skull.png")] private var ImgFullScareSkull:Class;
		[Embed(source = "../../../../data/gfx/skull_shadow.png")] private var ImgSkullShadow:Class;
		
		[Embed(source = "../../../../data/gfx/male1.png")] private var ImgMale1:Class;
		[Embed(source = "../../../../data/gfx/male2.png")] private var ImgMale2:Class;
		[Embed(source = "../../../../data/gfx/female1.png")] private var ImgFemale1:Class;
				
		private var _scaredGuests:FlxGroup;
		
		private var _timer:Number = 0;
		private var _timeMax:Number = 0.1;
		private var _on:Boolean;
		private var _doneDrawingScaredGuests:Boolean;
		private var _index:uint;
		private var _allScared:Boolean;
		
		private var _fullScaredBanner:FlxSprite;
		private var _skull:FlxSprite;
		private var _skulShadow:FlxSprite;
		
		public function LevelTally() 
		{
			super();
			
			var totalScared:FlxSprite = new FlxSprite(0, 0, ImgTotalScared);
			_fullScaredBanner = new FlxSprite(0, 75, ImgFullScareAward);
			_fullScaredBanner.visible = false;
			
			_skull = new FlxSprite(150, 70);
			_skull.loadGraphic(ImgFullScareSkull, false, false, 32, 32);
			_skull.visible = false;
			_skull.scale = new FlxPoint(2, 2);
			
			_skulShadow = new FlxSprite(150, 70, ImgSkullShadow);
			_skulShadow.visible = false;
			
			_allScared = false;
			_on = false;
			_doneDrawingScaredGuests = false;
			_scaredGuests = new FlxGroup();
			
			add(totalScared);
			add(_fullScaredBanner);
			add(_skulShadow);
			add(_scaredGuests);
			add(_skull);
		}
		
		public function start(guests:FlxGroup, allScared:Boolean):void {
			if (!_on && !_doneDrawingScaredGuests) {
				if (Stats.LevelsComplete < FlxG.level)
					Stats.LevelsComplete = FlxG.level;
				if (allScared)
					Stats.LevelsMastered[FlxG.level] = 1;
				
				_allScared = allScared;
				populateScaredGuests(guests);
				arrangeGuests();
				_index = 0;
				_on = true;
				
				if (_index >= _scaredGuests.members.length) {
					_on = false;
					_doneDrawingScaredGuests = true;
				}
			}
		}
		
		override public function update():void
		{
			for (var i:uint = 0; i < _scaredGuests.members.length; i++) {
				var g:FlxSprite = _scaredGuests.members[i] as FlxSprite;
				if (g.visible) {
					if (g.scale.x > 1) {
						g.scale.x -= FlxG.elapsed * 2;
						if (g.scale.x < 1)
							g.scale.x = 1;
					}
					if (g.scale.y > 1) {
						g.scale.y -= FlxG.elapsed * 2;
						if (g.scale.y < 1)
							g.scale.y = 1;
					}
				}
			}
			
			if (_on) {
				_timer += FlxG.elapsed;
				
				if (!_doneDrawingScaredGuests) {
					if (_timer >= _timeMax) {
						(_scaredGuests.members[_index] as FlxSprite).visible = true;
						FlxG.play(Assets.getResource("coin"));
						_index++;
						_timer -= _timeMax;
					
						if (_index >= _scaredGuests.members.length) {
							_doneDrawingScaredGuests = true;
						}
					}
				}
				
				if (_doneDrawingScaredGuests && _timer > 0.5) {
					_fullScaredBanner.visible = true;
					_skulShadow.visible = true;
					
					if (_timer > 1 && _allScared) {
						_skull.visible = true;
					
						if (_skull.scale.x > 1) {
							_skull.scale.x -= FlxG.elapsed * 3;
						}
						if (_skull.scale.y > 1) {
							_skull.scale.y -= FlxG.elapsed * 3;
						}
					
						if (_skull.scale.y < 1 && _skull.scale.x < 1) {
							_skull.scale.x = 1;
							_skull.scale.y = 1;
							_on = false;
							FlxG.quake.start();
							FlxG.play(Assets.getResource("all_scared"));
						}
					}
						
				}
			}
			
			super.update();
		}
		
		private function populateScaredGuests(guests:FlxGroup):void
		{
			for each (var g:Character in guests.members) {
				if (g.IsScared) {
					var Img:Class;
					if (g.Model == Character.MALE1)
						Img = ImgMale1;
					if (g.Model == Character.MALE2)
						Img = ImgMale2;
					if (g.Model == Character.FEMALE1)
						Img = ImgFemale1;
					_scaredGuests.add(new FlxSprite().loadGraphic(Img, false, false, 16, 16));
				}
			}
			
		}
		
		private function arrangeGuests():void
		{
			var columnIndex:uint = 0;
			var rowIndex:uint = 0;
			var total:uint = 0;
			
			for each (var g:FlxSprite in _scaredGuests.members) {
				g.visible = false;				
				g.x = this.x + columnIndex * 17;
				g.y = 20 + this.y + rowIndex * 12;
				g.scale = new FlxPoint(2.0, 2.0);
				
				columnIndex++;
				if (columnIndex > 14) {
					columnIndex = 0;
					rowIndex++;
				}
				total++;				
			}
		}
	}

}