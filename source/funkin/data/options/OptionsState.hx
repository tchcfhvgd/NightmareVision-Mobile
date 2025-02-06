package funkin.data.options;

import openfl.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import openfl.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import funkin.data.Controls;
import funkin.data.*;
import funkin.states.*;
import funkin.states.substates.*;
import funkin.objects.*;

using StringTools;

class OptionsState extends MusicBeatState
{
	public static var onPlayState:Bool = false;

	var options:Array<String> = [
		'Notes',
		'Controls',
		'Adjust Delay and Combo',
		'Graphics',
		'Visuals and UI',
		'Gameplay',
		"Mobile Options"
	];
	private var grpOptions:FlxTypedGroup<Alphabet>;

	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	function openSelectedSubstate(label:String)
	{
		if (label != "Adjust Delay and Combo"){
			persistentUpdate = false;
			removeTouchPad();
		}
		switch (label)
		{
			case 'Notes':
				openSubState(new funkin.data.options.NoteSettingsSubState());
			case 'Controls':
				openSubState(new funkin.data.options.ControlsSubState());
			case 'Graphics':
				openSubState(new funkin.data.options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new funkin.data.options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new funkin.data.options.GameplaySettingsSubState());
			case 'Mobile Options':
				openSubState(new mobile.options.MobileOptionsSubState());
			case 'Adjust Delay and Combo':
				LoadingState.loadAndSwitchState(new funkin.data.options.NoteOffsetState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true, false);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true, false);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true, false);
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();

		addTouchPad("UP_DOWN", "A_B_C");
	}

	override function closeSubState()
	{
		super.closeSubState();
		persistentUpdate = true;
		removeTouchPad();
		addTouchPad("UP_DOWN", "A_B_C");
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (onPlayState)
			{
				StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else FlxG.switchState(new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			openSelectedSubstate(options[curSelected]);
		}

		if (touchPad != null && touchPad.buttonC.justPressed) {
			touchPad.active = touchPad.visible = persistentUpdate = false;
			openSubState(new mobile.MobileControlSelectSubState());
		}
	}

	function changeSelection(change:Int = 0)
	{
		curSelected += change;
		if (curSelected < 0) curSelected = options.length - 1;
		if (curSelected >= options.length) curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}
