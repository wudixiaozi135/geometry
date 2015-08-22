/**
 * Created by Administrator on 2015/7/23 0023.
 */
package geometry.ui.shapes
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import geometry.interfaces.IDispose;

	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.core.UIComponent;

	public class Vertex extends Group implements IDispose
	{
		private var _point:Point;
		/**
		 * 起初的原点
		 * */
		private var _bg:UIComponent;
		private var _circle:UIComponent;

		private var _moveHandler:Function;
		private var _upHandler:Function;
		private var _downHandler:Function;

		public function Vertex()
		{
			super();
			_point = new Point();
			addElement(_bg = new UIComponent());
			_bg.mouseEnabled = false;
			_bg.mouseChildren = false;

			addElement(_circle = new UIComponent());
			_circle.mouseChildren = false;
			_circle.mouseEnabled = false;

			_bg.graphics.clear();
			_bg.graphics.beginFill(0x4E7850);
			_bg.graphics.drawCircle(0, 0, 17);
			_bg.graphics.endFill();

			_circle.graphics.clear();
			_circle.graphics.beginFill(0x34B9E6);
			_circle.graphics.drawCircle(0, 0, 5);
			_circle.graphics.endFill();

			buttonMode = true;
			setVisible(false);

			addEventListener(MouseEvent.MOUSE_DOWN, onVertexDown);
			addEventListener(Event.REMOVED, function ():void
			{
				removeEventListener(Event.REMOVED, arguments.callee);
				destroy();
			}, false, 0, true);
		}

		private function onVertexDown(event:MouseEvent):void
		{
			if (_downHandler != null)
			{
				_downHandler.call(this, event);
			}
			addEventListener(MouseEvent.MOUSE_MOVE, onVertexMove);
			addEventListener(MouseEvent.MOUSE_UP, onVertexUp);
		}

		public function setPoint(p:Point):Vertex
		{
			if (_point.x != p.x)
			{
				_point.x = p.x;
			}
			if (_point.y != p.y)
			{
				_point.y = p.y;
			}
			x = _point.x;
			y = _point.y;
			return this;
		}

		private function onVertexUp(event:MouseEvent):void
		{
			if (_upHandler != null)
			{
				_upHandler.call(this, event);
			}
			removeEventListener(MouseEvent.MOUSE_MOVE, onVertexMove);
			removeEventListener(MouseEvent.MOUSE_UP, onVertexUp);
		}

		private function onVertexMove(event:MouseEvent):void
		{
			if (_moveHandler != null)
			{
				_moveHandler.call(this, event);
			}
		}


		public function setVisible(bool:Boolean = false):Vertex
		{
			if (_bg)
			{
				_bg.alpha = bool ? 1 : 0;
			}
			return this;
		}

		public function get point():Point
		{
			return new Point(x, y);
		}

		public function get moveHandler():Function
		{
			return _moveHandler;
		}

		public function setMoveHandler(value:Function):Vertex
		{
			if (_moveHandler != value)
			{
				_moveHandler = value;
			}
			return this;
		}

		public function get upHandler():Function
		{
			return _upHandler;
		}

		public function setUpHandler(value:Function):Vertex
		{
			if (_upHandler != value)
			{
				_upHandler = value;
			}
			return this;
		}

		public function get downHandler():Function
		{
			return _downHandler;
		}

		public function setDownHandler(value:Function):Vertex
		{
			if (_downHandler != value)
			{
				_downHandler = value;
			}
			return this;
		}

		public function destroy():void
		{
			removeEventListener(MouseEvent.MOUSE_MOVE, onVertexMove);
			removeEventListener(MouseEvent.MOUSE_UP, onVertexUp);
			removeEventListener(MouseEvent.MOUSE_DOWN, onVertexDown);
			_upHandler && (_upHandler = null);
			_moveHandler && (_moveHandler = null);
			_downHandler && (_downHandler = null);
			removeAllElements();
			_point && (_point = null);
			_bg && (_bg = null);
			_circle && (_circle = null);
		}
	}
}
