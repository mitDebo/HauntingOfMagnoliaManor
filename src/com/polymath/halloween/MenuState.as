package com.polymath.halloween 
{
	import org.flixel.FlxButton;
	import org.flixel.FlxObject;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import org.flixel.FlxG;
	import org.flixel.FlxU;
	import org.flixel.FlxText;
	import org.flixel.FlxGroup;
	
	import Playtomic.*;
	
	public class MenuState extends FlxState 
	{
		[Embed(source = "../../../../data/gfx/polymath-games-logo.png")] private var ImgStudioLogo:Class;
		[Embed(source = "../../../../data/gfx/game_logo.png")] private var ImgGameLogo:Class;
		[Embed(source = "../../../../data/gfx/start_button_idle.png")] private var ImgStartButtonIdle:Class;
		[Embed(source = "../../../../data/gfx/start_button_active.png")] private var ImgStartButtonActive:Class;
		[Embed(source = "../../../../data/gfx/credits_button_idle.png")] private var ImgCreditsButtonIdle:Class;
		[Embed(source = "../../../../data/gfx/credits_button_active.png")] private var ImgCreditsButtonActive:Class;
		[Embed(source = "../../../../data/gfx/moon.png")] private var ImgMoon:Class;
		[Embed(source = "../../../../data/gfx/mansion.png")] private var ImgMansion:Class;
		[Embed(source = "../../../../data/gfx/level_select.png")] private var ImgLevelSelect:Class;
		[Embed(source = "../../../../data/gfx/credits.png")] private var ImgCredits:Class;
		[Embed(source = "../../../../data/gfx/back_button.png")] private var ImgBackButton:Class;
		
		[Embed(source = "../../../../data/fonts/ElderGodsBB.ttf", fontFamily = "ElderGods", embedAsCFF = "false")] private var FontElderGods:Class;
		
		private const BEGIN:uint = 0;
		private const DISPLAYING_LOGO:uint = 1;
		private const LOGO_FADE:uint = 2;
		private const SHOW_MOON:uint = 3;
		private const SHOW_MENU:uint = 7;
		private const SHOW_CREDITS:uint = 8;
		private const RETURN_TO_MENU:uint = 9;		
		private const SHOW_LEVEL_SELECT:uint = 10;
		
		private var _whereInMenu:uint;
		
		private var _studioLogo:FlxSprite;
		private var _timer:Number;
		
		private var _moon:FlxSprite;
		private var _presentText:FlxText;
		private var _presentTextFadeIn:Boolean;
		private var _mansion:FlxSprite;
		private var _gameLogo:FlxSprite;
		private var _startButton:FlxButton;
		private var _creditsButton:FlxButton;
		private var _credits:FlxGroup;
		private var _backButton:FlxButton;
		
		private var _nearClouds:FlxGroup;
		
		private var _levelButtons:FlxGroup;
		
		override public function create():void
		{
			if (!Assets.isDebug())
				Log.View(4346, "acbd6f20704e4a4c", "23f65ff4802641fcb66265e0045f98", root.loaderInfo.loaderURL);
			
			FlxG.mouse.show();
			_whereInMenu = BEGIN;
			
			_studioLogo = new FlxSprite(0, 0, ImgStudioLogo);
			_studioLogo.x = (FlxG.width >> 1) - (_studioLogo.width >> 1);
			_studioLogo.y = (FlxG.height >> 1) - (_studioLogo.height >> 1);
			_studioLogo.alpha = 0;
			
			_moon = new FlxSprite(0, 0, ImgMoon);
			_moon.visible = false;
			_moon.scrollFactor.y = 0.25;
			
			_nearClouds = new FlxGroup();
			var nc:NearClouds = new NearClouds(110, -.25);
			nc.scrollFactor.y = 0.25;
			_nearClouds.add(nc);
			
			nc = new NearClouds(60, -.66);
			nc.scrollFactor.y = 0.25;
			_nearClouds.add(nc);
			
			_nearClouds.visible = false;
			
			_presentText = new FlxText(0, 0, 240, "Kelly Weaver and Jimmy Hinson\n\nwith\n\nSponsor Name\n\npresent").setFormat(null, 8, 0xFF000000, "center", 0xFF555555);
			_presentText.x = FlxG.width / 2 - _presentText.width / 2;
			_presentText.y = FlxG.height / 2 - _presentText.height / 2;
			_presentText.alpha = 0;
			_presentText.visible = false;
			_presentTextFadeIn = true;
			
			_mansion = new FlxSprite(0, 240, ImgMansion);
			_mansion.visible = false;
			
			_gameLogo = new FlxSprite(0, 170, ImgGameLogo);
			_gameLogo.x = (FlxG.width >> 1) - (_gameLogo.width >> 1);
			_gameLogo.visible = false;
			
			_startButton = new FlxButton(0, 305, showLevelSelect);			
			_startButton.loadGraphic(new FlxSprite(0, 0, ImgStartButtonIdle), new FlxSprite(0, 0, ImgStartButtonActive));
			_startButton.x = (FlxG.width >> 1) - (_startButton.width >> 1);
			_startButton.visible = false;
			_creditsButton = new FlxButton(0, 345, showCredits );
			_creditsButton.loadGraphic(new FlxSprite(0, 0, ImgCreditsButtonIdle), new FlxSprite(0, 0, ImgCreditsButtonActive));
			_creditsButton.x = (FlxG.width >> 1) - (_creditsButton.width >> 1);
			_creditsButton.visible = false;
			
			_credits = new FlxGroup();
			_credits.add(new FlxSprite(0, 0, ImgCredits));
			_credits.add(new FlxText(7, 60, 182, "Kelly Weaver").setFormat(null, 8, 0xFFFFFFFF, "center", 0xFFA5A5A5));
			_credits.add(new FlxText(193, 110, 79, "Jimmy Hinson").setFormat(null, 8, 0xFFFFFFFF, "center", 0xFFA5A5A5));
			_credits.add(new FlxText(70, 160, 50, "as3sfxr").setFormat(null, 8, 0xFFFFFFFF, "center", 0xFFA5A5A5));
			_credits.add(new FlxText(0, 200, 320, "This game was heavily inspired by Blendo Game's vastly superior Atom Zombie Smasher. If you liked this, you really ought to buy that game. It's great.").setFormat(null, 8, 0xFFFFFFFF, "center", 0xFFA5A5A5));
			_credits.reset(0, 410);
			_credits.visible = false;
			
			_backButton = new FlxButton(278, 405, returnToMenu);
			_backButton.loadGraphic(new FlxSprite(0, 0, ImgBackButton));
			_backButton.visible = false;
			
			var blackBG:FlxSprite = new FlxSprite(0, 405).createGraphic(320, 240, 0xFF000000);
			
			_levelButtons = new FlxGroup();
			_levelButtons.add(new FlxSprite(68, 425, ImgLevelSelect));
			for (var i:uint = 0; i < 5; i++) {
				for (var k:uint = 0; k < 6; k++) {
					var levelNum:uint = 1 + (i * 6 + k);
					//if (levelNum < 21) {
						var lvlButton:LevelSelectButton = new LevelSelectButton(70 + (k * 28), 480 + (i * 28), levelNum, function():void {
							loadLevel(this)
						});
						lvlButton.active = false;
						_levelButtons.add(lvlButton);
					//}
				}
			}
			_levelButtons.visible = false;
			
			add(_studioLogo);
			add(_moon);
			add(_nearClouds);
			add(_presentText);
			add(blackBG);
			add(_mansion);
			add(_gameLogo);
			add(_startButton);
			add(_creditsButton);
			
			add(_levelButtons);
			add(_credits);
			add(_backButton);
		}
		
		override public function update():void
		{
			
			if (Assets.InitialStartUp) {
				if (_studioLogo.alpha < 1 && _whereInMenu == BEGIN) {
					_studioLogo.alpha += FlxG.elapsed * 1;
					if (_studioLogo.alpha >= 1) {
						_studioLogo.alpha = 1;
						_whereInMenu = DISPLAYING_LOGO;
						_timer = 0;
					}
				}	
			
				if (_whereInMenu == DISPLAYING_LOGO && _timer < 1.5) {
					_timer += FlxG.elapsed;
					if (_timer > 1.5) {
						_timer = 0;
						_whereInMenu = LOGO_FADE;
					}
				}
			
				if (_whereInMenu == LOGO_FADE && _studioLogo.alpha > 0) {
					_studioLogo.alpha -= FlxG.elapsed * 1;
					if (_studioLogo.alpha <= 0) {
						showMoon();
					}
				}
			} else if (_whereInMenu == BEGIN) {
				showMenu();
			}
			
			if (_whereInMenu == SHOW_MOON) {
				if (_presentText.visible && _presentTextFadeIn) {
					_presentText.alpha += FlxG.elapsed;
					if (_presentText.alpha >= 1) {
						_presentText.alpha = 1;
						_presentTextFadeIn = false;
						_timer = 0;
					}
				} else if (_presentText.visible && !_presentTextFadeIn && _timer < 1.5) {
					_timer += FlxG.elapsed;
				} else if (_presentText.visible && !_presentTextFadeIn) {
					_presentText.alpha -= FlxG.elapsed;
					if (_presentText.alpha <= 0) {
						_presentText.alpha = 0;
						_presentText.visible = false;
					}
				}
				
				if (!_presentText.visible) {
					FlxG.scroll.y -= FlxG.elapsed * 100;
					if (FlxG.scroll.y <= -165) {
						FlxG.scroll.y = -165;
						FlxG.flash.start();
						showMenu();
					}
				}
			}
			
			if (_whereInMenu == SHOW_LEVEL_SELECT || _whereInMenu == SHOW_CREDITS) {
				FlxG.scroll.y -= FlxG.elapsed * 200;
				if (FlxG.scroll.y <= -405) {
					FlxG.scroll.y = -405;
					_backButton.visible = true;
				}
			}
			
			if (_whereInMenu == RETURN_TO_MENU) {
				FlxG.scroll.y += FlxG.elapsed * 200;
				if (FlxG.scroll.y >= -165) {
					FlxG.scroll.y = -165;
					_startButton.visible = true;
					_creditsButton.visible = true;
					_gameLogo.visible = true;
					
					_levelButtons.visible = false;
					_credits.visible = false;
				}
			}
			
			super.update();
		}
		
		private function showMoon():void
		{
			_whereInMenu = SHOW_MOON;
			_moon.visible = true;
			_nearClouds.visible = true;
			_mansion.visible = true;
			_presentText.visible = true;
		}
		
		private function showMenu():void
		{
			//FlxG.playMusic(Assets.getResource("menu"));
			_whereInMenu = SHOW_MENU;
			FlxG.scroll.y = -165;
			
			_nearClouds.visible = true;
			_credits.visible = false;
			_levelButtons.visible = false;
			_moon.visible = true;
			_mansion.visible = true;
			_gameLogo.visible = true;
			_startButton.visible = true;
			_creditsButton.visible = true;
		}
		
		private function showLevelSelect():void
		{
			_whereInMenu = SHOW_LEVEL_SELECT;
			
			_startButton.visible = false;
			_creditsButton.visible = false;
			_gameLogo.visible = false;
			
			_levelButtons.visible = true;
			for each (var button:FlxObject in _levelButtons.members)
				if (button is LevelSelectButton)
					button.active = true;
		}
		
		private function showCredits():void
		{
			_whereInMenu = SHOW_CREDITS;
			_startButton.visible = false;
			_creditsButton.visible = false;
			_gameLogo.visible = false;
			_credits.visible = true;
		}
		
		private function returnToMenu():void
		{
			_backButton.visible = false;
			_whereInMenu = RETURN_TO_MENU;
		}
		
		private function loadLevel(button:LevelSelectButton):void
		{
			FlxG.level = button.Level;
			FlxG.play(Assets.getResource("level_select"));
			FlxG.flash.start(0xFFFFFFFF, 0.5, null, true);
			FlxG.fade.start(0xFF000000, 1, _noReallyLoadTheLevel, true);
			FlxG.music.fadeOut(1);
		}
		
		private function _noReallyLoadTheLevel():void
		{
			if (!Assets.isDebug()) 
				Log.Play();
			FlxG.state = new PlayState();
		}
	}

}
