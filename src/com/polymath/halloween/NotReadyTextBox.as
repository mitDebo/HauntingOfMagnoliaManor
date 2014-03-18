package com.polymath.halloween 
{
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	
	public class NotReadyTextBox extends FlxGroup 
	{
		private var _bg:FlxSprite;
		private var _infoText:FlxText;
		private var _unitList:FlxText;
		private var _okButton:FlxButton;
		
		public function NotReadyTextBox() 
		{
			super();
			
			_bg = new FlxSprite(0, 0).createGraphic(210, 125, 0xFF555555);
			_bg.alpha = 0.75;
			_infoText = new FlxText(5, 5, 200, "The level could not begin because the following units must be placed:").setFormat(null, 8, 0xFFFFFFFF, "center", 0xFF000000);
			
			_unitList = new FlxText(55, 10 + _infoText.height, 150, "").setFormat(null, 8, 0xFFFFFFFF, "left", 0xFF000000);
			
			_okButton = new FlxButton(0, 0, hide);
			_okButton.loadGraphic(new FlxSprite(0, 0).createGraphic(20, 13, 0xFF555555));
			_okButton.loadText(new FlxText(0, 0, 20, "OK").setFormat(null, 8, 0xFFA5A5A5, "left", 0xFF000000), new FlxText(0, 0, 20, "OK").setFormat(null, 8, 0xFFFFFFFF, "left", 0xFF000000));
			_okButton.active = true;
			
			_okButton.reset(95, 5 + _infoText.height + 5 + _unitList.height + 5);
			
			add(_bg, true);
			add(_infoText, true);
			add(_unitList, true);
			add(_okButton, true);
			
			reset( (FlxG.width >> 1) - 105, (FlxG.height >> 1) - 62);
		}
		
		public function addUnit(name:String):void
		{
			_unitList.text += "- " + name + "\n";
		}
		
		public function clear():void
		{
			_unitList.text = "";
		}
		
		public function show():void
		{
			_bg.createGraphic(210, 5 + _infoText.height + 5 + _unitList.height + 5 + _okButton.height + 5, 0xFF555555);
			_bg.alpha = 0.75;
			reset( (FlxG.width >> 1) - (_bg.width >> 1), (FlxG.height >> 1) - (_bg.height >> 1));
			_okButton.reset(x + 95, y + 5 + _infoText.height + 5 + _unitList.height + 5 );
			_okButton.active = true;
			visible = true;
		}
		
		public function hide():void
		{
			_okButton.active = false;
			visible = false;
			clear();
		}
	}

}