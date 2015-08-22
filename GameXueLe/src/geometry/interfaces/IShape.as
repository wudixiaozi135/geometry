/**
 * Created by Administrator on 2015/7/23 0023.
 */
package geometry.interfaces
{
	import flash.geom.Point;

	import geometry.pattern.IObserver;

	public interface IShape extends IObserver
	{
		function get globalVertexDatas():Vector.<Point>;

		function get localVertexDatas():Vector.<Point>;

		function drawInsect(start:Point, end:Point):void;

		function clearInsect():void;

		function canClick(x:Number, y:Number):Boolean;

		function checkPointInLine(a:Point, b:Point, c:Point):Boolean;

		function makeNewVertex():Array;

		function insectStartPoint():Point;

		function insectEndPoint():Point;

		function cancelDrag():void;

		function get insectRadian():Number;

		function get insectAngle():Number;

		function get distance():Number;

		function globalToLocal(point:Point):Point;

		function localToGlobal(point:Point):Point;

		function ringVector(data:*, head:Point, tail:Point,isGlobal:Boolean=true):*;

		/**紧凑数据*/
		function compactDatas(data:*):Object;
		function get position():Point;
		function set position(point:Point):void;

		function get isShowVertex():Boolean;
		function showRotateFrame(bool:Boolean):void;
		function destroy():void;
	}
}
