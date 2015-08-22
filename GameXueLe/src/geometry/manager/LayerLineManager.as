/**
 * Created by Administrator on 2015/7/23 0023.
 */
package geometry.manager
{
	import com.senocular.display.TransformToolInternalControl;
	import com.senocular.display.TransformToolMoveShape;

	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import geometry.interfaces.IShape;
	import geometry.pattern.messages.MessageConst;
	import geometry.ui.MatchPointUI;
	import geometry.ui.PenUI;
	import geometry.ui.ShapeContainerUI;
	import geometry.ui.shapes.PolygonShape;
	import geometry.ui.shapes.Vertex;

	public class LayerLineManager
	{
		private var _panelUI:ShapeContainerUI;
		private var _startX:Number = 0;
		private var _startY:Number = 0;
		private var _endX:Number = 0;
		private var _endY:Number = 0;

		private var _stage:Stage;

		public function LayerLineManager()
		{
		}

		public function init(stage:Stage):void
		{
			_stage = stage;
			_panelUI = ShapeContainerUI.getInstance;
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			_stage.addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);
		}

		private function onMouseClick(event:MouseEvent):void
		{
			if (TransformShapeManager.isShowRotateFrame)
			{
				var target:Object = event.target;
				var bool:Boolean = (target is TransformToolMoveShape) || (target is TransformToolInternalControl);
				if (bool == false)
				{
					TransformShapeManager.getInstance.reset();
				}
			}
		}

		private function onMouseDown(event:MouseEvent):void
		{
			var target:Object = event.target;
			trace("eventTarget: ", event.currentTarget, event.target);

			var isExcludeObj:Boolean = (target is Vertex) || (target is TransformToolMoveShape);
			if (isExcludeObj)
			{
				if (TransformShapeManager.isShowRotateFrame)
				{
					TransformShapeManager.getInstance.reset();
					var arr:Array = _stage.getObjectsUnderPoint(new Point(event.stageX, event.stageY));
					for each(var obj:* in arr)
					{
						if (obj is PolygonShape)
						{
							obj.startDrag(false);
							obj.addEventListener(MouseEvent.MOUSE_UP, function ():void
							{
								obj.removeEventListener(MouseEvent.MOUSE_UP, arguments.callee);
								obj.stopDrag();
							}, false, 100, true);
							break;
						}
					}
				}
				return;
			}

			if (target is TransformToolInternalControl)
				return;

			if (target is IShape)
			{
				var shape:IShape = target as IShape;
				if (shape.canClick(event.localX, event.localY))
				{
					return;
				}
			}

			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);

			_startX = event.stageX;
			_startY = event.stageY;
			IntersectPointManager.getInstance.startPoint = new Point(_startX, _startY);
		}

		private function onMouseUp(event:MouseEvent):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);

			_endX = event.stageX;
			_endY = event.stageY;

			IntersectPointManager.getInstance.endPoint = new Point(_endX, _endY);

			var count:int = checkInterSect();
			if (count <= 0)
			{
				IntersectPointManager.getInstance.startPoint = null;
				IntersectPointManager.getInstance.endPoint = null;
			}

			PenUI.getInstance.clear(PenUI.PEN_STYLE_GREEN);
			if (count > 1)
			{
				ShapeContainerUI.getInstance.notify(null, MessageConst.DRAW_LINE_UP);
				MatchPointUI.getInstance.cancelMatchLine();
			}
		}

		private function onMouseMove(event:MouseEvent):void
		{
			_endX = event.stageX;
			_endY = event.stageY;

			MouseTargetManager.currentTarget = event.currentTarget;
			MouseTargetManager.target = event.target;

			IntersectPointManager.getInstance.endPoint = new Point(_endX, _endY);
			PenUI.getInstance.drawLine(_startX, _startY, _endX, _endY, PenUI.PEN_STYLE_GREEN);

			var count:int = checkInterSect();
			var penIndex:int = LayerManager.getInstance.getLayerLevel(PenUI.getInstance);
			var shapeIndex:int = LayerManager.getInstance.getLayerLevel(ShapeContainerUI.getInstance);
			if (count > 0 && count % 2 == 0)
			{
				if (penIndex > shapeIndex)
				{
					LayerManager.getInstance.setLayerLevel(PenUI.getInstance, shapeIndex);
				}
			} else
			{
				if (penIndex < shapeIndex)
				{
					LayerManager.getInstance.setLayerLevel(PenUI.getInstance, shapeIndex);
				}
			}
		}

		/**返回交点数*/
		private function checkInterSect():int
		{
			var intersectCount:int = 0;
			var shapeDatas:Vector.<IShape> = MemShapeManager.getInstance.shapeVectors;
			for (var i:int = 0, len:int = shapeDatas.length; i < len; i++)
			{
				var shape:IShape = shapeDatas[i];
				intersectCount += IntersectPointManager.getInstance.checkIntersectPoint(shape.globalVertexDatas, shape);
			}
			return intersectCount;
		}

		private static var _instance:LayerLineManager = null;

		public static function get getInstance():LayerLineManager
		{
			if (_instance == null)
			{
				_instance = new LayerLineManager();
			}
			return _instance;
		}
	}
}
