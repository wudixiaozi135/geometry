/**
 * Created by Administrator on 2015/7/24 0024.
 */
package geometry.ui
{
	import flash.events.MouseEvent;
	import flash.geom.Point;

	import geometry.manager.MemShapeManager;
	import geometry.ui.shapes.PolygonShape;
	import geometry.utils.BasicShapeUtil;

	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.core.UIComponent;
	import org.flexlite.domUI.layouts.HorizontalLayout;

	public class BottomUI extends Group
	{
		public function BottomUI()
		{
			super();

			var horizonLayout:HorizontalLayout = new HorizontalLayout();
			horizonLayout.gap = 60;
			this.layout = horizonLayout;
			this.bottom = 100;
			this.horizontalCenter = 0;

			var barRect:UIComponent = BasicShapeUtil.getRect(50,50,0xbfc0c1,1,1,0x0,"barRect");
			barRect.buttonMode = true;
			barRect.toolTip = "点击生成一个三角形";
			this.addElement(barRect);

			var barTriangle:UIComponent=BasicShapeUtil.getTriangle(new Point(0, 0), new Point(50, 0), new Point(50, 50),0xbfc0c1,1,1,0x0,"barTriangle");
			barTriangle.buttonMode=true;
			barTriangle.toolTip = "点击生成一个矩形";
			this.addElement(barTriangle);
			this.addEventListener(MouseEvent.CLICK, handlerClick);
		}

		private function handlerClick(event:MouseEvent):void
		{
			var stageW:Number = stage.stageWidth;
			var stageH:Number = stage.stageHeight;
			var targetName:String = event.target.name;
			if (targetName == "barRect")
			{
				var rectShape:PolygonShape=new PolygonShape(new Point(0, 0), new Point(100, 0), new Point(100, 100), new Point(0, 100));
				MemShapeManager.getInstance.addShape(rectShape);
				ShapeContainerUI.getInstance.addItem(rectShape);
				rectShape.x = (stageW - rectShape.width) >> 1;
				rectShape.y = (stageH - rectShape.height) >> 1;
			}else if(targetName=="barTriangle"){
				var triangleShape:PolygonShape = new PolygonShape(new Point(0, 100), new Point(100, 0), new Point(200, 100));
				MemShapeManager.getInstance.addShape(triangleShape);
				ShapeContainerUI.getInstance.addItem(triangleShape);
				triangleShape.x = (stageW - triangleShape.width) >> 1;
				triangleShape.y = (stageH - triangleShape.height) >> 1;
			}
		}


		private static var _instance:BottomUI = null;

		public static function get getInstance():BottomUI
		{
			if (_instance == null)
			{
				_instance = new BottomUI();
			}
			return _instance;
		}
	}
}
