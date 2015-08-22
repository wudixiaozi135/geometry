/**
 * Created by Administrator on 2015/7/22 0022.
 */
package geometry.ui
{
	import app.AppContainer;

	import geometry.manager.KeyBoardManager;
	import geometry.manager.LayerLineManager;
	import geometry.manager.LayerManager;

	import org.flexlite.domUI.components.Group;
	import org.flexlite.domUI.components.Rect;

	public class GeometryMainUI extends AppContainer
	{
		public function GeometryMainUI()
		{
			super();
		}

		override protected function createChildren():void
		{
			super.createChildren();

			var canvas:Group = new Group();
			addElement(canvas);
			canvas.percentHeight = canvas.percentWidth = 100;

			var bg:Rect = new Rect();
			bg.fillAlpha = 1;
			bg.fillColor = 0x333333;
			bg.percentHeight = bg.percentWidth = 100;
			canvas.addElement(bg);

			LayerManager.getInstance.initUI(this);
			LayerLineManager.getInstance.init(stage);
			KeyBoardManager.getInstance.init(stage);
		}
	}
}
