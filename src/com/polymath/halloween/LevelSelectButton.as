package com.polymath.halloween 
{
	import org.flixel.FlxButton;
	import org.flixel.FlxText;
	import org.flixel.FlxSprite;
	
	public class LevelSelectButton extends FlxButton 
	{
		[Embed(source = "../../../../data/gfx/level_select_button.png")] private var ImgButton:Class;
		[Embed(source = "../../../../data/gfx/level_select_button_hover.png")] private var ImgButtonHover:Class;
		public function get Level():uint
		{
			return _level;
		}
		private var _level:uint;
		
		public function get Maxed():Boolean
		{
			return _isMaxed;
		}
		public function set Maxed(max:Boolean):void
		{
			_isMaxed = max;
		}
		private var _isMaxed:Boolean;
		
		private var _levelText:FlxText;
		private var _buttonImg:FlxSprite;
		private var _buttonImgHover:FlxSprite;
		
		public function LevelSelectButton(X:uint, Y:uint, LevelNumber:uint, Callback:Function) 
		{
			super(X, Y, Callback);
			_level = LevelNumber
				
			_isMaxed = false;
			_levelText = new FlxText(3, 3, 20, _level.toString()).setFormat(null, 8, 0xFFA5A5A5, "left", 0xFF000000);
			loadText(_levelText);
			
			_buttonImg = new FlxSprite(0, 0);
			_buttonImg.loadGraphic(ImgButton, true, false, 24, 24);
			_buttonImg.addAnimation("regular", [0]);
			_buttonImg.addAnimation("maxed", [1]);
			
			_buttonImgHover = new FlxSprite(0, 0);
			_buttonImgHover.loadGraphic(ImgButtonHover, true, false, 24, 24);
			_buttonImgHover.addAnimation("regular", [0]);
			_buttonImgHover.addAnimation("maxed", [1]);
			
			loadGraphic(_buttonImg, _buttonImgHover);
		}
		
		override public function update():void
		{
			if (visible && _level <= Stats.LevelsComplete + 1) {
				active = true;
				_levelText.color = 0xFFFFFFFF;
			} else {
				active = false;
			}
			
			if (Stats.LevelsMastered[_level] == 1)
				_isMaxed = true;
			
			if (_isMaxed) {
				_buttonImg.play("maxed");
				_buttonImgHover.play("maxed");
			} else{
				_buttonImg.play("regular");
				_buttonImgHover.play("regular");
			}
				
			super.update();
		}
		
	}

}