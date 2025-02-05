package funkin.data.scripts;

class ScriptManager extends FlxBasic
{
	public static var instance:ScriptManager;

	public function new()
	{
		super();
		this.visible = false;

		// instance = this;
	}
}
