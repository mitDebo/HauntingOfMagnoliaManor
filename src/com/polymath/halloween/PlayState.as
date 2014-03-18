package com.polymath.halloween 
{
	import com.polymath.halloween.minions.PossessionGhost;
	import com.polymath.halloween.minions.SummoningCircle;
	import org.flixel.*
	import Playtomic.*;
	
	public class PlayState extends FlxState 
	{
		[Embed (source = "../../../../data/gfx/reset_dialog_bg.png")] private var ImgResetDialog:Class;
		[Embed (source = "../../../../data/gfx/failure_banner.png")] private var ImgFailureBanner:Class;
		[Embed (source = "../../../../data/gfx/success_banner.png")] private var ImgSuccessBanner:Class;		
		
		[Embed (source = "../../../../data/gfx/return_to_title_button_idle.png")] private var ImgReturnToTitleIdle:Class;
		[Embed (source = "../../../../data/gfx/return_to_title_button_active.png")] private var ImgReturnToTitleActive:Class;
		[Embed (source = "../../../../data/gfx/try_again_button_idle.png")] private var ImgTryAgainIdle:Class;
		[Embed (source = "../../../../data/gfx/try_again_button_active.png")] private var ImgTryAgainActive:Class;
		[Embed (source = "../../../../data/gfx/next_level_button_idle.png")] private var ImgNextLevelIdle:Class;
		[Embed (source = "../../../../data/gfx/next_level_button_active.png")] private var ImgNextLevelActive:Class;
		
		[Embed(source = "../../../../data/gfx/sound.png")] private var ImgSound:Class;
		[Embed(source = "../../../../data/gfx/reset_button.png")] private var ImgReset:Class;
		
		public static const SELECTION_NONE:uint = 0;
		public static const SELECTION_CHARACTER:uint = 1;
		public static const SELECTION_CIRCLE:uint = 2;
		public static const SELECTION_ROOM:uint = 3;
		
		public static const MENU_NONE:uint = 0;
		public static const MENU_RESET:uint = 1;
		public static const MENU_FAILURE:uint = 2;
		public static const MENU_SUCCESS:uint = 3;
		
		public static function get GlowingSquareAlpha():Number
		{
			return _glowingSquareAlpha;
		}
		
		public function get CurrentLevel():Level {
			return _currentLevel;
		}
		private var _currentLevel:Level;
		
		private static var _glowingSquareAlpha:Number = 0.25;
		private var _glowingSquareAlphaIncreasing:Boolean = true;
		
		private var _previousRoom:FlxObject;
		private var _previousCircleCenter:FlxPoint;
		private var _previousGuest:Character;
		private var _isSelectionValid:Boolean;
		
		private var _failureBanner:FlxSprite;
		private var _successBanner:FlxSprite;
		
		private var _failureDialog:FlxGroup;
		private var _successDialog:FlxGroup;
		private var _endOfLevelBg:FlxSprite;
		
		private var _resetDialog:FlxGroup;
		private var _soundButton:FlxButton;
		private var _soundButtonImage:FlxSprite;
		private var _resetButton:FlxButton;
		
		private var _levelTally:LevelTally;
		private var _tutorial:Tutorial;
		
		private var _logSuccessSent:Boolean;
		private var _logFailureSent:Boolean;
		private var _logResetSent:Boolean;
		
		public function set SelectionMode(mode:uint):void
		{
			switch (___sM) {
				case (SELECTION_ROOM): 
					if (_previousRoom != null)
						_currentLevel.unhighlightRoom(_previousRoom); 
					_previousRoom = null;
					break;
				case (SELECTION_CIRCLE): 
					if (_previousCircleCenter != null)
						_currentLevel.unhighlightCircle(_previousCircleCenter.x, _previousCircleCenter.y);
					_previousCircleCenter = null;
					break;
				case (SELECTION_CHARACTER):
					if (_previousGuest != null)
						_currentLevel.unhighlightGuest(_previousGuest);
					_previousGuest = null;
					break;
			}
			
			___sM = mode;
		}
		
		public function get SelectionMode():uint
		{
			return ___sM;
		}
		private var ___sM:uint;
		
		private function get MenuMode():uint
		{
			return ___mM;
		}
		private function set MenuMode(mode:uint):void
		{
			___mM = mode;
		}
		private var ___mM:uint;
		
		override public function create():void
		{
			FlxG.mouse.show();
			SelectionMode = SELECTION_NONE;
			MenuMode = MENU_NONE;
			_previousRoom = null;
			_previousCircleCenter = null;
			_previousGuest = null;
			
			_currentLevel = new Level(Assets.getLevelName(FlxG.level));
			if (!Assets.isDebug()) {
				Log.LevelCounterMetric("BeganLevel", Assets.getLevelName(FlxG.level), true);
				Log.ForceSend();
			}
			
			_resetDialog = GenerateResetDialog();
			_failureDialog = GeneratFailureDialog();
			_successDialog = GenerateSuccessDialog();
			
			_endOfLevelBg = new FlxSprite(20, 70).createGraphic(280, 170, 0xFF555555);
			_endOfLevelBg.alpha = 0;
			_endOfLevelBg.visible = false;
			
			/** Sound and reset buttons **/
			_soundButtonImage = new FlxSprite(0, 0);
			_soundButtonImage.loadGraphic(ImgSound, true);
			_soundButtonImage.addAnimation("unmute", [0]);
			_soundButtonImage.addAnimation("mute", [1]);
			_soundButton = new FlxButton(3, 0, toggleMute);
			_soundButton.loadGraphic(_soundButtonImage);
			_soundButton.y = FlxG.height - _soundButton.height - 3;
			_resetButton = new FlxButton(18, 0, showResetDialog);
			_resetButton.loadGraphic(new FlxSprite(0, 0, ImgReset));
			_resetButton.y = FlxG.height - _soundButton.height - 3;
			
			add(_currentLevel);
			add(_soundButton);
			add(_resetButton);
			
			add(_endOfLevelBg);
			
			add(_failureBanner);
			add(_successBanner);
			add(_successDialog);
			add(_failureDialog);
			add(_resetDialog);
			
			/** not distributing Jimmy's music with the source, so don't need this
			if (FlxG.music == null || !FlxG.music.playing)
				FlxG.playMusic(Assets.getResource("in-game")); */
				
			_logFailureSent = false;
			_logResetSent = false;
			_logSuccessSent = false;
		}
		
		override public function update():void
		{
			
			if (MenuMode == MENU_NONE) {
				handleGameplay();
				scrollAwayMenus();
			} else {
				SelectionMode = SELECTION_NONE;
				if (MenuMode == MENU_RESET) {
					scrollInResetDialog();
					if (!Assets.isDebug() && !_logResetSent) {
						Log.LevelCounterMetric("Reset", Assets.getLevelName(FlxG.level));
						Log.ForceSend();
						_logResetSent = false;
					}
				}
				if (MenuMode == MENU_FAILURE) {
					scrollInFailureDialog();
					if (!Assets.isDebug() && !_logFailureSent) {
						Log.LevelCounterMetric("Failed", Assets.getLevelName(FlxG.level));
						Log.ForceSend();
						_logFailureSent = false;
					}
				}
				if (MenuMode == MENU_SUCCESS) {
					scrollInSuccessDialog();
					if (!Assets.isDebug() && !_logSuccessSent) {
						Log.LevelCounterMetric("Success", Assets.getLevelName(FlxG.level));
						Log.ForceSend();
						_logSuccessSent = true;
					}
				}
					
			}
			
			/** Misc **/
			if (_glowingSquareAlphaIncreasing) {
				_glowingSquareAlpha += FlxG.elapsed;
				if (_glowingSquareAlpha > 0.75)
					_glowingSquareAlphaIncreasing = false;
			} else {
				_glowingSquareAlpha -= FlxG.elapsed;
				if (_glowingSquareAlpha < 0.25)
					_glowingSquareAlphaIncreasing = true;
			}
			
			if (FlxG.mute)
				_soundButtonImage.play("mute");
			else
				_soundButtonImage.play("unmute");
			
			super.update();
		}
		
		private function handleGameplay():void
		{
			_isSelectionValid = false;
			
			/** Dealing with selection modes */
			if (SelectionMode == SELECTION_ROOM) {
				var roomUnderMouse:FlxObject = _currentLevel.getRoomAt(FlxG.mouse.x, FlxG.mouse.y);
				if (roomUnderMouse == null && _previousRoom != null)
					_currentLevel.unhighlightRoom(_previousRoom);
				if (roomUnderMouse != null && roomUnderMouse != _previousRoom) {
					if (_previousRoom != null)
						_currentLevel.unhighlightRoom(_previousRoom);
					_currentLevel.highlightRoom(roomUnderMouse);
				}
				
				_previousRoom = roomUnderMouse;
				if (roomUnderMouse != null) {
					_isSelectionValid = true;
				}
			}
			
			if (SelectionMode == SELECTION_CIRCLE) {
				var circleCenter:FlxPoint = _currentLevel.getCircleCenter(FlxG.mouse.x, FlxG.mouse.y);
				if (_previousCircleCenter != null) {
					if (_previousCircleCenter.x != circleCenter.x || _previousCircleCenter.y != circleCenter.y) {
						_currentLevel.unhighlightCircle(_previousCircleCenter.x, _previousCircleCenter.y);
						_currentLevel.highlightCircle(circleCenter.x, circleCenter.y);
					}						
				} else {
					_currentLevel.highlightCircle(FlxG.mouse.x, FlxG.mouse.y);
				}
				
				_previousCircleCenter = circleCenter;
				if (circleCenter != null) {
					_isSelectionValid = true;
				}
			}
			
			if (SelectionMode == SELECTION_CHARACTER) {
				var guest:Character = _currentLevel.getGuestAt(FlxG.mouse.x, FlxG.mouse.y);
				if (_previousGuest != null && _previousGuest != guest) {
					_currentLevel.unhighlightGuest(_previousGuest);
				}
				if (guest != null)
					_currentLevel.highlightGuest(guest);
				
				_previousGuest = guest;
				if (guest != null) {
					_isSelectionValid = true;
				}
			}
			
			/** Deal with key presses **/
			if (FlxG.keys.justReleased("ENTER")) {
				_currentLevel.start();
			}
			
			if (FlxG.keys.justReleased("ONE")) {
				_currentLevel.fireAbility(1);
			}
			if (FlxG.keys.justReleased("TWO")) {
				_currentLevel.fireAbility(2);
			}
			if (FlxG.keys.justReleased("THREE")) {
				_currentLevel.fireAbility(3);
			}
			if (FlxG.keys.justReleased("FOUR")) {
				_currentLevel.fireAbility(4);
			}
			if (FlxG.keys.justReleased("FIVE")) {
				_currentLevel.fireAbility(5);
			}
			if (FlxG.keys.justReleased("SIX")) {
				_currentLevel.fireAbility(6);
			}
			
			if (FlxG.mouse.justPressed() && SelectionMode != SELECTION_NONE) {
				var guests:FlxGroup;
				if (SelectionMode == SELECTION_CIRCLE && _isSelectionValid) {
					_currentLevel.makeCircleSelection(FlxG.mouse.x, FlxG.mouse.y);
				}
				if (SelectionMode == SELECTION_ROOM && _previousRoom != null && _isSelectionValid) {
					_currentLevel.makeRoomSelection(_previousRoom);
				}
				if (SelectionMode == SELECTION_CHARACTER && _previousGuest != null && _isSelectionValid) {
					_currentLevel.makeCharacterSelection(_previousGuest);
				}
				if (_isSelectionValid && _currentLevel.doneWithSelections())
					SelectionMode = SELECTION_NONE;
			}
			
			/** Checking level status **/
			if (_currentLevel.TimesUp) {
				if (_currentLevel.wasGoalMet()) {
					MenuMode = MENU_SUCCESS;
				} else {
					MenuMode = MENU_FAILURE;
				}
			}
			
			if (_currentLevel.isEveryoneScared()) {
				MenuMode = MENU_SUCCESS;
			}
		}
		
		private function isResetDialogVisible():Boolean
		{
			return _resetDialog.visible;
		}
		
		private function isFailureDialogVisible():Boolean
		{
			return (_failureBanner.visible);
		}
		
		private function isSuccessDialogVisible():Boolean
		{
			return (_successBanner.visible);
		}
		
		private function isEndOfLevelBgDoneFadingIn():Boolean
		{
			return (_endOfLevelBg.alpha == 0.75);
		}
		
		private function scrollAwayMenus():void
		{
			scrollAwayResetDialog();
			scrollAwayFailureDialog();
			scrollAwaySuccessDialog();
		}
		
		private function scrollInSuccessDialog():void
		{
			if (isResetDialogVisible()) {
				scrollAwayResetDialog();
				return;
			}
			if (isFailureDialogVisible()) {
				scrollAwayFailureDialog();
				return;
			}
			
			_successBanner.visible = true;
			if (_successBanner.x > 0) {
				_successBanner.velocity.x = -1200;
				if (_successBanner.x + _successBanner.velocity.x * FlxG.elapsed <= 0) {
					_successBanner.velocity.x = 0;
					_successBanner.x = 0;
				}
			} else {
				if (!isEndOfLevelBgDoneFadingIn()) {
					fadeInEndOfLevelBg();
				} else {
					activateSuccessButtons();
					_successDialog.visible = true;
					_levelTally.start(_currentLevel.getGuests(), _currentLevel.isEveryoneScared());
				}
			}
		}
		
		private function scrollAwaySuccessDialog():void
		{
			deactivateSuccessButtons();
			_successDialog.visible = false;
			if (_successBanner.x < FlxG.width) {
				_successBanner.velocity.x = 1200;
				if (_successBanner.x + _successBanner.velocity.x * FlxG.elapsed >= FlxG.width) {
					_successBanner.velocity.x = 0;
					_successBanner.x = FlxG.width;
					_successBanner.visible = false;
				}
			}
			
			if (_endOfLevelBg.visible || _endOfLevelBg.alpha > 0) {
				fadeOutEndOfLevelBg();
			}
		}
		
		private function scrollInFailureDialog():void
		{
			if (isResetDialogVisible()) {
				scrollAwayResetDialog();
				return;
			}
			if (isSuccessDialogVisible()) {
				scrollAwaySuccessDialog();
				return;
			}
			
			_failureBanner.visible = true;
			if (_failureBanner.x > 0) {
				_failureBanner.velocity.x = -1200;
				if (_failureBanner.x + _failureBanner.velocity.x * FlxG.elapsed <= 0) {
					_failureBanner.velocity.x = 0;
					_failureBanner.x = 0;
				}
			} else {
				if (!isEndOfLevelBgDoneFadingIn()) {
					fadeInEndOfLevelBg();
				} else {
					activateFailureButtons();
					_failureDialog.visible = true;
				}
			}
			
		}
		
		private function scrollAwayFailureDialog():void
		{
			deactivateFailureButtons();
			_failureDialog.visible = false;
			if (_failureBanner.x < FlxG.width) {
				_failureBanner.velocity.x = 1200;
				if (_failureBanner.x + _failureBanner.velocity.x * FlxG.elapsed >= FlxG.width) {
					_failureBanner.velocity.x = 0;
					_failureBanner.x = FlxG.width;
					_failureBanner.visible = false;
				}
			}
			
			if (_endOfLevelBg.visible || _endOfLevelBg.alpha > 0) {
				fadeOutEndOfLevelBg();
			}
		}
		
		private function activateSuccessButtons():void
		{
			if (!_successDialog.visible) {
				for each (var obj:FlxObject in _successDialog.members) {
					if (obj is FlxButton)
						(obj as FlxButton).active = true;
				}
			}
		}
		
		private function deactivateSuccessButtons():void
		{
			if (_successDialog.visible) {
				for each (var obj:FlxObject in _successDialog.members) {
					if (obj is FlxButton)
						(obj as FlxButton).active = false;
				}
			}
		}
		
		private function activateFailureButtons():void
		{
			if (!_failureDialog.visible) {
				for each (var obj:FlxObject in _failureDialog.members) {
					if (obj is FlxButton)
						(obj as FlxButton).active = true;
				}
			}
		}
		
		private function deactivateFailureButtons():void
		{
			if (_failureDialog.visible) {
				for each (var obj:FlxObject in _failureDialog.members) {
					if (obj is FlxButton)
						(obj as FlxButton).active = false;
				}
			}
		}
		
		private function scrollInResetDialog():void
		{
			if (isFailureDialogVisible()) {
				scrollAwayFailureDialog();
				return;
			}
			if (isSuccessDialogVisible()) {
				scrollAwaySuccessDialog();
				return;
			}
			
			if (_endOfLevelBg.visible) {
				fadeOutEndOfLevelBg();
				return;
			}
			
			_resetDialog.visible = true;
			if (_resetDialog.left < 0) {
				_resetDialog.velocity.x = 600;
					if (_resetDialog.x + _resetDialog.velocity.x * FlxG.elapsed >= 0 ) {
						_resetDialog.velocity.x = 0;
						_resetDialog.reset(0, _resetDialog.y);
					}
			}
		}
		
		private function scrollAwayResetDialog():void
		{
			if (_resetDialog.x >= -155) {
				_resetDialog.velocity.x = -600;
				if (_resetDialog.x + _resetDialog.velocity.x * FlxG.elapsed <= -155) {
					_resetDialog.velocity.x = 0;
					_resetDialog.reset( -155, _resetDialog.y);
					_resetDialog.visible = false;
				}
			}
		}
		
		private function fadeInEndOfLevelBg():void
		{
			_endOfLevelBg.visible = true;
			if (_endOfLevelBg.alpha < 0.75) {
				_endOfLevelBg.alpha += FlxG.elapsed * 2;
				if (_endOfLevelBg.alpha >= 0.75) {
					_endOfLevelBg.alpha = 0.75;
				}
			}
		}
		
		private function fadeOutEndOfLevelBg():void
		{
			if (_endOfLevelBg.alpha > 0) {
				_endOfLevelBg.alpha -= FlxG.elapsed * 3;
				if (_endOfLevelBg.alpha <= 0) {
					_endOfLevelBg.alpha = 0;
					_endOfLevelBg.visible = false;
				}
			}
		}
		
		private function showResetDialog():void
		{
			MenuMode = MENU_RESET;
		}
		
		
		private function toggleMute():void
		{
			FlxG.mute = !FlxG.mute;
		}
		
		private function startFresh():void
		{
			FlxG.flash.start(0xFFFFFFFF, 0.5);
			
			defaultGroup.remove(_currentLevel, true);
			_currentLevel.destroy();
			_currentLevel = new Level(Assets.getLevelName(FlxG.level));
			if (!Assets.isDebug()) {
				Log.LevelCounterMetric("StartFresh", Assets.getLevelName(FlxG.level));
			}
			defaultGroup.members.unshift(_currentLevel);
			
			_successDialog.remove(_levelTally);
			_levelTally.destroy();
			_levelTally = new LevelTally();
			_successDialog.add(_levelTally);
			_levelTally.reset(30, 80);
			
			MenuMode = MENU_NONE;
			_logFailureSent = false;
			_logResetSent = false;
			_logSuccessSent = false;
		}
		
		private function loadNextLevel():void
		{
			FlxG.flash.start(0xFFFFFFFF, 0.5);
			if (FlxG.level + 1 > 30) {
				Assets.InitialStartUp = false;
				if (FlxG.music != null)
					FlxG.music.stop();
				FlxG.state = new MenuState();
				return;
			}
			FlxG.level = FlxG.level + 1;
			
			defaultGroup.remove(_currentLevel, true);
			_currentLevel.destroy();
			_currentLevel = new Level(Assets.getLevelName(FlxG.level));
			if (!Assets.isDebug()) {
				Log.LevelCounterMetric("BeganLevel", Assets.getLevelName(FlxG.level), true);
				Log.ForceSend();
			}
			defaultGroup.members.unshift(_currentLevel);
			
			_successDialog.remove(_levelTally);
			_levelTally.destroy();
			_levelTally = new LevelTally();
			_successDialog.add(_levelTally);
			_levelTally.reset(30, 80);
			
			MenuMode = MENU_NONE;
			_logFailureSent = false;
			_logResetSent = false;
			_logSuccessSent = false;
		}
		
		private function reusePlacements():void
		{
			FlxG.flash.start(0xFFFFFFFF, 0.5);
			MenuMode = MENU_NONE;
			_currentLevel.restart();
			if (!Assets.isDebug()) {
				Log.LevelCounterMetric("ReusedPlacements", Assets.getLevelName(FlxG.level));
				Log.ForceSend();
			}
			_successDialog.remove(_levelTally);
			_levelTally.destroy();
			_levelTally = new LevelTally();
			_successDialog.add(_levelTally);
			_levelTally.reset(30, 80);
		}
		
		private function GeneratFailureDialog():FlxGroup
		{
			var grp:FlxGroup = new FlxGroup();
			_failureBanner = new FlxSprite(320, 20, ImgFailureBanner);
			_failureBanner.visible = false;
			
			var text:FlxText = new FlxText(0, 60, 250, "You failed to chase off enough flesh bags from your estate. I hope you enjoy the stench of life.").setFormat(null, 8, 0xFFFFFFFF, "center", 0xFF000000);
			grp.add(text);
			text = new FlxText(0, 60 + text.height, 245, "Because now you'll be dealing with it for a long time to come...").setFormat(null, 8, 0xFFFFFFFF, "center", 0xFF000000);
			grp.add(text);
			
			var button:FlxButton = new FlxButton(0, 110, function():void {
				_currentLevel.destroy();
				Assets.InitialStartUp = false;
				if (FlxG.music != null)
					FlxG.music.stop();
				FlxG.state = new MenuState();
			});
			button.loadGraphic(new FlxSprite(0, 0, ImgReturnToTitleIdle), new FlxSprite(0, 0, ImgReturnToTitleActive));
			button.active = false;
			grp.add(button);
			
			button = new FlxButton(140, 110, function():void {
				MenuMode = MENU_RESET;
			});
			button.loadGraphic(new FlxSprite(0, 0, ImgTryAgainIdle), new FlxSprite(0, 0, ImgTryAgainActive));
			button.active = false;
			grp.add(button);
			
			
			grp.reset(35, 90);
			grp.visible = false;
			
			return grp;
		}
		
		private function GenerateSuccessDialog():FlxGroup
		{
			var grp:FlxGroup = new FlxGroup();
			_successBanner = new FlxSprite(320, 20, ImgSuccessBanner);
			_successBanner.visible = false;
			
			_levelTally = new LevelTally();
			_levelTally.reset(0, 0);
			grp.add(_levelTally);
			
			var button:FlxButton = new FlxButton(0, 110, function():void {
				MenuMode = MENU_RESET;
			});
			button.loadGraphic(new FlxSprite(0, 0, ImgTryAgainIdle), new FlxSprite(0, 0, ImgTryAgainActive));
			button.active = false;
			grp.add(button);
			
			button = new FlxButton(140, 110, function():void {
				loadNextLevel();
			});
			button.loadGraphic(new FlxSprite(0, 0, ImgNextLevelIdle), new FlxSprite(0, 0, ImgNextLevelActive));
			button.active = false;
			grp.add(button);
			
			grp.reset(30, 80);
			grp.visible = false;
			
			return grp;
		}
		
		private function GenerateResetDialog():FlxGroup
		{
			var grp:FlxGroup = new FlxGroup();
			
			var bg:FlxSprite = new FlxSprite(0, 0, ImgResetDialog);
			grp.add(bg, true);
			
			var textPrompt:FlxText = new FlxText(5, 10, 140, "Would you like to use your previous placements?").setFormat(null, 8, 0xFFFFFFFF, "center", 0xFF000000);
			grp.add(textPrompt, true);
			
			var yesButton:FlxButton = new FlxButton(40, 35, reusePlacements);
			yesButton.loadText(new FlxText(0, 0, 70, "Yes").setFormat(null, 8, 0xFFA5A5A5, "left", 0xFF000000), new FlxText(0, 0, 70, "Yes").setFormat(null, 8, 0xFFFFFFFF, "left", 0xFF000000));
			yesButton.loadGraphic(new FlxSprite(0, 0).createGraphic(25, 12, 0xFF555555));
			grp.add(yesButton, true);
			
			var noButton:FlxButton = new FlxButton(90, 35, startFresh);
			noButton.loadText(new FlxText(0, 0, 70, "No").setFormat(null, 8, 0xFFA5A5A5, "left", 0xFF000000), new FlxText(0, 0, 70, "No").setFormat(null, 8, 0xFFFFFFFF, "left", 0xFF000000));
			noButton.loadGraphic(new FlxSprite(0, 0).createGraphic(25, 12, 0xFF555555));
			grp.add(noButton, true);
						
			grp.reset(-155, 95);
			grp.visible = false;
			
			return grp;
		}
	}
}