/**
 * Created by Administrator on 2015/7/22 0022.
 */
package geometry.ui.shapes
{
	import com.greensock.TweenMax;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.GraphicsPathCommand;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import geometry.interfaces.IDispose;
	import geometry.interfaces.IShape;
	import geometry.manager.CollisionCheckManager;
	import geometry.manager.MemShapeManager;
	import geometry.manager.TransformShapeManager;
	import geometry.pattern.IObserver;
	import geometry.pattern.event.GameDispatcher;
	import geometry.pattern.event.GameEvent;
	import geometry.pattern.event.GameEventConst;
	import geometry.pattern.messages.MessageConst;
	import geometry.ui.MatchPointUI;
	import geometry.ui.ShapeContainerUI;
	import geometry.utils.MathTool;

	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.core.UIComponent;

	public class PolygonShape extends Group implements IShape,IDispose
	{
		private var _commands:Vector.<int>;
		private var _datas:Vector.<Number>;
		private var _localVertexDatas:Vector.<Point>;
		private var _globalVertexDatas:Vector.<Point>;

		private var _shape:UIComponent;
		private var _vertexGroup:Group;
		private var _redLine:UIComponent;
		private var _bmd:BitmapData;

		private var _insectStartPoint:Point;
		private var _insectEndPoint:Point;

		public const gap:Number = 5;
		public const timeSpan:Number = .5;

		public const PRECISE:Number = .1;

		private var _vertexDic:Dictionary;

		private var _mouseDownPx:int = -1;
		private var _mouseDownPy:int = -1;
		//上次点击的控制点
		private var _lastTarget:Vertex;

		public function PolygonShape(...args)
		{
			_localVertexDatas = new Vector.<Point>();
			_commands = new Vector.<int>();
			_datas = new Vector.<Number>();
			_vertexDic = new Dictionary();

			var point:Point, datas:*;
			if (args.length == 1)
			{
				if (args[0] is Vector.<PointData>)
				{
					datas = args[0];
				}
			} else
			{
				datas = args;
			}

			var i:int = 0;
			for (i = 0; i < datas.length; i++)
			{
				point = datas[i];
				_localVertexDatas.push(point);
				if (i == 0)
				{
					_commands.push(GraphicsPathCommand.MOVE_TO);
				} else
				{
					_commands.push(GraphicsPathCommand.LINE_TO);
				}
				_datas.push(point.x, point.y);
			}
			_globalVertexDatas = new Vector.<Point>(_localVertexDatas.length);
			_datas.push(datas[0].x, datas[0].y);
			_commands.push(GraphicsPathCommand.LINE_TO);

			_shape = new UIComponent();
			_shape.mouseEnabled = false;
			_shape.mouseChildren = false;
			addElementAt(_shape, 0);
			addElement(_vertexGroup = new Group());
			addElement(_redLine = new UIComponent());

			initVertexGroup();

			addEventListener(Event.ADDED_TO_STAGE, function ():void
			{
				removeEventListener(Event.ADDED_TO_STAGE, arguments.callee);
				addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			}, false, 0, true);
			reDraw();
		}

		/**初始化顶点形状*/
		private function initVertexGroup():void
		{
			if (_datas)
			{
				for (var i:int = 0; i < _datas.length - 2; i += 2)
				{
					var vertex:Vertex = null;
					if (!_vertexDic[i])
					{
						_vertexDic[i] = new Vertex()
								.setPoint(new Point(_datas[i], _datas[i + 1]))
								.setDownHandler(handlerVertexDown)
								.setMoveHandler(handlerVertexMove)
								.setVisible(false);
					}
					vertex = _vertexDic[i];
					if (!_vertexGroup.containsElement(vertex))
					{
						_vertexGroup.addElement(vertex);
					}
				}
			}
		}

		/**
		 * 处理翻转变形
		 * */
		private function handlerTransform(event:GameEvent):void
		{
			var vec:Vector.<PointData> = new Vector.<PointData>();
			var global:Point, i:int = 0;
			for (i = 0; i < _datas.length - 2; i += 2)
			{
				var vertex:Vertex = _vertexDic[i];
				global = _vertexGroup.localToGlobal(vertex.point);
				vec.push(new PointData(global.x, global.y));
			}

			//重塑数据，使其紧凑，分割时也是同理
			var obj:Object = compactDatas(vec);
			var rectShape:PolygonShape = new PolygonShape(vec);
			MemShapeManager.getInstance.addShape(rectShape);
			ShapeContainerUI.getInstance.addItem(rectShape);
			rectShape.x = obj.minX;
			rectShape.y = obj.minY;
			destroy();
		}

		private function onMouseDown(event:MouseEvent):void
		{
			var target:* = event.target;
			if (target is Vertex)
			{
				var vertex:Vertex = target as Vertex;
				_lastTarget = vertex;
				for each(var item:Vertex in _vertexDic)
				{
					if (item == _lastTarget) continue;
					item.mouseEnabled = false;
				}

				var newPoint:Point = vertex.point;
				var px:Number, py:Number;
				//单击顶点后找到数组中的位置
				for (var i:int = 0; i < _datas.length; i += 2)
				{
					px = _datas[i];
					py = _datas[i + 1];
					if ((Math.abs(newPoint.x - px) <= PRECISE) && (Math.abs(newPoint.y - py) <= PRECISE))
					{
						_mouseDownPx = i;
						_mouseDownPy = i + 1;
						break;
					}
				}
			}

			trace("aaa: ", _mouseDownPx, _mouseDownPy);

			if ((target is PolygonShape) && canClick(event.localX, event.localY))
			{
				startDrag(false);
				addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
				addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);

				if (MatchPointUI.getInstance.isExistPoint)
				{
					MatchPointUI.getInstance.cancelMatchLine();
				}
			}
		}

		private function handlerVertexDown(event:MouseEvent):void
		{
			var vertex:Vertex = event.target as Vertex;
			if (vertex)
			{
				_lastTarget = vertex;
				for each(var item:Vertex in _vertexDic)
				{
					if (item == _lastTarget) continue;
					item.mouseEnabled = false;
				}

				var newPoint:Point = vertex.point;
				var px:Number, py:Number;
				//单击顶点后找到数组中的位置
				for (var i:int = 0; i < _datas.length; i += 2)
				{
					px = _datas[i];
					py = _datas[i + 1];

					if ((Math.abs(newPoint.x - px) <= PRECISE) && (Math.abs(newPoint.y - py) <= PRECISE))
					{
						_mouseDownPx = i;
						_mouseDownPy = i + 1;
						break;
					}
				}
				vertex.setVisible(true).startDrag();
				if (stage)
				{
					stage.addEventListener(MouseEvent.MOUSE_UP, onStageUp, false, 0, true);
				}
			}
		}

		private function onStageUp(event:MouseEvent):void
		{
			if (stage)
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, onStageUp);
			}
			if (_lastTarget)
			{
				_lastTarget.stopDrag();
				handlerVertexUp(_lastTarget);
				_lastTarget = null;
			}
		}

		private function handlerVertexUp(vertex:Vertex):void
		{
			if (vertex)
			{
				updateLocalVertex();
				_mouseDownPx = -1;
				_mouseDownPy = -1;

				vertex.setVisible(false);

				for each(var item:Vertex in _vertexDic)
				{
					item.mouseEnabled = true;
				}

				updateData(vertex.point);

				//重塑数据，使其紧凑，分割时也是同理
				var obj:Object = compactDatas(_localVertexDatas);
				var i:int = 0, count:int = 0, len:int = 0;
				for (i = 0, len = _localVertexDatas.length; i < len; i++)
				{
					_datas[count] = _localVertexDatas[i].x;
					_datas[count + 1] = _localVertexDatas[i].y;
					count += 2;
				}
				_datas[count] = _localVertexDatas[0].x;
				_datas[count + 1] = _localVertexDatas[0].y;

				reDraw();
				x += obj.minX;
				y += obj.minY;
			}
		}

		/**图形本身可视全局坐标*/
		public function globalXY(parent:PolygonShape, child:PolygonShape):Point
		{
			var point:Point = new Point(child.getMinLeft(), child.getMinTop());
			var global:Point = parent.localToGlobal(point);
			return global;
		}

		private function handlerVertexMove(event:MouseEvent):void
		{
			var vertex:Vertex = event.target as Vertex;
			if (vertex)
			{
				updateData(vertex.point);
			}
		}

		/**
		 * 更新局部坐标
		 * */
		private function updateLocalVertex():void
		{
			if (_localVertexDatas)
			{
				if (_mouseDownPx < 0) return;

				var localP:Point = _localVertexDatas[_mouseDownPx / 2];
				if (localP.x != _datas[_mouseDownPx])
				{
					localP.x = _datas[_mouseDownPx];
				}

				if (localP.y != _datas[_mouseDownPy])
				{
					localP.y = _datas[_mouseDownPy];
				}
			}
		}

		override public function getBounds(targetCoordinateSpace:DisplayObject):Rectangle
		{
			return _shape.getBounds(_shape);
		}

		private function updateData(newPoint:Point):void
		{
			if (_mouseDownPx != -1 && _mouseDownPy != -1)
			{
				if (_datas && _datas.length)
				{
					if ((_mouseDownPx == 0 && _mouseDownPx == 0))
					{
						_datas[_mouseDownPx] = newPoint.x;
						_datas[_mouseDownPy] = newPoint.y;

						_datas[_datas.length - 2] = newPoint.x;
						_datas[_datas.length - 1] = newPoint.y;
					} else
					{
						_datas[_mouseDownPx] = newPoint.x;
						_datas[_mouseDownPy] = newPoint.y;
					}
					reDraw();
				}
			}
		}

		private function onMouseMove(event:MouseEvent):void
		{
			if (MatchPointUI.getInstance.isExistPoint == false)
			{
				CollisionCheckManager.getInstance.checkCollision(this);
			}
		}

		private function onMouseUp(event:MouseEvent):void
		{
			stopDrag();
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}

		/**只重绘整个外框*/
		private function reDraw():void
		{
			_shape.graphics.clear();
			_shape.graphics.lineStyle(2, 0x0);
			_shape.graphics.beginFill(0xBFC0C1, .7);
			_shape.graphics.drawPath(_commands, _datas);
			_shape.graphics.endFill();

			for (var i:int = 0; i < _datas.length - 2; i += 2)
			{
				var vertex:Vertex = null;
				vertex = _vertexDic[i];
				vertex.setPoint(new Point(_datas[i], _datas[i + 1]));
			}

			_bmd && _bmd.dispose();
			_bmd = null;

			if (int(width) <= 0 || int(height) <= 0)
			{
				_bmd = new BitmapData(1, 1, false);
			} else
			{
				_bmd = new BitmapData(width, height, false);
			}
			_bmd.draw(_shape);
		}

		public function hideVertex():void
		{
			_vertexGroup.visible = false;
		}

		public function showVertex():void
		{
			_vertexGroup.visible = true;
		}

		public function get isShowVertex():Boolean
		{
			return _vertexGroup.visible;
		}

		override public function get width():Number
		{
			return getMaxLeft() - getMinLeft();
		}

		override public function get height():Number
		{
			return getMaxTop() - getMinTop();
		}

		public function get position():Point
		{
			return new Point(x, y);
		}

		public function set position(point:Point):void
		{
			x = point.x;
			y = point.y;
		}

		/**顶点集合*/
		public function get globalVertexDatas():Vector.<Point>
		{
			if (_localVertexDatas)
			{
				for (var i:int = 0, len:int = _localVertexDatas.length; i < len; i++)
				{
					if (!_globalVertexDatas[i])
					{
						_globalVertexDatas[i] = new Point(_localVertexDatas[i].x + x, _localVertexDatas[i].y + y);
					} else
					{
						if (_globalVertexDatas[i].x != _localVertexDatas[i].x + x)
						{
							_globalVertexDatas[i].x = _localVertexDatas[i].x + x;
						}
						if (_globalVertexDatas[i].y != _localVertexDatas[i].y + y)
						{
							_globalVertexDatas[i].y = _localVertexDatas[i].y + y;
						}
					}
				}
			}
			return _globalVertexDatas;
		}

		public function drawInsect(start:Point, end:Point):void
		{
			var localStart:Point = globalToLocal(start);
			var localEnd:Point = globalToLocal(end);

			_insectStartPoint = localStart;
			_insectEndPoint = localEnd;

			_redLine.graphics.clear();
			_redLine.graphics.lineStyle(2, 0xff0000);
			_redLine.graphics.moveTo(localStart.x, localStart.y);
			_redLine.graphics.lineTo(localEnd.x, localEnd.y);
			setElementIndex(_redLine, numElements - 1);
		}

		public function clearInsect():void
		{
			_redLine.graphics.clear();
		}

		public function canClick(x:Number, y:Number):Boolean
		{
			return _bmd && _bmd.getPixel(x, y) != 0xffffff;
		}

		public function checkPointInLine(a:Point, b:Point, c:Point):Boolean
		{
			return MathTool.IsPointInLine(a, b, c);
		}

		public function makeNewVertex():Array
		{
			var startP:Point = insectStartPoint();
			var endP:Point = insectEndPoint();
			if (!startP || !endP) return null;
			var startPosition:int = -1;
			var endPosition:int = -1;

			var bool:Boolean = false;
			var originData:Vector.<Point> = _localVertexDatas;
			var i:int = 0, j:int = 0, len:int = 0;

			var newVertex:Vector.<PointData> = new Vector.<PointData>();
			for (i = 0, len = originData.length; i < len; i++)
			{
				newVertex.push(new PointData(originData[i].x, originData[i].y));
				if (startPosition == -1)
				{
					bool = MathTool.IsPointInLine(originData[i], originData[(i + 1) % len], startP);
					if (bool)
					{
						startPosition = i;
						newVertex.push(new PointData(startP.x, startP.y, true));
					}
				}
				if (endPosition == -1)
				{
					bool = MathTool.IsPointInLine(originData[i], originData[(i + 1) % len], endP);
					if (bool)
					{
						endPosition = i;
						newVertex.push(new PointData(endP.x, endP.y, true));
					}
				}
			}

			if (!(newVertex[0].flag) && !(newVertex[newVertex.length - 1].flag))
			{
				newVertex = ringVector(newVertex, startP, endP, false);
			}

			if (!newVertex[0].flag)
			{
				newVertex = newVertex.reverse();
			}

			for (i = newVertex.length - 1; i >= 0; i--)
			{
				if (newVertex[i].flag)
				{
					endPosition = i;
					break;
				}
			}

			if (endPosition <= -1)
			{
				return null;
			}

			var vec1:Vector.<PointData> = new Vector.<PointData>();
			for (i = 0; i < endPosition + 1; i++)
			{
				vec1.push(new PointData(newVertex[i].x, newVertex[i].y));
			}

			var vec2:Vector.<PointData> = new Vector.<PointData>();
			for (i = endPosition; i < newVertex.length; i++)
			{
				vec2.push(new PointData(newVertex[i].x, newVertex[i].y));
			}
			vec2.push(new PointData(newVertex[0].x, newVertex[0].y));

			var exist:Boolean = MathTool.existZeroPoint(vec1);

			var globalVec1:Vector.<Point> = new Vector.<Point>();
			var globalVec2:Vector.<Point> = new Vector.<Point>();
			for (i = 0, len = vec1.length; i < len; i++)
			{
				globalVec1.push(localToGlobal(vec1[i]));
			}
			for (i = 0, len = vec2.length; i < len; i++)
			{
				globalVec2.push(localToGlobal(vec2[i]));
			}

			compactDatas(vec1);
			compactDatas(vec2);
			if (!exist)//不存在零点就是分离的图形
			{
				return [{
					data: vec2,
					position: new Point(MathTool.getMinValue(globalVec2, 1), MathTool.getMinValue(globalVec2, 2))
				}, {
					data: vec1,
					position: new Point(MathTool.getMinValue(globalVec1, 1), MathTool.getMinValue(globalVec1, 2))
				}];
			} else
			{
				return [{
					data: vec1,
					position: new Point(MathTool.getMinValue(globalVec1, 1), MathTool.getMinValue(globalVec1, 2))
				}, {
					data: vec2,
					position: new Point(MathTool.getMinValue(globalVec2, 1), MathTool.getMinValue(globalVec2, 2))
				}];
			}
			return null;
		}

		/**使数据紧凑*/
		public function compactDatas(data:*):Object
		{
			var minX:Number = 0, minY:Number = 0;
			minX = MathTool.getMinValue(data, 1);
			minY = MathTool.getMinValue(data, 2);
			data.forEach(function (element:*, index:int, vector:*):void
			{
				element.x -= minX;
				element.y -= minY;
			});
			return {minX: minX, minY: minY};
		}

		public function carveShapes():void
		{
			//0是位置未改变的 1分离的图形位置发生改变
			var newVertex:Array = makeNewVertex();
			var vertexs:Vector.<PointData>;
			if (!newVertex || newVertex.length <= 0 || newVertex[0].data.length <= 0 || newVertex[1].data.length <= 0) return;

			if (newVertex && newVertex.length > 1)
			{
				var diffP:Point = _insectEndPoint.subtract(_insectStartPoint);
				var layout:int = 0;
				if (Math.abs(diffP.x) > Math.abs(diffP.y))
				{
					layout = 1;//偏水平
				} else
				{
					layout = 2;//偏垂直
				}

				var vertex1:Vector.<PointData> = newVertex[0].data;
				var vertex2:Vector.<PointData> = newVertex[1].data;
				var shape1:PolygonShape = new PolygonShape(vertex1);
				MemShapeManager.getInstance.addShape(shape1);
				ShapeContainerUI.getInstance.addItem(shape1);
				shape1.position = newVertex[0].position;

				var shape2:PolygonShape = new PolygonShape(vertex2);//分离的图形
				MemShapeManager.getInstance.addShape(shape2);
				ShapeContainerUI.getInstance.addItem(shape2);
				shape2.position = newVertex[1].position;


				var shape1MaxLeft:Number = shape1.getMaxLeft();
				var shape1MinLeft:Number = shape1.getMinLeft();

				var shape1MaxTop:Number = shape1.getMaxTop();
				var shape1MinTop:Number = shape1.getMinTop();

				var shape1Width:Number = shape1MaxLeft - shape1MinLeft;
				var shape1Height:Number = shape1MaxTop - shape1MinTop;

				var shape2MaxLeft:Number = shape2.getMaxLeft();
				var shape2MinLeft:Number = shape2.getMinLeft();

				var shape2MaxTop:Number = shape2.getMaxTop();
				var shape2MinTop:Number = shape2.getMinTop();

				var shape2Width:Number = shape2MaxLeft - shape2MinLeft;
				var shape2Height:Number = shape2MaxTop - shape2MinTop;

				//缓动处理
				if (layout == 1)
				{
					if (shape1.y < shape2.y)
					{
						TweenMax.to(shape1, timeSpan, {y: shape1.y - gap});
						TweenMax.to(shape2, timeSpan, {y: shape2.y + gap});
					} else if (shape1.y > shape2.y)
					{
						TweenMax.to(shape1, timeSpan, {y: shape1.y + gap});
						TweenMax.to(shape2, timeSpan, {y: shape2.y - gap});
					} else
					{
						if (shape1.x < shape2.x)
						{
							TweenMax.to(shape1, timeSpan, {x: shape1.x - gap});
							TweenMax.to(shape2, timeSpan, {x: shape2.x + gap});
						} else if (shape1.x > shape2.x)
						{
							TweenMax.to(shape1, timeSpan, {x: shape1.x + gap});
							TweenMax.to(shape2, timeSpan, {x: shape2.x - gap});
						} else
						{
							if (shape1Height < shape2Height)
							{
								TweenMax.to(shape1, timeSpan, {y: shape1.y - gap});
								TweenMax.to(shape2, timeSpan, {y: shape2.y + gap});
							} else
							{
								TweenMax.to(shape1, timeSpan, {y: shape1.y - gap});
								TweenMax.to(shape2, timeSpan, {y: shape2.y + gap});
							}
						}
					}
				} else
				{
					if (shape1.x < shape2.x)
					{
						TweenMax.to(shape1, timeSpan, {x: shape1.x - gap});
						TweenMax.to(shape2, timeSpan, {x: shape2.x + gap});
					} else if (shape1.x > shape2.x)
					{
						TweenMax.to(shape1, timeSpan, {x: shape1.x + gap});
						TweenMax.to(shape2, timeSpan, {x: shape2.x - gap});
					} else
					{
						if (shape1.y < shape2.y)
						{
							TweenMax.to(shape1, timeSpan, {y: shape1.y - gap});
							TweenMax.to(shape2, timeSpan, {y: shape2.y + gap});
						} else if (shape1.y > shape2.y)
						{
							TweenMax.to(shape1, timeSpan, {y: shape1.y - gap});
							TweenMax.to(shape2, timeSpan, {y: shape2.y + gap});
						} else
						{
							if (shape1Width < shape2Width)
							{
								TweenMax.to(shape1, timeSpan, {x: shape1.x - gap});
								TweenMax.to(shape2, timeSpan, {x: shape2.x + gap});
							} else
							{
								TweenMax.to(shape1, timeSpan, {x: shape1.x + gap});
								TweenMax.to(shape2, timeSpan, {x: shape2.x - gap});
							}
						}
					}
				}
			}

			var timeId:uint = setTimeout(function ():void
			{
				destroy();
				clearTimeout(timeId);
			}, 1);
		}

		private function getMaxTop():Number
		{
			var max:Number = _localVertexDatas[0].y;
			for (var i:int = 1, len:int = _localVertexDatas.length; i < len; i++)
			{
				if (max < _localVertexDatas[i].y)
				{
					max = _localVertexDatas[i].y;
				}
			}
			return max;
		}

		private function getMinTop():Number
		{
			var min:Number = _localVertexDatas[0].y;
			for (var i:int = 1, len:int = _localVertexDatas.length; i < len; i++)
			{
				if (min > _localVertexDatas[i].y)
				{
					min = _localVertexDatas[i].y;
				}
			}
			return min;
		}

		private function getMaxLeft():Number
		{
			var max:Number = _localVertexDatas[0].x;
			for (var i:int = 1, len:int = _localVertexDatas.length; i < len; i++)
			{
				if (max < _localVertexDatas[i].x)
				{
					max = _localVertexDatas[i].x;
				}
			}
			return max;
		}

		private function getMinLeft():Number
		{
			var min:Number = _localVertexDatas[0].x;
			for (var i:int = 1, len:int = _localVertexDatas.length; i < len; i++)
			{
				if (min > _localVertexDatas[i].x)
				{
					min = _localVertexDatas[i].x;
				}
			}
			return min;
		}


		/**局部坐标*/
		public function insectStartPoint():Point
		{
			return _insectStartPoint;
		}

		/**局部坐标*/
		public function insectEndPoint():Point
		{
			return _insectEndPoint;
		}

		public function update(observer:IObserver, command:int):void
		{
			if (observer != this)
			{
				if (command == MessageConst.message_001)
				{
					hideVertex();
				}
				if (command == MessageConst.DRAW_LINE_UP)
				{
					clearInsect();
					carveShapes();
				}
				return;
			}
			if (command == MessageConst.message_001)
			{
				showVertex();
			}
		}

		public function get insectRadian():Number
		{
			if (_insectStartPoint && _insectEndPoint)
			{
				return MathTool.getRadian(_insectStartPoint, _insectEndPoint);
			}
			return 0;
		}


		public function get insectAngle():Number
		{
			if (_insectStartPoint && _insectEndPoint)
			{
				return MathTool.getAngle(_insectStartPoint, _insectEndPoint);
			}
			return 0;
		}

		public function get distance():Number
		{
			if (_insectStartPoint && _insectEndPoint)
			{
				return MathTool.distance(_insectStartPoint, _insectEndPoint);
			}
			return 0;
		}

		public function cancelDrag():void
		{
			onMouseUp(null);
		}

		public function get localVertexDatas():Vector.<Point>
		{
			if (_localVertexDatas)
			{
				return _localVertexDatas;
			}
			return null;
		}

		/**构建类似一个环形队列
		 * forward 移步数
		 * */
		public function ringVector(data:*, head:Point, tail:Point, isGlobal:Boolean = true):*
		{
			var h:Point = null;
			var t:Point = null;
			if (isGlobal)
			{
				h = globalToLocal(head);
				t = globalToLocal(tail);
			} else
			{
				h = head;
				t = tail;
			}
			var hPos:int = -1, tPos:int = -1;
			for (var i:int = 0, len:int = data.length; i < len; i++)
			{
				if (Point.distance(h, data[i]) <= CollisionCheckManager.PRECISION)
				{
					hPos = i;
				}
				if (Point.distance(t, data[i]) <= CollisionCheckManager.PRECISION)
				{
					tPos = i;
				}
				if (hPos != -1 && tPos != -1)
				{
					break;
				}
			}

			if ((hPos == 0 && tPos == data.length - 1) || (hPos == data.length - 1 && tPos == 0))
			{
				return data;
			} else
			{
				var pos:int = hPos < tPos ? hPos : tPos;
				if (pos > data.length / 2)
				{
					MathTool.forward(data, data.length - hPos);
				} else
				{
					MathTool.backward(data, hPos);
				}
			}
			return data;
		}


		override public function globalToLocal(point:Point):Point
		{
			return super.globalToLocal(point);
		}

		override public function localToGlobal(point:Point):Point
		{
			return super.localToGlobal(point);
		}

		public function showRotateFrame(bool:Boolean):void
		{
			if (bool)
			{
				TransformShapeManager.getInstance.addTarget(this);
				addTransformEvt();

				if (TransformShapeManager.isShowRotateFrame)
				{
					stopDrag();
					removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
				}
			} else
			{
				TransformShapeManager.getInstance.reset();
			}
		}

		public function removeTransformEvt():void
		{
			GameDispatcher.removeEventListener(GameEventConst.TRANSFORM_VERTEX_DATA, handlerTransform);
		}

		public function addTransformEvt():void
		{
			removeTransformEvt();
			GameDispatcher.addEventListener(GameEventConst.TRANSFORM_VERTEX_DATA, handlerTransform);
		}

		public function destroy():void
		{
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			removeTransformEvt();
			TransformShapeManager.getInstance.reset();
			if (_commands)
			{
				_commands.length = 0;
				_commands = null;
			}
			if (_datas)
			{
				_datas.length = 0;
				_datas = null;
			}

			if (_localVertexDatas)
			{
				_localVertexDatas.forEach(function (element:Point, index:int, vec:Vector.<Point>):void
				{
					element = null;
				});
				_localVertexDatas.length = 0;
				_localVertexDatas = null;
			}
			if (_globalVertexDatas)
			{
				_globalVertexDatas.forEach(function (element:Point, index:int, vec:Vector.<Point>):void
				{
					element = null;
				});
				_globalVertexDatas.length = 0;
				_globalVertexDatas = null;
			}

			_shape && (_shape = null);
			_insectEndPoint && (_insectEndPoint = null);
			_insectStartPoint && (_insectStartPoint = null);

			clearInsect();
			removeAllElements();

			_redLine && (_redLine = null);
			if (_vertexGroup)
			{
				_vertexGroup.removeAllElements();
				_vertexGroup = null;
			}

			if (_vertexDic)
			{
				for (var key:String in _vertexDic)
				{
					delete _vertexDic[key];
				}
				_vertexDic = null;
			}
			if (stage)
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP, onStageUp);
			}
			removeTransformEvt();
			MemShapeManager.getInstance.removeShape(this);
			ShapeContainerUI.getInstance.removeItem(this);
		}
	}
}
