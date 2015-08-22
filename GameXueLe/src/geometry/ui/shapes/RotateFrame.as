/**
 * Created by Administrator on 2015/8/4.
 * 旋转外框
 */
package geometry.ui.shapes
{
	import flash.display.GraphicsPathCommand;
	import flash.geom.Point;

	import org.flexlite.domUI.components.Group;

	public class RotateFrame extends Group
	{
		private var _commands:Vector.<int>;
		private var _datas:Vector.<Number>;
		private var _localVertexDatas:Vector.<Point>;

		public function RotateFrame()
		{
			super();
			_localVertexDatas = new Vector.<Point>();

		}

		public function setVertexs(...args):void
		{
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
			_datas.push(datas[0].x, datas[0].y);
			_commands.push(GraphicsPathCommand.LINE_TO);

		}

	}
}
