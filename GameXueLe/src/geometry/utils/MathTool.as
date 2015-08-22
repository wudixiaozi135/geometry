/**
 * Created by Administrator on 2015/7/22 0022.
 */
package geometry.utils
{
	import flash.geom.Point;

	public class MathTool
	{
		public function MathTool()
		{
		}

		/**
		 * [1,2,3]==>[3,1,2]
		 * 前进几步
		 * */
		public static function forward(datas:*, step:int = 1):void
		{
			var i:int = 0, len:int = datas.length;
			var arr1:Vector.<Object> = new Vector.<Object>(datas.length);
			for (var t:int = 0; t < step; t++)
			{
				for (i = len - 1; i >= 0; i--)
				{
					arr1[i] = datas[(i - 1) < 0 ? len - 1 : i - 1];
				}

				for (i = 0; i < len; i++)
				{
					datas[i] = arr1[i];
				}
			}
		}

		/**
		 * [1,2,3]==>[2,3,1]
		 * step 后退几步
		 * */
		public static function backward(datas:*, step:int = 1):void
		{
			var i:int = 0, len:int = datas.length;
			var arr1:Vector.<Object> = new Vector.<Object>(datas.length);
			for (var t:int = 0; t < step; t++)
			{
				for (i = 0; i < len; i++)
				{
					arr1[i] = datas[(i + 1) % len];
				}

				for (i = 0; i < len; i++)
				{
					datas[i] = arr1[i];
				}
			}
		}

		public static function threePointInLine(p1:Point, p2:Point, p3:Point):Boolean
		{
			var result:Number = (p3.x - p1.x ) * (p2.y - p1.y) - (p3.y - p1.y) * (p2.x - p1.x);
//			trace("三点共线精度：5 ", result);
			var bool:Boolean = Math.abs(result * .01) <= 5;
			return bool;
		}

		public static function getAngleByThreePoint(first:Point, cen:Point, second:Point):Number
		{
			const M_PI:Number = 3.1415926535897;
			var ma_x:Number = first.x - cen.x;
			var ma_y:Number = first.y - cen.y;
			var mb_x:Number = second.x - cen.x;
			var mb_y:Number = second.y - cen.y;
			var v1:Number = (ma_x * mb_x) + (ma_y * mb_y);
			var ma_val:Number = Math.sqrt(ma_x * ma_x + ma_y * ma_y);
			var mb_val:Number = Math.sqrt(mb_x * mb_x + mb_y * mb_y);
			var cosM:Number = v1 / (ma_val * mb_val);
			var angleAMB:Number = Math.acos(cosM) * 180 / M_PI;
			return angleAMB;
		}


		/**判断两条线段是否相交
		 * 不相交 @return null
		 * 相交返回交点坐标 point
		 * */
		public static function IsIntersect(a:Point, b:Point, c:Point, d:Point):Point
		{
			// 三角形abc 面积的2倍
			var area_abc:Number = (a.x - c.x) * (b.y - c.y) - (a.y - c.y) * (b.x - c.x);

			// 三角形abd 面积的2倍
			var area_abd:Number = (a.x - d.x) * (b.y - d.y) - (a.y - d.y) * (b.x - d.x);

			// 面积符号相同则两点在线段同侧,不相交 (对点在线段上的情况,本例当作不相交处理);
			if (area_abc * area_abd >= 0)
			{
				return null;
			}

			// 三角形cda 面积的2倍
			var area_cda:Number = (c.x - a.x) * (d.y - a.y) - (c.y - a.y) * (d.x - a.x);
			// 三角形cdb 面积的2倍
			// 注意: 这里有一个小优化.不需要再用公式计算面积,而是通过已知的三个面积加减得出.
			var area_cdb:Number = area_cda + area_abc - area_abd;
			if (area_cda * area_cdb >= 0)
			{
				return null;
			}

			//计算交点坐标
			var t:Number = area_cda / ( area_abd - area_abc );
			var dx:Number = t * (b.x - a.x);
			var dy:Number = t * (b.y - a.y);

			var px:Number = a.x + dx;
			var py:Number = a.y + dy;

			return new Point(px, py);//这里强制使用整形坐标
		}

		/**判断点在线上*/
		public static function IsPointInLine(p1:Point, p2:Point, p:Point, nNear:Number = .5):Boolean
		{
			//精度值太大了，不准确
//			var value:Number = (p1.x - p.x) * (p2.y - p.y) - (p2.x - p.x) * (p1.y - p.y);
//			return Math.abs(int(value)) <= 1e-6 + 5;

			//可精确到两位小数点（不错）
			var value:Number = DistPt2Line(p1, p2, p);
//			trace("点在线上：",value);
			return value < nNear;
		}

		public static function DistPt2Line(ptStart:Point, ptEnd:Point, pt:Point):Number
		{
			var abx:Number = ptEnd.x - ptStart.x;
			var aby:Number = ptEnd.y - ptStart.y;
			var acx:Number = pt.x - ptStart.x;
			var acy:Number = pt.y - ptStart.y;

			var f:Number = abx * acx + aby * acy;
			if (f < 0)   return distance(ptStart, pt);

			var d:Number = abx * abx + aby * aby;
			if (f > d)   return distance(ptEnd, pt);

			f /= d;
			var dx:Number = ptStart.x + f * abx;
			var dy:Number = ptStart.y + f * aby;

			return distance(new Point(dx, dy), pt);
		}

		/**
		 * 求两点点距离
		 * */
		public static function distance(a:Point, b:Point):Number
		{
			return Point.distance(a, b);
		}

		public static function getAngle(p1:Point, p2:Point):Number
		{
			return Math.atan2(p2.y - p1.y, p2.x - p1.x) * 180 / Math.PI;
		}

		public static function getRadian(p1:Point, p2:Point):Number
		{
			return Math.atan2(p2.y - p1.y, p2.x - p1.x);
		}

		public static function getAngleByRadian(radian:Number):Number
		{
			return radian * 180 / Math.PI;
		}

		public static function getRadianByAngle(angle:Number):Number
		{
			return angle * Math.PI / 180;
		}

		public static function getRotation(p1:Point, p2:Point):Number
		{
			var r:Number = Math.PI / 2;
			if (p1.x != p2.x)
			{
				r = Math.atan((p1.y - p2.y) / (p1.x - p2.x));
			}
			return r;
		}

		/*
		 * 求出最小值
		 * @style 1根据点x求最小 2根据点y求最小
		 * */
		public static function getMinValue(vertex:*, style:int = 1):Number
		{
			var temp:Number;
			if (style == 1)
			{
				temp = vertex[0].x;
			} else if (style == 2)
			{
				temp = vertex[0].y;
			}
			for (var i:int = 1, len:int = vertex.length; i < len; i++)
			{
				if (style == 1)
				{
					if (vertex[i].x < temp)
					{
						temp = vertex[i].x;
					}
				} else if (style == 2)
				{
					if (vertex[i].y < temp)
					{
						temp = vertex[i].y;
					}
				}
			}
			return temp;
		}

		/*
		 * 求出最小值
		 * @style 1根据点x求最小 2根据点y求最小
		 * */
		public static function getMaxValue(vertex:*, style:int = 1):Number
		{
			var temp:Number;
			if (style == 1)
			{
				temp = vertex[0].x;
			} else if (style == 2)
			{
				temp = vertex[0].y;
			}
			for (var i:int = 1, len:int = vertex.length; i < len; i++)
			{
				if (style == 1)
				{
					if (vertex[i].x > temp)
					{
						temp = vertex[i].x;
					}
				} else if (style == 2)
				{
					if (vertex[i].y > temp)
					{
						temp = vertex[i].y;
					}
				}
			}
			return temp;
		}

		public static function existZeroPoint(vertex:*):Boolean
		{
			var zero:Point = new Point(0, 0);
			for each(var point:* in vertex)
			{
				if (zero.equals(point))
				{
					return true;
					break;
				}
			}
			return false;
		}

		/**
		 * 不影响原数据
		 * */
		public static function copyVectorPoint(source:Vector.<Point>):Vector.<Point>
		{
			var vec:Vector.<Point> = new Vector.<Point>();
			for (var i:int = 0, len:int = source.length; i < len; i++)
			{
				vec.push(new Point(source[i].x, source[i].y));
			}
			return vec;
		}

		/**
		 * 将点p绕点registration旋转多少弧度
		 * */
		public static function pointRotateToRadian(point:Point, registration:Point, rotateRadian:Number):Point
		{
			var cos:Number = Math.cos(rotateRadian);
			var sin:Number = Math.sin(rotateRadian);
			var offX:Number, offY:Number = 0;
			offX = (point.x - registration.x) * cos - (point.y - registration.y) * sin;
			offY = (point.x - registration.x) * sin + (point.y - registration.y) * cos;
			return new Point(offX, offY);
		}
	}
}
