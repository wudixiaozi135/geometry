/**
 * Created by Administrator on 2015/8/5.
 */
package geometry.manager
{
	import com.senocular.display.TransformTool;

	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	import geometry.interfaces.IShape;
	import geometry.ui.shapes.PolygonShape;

	import org.flexlite.domUI.components.Group;

	public class TransformShapeManager
	{
		public static var isShowRotateFrame:Boolean = false;
		public static var isElaspe:Boolean = false;
		public static var delayShowRotateFrame:int = 800;
		public static var delayShowTimeID:int = 0;


		private var _transformTool:TransformTool;
		private var _target:PolygonShape;
		public function TransformShapeManager()
		{
			_transformTool = new TransformTool();
		}

		public function addTarget(shape:PolygonShape):void
		{
			if(_target){
				_target.removeTransformEvt();
				_target=null;
			}
			_target=shape;
			_target.hideVertex();
			if (_transformTool.parent)
			{
				Group(shape.parent).removeElement(_transformTool);
			}
			Group(shape.parent).addElement(_transformTool);
			_transformTool.target = shape;

			var container:Group = _transformTool.parent as Group;
			if (container)
			{
				container.setElementIndex(_transformTool, container.numElements - 1);
			}
			isShowRotateFrame = true;
		}

		public function setDelayTime(shape:IShape):void
		{
			delayShowTimeID = setTimeout(function ():void
			{
				TransformShapeManager.isElaspe = true;
				shape.showRotateFrame(true);
			}, delayShowRotateFrame);
		}

		public function clearTimeID():void
		{
			if (delayShowTimeID > 0)
			{
				clearTimeout(delayShowTimeID);
				delayShowTimeID = 0;
			}
		}

		public function reset():void
		{
			if(_target){
				_target.removeTransformEvt();
				_target=null;
			}
			_transformTool.target = null;
			isShowRotateFrame = false;
			isElaspe = false;
			clearTimeID();
		}

		private static var _instance:TransformShapeManager = null;

		public static function get getInstance():TransformShapeManager
		{
			if (_instance == null)
			{
				_instance = new TransformShapeManager();
			}
			return _instance;
		}
	}
}
