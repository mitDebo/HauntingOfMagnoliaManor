package com.polymath.halloween 
{
	import org.flixel.FlxButton;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.FlxText;
	import org.flixel.FlxG;
	
	public class ErrorMessage extends FlxGroup 
	{
		private var _bg:FlxSprite;
		private var _header:FlxText;
		private var _text:FlxText;
		private var _okButton:FlxButton;
		
		public function ErrorMessage() 
		{
			super();
			_bg = new FlxSprite(0, 0);
			_bg.alpha = 0.75;
			
			_header = new FlxText(0, 5, 200, "Error").setFormat(null, 8, 0xFFFFFFFF, "center", 0xFF000000);
			
			_text = new FlxText(5, 5 + _header.height + 5, 200, "").setFormat(null, 8, 0xFFFFFFFF, "left", 0xFF000000);
			
			_okButton = new FlxButton(0, 0, hide);
			_okButton.loadText(new FlxText(0, 0, 30, "OK").setFormat(null, 8, 0xFFA5A5A5, "center", 0xFF000000), new FlxText(0, 0, 30, "OK").setFormat(null, 8, 0xFFFFFFFF, "center", 0xFF000000));
			_okButton.loadGraphic(new FlxSprite(0, 0).createGraphic(30, 12, 0xFF555555));
			
			_bg.createGraphic(210, _text.bottom + 5 + _okButton.height + 5, 0xFF555555);			
			
			add(_bg);
			add(_header);
			add(_text);
			add(_okButton);
			
			reset( (FlxG.width >> 1) - (_bg.width >> 1), (FlxG.height >> 1) - (_bg.height >> 1));
			_okButton.active = false;
			visible = false;
		}
		
		public function show(text:String):void
		{
			visible = true;
			
			_text.text = text;
			_okButton.active = true;
			
			_bg.createGraphic(210, 5 + _header.height + 5 + _text.height + 5 + _okButton.height + 5, 0xFF555555);
			reset( (FlxG.width >> 1) - (_bg.width >> 1), (FlxG.height >> 1) - (_bg.height >> 1));			
			_okButton.reset(this.x + 105 - _okButton.width / 2, this.y + 5 + _header.height + 5 + _text.height + 5);
			
		}
		
		public function hide():void
		{
			_okButton.active = false;
			visible = false;
		}
	}

}