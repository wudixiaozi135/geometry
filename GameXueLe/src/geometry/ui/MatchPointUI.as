/**
 * Created by Administrator on 2015/7/27.
 */
package geometry.ui
{
	import flash.geom.Point;

	import geometry.pattern.event.GameDispatcher;
	import geometry.pattern.event.GameEvent;
	import geometry.pattern.event.GameEventConst;
	import geometry.ui.shapes.MatchLineShape;

	import org.flexlite.domUI.components.Group;

	public class MatchPointUI extends Group
	{
		private var _matchLine:MatchLineShape;

		public function MatchPointUI()
		{
			super();
			mouseEnabled = false;
			GameDispatcher.addEventListener(GameEventConst.FIND_MATCH_POINT, handlerFindMatchPoint, false, 0, true);
			GameDispatcher.addEventListener(GameEventConst.HANDLER_PASTE_LINE,handlerPasteLine,false,0,true);
		}

		private function handlerPasteLine(event:GameEvent):void
		{
			destroyMatchLine();
		}

		private function handlerFindMatchPoint(event:GameEvent):void
		{
			var param:Object = event.param;
			if (param)
			{
				destroyMatchLine();
				var startP:Point = param.startP;
				var endP:Point = param.endP;
				addElement(_matchLine = new MatchLineShape());
				_matchLine.drawLine(startP.x, startP.y, endP.x, endP.y);
			}
		}

		public function get isExistPoint():Boolean
		{
			return _matchLine&&containsElement(_matchLine);
		}
		
		private function destroyMatchLine():void
		{
			if (_matchLine && containsElement(_matchLine))
			{
				removeElement(_matchLine);
				_matchLine.destroy();
				_matchLine = null;
			}
		}

		/**取消匹配线*/
		public function cancelMatchLine():void
		{
			if(isExistPoint){
				destroyMatchLine();
			}
		}

		private static var _instance:MatchPointUI = null;

		public static function get getInstance():MatchPointUI
		{
			if (_instance == null)
			{
				_instance = new MatchPointUI();
			}
			return _instance;
		}
	}
}
