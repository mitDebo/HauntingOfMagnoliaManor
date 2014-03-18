package com.polymath.halloween.abilities 
{
	import flash.utils.ByteArray;
	import flash.xml.*;
	
	import org.flixel.FlxG;
	
	import com.polymath.halloween.Assets;
	import com.polymath.halloween.abilities.Ability;
	import com.polymath.halloween.abilities.DeathsClutch;
	import com.polymath.halloween.abilities.Demon;
	import com.polymath.halloween.abilities.Ectoplasm;
	import com.polymath.halloween.abilities.Haunt;
	import com.polymath.halloween.abilities.Onryo;
	import com.polymath.halloween.abilities.Possess;
	import com.polymath.halloween.abilities.Scare;
	import com.polymath.halloween.abilities.SealDoor;
	
	public class AbilityInfo 
	{
		private static var _data:XML;
		
		public static function getCooldown(ability:Ability):Number
		{
			if (_data == null)
				loadXML();
				
			var abilityName:String = getAbilityName(ability).toLowerCase();
			var levelName:String = Assets.getLevelName(FlxG.level);
			
			return parseFloat(_data.level.(@name == levelName).ability.(@name == abilityName).Cooldown.text());
		};
		
		public static function getInventory(ability:Ability):uint
		{
			if (_data == null)
				loadXML();
				
			var abilityName:String = getAbilityName(ability).toLowerCase();
			var levelName:String = Assets.getLevelName(FlxG.level);
			
			return parseFloat(_data.level.(@name == levelName).ability.(@name == abilityName).Inventory.text());
		}
		
		public static function getDiameter(ability:Ability):uint
		{
			if (_data == null)
				loadXML();
				
			var abilityName:String = getAbilityName(ability).toLowerCase();
			var levelName:String = Assets.getLevelName(FlxG.level);
			
			return parseFloat(_data.level.(@name == levelName).ability.(@name == abilityName).Diameter.text());
		}
		
		public static function getDuration(ability:Ability):Number
		{
			if (_data == null)
				loadXML();
				
			var abilityName:String = getAbilityName(ability).toLowerCase();
			var levelName:String = Assets.getLevelName(FlxG.level);
			
			return parseFloat(_data.level.(@name == levelName).ability.(@name == abilityName).Duration.text());
		};
		
		public static function getAmount(ability:Ability):Number
		{
			if (_data == null)
				loadXML();
				
			var abilityName:String = getAbilityName(ability).toLowerCase();
			var levelName:String = Assets.getLevelName(FlxG.level);
			
			return parseFloat(_data.level.(@name == levelName).ability.(@name == abilityName).Amount.text());
		};
		
		public static function getLevelInfoHeader():String
		{
			if (_data == null)
				loadXML();
				
			var levelName:String = Assets.getLevelName(FlxG.level);
			return _data.level.(@name == levelName).LevelInfo.Header.text();
		}
		
		public static function getLevelInfoBody():String
		{
			if (_data == null)
				loadXML();
				
			var levelName:String = Assets.getLevelName(FlxG.level);
			return _data.level.(@name == levelName).LevelInfo.Body.text();
		}
		
		private static function loadXML():void
		{
			var file:ByteArray;
			var classInstance:Class;
			classInstance = Assets.getResource("ability_info.xml");
			file = new classInstance() as ByteArray;
						
			var str:String = file.readUTFBytes(file.length);			
			_data = new XML(str);
		}
		
		private static function getAbilityName(ability:Ability):String
		{
			var abilityName:String = null;
			if (ability is DeathsClutch) abilityName = "DeathsCluth";
			if (ability is Demon) abilityName = "Demon";
			if (ability is Ectoplasm) abilityName = "Ectoplasm";
			if (ability is Haunt) abilityName = "Haunt";
			if (ability is Onryo) abilityName = "Onryo";
			if (ability is Possess) abilityName = "Possess";
			if (ability is Scare) abilityName = "Scare";
			if (ability is SealDoor) abilityName = "SealDoor";
			return abilityName;
		}
	}

}