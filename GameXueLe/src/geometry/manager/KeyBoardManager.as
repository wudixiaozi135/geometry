/**
 * Created by Administrator on 2015/8/20.
 */
package geometry.manager
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	import geometry.interfaces.IShape;

	public class KeyBoardManager
	{
		private var _stage:Stage;

		public function KeyBoardManager()
		{
		}

		public function init(stage:Stage):void
		{
			_stage = stage;
			_stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpEvt, false, 0, true);
		}

		private function onKeyUpEvt(event:KeyboardEvent):void
		{
			var keyCode:int = event.keyCode;
			if (keyCode == Keyboard.DELETE)
			{
				if (event.shiftKey)
				{
					dealDeleteAll();
				} else
				{
					dealDelete();
				}
			}
		}

		private function dealDeleteAll():void
		{
			var shapeVec:Vector.<IShape> = MemShapeManager.getInstance.shapeVectors;
			for (var i:int = shapeVec.length - 1; i >= 0; i--)
			{
				shapeVec[i].destroy();
			}
		}

		private function dealDelete():void
		{
			var shapeVec:Vector.<IShape> = MemShapeManager.getInstance.shapeVectors;
			for (var i:int = 0; i < shapeVec.length; i++)
			{
				if (shapeVec[i].isShowVertex)
				{
					shapeVec[i].destroy();
					break;
				}
			}
		}

		public function destroy():void
		{
			if (_stage)
			{
				_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUpEvt);
				_stage = null;
			}
			_instance = null;
		}

		private static var _instance:KeyBoardManager = null;

		public static function get getInstance():KeyBoardManager
		{
			if (_instance == null)
			{
				_instance = new KeyBoardManager();
			}
			return _instance;
		}

	}
}
