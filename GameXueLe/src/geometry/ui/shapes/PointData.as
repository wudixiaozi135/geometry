/**
 * Created by Administrator on 2015/7/24 0024.
 */
package geometry.ui.shapes
{
	import flash.geom.Point;

	public class PointData extends Point
	{
		public var flag:Boolean=false;
		public function PointData(x:Number = 0, y:Number = 0,flag:Boolean=false)
		{
			super(x, y);
			this.flag=flag;
		}

		override public function toString():String
		{
			return "(x="+x+",y="+y+",flag="+flag+")";
		}
	}
}
