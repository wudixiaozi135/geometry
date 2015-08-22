/**
 * Created by Administrator on 2015/7/24 0024.
 */
package geometry.manager
{
	import geometry.interfaces.IShape;

	public class MemShapeManager
	{
		private var _shapeVectors:Vector.<IShape>;

		public function MemShapeManager()
		{
			_shapeVectors=new Vector.<IShape>();
		}

		public function addShape(shape:IShape):void
		{
			_shapeVectors.push(shape);
		}

		public function removeShape(shape:IShape):void
		{
			var index:int=_shapeVectors.indexOf(shape);
			if(index>=0){
				_shapeVectors.splice(index,1);
			}
		}

		/**存储所有图形数据*/
		public function get shapeVectors():Vector.<IShape>
		{
			return _shapeVectors;
		}

		private static var _instance:MemShapeManager = null;

		public static function get getInstance():MemShapeManager
		{
			if (_instance == null)
			{
				_instance = new MemShapeManager();
			}
			return _instance;
		}
	}
}
