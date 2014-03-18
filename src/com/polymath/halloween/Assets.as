package com.polymath.halloween 
{
	import org.flixel.FlxG;
	
	public class Assets 
	{
		// Ability info file
		[Embed (source = "../../../../data/levels/ability_info.xml", mimeType = "application/octet-stream")] public static const AbilityInfoXML:Class;
		
		// The level xml files
		[Embed (source = "../../../../data/levels/compiled/level01.oel", mimeType = "application/octet-stream")] public static const Level01:Class;
		[Embed (source = "../../../../data/levels/compiled/level02.oel", mimeType = "application/octet-stream")] public static const Level02:Class;
		[Embed (source = "../../../../data/levels/compiled/level03.oel", mimeType = "application/octet-stream")] public static const Level03:Class;
		[Embed (source = "../../../../data/levels/compiled/level04.oel", mimeType = "application/octet-stream")] public static const Level04:Class;
		[Embed (source = "../../../../data/levels/compiled/level05.oel", mimeType = "application/octet-stream")] public static const Level05:Class;
		[Embed (source = "../../../../data/levels/compiled/level06.oel", mimeType = "application/octet-stream")] public static const Level06:Class;
		[Embed (source = "../../../../data/levels/compiled/level07.oel", mimeType = "application/octet-stream")] public static const Level07:Class;
		[Embed (source = "../../../../data/levels/compiled/level08.oel", mimeType = "application/octet-stream")] public static const Level08:Class;
		[Embed (source = "../../../../data/levels/compiled/level09.oel", mimeType = "application/octet-stream")] public static const Level09:Class;
		[Embed (source = "../../../../data/levels/compiled/level10.oel", mimeType = "application/octet-stream")] public static const Level10:Class;
		[Embed (source = "../../../../data/levels/compiled/level11.oel", mimeType = "application/octet-stream")] public static const Level11:Class;
		[Embed (source = "../../../../data/levels/compiled/level12.oel", mimeType = "application/octet-stream")] public static const Level12:Class;
		[Embed (source = "../../../../data/levels/compiled/level13.oel", mimeType = "application/octet-stream")] public static const Level13:Class;
		[Embed (source = "../../../../data/levels/compiled/level14.oel", mimeType = "application/octet-stream")] public static const Level14:Class;
		[Embed (source = "../../../../data/levels/compiled/level15.oel", mimeType = "application/octet-stream")] public static const Level15:Class;
		[Embed (source = "../../../../data/levels/compiled/level16.oel", mimeType = "application/octet-stream")] public static const Level16:Class;
		[Embed (source = "../../../../data/levels/compiled/level17.oel", mimeType = "application/octet-stream")] public static const Level17:Class;
		[Embed (source = "../../../../data/levels/compiled/level18.oel", mimeType = "application/octet-stream")] public static const Level18:Class;
		[Embed (source = "../../../../data/levels/compiled/level19.oel", mimeType = "application/octet-stream")] public static const Level19:Class;
		[Embed (source = "../../../../data/levels/compiled/level20.oel", mimeType = "application/octet-stream")] public static const Level20:Class;
		[Embed (source = "../../../../data/levels/compiled/level21.oel", mimeType = "application/octet-stream")] public static const Level21:Class;
		[Embed (source = "../../../../data/levels/compiled/level22.oel", mimeType = "application/octet-stream")] public static const Level22:Class;
		[Embed (source = "../../../../data/levels/compiled/level23.oel", mimeType = "application/octet-stream")] public static const Level23:Class;
		[Embed (source = "../../../../data/levels/compiled/level24.oel", mimeType = "application/octet-stream")] public static const Level24:Class;
		[Embed (source = "../../../../data/levels/compiled/level25.oel", mimeType = "application/octet-stream")] public static const Level25:Class;
		[Embed (source = "../../../../data/levels/compiled/level26.oel", mimeType = "application/octet-stream")] public static const Level26:Class;
		[Embed (source = "../../../../data/levels/compiled/level27.oel", mimeType = "application/octet-stream")] public static const Level27:Class;
		[Embed (source = "../../../../data/levels/compiled/level28.oel", mimeType = "application/octet-stream")] public static const Level28:Class;
		[Embed (source = "../../../../data/levels/compiled/level29.oel", mimeType = "application/octet-stream")] public static const Level29:Class;
		[Embed (source = "../../../../data/levels/compiled/level30.oel", mimeType = "application/octet-stream")] public static const Level30:Class;
		
		// Fonts
		[Embed(source = "../../../../data/fonts/8_bit.ttf", fontFamily = "8bit", embedAsCFF = "false")] public static const Font8Bit:Class;
		
		// Music
		//[Embed(source = "../../../../data/music/Urgent Gameboy v2a.mp3")] public static const MusicIngame:Class;
		//[Embed(source = "../../../../data/music/Haunting MM title in E.mp3")] public static const MusicMenu:Class;
		
		// Sfx
		[Embed(source = "../../../../data/sfx/male_scream1.mp3")] public static const SfxMaleScream1:Class;
		[Embed(source = "../../../../data/sfx/male_scream2.mp3")] public static const SfxMaleScream2:Class;
		[Embed(source = "../../../../data/sfx/male_scream3.mp3")] public static const SfxMaleScream3:Class;
		[Embed(source = "../../../../data/sfx/female_scream1.mp3")] public static const SfxFemaleScream1:Class;
		[Embed(source = "../../../../data/sfx/female_scream2.mp3")] public static const SfxFemaleScream2:Class;
		[Embed(source = "../../../../data/sfx/female_scream3.mp3")] public static const SfxFemaleScream3:Class;
		[Embed(source = "../../../../data/sfx/level_select.mp3")] public static const SfxLevelSelect:Class;
		[Embed(source = "../../../../data/sfx/coin.mp3")] public static const SfxCoin:Class;
		[Embed(source = "../../../../data/sfx/all_scared.mp3")] public static const SfxAllScared:Class;
		[Embed(source = "../../../../data/sfx/warning.mp3")] public static const SfxWarning:Class;
		
		public static var InitialStartUp:Boolean = true;
		
		public static function getLevelName(level:int):String
		{
			var name:String = "level";
			if (level < 10)
				name += "0" + level.toString();
			else
				name += level.toString();
			name += ".oel";
			
			return name;
		}
		
		public static function getResource(resourceName:String):Class
		{
			switch (resourceName) {
				// Ability info
				case ("ability_info.xml"): return AbilityInfoXML;
				
				// Levels
				case ("level01.oel"): return Level01;
				case ("level02.oel"): return Level02;
				case ("level03.oel"): return Level03;
				case ("level04.oel"): return Level04;
				case ("level05.oel"): return Level05;
				case ("level06.oel"): return Level06;
				case ("level07.oel"): return Level07;
				case ("level08.oel"): return Level08;
				case ("level09.oel"): return Level09;
				case ("level10.oel"): return Level10;
				case ("level11.oel"): return Level11;
				case ("level12.oel"): return Level12;
				case ("level13.oel"): return Level13;
				case ("level14.oel"): return Level14;
				case ("level15.oel"): return Level15;
				case ("level16.oel"): return Level16;
				case ("level17.oel"): return Level17;
				case ("level18.oel"): return Level18;
				case ("level19.oel"): return Level19;
				case ("level20.oel"): return Level20;
				case ("level21.oel"): return Level21;
				case ("level22.oel"): return Level22;
				case ("level23.oel"): return Level23;
				case ("level24.oel"): return Level24;
				case ("level25.oel"): return Level25;
				case ("level26.oel"): return Level26;
				case ("level27.oel"): return Level27;
				case ("level28.oel"): return Level28;
				case ("level29.oel"): return Level29;
				case ("level30.oel"): return Level30;
				
				// Music
				//case ("in-game"): return MusicIngame;
				//case ("menu"): return MusicMenu;
				
				// Sfx
				case ("male_scream1"): return SfxMaleScream1;
				case ("male_scream2"): return SfxMaleScream2;
				case ("male_scream3"): return SfxMaleScream3;
				case ("female_scream1"): return SfxFemaleScream1;
				case ("female_scream2"): return SfxFemaleScream2;
				case ("female_scream3"): return SfxFemaleScream3;
				case ("level_select"): return SfxLevelSelect;
				case ("coin"): return SfxCoin;
				case ("all_scared"): return SfxAllScared;
				case ("warning"): return SfxWarning;
			}
			
			return null;
		}
		
		public static function isDebug():Boolean
		{
			var debug:Boolean = false;
			
			CONFIG::debug
			{
				debug = true;
			}
			
			return debug;
		}
	}

}
