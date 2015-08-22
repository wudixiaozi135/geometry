/**
 * Created by Administrator on 2015/7/23 0023.
 */
package geometry.manager
{
	import flash.geom.Point;

	import geometry.interfaces.IShape;
	import geometry.utils.MathTool;

	public class IntersectPointManager
	{
		private var _startPoint:Point;
		private var _endPoint:Point;

		public function IntersectPointManager()
		{
		}

		/**
		 * 这里使用的是全局点
		 * */
		public function checkIntersectPoint(vertexDatas:Vector.<Point>, shape:IShape):int
		{
			var intersectDatas:Vector.<Point> = new Vector.<Point>();
			var intersectPoint:Point;
			if (startPoint == null || endPoint == null) return 0;

			for (var i:int = 0, len:int = vertexDatas.length; i < len; i++)
			{
				if (vertexDatas[i])
				{
					intersectPoint = MathTool.IsIntersect(vertexDatas[i], vertexDatas[(i + 1) % len], startPoint, endPoint);
				}
				if (intersectPoint != null)
				{
					intersectDatas.push(intersectPoint);
				}
			}

			if (intersectDatas.length > 1)
			{
				var diffP:Point = endPoint.subtract(startPoint);
				var layout:int = 0;
				if (Math.abs(diffP.x) > Math.abs(diffP.y))
				{
					layout = 1;//偏水平
				} else
				{
					layout = 2;//偏垂直
				}

				var temp:Point;
				if (layout == 1)
				{
					if (intersectDatas[0].x > intersectDatas[1].x)
					{
						temp = intersectDatas[0];
						intersectDatas[0] = intersectDatas[1];
						intersectDatas[1] = temp;
					}
				} else
				{
					if (intersectDatas[0].y > intersectDatas[1].y)
					{
						temp = intersectDatas[0];
						intersectDatas[0] = intersectDatas[1];
						intersectDatas[1] = temp;
					}
				}
				shape.drawInsect(intersectDatas[0], intersectDatas[1]);
			} else
			{
				shape.clearInsect();
			}
			return intersectDatas.length;
		}


		public function get startPoint():Point
		{
			return _startPoint;
		}

		public function set startPoint(value:Point):void
		{
			_startPoint = value;
		}

		public function get endPoint():Point
		{
			return _endPoint;
		}

		public function set endPoint(value:Point):void
		{
			_endPoint = value;
		}

		private static var _instance:IntersectPointManager = null;

		public static function get getInstance():IntersectPointManager
		{
			if (_instance == null)
			{
				_instance = new IntersectPointManager();
			}
			return _instance;
		}
	}
}
