package com.polymath.halloween 
{
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	
	public class Tutorial extends FlxGroup
	{
		[Embed(source = "../../../../data/gfx/arrow.png")] private var ImgArrow:Class;
		
		private var _tutorialHeader:FlxText;
		private var _bg:FlxSprite;
		private var _arrow:FlxSprite;
		private var _text:FlxText;
		
		private var _step:Array = ["Living people are holding a party in the old estate that you still haunt. It is up to you to scare them off.",
									"You have a number of abilities at your disposal to help you do so. Begin by clicking your haunt ability, and place a ghost in any room.",
									"",
									"Once you start the level, your ghost will be stuck in the room you placed him. He'll only be able to scare people in that room.",
									"But you also have a number of abilities during play that you can use to frighten off the intruders, such as your Scare ability.",
									"You can also select any of the abilities with your number keys, 1 - 6. It's quicker than using the mouse!",
									"You'll unlock more powers as the game progresses. Make sure to read each power's description so that you understand how it works!",
									"Hit the go button when you're ready. See if you can scare off every single flesh bag in the area!"];
		
		public function get Index():uint
		{
			return _index;
		}
		private var _index:uint;
		
		private var _nextButton:FlxButton;
		private var _skipButton:FlxButton;
		private var _arrowGoingDown:Boolean;
		
		public function Tutorial() 
		{
			super();
			_bg = new FlxSprite(0, 0);
			_bg.alpha = 0.75;
			
			_arrow = new FlxSprite(0, 0, ImgArrow);
			_arrow.visible = false;
			
			_tutorialHeader = new FlxText(0, 5, 200, "Tutorial").setFormat(null, 8, 0xFFFFFFFF, "center", 0xFF000000);
			
			_text = new FlxText(5, 5 + _tutorialHeader.height + 5, 200, _step[0]).setFormat(null, 8, 0xFFFFFFFF, "left", 0xFF000000);
			_index = 0;
			
			_nextButton = new FlxButton(140, _tutorialHeader.height + 5 + _text.height + 5, nextStep);
			_nextButton.loadText(new FlxText(0, 0, 30, "Next").setFormat(null, 8, 0xFFA5A5A5, "center", 0xFF000000), new FlxText(0, 0, 30, "Next").setFormat(null, 8, 0xFFFFFFFF, "center", 0xFF000000));
			_nextButton.loadGraphic(new FlxSprite(0, 0).createGraphic(30, 12, 0xFF555555));
			
			_skipButton = new FlxButton(175, _tutorialHeader.height + 5 + _text.height + 5, skip);
			_skipButton.loadText(new FlxText(0, 0, 30, "Skip").setFormat(null, 8, 0xFFA5A5A5, "center", 0xFF000000), new FlxText(0, 0, 30, "Skip").setFormat(null, 8, 0xFFFFFFFF, "center", 0xFF000000));
			_skipButton.loadGraphic(new FlxSprite(0, 0).createGraphic(30, 12, 0xFF555555));
			
			_bg.createGraphic(210, _text.bottom + 5 + _nextButton.height + 5, 0xFF555555);
			
			_arrowGoingDown = true;
			
			add(_bg);
			add(_tutorialHeader);
			add(_text);
			add(_nextButton);
			add(_skipButton);
			add(_arrow);
			
			reset( (FlxG.width >> 1) - (_bg.width >> 1), (FlxG.height >> 1) - (_bg.height >> 1));
			_nextButton.active = false;
			visible = false;
		}
		
		public function nextStep():void
		{
			_index++;
			if (_index >= _step.length) {
				visible = false;
				_nextButton.active = false;
				Stats.NeedsTutorial = false;
				return;
			}
				
			_text.text = _step[_index];
			
			if (_index == 1) {
				_arrow.visible = true;
				_arrow.x = 59 - _arrow.width / 2;
				_arrow.y = 206;
				_nextButton.visible = false;
				_nextButton.active = false;
			}
			
			if (_index == 2) {
				visible = false;
			}
			
			if (_index == 3) {
				_arrow.visible = false;
				visible = true;
				_nextButton.visible = true;
				_nextButton.active = true;
			}
				
			if (_index == 4) {
				_arrow.visible = true;
				_arrow.x += 35;
			}
			
			if (_index == 5)
				_arrow.visible = false;
			
			if (_index == 7) {
				_nextButton.active = false;
				_nextButton.visible = false;
				_arrow.visible = true;
				_arrow.x = 260;
			}
			
			_nextButton.reset(_nextButton.x, _text.bottom + 5);
			_skipButton.reset(_skipButton.x, _text.bottom + 5);
			_bg.createGraphic(210, 5 + _tutorialHeader.height + 5 + _text.height + 5 + _nextButton.height + 5, 0xFF555555);
			reset( (FlxG.width >> 1) - (_bg.width >> 1), (FlxG.height >> 1) - (_bg.height >> 1));
		}
		
		override public function update():void
		{
			if (_arrowGoingDown) {
				_arrow.velocity.y = 10;
				if (_arrow.top > 206)
					_arrowGoingDown = false;
			} else {
				_arrow.velocity.y = -10;
				if (_arrow.top < 200)
					_arrowGoingDown = true;
			}
			
			if (visible) {
				if (_index != 1) 
					_nextButton.active = true;
			}
			
			super.update();
		}
		
		public function skip():void
		{
			visible = false;
			_nextButton.active = false;
			Stats.NeedsTutorial = false;
			return;
		}
	}

}