/**
 * Created by Administrator on 2015/8/5.
 */
package com.senocular.display
{
	import flash.events.Event;
	import flash.geom.Point;

	public class TransformToolRotateControl extends TransformToolInternalControl
	{

		private var locationName:String;

		function TransformToolRotateControl(name:String, interactionMethod:Function, locationName:String)
		{
			super(name, interactionMethod);
			this.locationName = locationName;
		}

		override public function draw(event:Event = null):void
		{
			graphics.clear();
			if (!_skin)
			{
				graphics.lineStyle(1, 0, 0);
				graphics.beginFill(0xffffff, 0);
				graphics.drawCircle(0, 0, _transformTool.controlSize * 3);
				graphics.endFill();
			}
			super.draw();
		}

		override public function position(event:Event = null):void
		{
			if (locationName in _transformTool)
			{
				var location:Point = _transformTool[locationName];
				x = location.x;
				y = location.y;
				/*
				 switch(locationName){
				 case "boundsTopLeft":
				 x=location.x-10;
				 y=location.y-10;
				 break;
				 case "boundsTopRight":
				 x=location.x+10;
				 y=location.y-10;
				 break;
				 case "boundsBottomLeft":
				 x=location.x-10;
				 y=location.y+10;
				 break;
				 case "boundsBottomRight":
				 x=location.x+10;
				 y=location.y+10;
				 break;
				 default:
				 break;
				 }
				 */
			}
		}
	}
}
