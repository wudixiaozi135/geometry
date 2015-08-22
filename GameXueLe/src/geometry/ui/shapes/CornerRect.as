/**
 * Created by Administrator on 2015/8/5.
 */
package geometry.ui.shapes
{
	import com.greensock.TweenMax;

	import flash.display.Shape;
	import flash.events.MouseEvent;

	import geometry.interfaces.IDispose;

	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.components.UIAsset;

	public class CornerRect extends Group implements IDispose
	{
		private var _rect:Shape;

		public function CornerRect()
		{
			super();
			_rect = new Shape();

			_rect.graphics.lineStyle(1, 0xB44079, .8);
			_rect.graphics.beginFill(0xffffff);
			_rect.graphics.drawRect(0, 0, 15, 15);
			_rect.graphics.endFill();

			var ui:UIAsset = new UIAsset();
			ui.skinName = _rect;
			addElement(ui);

			addEventListener(MouseEvent.MOUSE_DOWN, handlerMouseDown, false, 0, true);
		}

		private function handlerMouseDown(event:MouseEvent):void
		{
			addEventListener(MouseEvent.MOUSE_UP, handlerMouseUp, false, 0, true);
			scaleWH(.5);
		}

		private function handlerMouseUp(event:MouseEvent):void
		{
			scaleWH(1);
			removeEventListener(MouseEvent.MOUSE_UP, handlerMouseUp);
		}

		private function scaleWH(scale:Number = .5):void
		{
			TweenMax.to(_rect, .5, {
				scaleX: scale,
				scaleY: scale,
				onUpdate: function ():void
				{
					_rect.x = (width - _rect.width) * .5;
					_rect.y = (height - _rect.height) * .5;
				}
			});
		}

		public function destroy():void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, handlerMouseDown);
			removeEventListener(MouseEvent.MOUSE_UP, handlerMouseUp);
			removeAllElements();
			if (_rect)
			{
				TweenMax.killTweensOf(_rect);
				_rect = null;
			}
		}
	}
}
