/**
 * Created by Administrator on 2015/7/28.
 */
package geometry.ui.shapes
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFormatAlign;

	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.components.Label;
	import org.flexlite.domUI.core.UIComponent;

	public class CircleLabel extends Group
	{
		private var _circle:UIComponent;
		private var _label:Label;
		private var _callBack:Function;

		public function CircleLabel()
		{
			super();
			width = height = 30;

			_circle = new UIComponent();
			_circle.graphics.clear();
			_circle.graphics.beginFill(0xf4f4f4);
			_circle.graphics.drawCircle(15, 15, 15);
			_circle.graphics.endFill();
			addElement(_circle);
			_circle.mouseChildren = false;
			_circle.mouseEnabled = false;

			_label = new Label();
			_label.textColor = 0xA82A2A;
			_label.text = "粘合";
			addElement(_label);
			_label.textAlign = TextFormatAlign.LEFT;
			_label.mouseEnabled = false;
			_label.mouseChildren = false;
			_label.x = 1 + (width - _label.textWidth) >> 1;
			_label.y = (height - _label.textHeight) >> 1;

			addEventListener(MouseEvent.CLICK, onClick, false, 0, true);

			buttonMode = true;
			mouseEnabled = true;
		}

		public function setPosition(p:Point):void
		{
			x = p.x - 15;
			y = p.y - 15;
		}

		private function onClick(event:MouseEvent):void
		{
			if (_callBack != null)
			{
				_callBack();
			}
		}

		public function set callBack(value:Function):void
		{
			_callBack = value;
		}

		public function destroy():void
		{
			removeEventListener(MouseEvent.CLICK, onClick);
			removeAllElements();
		}
	}
}
