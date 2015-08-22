package
{

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;

	import geometry.ui.GeometryMainUI;

	[SWF(backgroundColor="#818285", frameRate='60')]
	public class Main extends Sprite
	{
		public function Main()
		{
			if (stage)
			{
				init();
			} else
			{
				addEventListener(Event.ADDED_TO_STAGE, function ():void
				{
					init();
					removeEventListener(Event.ADDED_TO_STAGE, arguments.callee);
				}, false, 0, true);
			}
		}

		private function init():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			addChild(new GeometryMainUI());
		}
	}
}
