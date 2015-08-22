/**
 * Created by Administrator on 2015/7/27 0027.
 */
package geometry.manager
{
	import flash.geom.Point;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import geometry.interfaces.IShape;
	import geometry.pattern.event.GameDispatcher;
	import geometry.pattern.event.GameEvent;
	import geometry.pattern.event.GameEventConst;
	import geometry.ui.MatchPointUI;
	import geometry.ui.ShapeContainerUI;
	import geometry.ui.shapes.PointData;
	import geometry.ui.shapes.PolygonShape;
	import geometry.utils.MathTool;

	public class CollisionCheckManager
	{
		/**精度*/
		public static const PRECISION:Number = 3;

		private var _collisionVec:Vector.<IShape>;
		public var _collisionPointVec:Vector.<Point>;

		public function CollisionCheckManager()
		{
			_collisionVec = new Vector.<IShape>();
			_collisionPointVec = new Vector.<Point>();
			GameDispatcher.addEventListener(GameEventConst.HANDLER_PASTE_LINE, handlerPasteLine, false, 0, true);
		}

		private function handlerPasteLine(event:GameEvent):void
		{
			if (_collisionVec && _collisionVec.length > 1)
			{
				var source:IShape = _collisionVec[0];
				var target:IShape = _collisionVec[1];

				var sourceDatas:Vector.<Point> = source.ringVector(source.globalVertexDatas, _collisionPointVec[0], _collisionPointVec[1]);
				var targetDatas:Vector.<Point> = target.ringVector(target.globalVertexDatas, _collisionPointVec[0], _collisionPointVec[1]);

				//根据_collisionPointVec碰撞点的第一个点来比较
				var head:Point = _collisionPointVec[0];
				var tail:Point = _collisionPointVec[1];

				var i:int = 0, len:int = 0;

				var sourceObj:Object = sortSmallToBigVec(head, tail, sourceDatas);
				var targetObj:Object = sortSmallToBigVec(head, tail, targetDatas);

				//保证sourceDatas和targetDatas两个数组顺序一致，否则插入会错乱
				var sourceVec:Vector.<Point> = sourceDatas.slice();
				var targetVec:Vector.<Point> = targetDatas.slice();

				var insertPos:int = -1;//插入数据的位置
				var insertEndPos:int = -1;
				if (sourceObj.tail != sourceDatas.length - 1)//如果source的尾不在最后，那一定在第二个，第一个为头
				{
					insertPos = 2;
					insertEndPos = sourceDatas.length;
				} else
				{
					insertPos = 1;
					insertEndPos = sourceDatas.length - 1;
				}

				var targetClockWise:Boolean, sourceClockWise:Boolean;
				targetClockWise = targetObj.tail == targetDatas.length - 1;//首到尾
				sourceClockWise = sourceObj.tail == sourceDatas.length - 1;

				if (targetClockWise)
				{
					if (sourceClockWise)
					{
						for (i = insertPos; i < insertEndPos; i++)
						{
							targetVec.splice(0, 0, sourceVec[i]);
						}
					} else
					{//正确
						for (i = insertPos; i < insertEndPos; i++)
						{
							targetVec.splice(0, 0, sourceVec[insertEndPos - i + 1]);
						}
					}
				} else
				{
					if (sourceClockWise)
					{
						for (i = insertPos; i < insertEndPos; i++)
						{
							targetVec.splice(0, 0, sourceVec[i]);
						}
					} else
					{//正确
						for (i = insertPos; i < insertEndPos; i++)
						{
							targetVec.splice(1, 0, sourceVec[i]);
						}
					}
				}


				var vertexs:Vector.<PointData> = new Vector.<PointData>();
				for (i = 0; i < targetVec.length; i++)
				{
					vertexs.push(new PointData(targetVec[i].x, targetVec[i].y));
				}

				///去除不必要的点，三点共线原理
				var isOnLine:Boolean = false;
				var p1:Point, p2:Point, p3:Point;

				for (i = 0; i < vertexs.length; i++)
				{
					p1 = vertexs[i];
					p2 = vertexs[(i + 1) > (vertexs.length - 1) ? (i + 1) % vertexs.length : i + 1];
					p3 = vertexs[(i + 2) > (vertexs.length - 1) ? (i + 2 - vertexs.length) : i + 2];
					isOnLine = MathTool.threePointInLine(p1, p2, p3);
					if (isOnLine)
					{
						if (Math.abs(p1.x - p3.x) < PRECISION)
						{
							p1.x = p2.x = p3.x;
						}

						if (Math.abs(p1.y - p3.y) < PRECISION)
						{
							p1.y = p2.y = p3.y;
						}

						vertexs.splice(i + 1, 1);
					}
				}

				var lastP:Point = new Point();
				if (target.position.y < source.position.y)
				{
					lastP.y = target.position.y;
				} else
				{
					lastP.y = source.position.y;
				}

				if (target.position.x < source.position.x)
				{
					lastP.x = target.position.x;
				} else
				{
					lastP.x = source.position.x;
				}

				var timeId:uint = setTimeout(function ():void
				{
					source.destroy();
					target.destroy();
					_collisionPointVec.length = 0;
					_collisionVec.length = 0;
					clearTimeout(timeId);
				}, 1);

				var minX:Number = MathTool.getMinValue(vertexs, 1);
				var minY:Number = MathTool.getMinValue(vertexs, 2);

				for (i = 0, len = vertexs.length; i < len; i++)
				{
					vertexs[i].x -= minX;
					vertexs[i].y -= minY;
				}

				var shape:PolygonShape = new PolygonShape(vertexs);
				MemShapeManager.getInstance.addShape(shape);
				ShapeContainerUI.getInstance.addItem(shape);
				shape.position = lastP;
				lastP = null;
			}
		}

		/**
		 * 返回一个对象｛head:xxx,tail:xxx｝
		 * 并对vec进行从head到tail排序
		 * */
		private function sortSmallToBigVec(small:Point, big:Point, vec:Vector.<Point>):Object
		{
			var i:int = 0, len:int = 0;
			var startP:int = -1, endP:int = -1;

			for (i = 0, len = vec.length; i < len; i++)
			{
				if (Point.distance(vec[i], small) <= PRECISION)
				{
					startP = i;
				}
				if (Point.distance(vec[i], big) <= PRECISION)
				{
					endP = i;
				}
				if (startP != -1 && endP != -1)
				{
					break;
				}
			}

			if (startP != 0)
			{
				MathTool.backward(vec, startP);

				startP = endP = -1;
				for (i = 0, len = vec.length; i < len; i++)
				{
					if (Point.distance(vec[i], small) <= PRECISION)
					{
						startP = i;
					}
					if (Point.distance(vec[i], big) <= PRECISION)
					{
						endP = i;
					}
					if (startP != -1 && endP != -1)
					{
						break;
					}
				}
			}
			return {head: startP, tail: endP};
		}


		public function checkCollision(source:IShape):void
		{
			var isCollision:Boolean = check(source);
			if (!isCollision)
			{
				MatchPointUI.getInstance.cancelMatchLine();
			}
		}

		private function check(source:IShape):Boolean
		{
			var shapeVec:Vector.<IShape> = MemShapeManager.getInstance.shapeVectors;
			var target:IShape;
			var sourceVertexs:Vector.<Point> = source.globalVertexDatas;
			var sP1:Point, sP2:Point, tP1:Point, tP2:Point;
			var targetVertexs:Vector.<Point>;
			var dis1:Number = 0, dis2:Number = 0;
			var dis3:Number = 0, dis4:Number = 0;

			for (var i:int = 0, len:int = shapeVec.length; i < len; i++)
			{
				target = shapeVec[i];
				if (source != target)
				{
					targetVertexs = target.globalVertexDatas;
					for (var j:int = 0, len1:int = sourceVertexs.length; j < len1; j++)
					{
						sP1 = sourceVertexs[j];
						sP2 = sourceVertexs[(j + 1) % len1];

						for (var m:int = 0, len2:int = targetVertexs.length; m < len2; m++)
						{
							tP1 = targetVertexs[m];
							tP2 = targetVertexs[(m + 1) % len2];
							dis1 = Point.distance(sP1, tP1);
							dis2 = Point.distance(sP2, tP2);

							dis3 = Point.distance(sP1, tP2);
							dis4 = Point.distance(sP2, tP1);

							if ((dis1 <= PRECISION && dis2 <= PRECISION) || (dis3 <= PRECISION && dis4 <= PRECISION))
							{
								if (_collisionVec && _collisionVec.length > 0)
								{
									_collisionVec.length = 0;
								}
								if (_collisionPointVec && _collisionPointVec.length > 0)
								{
									_collisionPointVec.length = 0;
								}
								_collisionVec.push(source, target);
								_collisionPointVec.push(sP1, sP2);
								source.cancelDrag();
								GameDispatcher.dispatchEvent(GameEventConst.FIND_MATCH_POINT, {startP: sP1, endP: sP2});
								return true;
							}
						}
					}
				}
			}
			return false;
		}

		private static var _instance:CollisionCheckManager = null;

		public static function get getInstance():CollisionCheckManager
		{
			if (_instance == null)
			{
				_instance = new CollisionCheckManager();
			}
			return _instance;
		}
	}
}
