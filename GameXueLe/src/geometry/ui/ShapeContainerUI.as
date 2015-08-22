/**
 * Created by Administrator on 2015/7/23 0023.
 */
package geometry.ui
{
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import geometry.interfaces.IShape;
	import geometry.manager.TransformShapeManager;
	import geometry.pattern.IObserver;
	import geometry.pattern.Stock;
	import geometry.pattern.messages.MessageConst;

	import org.flexlite.domUI.components.Group;

	public class ShapeContainerUI extends Group
	{
		private var _shapeStock:Stock;

		public function ShapeContainerUI()
		{
			super();
			percentHeight = percentWidth = 100;
			_shapeStock = new Stock();
			addEventListener(MouseEvent.MOUSE_DOWN, onClickHandler, false, 0, true);
		}

		private function onClickHandler(event:MouseEvent):void
		{
			if (event.target is IShape)
			{
				var target:* = null;
				var shape:IShape = event.target as IShape;
				var point:Point = new Point(event.localX, event.localY);
				if (!shape.canClick(point.x, point.y))
				{
					var array:Array = getObjectsUnderPoint(event.target.localToGlobal(point));
					var i:int = 0;
					for (i = array.length - 1; i >= 0; i--)
					{
						if (!(array[i] as IShape))
						{
							array.splice(i, 1);
						} else
						{
							if (array[i] == event.target)
							{
								array.splice(i, 1);
							}
						}
					}

					if (array.length > 0)
					{
						for (i = 0; i < array.length; i++)
						{
							if (array[i].canClick(point.x, point.y))
							{
								target = array[i];
								break;
							}
						}
					}
				} else
				{
					target = event.target;
				}
				if (target != null)
				{
					setElementIndex(target, numElements - 1);
					notify(target, MessageConst.message_001);
				}

				if (event.buttonDown)
				{//按下且未发生移动事件经历1秒显示边框
					TransformShapeManager.getInstance.setDelayTime(shape);
				}
			} else
			{
				if (event.buttonDown)
				{
					if (!TransformShapeManager.isElaspe)
					{
						TransformShapeManager.getInstance.reset();
					}
				}
			}

			addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}


		private function onMouseUp(event:MouseEvent):void
		{
			removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);

			if (!TransformShapeManager.isElaspe)
			{
				TransformShapeManager.getInstance.reset();
			}
		}

		private function onMouseMove(event:MouseEvent):void
		{
			if (event.buttonDown)
			{
				if (!TransformShapeManager.isElaspe)
				{
					TransformShapeManager.getInstance.reset();
				}
			}
		}

		public function addItem(item:*):void
		{
			addObserver(item);
			addElement(item);
			notify(item, MessageConst.message_001);
		}

		public function removeItem(item:*):void
		{
			removeObserver(item);
			removeElement(item);
		}

		public function addObserver(observer:IObserver):void
		{
			_shapeStock.attach(observer);
		}

		public function removeObserver(observer:IObserver):void
		{
			_shapeStock.detach(observer);
		}

		public function notify(observer:IObserver, command:int):void
		{
			_shapeStock.notify(observer, command);
		}

		private static var _instance:ShapeContainerUI = null;

		public static function get getInstance():ShapeContainerUI
		{
			if (_instance == null)
			{
				_instance = new ShapeContainerUI();
			}
			return _instance;
		}
	}
}
