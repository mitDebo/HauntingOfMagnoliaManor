package com.polymath.halloween.abilities 
{
	import org.flixel.FlxButton;
	import org.flixel.FlxSprite;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxG;
	
	import com.polymath.halloween.Character;	
	import com.polymath.halloween.PlayState;
	
	public class Scare extends Ability
	{
		[Embed(source = "../../../../../data/gfx/scare_button.png")] private var ImgButton:Class;
		private var _buttonSprite:FlxSprite;
		
		public function Scare(X:uint, Y:uint, Callback:Function ) 
		{
			super(X, Y, Callback);
			width = 32;
			height = 16;
			
			_buttonSprite = new FlxSprite(0, 0);
			_buttonSprite.loadGraphic(ImgButton, true, false, 32, 16);
			_buttonSprite.addAnimation("up", [0]);
			_buttonSprite.addAnimation("down", [1]);
			
			loadGraphic(_buttonSprite);
			
			Enabled = true;
			Cooldown = AbilityInfo.getCooldown(this);
			
			makeTooltip("Scare", "Causes a single occupant that you select to flee in terror.");
		}
		
		override public function click():void
		{
			if (!inCooldown && Enabled) {
				state.SelectionMode = PlayState.SELECTION_CHARACTER;
			}
		}
		
		override public function makeSelectionWithObject(obj:FlxObject):void {
			var guest:Character = obj as Character;
			guest.scare();
			beginCooldown();
		}
		
		public override function update():void
		{	
			if (state.CurrentLevel.HasStarted) {
				Enabled = true;
			} else {
				Enabled = false;
			}
			
			if (Enabled) {
				if (_pressed && !inCooldown)
					_buttonSprite.play("down");
				else
					_buttonSprite.play("up");
				
			} else {
				_buttonSprite.play("down");
			}				
				
			super.update();
		}
	}

}