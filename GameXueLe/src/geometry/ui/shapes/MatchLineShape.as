/**
 * Created by Administrator on 2015/7/27.
 */
package geometry.ui.shapes
{
	import flash.display.Graphics;
	import flash.geom.Point;

	import geometry.pattern.event.GameDispatcher;
	import geometry.pattern.event.GameEventConst;

	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.core.UIComponent;

	public class MatchLineShape extends Group
	{
		private var _matchLine:UIComponent;

		private var _circleLabel:CircleLabel;

		public function MatchLineShape()
		{
			super();
			mouseEnabled = false;
			_matchLine = new UIComponent();
			_matchLine.mouseEnabled = false;
			addElement(_matchLine);

			_circleLabel = new CircleLabel();
			addElement(_circleLabel);
			_circleLabel.callBack=handlerPaste;
		}

		/**处理粘合*/
		private function handlerPaste():void
		{
			GameDispatcher.dispatchEvent(GameEventConst.HANDLER_PASTE_LINE);
		}

		public function drawLine(startX:Number, startY:Number, endX:Number, endY:Number):void
		{
			var pen:Graphics, color:uint;
			pen = _matchLine.graphics;
			color = 0xff00ff;
			if (pen != null)
			{
				with (pen)
				{
					clear();
					lineStyle(5, color);
					moveTo(startX, startY);
					lineTo(endX, endY);
				}
			}

			var center:Point = Point.interpolate(new Point(startX, startY), new Point(endX, endY), .5);
			_circleLabel.setPosition(center);
		}

		public function destroy():void
		{
			if (_circleLabel)
			{
				_circleLabel.destroy();
				_circleLabel.callBack=null;
			}
			removeAllElements();
		}
	}
}
