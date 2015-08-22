/**
 * Created by Administrator on 2015/7/23 0023.
 */
package geometry.manager
{
	import geometry.ui.BottomUI;
	import geometry.ui.GeometryMainUI;
	import geometry.ui.MatchPointUI;
	import geometry.ui.PenUI;
	import geometry.ui.ShapeContainerUI;

	import org.flexlite.domUI.core.IVisualElement;

	public class LayerManager
	{

		private var _mainUI:GeometryMainUI;

		public function LayerManager()
		{
		}

		public function initUI(mainUI:GeometryMainUI):void
		{
			_mainUI = mainUI;
			_mainUI.addElement(ShapeContainerUI.getInstance);
			_mainUI.addElement(PenUI.getInstance);
			_mainUI.addElement(BottomUI.getInstance);
			_mainUI.addElement(MatchPointUI.getInstance);
		}

		public function swapLayerLevel(layer1:IVisualElement, layer2:IVisualElement):void
		{
			_mainUI.swapElements(layer1, layer2);
		}

		public function setLayerLevel(layer:IVisualElement, index:int):void
		{
			_mainUI.setElementIndex(layer, index);
		}

		public function getLayerLevel(layer:IVisualElement):int
		{
			return _mainUI.getElementIndex(layer);
		}

		private static var _instance:LayerManager = null;

		public static function get getInstance():LayerManager
		{
			if (_instance == null)
			{
				_instance = new LayerManager();
			}
			return _instance;
		}

	}
}
